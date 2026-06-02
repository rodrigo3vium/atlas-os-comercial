import { notFound } from "next/navigation";
import Link from "next/link";
import { createServiceClient } from "@/lib/supabase/server";
import { ReanalisarButton } from "./reanalisar-button";
import { CopyScriptButton } from "@/components/analysis/copy-script-button";
import { ScoreRing } from "@/components/analysis/score-ring";
import { BlocoBar } from "@/components/analysis/bloco-bar";
import { cn } from "@/lib/utils";
import {
  ORDEM_BLOCOS,
  NOMES_DIAGNOSTICO,
  PESOS_DIAGNOSTICO,
  tierFromScore,
  flagLabel,
  isStructuredResult,
  type WhatsappAnalysisResult,
} from "@/lib/analysis/commercial-rubric";

function formatarDataHora(iso: string) {
  return new Intl.DateTimeFormat("pt-BR", {
    day: "2-digit",
    month: "2-digit",
    hour: "2-digit",
    minute: "2-digit",
  }).format(new Date(iso));
}

function ScoreBadge({ score }: { score: number }) {
  const cls =
    score >= 80
      ? "bg-status-success-soft text-status-success"
      : score >= 50
        ? "bg-status-warning-soft text-status-warning"
        : "bg-status-danger-soft text-status-danger";
  return (
    <span
      className={`inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-semibold ${cls}`}
    >
      {score}/100
    </span>
  );
}

export default async function WhatsappDetalhe({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const supabase = await createServiceClient();

  const [{ data: conversa }, { data: mensagens }, { data: analises }] = await Promise.all([
    supabase
      .schema("comercial")
      .from("conversas")
      .select(
        "*, lead:leads(id, nome, telefone, status, origem), evolution_instance:evolution_instances(apelido)",
      )
      .eq("id", id)
      .single(),
    supabase
      .schema("comercial")
      .from("mensagens")
      .select("id, tipo, fonte, conteudo, remetente, enviada_em")
      .eq("conversa_id", id)
      .order("enviada_em", { ascending: true }),
    supabase
      .schema("comercial")
      .from("analises_whatsapp")
      .select("*")
      .eq("conversa_id", id)
      .order("created_at", { ascending: false }),
  ]);

  if (!conversa) notFound();

  const lead = Array.isArray(conversa.lead) ? conversa.lead[0] : conversa.lead;
  const ultimaAnalise = analises?.[0] ?? null;

  const resultado = isStructuredResult(ultimaAnalise?.fases)
    ? (ultimaAnalise!.fases as unknown as WhatsappAnalysisResult)
    : null;
  const tier = resultado ? tierFromScore(resultado.score_global) : null;
  const blocosPorId = new Map((resultado?.blocos ?? []).map((b) => [b.id, b]));

  return (
    <div className="space-y-4">
      {/* Header */}
      <div className="flex items-start justify-between gap-3">
        <div>
          <Link
            href="/whatsapp"
            className="text-caption font-medium text-teal hover:text-teal-hover"
          >
            ← Conversas
          </Link>
          <h1 className="text-h1 mt-1 text-text-primary">
            {lead?.nome ?? lead?.telefone ?? "Lead desconhecido"}
          </h1>
          <p className="text-sm text-text-secondary">{lead?.telefone}</p>
        </div>
        <div className="flex flex-wrap items-center justify-end gap-2">
          {resultado && tier ? (
            <span
              className={cn("text-caption rounded-full px-3 py-1 font-semibold", tier.badgeClass)}
            >
              {tier.label}
            </span>
          ) : (
            conversa.ultimo_score != null && <ScoreBadge score={conversa.ultimo_score} />
          )}
          <ReanalisarButton conversaId={id} />
        </div>
      </div>

      <div className="grid gap-4 lg:grid-cols-3">
        {/* Coluna principal: análise */}
        <div className="space-y-4 lg:col-span-2">
          {resultado && tier ? (
            <>
              {/* Hero: anel + leitura + flags */}
              <div className="surface-sheen rounded-lg border border-border bg-surface p-4 shadow-sm">
                <div className="flex flex-col gap-4 sm:flex-row sm:items-center">
                  <ScoreRing score={resultado.score_global} cssVar={tier.cssVar} />
                  <div className="flex-1 space-y-3">
                    <p className="text-body-strong leading-relaxed text-text-primary">
                      {resultado.leitura}
                    </p>
                    <div className="flex flex-wrap gap-1.5">
                      {resultado.flags_positivas?.map((f) => (
                        <span
                          key={f}
                          className="rounded-full bg-status-success-soft px-2 py-0.5 text-[11px] font-medium text-status-success"
                        >
                          {flagLabel(f)}
                        </span>
                      ))}
                      {resultado.flags_negativas?.map((f) => (
                        <span
                          key={f}
                          className="rounded-full bg-status-danger-soft px-2 py-0.5 text-[11px] font-medium text-status-danger"
                        >
                          {flagLabel(f)}
                        </span>
                      ))}
                    </div>
                  </div>
                </div>
              </div>

              {/* Performance por bloco */}
              <div className="rounded-lg border border-border bg-surface p-4 shadow-sm">
                <h2 className="text-h3 mb-3 text-text-primary">Performance por bloco</h2>
                <div className="space-y-2">
                  {ORDEM_BLOCOS.map((bid) => {
                    const bloco = blocosPorId.get(bid);
                    if (!bloco) return null;
                    return (
                      <BlocoBar
                        key={bid}
                        bloco={bloco}
                        nome={NOMES_DIAGNOSTICO[bid]}
                        peso={PESOS_DIAGNOSTICO[bid]}
                      />
                    );
                  })}
                </div>
              </div>

              {/* Sinais vermelhos */}
              {resultado.flags_negativas?.length > 0 && (
                <div className="rounded-lg border border-status-danger bg-status-danger-soft p-4">
                  <p className="text-label mb-2 text-status-danger">Sinais vermelhos</p>
                  <ul className="space-y-1">
                    {resultado.flags_negativas.map((f) => (
                      <li key={f} className="text-caption flex items-start gap-2 text-text-primary">
                        <span className="text-status-danger">▸</span>
                        {flagLabel(f)}
                      </li>
                    ))}
                  </ul>
                </div>
              )}

              {/* Ação recomendada */}
              {resultado.recomendacoes?.length > 0 && (
                <div className="space-y-3">
                  <h2 className="text-h3 text-text-primary">Ação recomendada</h2>
                  {resultado.recomendacoes.map((rec, i) => (
                    <div
                      key={i}
                      className="rounded-lg border border-border bg-surface p-4 shadow-sm"
                    >
                      <div className="mb-2 flex items-start justify-between gap-2">
                        <p className="text-label text-teal">{rec.gatilho}</p>
                        {rec.bloco_ref && (
                          <span className="font-mono text-[10px] uppercase tracking-[0.1em] text-text-muted">
                            Bloco {rec.bloco_ref}
                          </span>
                        )}
                      </div>
                      <p className="text-caption mb-3 text-text-secondary">{rec.racional}</p>
                      <div className="rounded-md border border-border bg-surface-muted p-3">
                        <div className="mb-1.5 flex items-center justify-between">
                          <span className="font-mono text-[10px] uppercase tracking-[0.1em] text-text-muted">
                            Script
                          </span>
                          <CopyScriptButton texto={rec.script} />
                        </div>
                        <p className="text-caption leading-relaxed text-text-primary">
                          {rec.script}
                        </p>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </>
          ) : ultimaAnalise ? (
            /* Fallback: análise em formato antigo (prosa) */
            <>
              <div className="rounded-lg border border-border bg-surface p-4 shadow-sm">
                <div className="mb-3 flex items-center justify-between">
                  <h2 className="text-h3 text-text-primary">Análise IA</h2>
                  <ScoreBadge score={ultimaAnalise.score} />
                </div>
                {ultimaAnalise.tags_positivas?.length > 0 && (
                  <div className="mb-2 flex flex-wrap gap-1">
                    {ultimaAnalise.tags_positivas.map((t: string) => (
                      <span
                        key={t}
                        className="rounded bg-status-success-soft px-1.5 py-0.5 text-[11px] font-medium text-status-success"
                      >
                        {flagLabel(t)}
                      </span>
                    ))}
                  </div>
                )}
                {ultimaAnalise.tags_negativas?.length > 0 && (
                  <div className="mb-3 flex flex-wrap gap-1">
                    {ultimaAnalise.tags_negativas.map((t: string) => (
                      <span
                        key={t}
                        className="rounded bg-status-danger-soft px-1.5 py-0.5 text-[11px] font-medium text-status-danger"
                      >
                        {flagLabel(t)}
                      </span>
                    ))}
                  </div>
                )}
                {ultimaAnalise.resumo && (
                  <p className="text-caption mb-2 text-text-secondary">{ultimaAnalise.resumo}</p>
                )}
                {ultimaAnalise.diagnostico && (
                  <div className="rounded-md bg-surface-muted p-2.5">
                    <p className="text-label mb-0.5 text-text-tertiary">Diagnóstico</p>
                    <p className="text-caption whitespace-pre-wrap text-text-primary">
                      {ultimaAnalise.diagnostico}
                    </p>
                  </div>
                )}
              </div>
              {ultimaAnalise.acao_recomendada && (
                <div className="rounded-lg border border-border bg-teal-soft p-4 shadow-sm">
                  <p className="text-label mb-1.5 text-teal">Ação recomendada</p>
                  <p className="text-caption whitespace-pre-wrap text-teal-soft-text">
                    {ultimaAnalise.acao_recomendada}
                  </p>
                </div>
              )}
            </>
          ) : (
            <div className="rounded-lg border border-border bg-surface p-8 text-center shadow-sm">
              <div className="mx-auto mb-3 flex h-10 w-10 items-center justify-center rounded-full bg-surface-muted">
                <span className="text-lg text-text-muted">✦</span>
              </div>
              <p className="text-body-strong text-text-primary">Nenhuma análise disponível</p>
              <p className="text-caption mt-1 text-text-muted">
                A análise roda automaticamente após 1h de silêncio.
              </p>
            </div>
          )}
        </div>

        {/* Sidebar: chat + histórico + lead */}
        <div className="space-y-4">
          {/* Chat */}
          <div className="rounded-lg border border-border bg-surface shadow-sm">
            <div className="border-b border-border px-4 py-3">
              <p className="text-body-strong text-text-primary">
                Conversa ({mensagens?.length ?? 0} mensagens)
              </p>
            </div>
            <div className="max-h-[55vh] space-y-2 overflow-y-auto p-4">
              {(mensagens ?? []).length === 0 ? (
                <div className="py-8 text-center">
                  <p className="text-body-strong text-text-primary">Nenhuma mensagem</p>
                  <p className="text-caption mt-1 text-text-muted">
                    Ainda não há mensagens nesta conversa.
                  </p>
                </div>
              ) : (
                (mensagens ?? []).map((m) => (
                  <div
                    key={m.id}
                    className={`flex ${m.remetente === "lead" ? "justify-start" : "justify-end"}`}
                  >
                    <div
                      className={`max-w-[85%] rounded-2xl px-3 py-2 text-sm ${
                        m.remetente === "lead"
                          ? "border border-border bg-surface-muted text-text-primary"
                          : "bg-teal-soft text-teal-soft-text"
                      }`}
                    >
                      <p className="whitespace-pre-wrap">{m.conteudo ?? `[${m.tipo}]`}</p>
                      <p className="mt-1 text-right text-[10px] text-text-tertiary">
                        {formatarDataHora(m.enviada_em)}
                      </p>
                    </div>
                  </div>
                ))
              )}
            </div>
          </div>

          {/* Histórico de análises */}
          {(analises ?? []).length > 1 && (
            <div className="rounded-lg border border-border bg-surface p-4 shadow-sm">
              <h2 className="text-h3 mb-2 text-text-primary">Histórico</h2>
              <ul className="space-y-1.5">
                {(analises ?? []).slice(1).map((a) => (
                  <li key={a.id} className="flex items-center justify-between">
                    <span className="text-caption text-text-muted">
                      {formatarDataHora(a.created_at)}
                    </span>
                    <ScoreBadge score={a.score} />
                  </li>
                ))}
              </ul>
            </div>
          )}

          {/* Lead */}
          {lead && (
            <div className="rounded-lg border border-border bg-surface p-4 shadow-sm">
              <h2 className="text-h3 mb-3 text-text-primary">Lead</h2>
              <dl className="space-y-2">
                <div className="flex items-center justify-between">
                  <dt className="text-label text-text-tertiary">Status</dt>
                  <dd>
                    <span className="rounded-full bg-teal-soft px-2 py-0.5 text-[11px] font-medium capitalize text-teal-soft-text">
                      {lead.status.replace("_", " ")}
                    </span>
                  </dd>
                </div>
                {lead.origem && (
                  <div className="flex items-center justify-between">
                    <dt className="text-label text-text-tertiary">Origem</dt>
                    <dd className="text-body-strong text-text-primary">{lead.origem}</dd>
                  </div>
                )}
              </dl>
              <Link
                href={`/leads/${lead.id}`}
                className="text-caption mt-3 block font-medium text-teal hover:text-teal-hover"
              >
                Ver perfil completo →
              </Link>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
