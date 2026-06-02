import OpenAI from "openai";
import type { SupabaseClient } from "@supabase/supabase-js";
import { PROMPT_VERSION, SYSTEM_PROMPT } from "@/lib/prompts/analyze-whatsapp";
import { recomputarStatusLead, type LeadStatus } from "@/lib/modules/lead-status-machine";
import { dispararAlertaSeNecessario } from "@/lib/modules/alerta-imediato";
import { log } from "@/lib/log";

const MODELO = "gpt-4o";
const BATCH_SIZE = 10;
const JANELA_MENSAGENS = 50;

export type ResultadoAnalise = {
  analisadas: number;
  erros: number;
};

type AnaliseIA = {
  score: number;
  tags_positivas: string[];
  tags_negativas: string[];
  resumo: string | null;
  diagnostico: string | null;
  acao_recomendada: string | null;
  lead_status: string;
  origem_detectada: string | null;
  origem_confidence: number | null;
};

let _openai: OpenAI | null = null;

function getOpenAIClient() {
  if (!_openai) _openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });
  return _openai;
}

export async function analisarConversasPendentes(
  supabase: SupabaseClient,
): Promise<ResultadoAnalise> {
  const resultado: ResultadoAnalise = { analisadas: 0, erros: 0 };

  const umHoraAtras = new Date(Date.now() - 3_600_000).toISOString();

  const { data: conversas } = await supabase
    .schema("comercial")
    .from("conversas")
    .select("id, lead_id, ultima_mensagem_em, ultima_analise_em")
    .eq("status", "ativa")
    .lt("ultima_mensagem_em", umHoraAtras)
    .not("ultima_mensagem_em", "is", null)
    .limit(BATCH_SIZE)
    .throwOnError();

  const pendentes = (conversas ?? []).filter(
    (c) => !c.ultima_analise_em || c.ultima_analise_em < c.ultima_mensagem_em,
  );

  for (const conversa of pendentes) {
    try {
      await analisarConversa(conversa.id, conversa.lead_id as string | null, supabase);
      resultado.analisadas++;
    } catch (err) {
      log.error("analisador_whatsapp.erro", {
        conversaId: conversa.id,
        erro: err instanceof Error ? err.message : String(err),
      });
      resultado.erros++;
    }
  }

  return resultado;
}

async function analisarConversa(
  conversaId: string,
  leadId: string | null,
  supabase: SupabaseClient,
) {
  const { data: mensagens } = await supabase
    .schema("comercial")
    .from("mensagens")
    .select("tipo, fonte, conteudo, remetente, enviada_em")
    .eq("conversa_id", conversaId)
    .order("enviada_em", { ascending: true })
    .limit(JANELA_MENSAGENS)
    .throwOnError();

  if (!mensagens?.length) return;

  const conversaTexto = mensagens
    .map((m) => `[${m.remetente === "lead" ? "Lead" : "Clínica"}] ${m.conteudo ?? "[mídia]"}`)
    .join("\n");

  const client = getOpenAIClient();

  const response = await client.chat.completions.create({
    model: MODELO,
    max_tokens: 4096,
    response_format: { type: "json_object" },
    messages: [
      { role: "system", content: SYSTEM_PROMPT },
      { role: "user", content: `Analise esta conversa WhatsApp:\n\n${conversaTexto}` },
    ],
  });

  const rawText = response.choices[0]?.message?.content ?? "";
  const analise = JSON.parse(rawText) as AnaliseIA;

  await supabase
    .schema("comercial")
    .from("analises_whatsapp")
    .insert({
      conversa_id: conversaId,
      score: analise.score,
      tags_positivas: analise.tags_positivas ?? [],
      tags_negativas: analise.tags_negativas ?? [],
      resumo: analise.resumo ?? null,
      diagnostico: analise.diagnostico ?? null,
      acao_recomendada: analise.acao_recomendada ?? null,
      origem_detectada: analise.origem_detectada ?? null,
      origem_confidence: analise.origem_confidence ?? null,
      total_mensagens_analisadas: mensagens.length,
      modelo: MODELO,
      prompt_versao: PROMPT_VERSION,
      tokens_entrada: response.usage?.prompt_tokens ?? null,
      tokens_saida: response.usage?.completion_tokens ?? null,
    })
    .throwOnError();

  const agora = new Date().toISOString();

  await supabase
    .schema("comercial")
    .from("conversas")
    .update({ ultimo_score: analise.score, ultima_analise_em: agora })
    .eq("id", conversaId)
    .throwOnError();

  if (
    leadId &&
    analise.origem_detectada &&
    analise.origem_confidence != null &&
    analise.origem_confidence >= 0.8
  ) {
    const { data: lead } = await supabase
      .schema("comercial")
      .from("leads")
      .select("origem_status")
      .eq("id", leadId)
      .single()
      .throwOnError();

    if (lead && lead.origem_status !== "manual") {
      await supabase
        .schema("comercial")
        .from("leads")
        .update({
          origem: analise.origem_detectada,
          origem_confidence: analise.origem_confidence,
          origem_status: "detectado",
        })
        .eq("id", leadId)
        .throwOnError();
    }
  }

  if (leadId && analise.lead_status) {
    await recomputarStatusLead(leadId, analise.lead_status as LeadStatus, supabase);
  }

  if (leadId) {
    const { data: lead } = await supabase
      .schema("comercial")
      .from("leads")
      .select("nome, telefone")
      .eq("id", leadId)
      .single();

    if (lead) {
      await dispararAlertaSeNecessario(
        "whatsapp",
        leadId,
        lead.nome as string,
        lead.telefone as string,
        analise.score,
        supabase,
      );
    }
  }
}
