import Anthropic from "@anthropic-ai/sdk";
import type { SupabaseClient } from "@supabase/supabase-js";
import { PROMPT_VERSION, SYSTEM_PROMPT_ANALISE } from "@/lib/prompts/analyze-call";
import {
  RUBRIC_VERSION,
  computeScoreGlobal,
  tierFromScore,
  type CallAnalysisModel,
  type CallAnalysisResult,
} from "@/lib/analysis/call-rubric";
import type { Json } from "@/lib/supabase/types";
import { matchCallLead } from "@/lib/modules/matcher-call-lead";
import { dispararAlertaSeNecessario } from "@/lib/modules/alerta-imediato";
import { log } from "@/lib/log";

const MODELO = "claude-sonnet-4-6";
const BATCH_SIZE = 10;

export type ResultadoAnaliseCall = {
  analisadas: number;
  erros: number;
};

// Serializa as recomendações estruturadas em texto curto para preencher a coluna
// legada `acao_recomendada` (consumida por dashboard/rondas/listas).
function recomendacoesParaTexto(recomendacoes: CallAnalysisModel["recomendacoes"]): string | null {
  if (!recomendacoes?.length) return null;
  return recomendacoes.map((r, i) => `${i + 1}) [${r.gatilho}] ${r.script}`).join("\n");
}

let _anthropic: Anthropic | null = null;

function getAnthropicClient() {
  if (!_anthropic) _anthropic = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });
  return _anthropic;
}

export async function analisarCallsPendentes(
  supabase: SupabaseClient,
): Promise<ResultadoAnaliseCall> {
  const resultado: ResultadoAnaliseCall = { analisadas: 0, erros: 0 };

  const { data: calls } = await supabase
    .schema("comercial")
    .from("calls")
    .select("id, transcricao, titulo")
    .not("transcricao", "is", null)
    .is("analisada_em", null)
    .limit(BATCH_SIZE)
    .throwOnError();

  for (const call of calls ?? []) {
    try {
      // Análise e match rodam em paralelo
      await Promise.all([
        analisarCall(call.id, call.transcricao!, call.titulo, supabase),
        matchCallLead(call.id, supabase),
      ]);
      resultado.analisadas++;
    } catch (err) {
      log.error("analisador_calls.erro", {
        callId: call.id,
        erro: err instanceof Error ? err.message : String(err),
      });
      resultado.erros++;
    }
  }

  return resultado;
}

async function analisarCall(
  callId: string,
  transcricao: string,
  titulo: string | null,
  supabase: SupabaseClient,
) {
  const client = getAnthropicClient();

  const contexto = titulo
    ? `Título da call: ${titulo}\n\nTranscrição:\n${transcricao}`
    : transcricao;

  const response = await client.messages.create({
    model: MODELO,
    max_tokens: 4096,
    system: [
      {
        type: "text",
        text: SYSTEM_PROMPT_ANALISE,
        cache_control: { type: "ephemeral" },
      },
    ],
    messages: [
      {
        role: "user",
        content: `Avalie esta call de fechamento:\n\n${contexto}`,
      },
    ],
  });

  const textBlock = response.content.find((c) => c.type === "text");
  if (!textBlock || textBlock.type !== "text") {
    throw new Error("Resposta Anthropic sem conteúdo de texto");
  }

  const rawText = textBlock.text
    .replace(/^```(?:json)?\s*\n?/, "")
    .replace(/\n?```\s*$/, "")
    .trim();
  const analise = JSON.parse(rawText) as CallAnalysisModel;

  // Score global é calculado AQUI (ponderado), nunca pelo modelo.
  const scoreGlobal = computeScoreGlobal(analise.blocos ?? []);
  const { classificacao } = tierFromScore(scoreGlobal);

  if (analise.etapa && analise.etapa !== "fechamento") {
    log.warn("analisador_calls.etapa_inesperada", {
      callId,
      etapa: analise.etapa,
      nota: "usando régua de fechamento como fallback",
    });
  }

  const resultado: CallAnalysisResult = {
    ...analise,
    etapa: analise.etapa ?? "fechamento",
    rubric_version: RUBRIC_VERSION,
    score_global: scoreGlobal,
  };

  await supabase
    .schema("comercial")
    .from("analises_calls")
    .insert({
      call_id: callId,
      classificacao,
      score_geral: scoreGlobal,
      fases: resultado as unknown as Json,
      diagnostico: analise.leitura ?? null,
      acao_recomendada: recomendacoesParaTexto(analise.recomendacoes),
      modelo: MODELO,
      prompt_versao: PROMPT_VERSION,
      tokens_entrada: response.usage?.input_tokens ?? null,
      tokens_saida: response.usage?.output_tokens ?? null,
    })
    .throwOnError();

  await supabase
    .schema("comercial")
    .from("calls")
    .update({ analisada_em: new Date().toISOString() })
    .eq("id", callId)
    .throwOnError();

  // Alerta imediato se score baixo
  const { data: call } = await supabase
    .schema("comercial")
    .from("calls")
    .select("lead_id, leads(nome, telefone)")
    .eq("id", callId)
    .single();

  if (call?.lead_id) {
    const leadsRaw = call.leads;
    const lead = (Array.isArray(leadsRaw) ? leadsRaw[0] : leadsRaw) as {
      nome: string;
      telefone: string;
    } | null;
    if (lead) {
      await dispararAlertaSeNecessario(
        "call",
        call.lead_id as string,
        lead.nome,
        lead.telefone,
        scoreGlobal,
        supabase,
      );
    }
  }
}
