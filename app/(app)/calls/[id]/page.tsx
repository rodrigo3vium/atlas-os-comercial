import { notFound } from "next/navigation";
import Link from "next/link";
import { createServiceClient } from "@/lib/supabase/server";
import { MatchActions } from "./match-actions";
import { CopyScriptButton } from "@/components/analysis/copy-script-button";
import { ScoreRing } from "@/components/analysis/score-ring";
import { BlocoBar } from "@/components/analysis/bloco-bar";
import { cn } from "@/lib/utils";
import {
  ORDEM_BLOCOS,
  NOMES_FECHAMENTO,
  PESOS_FECHAMENTO,
  ETAPA_LABELS,
  tierFromScore,
  notaCor,
  flagLabel,
  isStructuredResult,
  type CallAnalysisResult,
} from "@/lib/analysis/commercial-rubric";

export default async function CallDetalhe({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const supabase = await createServiceClient();

  const [{ data: call }, { data: analises }] = await Promise.all([
    supabase
      .schema("comercial")
      .from("calls")
      .select("*, lead:leads(id, nome, telefone, status), match_sugestoes")
      .eq("id", id)
      .single(),
    supabase
      .schema("comercial")
      .from("analises_calls")
      .select("*")
      .eq("call_id", id)
      .order("created_at", { ascending: false }),
  ]);

  if (!call) notFound();

  const analise = analises?.[0] ?? null;
  const lead = Array.isArray(call.lead) ? call.lead[0] : call.lead;
  const resultado = isStructuredResult(analise?.fases)
    ? (analise!.fases as unknown as CallAnalysisResult)
    : null;

  const tier = resultado ? tierFromScore(resultado.score_global) : null;
  const blocosPorId = new Map((resultado?.blocos ?? []).map((b) => [b.id, b]));

  return (
    <div className="space-y-4">
      {/* Header */}
      <div className="flex items-start justify-between gap-3">
        <div>
          <Link href="/calls" className="text-caption font-medium text-teal hover:text-teal-hover">
            ← Calls
          </Link>
          <h1 className="text-h1 mt-1 text-text-primary">{call.titulo ?? "Call sem título"}</h1>
          <p className="text-sm text-text-secondary">
            {call.duracao_segundos
              ? `${Math.floor(call.duracao_segundos / 60)} min`
              : "Duração desconhecida"}
          </p>
        </div>
        {resultado && tier && (
          <div className="flex flex-wrap items-center justify-end gap-2">
            <span className="text-label rounded-full bg-surface-muted px-3 py-1 font-mono uppercase tracking-[0.12em] text-text-secondary">
              {ETAPA_LABELS[resultado.etapa] ?? resultado.etapa}
            </span>
            <span
              className={cn("text-caption rounded-full px-3 py-1 font-semibold", tier.badgeClass)}
            >
              {tier.label}
            </span>
          </div>
        )}
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
                      {resultado.sinais_vermelhos?.map((f) => (
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
                        nome={NOMES_FECHAMENTO[bid]}
                        peso={PESOS_FECHAMENTO[bid]}
                      />
                    );
                  })}
                  {typeof resultado.rapport_0_10 === "number" && (
                    <div className="flex items-center justify-between rounded-md border border-dashed border-border bg-surface-muted px-3 py-2.5">
                      <div className="flex items-center gap-2">
                        <span className="text-caption text-text-secondary">Crenças do closer</span>
                        <span className="font-mono text-[10px] uppercase tracking-[0.1em] text-text-muted">
                          Bônus · fora do score
                        </span>
                      </div>
                      <span
                        className={cn(
                          "text-body-strong tabular-nums",
                          notaCor(resultado.rapport_0_10).text,
                        )}
                      >
                        {resultado.rapport_0_10}
                        <span className="text-text-muted">/10</span>
                      </span>
                    </div>
                  )}
                </div>
              </div>

              {/* Sinais vermelhos */}
              {resultado.sinais_vermelhos?.length > 0 && (
                <div className="rounded-lg border border-status-danger bg-status-danger-soft p-4">
                  <p className="text-label mb-2 text-status-danger">Sinais vermelhos</p>
                  <ul className="space-y-1">
                    {resultado.sinais_vermelhos.map((f) => (
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
          ) : analise ? (
            /* Fallback: análise em formato antigo (prosa) */
            <>
              <div className="rounded-lg border border-border bg-surface p-4 shadow-sm">
                <div className="mb-3 flex items-center justify-between">
                  <h2 className="text-h3 text-text-primary">Análise</h2>
                  <div className="flex items-baseline gap-0.5">
                    <span className="text-kpi tabular-nums text-text-primary">
                      {analise.score_geral}
                    </span>
                    <span className="text-caption text-text-muted">/100</span>
                  </div>
                </div>
                {analise.diagnostico && (
                  <p className="whitespace-pre-wrap text-sm text-text-primary">
                    {analise.diagnostico}
                  </p>
                )}
              </div>
              {analise.acao_recomendada && (
                <div className="rounded-lg border border-border bg-teal-soft p-4 shadow-sm">
                  <p className="text-label mb-1.5 text-teal">Ação recomendada</p>
                  <p className="whitespace-pre-wrap text-sm text-teal-soft-text">
                    {analise.acao_recomendada}
                  </p>
                </div>
              )}
            </>
          ) : (
            <div className="rounded-lg border border-border bg-surface p-8 text-center shadow-sm">
              <div className="mx-auto mb-3 flex h-10 w-10 items-center justify-center rounded-full bg-surface-muted">
                <span className="text-lg text-text-muted">○</span>
              </div>
              <p className="text-body-strong text-text-primary">Análise pendente</p>
              <p className="text-caption mt-1 text-text-muted">
                A análise será gerada automaticamente.
              </p>
            </div>
          )}

          {/* Transcrição */}
          {call.transcricao && (
            <details className="rounded-lg border border-border bg-surface shadow-sm">
              <summary className="text-body-strong cursor-pointer px-4 py-3 text-text-primary hover:bg-surface-muted">
                Transcrição completa
              </summary>
              <div className="border-t border-border px-4 py-3">
                <p className="text-caption whitespace-pre-wrap leading-relaxed text-text-secondary">
                  {call.transcricao}
                </p>
              </div>
            </details>
          )}
        </div>

        {/* Sidebar: match + lead */}
        <div className="space-y-4">
          {/* Match */}
          <div className="rounded-lg border border-border bg-surface p-4 shadow-sm">
            <h2 className="text-h3 mb-3 text-text-primary">Match</h2>
            <div className="mb-3">
              <span className="rounded-full bg-surface-muted px-2 py-0.5 text-[11px] font-medium capitalize text-text-secondary">
                {call.match_status}
              </span>
            </div>

            {lead ? (
              <div className="mb-3">
                <p className="text-body-strong text-text-primary">{lead.nome}</p>
                <p className="text-caption text-text-muted">{lead.telefone}</p>
                <Link
                  href={`/leads/${lead.id}`}
                  className="text-caption mt-1 block font-medium text-teal hover:text-teal-hover"
                >
                  Ver lead →
                </Link>
              </div>
            ) : null}

            <MatchActions
              callId={id}
              matchStatus={call.match_status}
              leadAtual={lead ? { id: lead.id, nome: lead.nome, telefone: lead.telefone } : null}
              sugestoes={
                Array.isArray(call.match_sugestoes)
                  ? (call.match_sugestoes as Array<{
                      lead_id: string;
                      nome: string;
                      telefone: string;
                      confidence: number;
                    }>)
                  : []
              }
            />
          </div>

          {/* Detalhes da call */}
          <div className="rounded-lg border border-border bg-surface p-4 shadow-sm">
            <h2 className="text-h3 mb-3 text-text-primary">Detalhes</h2>
            <dl className="space-y-2">
              <div className="flex justify-between">
                <dt className="text-label text-text-tertiary">Origem transcrição</dt>
                <dd className="text-body-strong text-text-primary">
                  {call.transcricao_origem ?? "—"}
                </dd>
              </div>
              {call.realizada_em && (
                <div className="flex justify-between">
                  <dt className="text-label text-text-tertiary">Realizada em</dt>
                  <dd className="text-body-strong text-text-primary">
                    {new Intl.DateTimeFormat("pt-BR").format(new Date(call.realizada_em))}
                  </dd>
                </div>
              )}
              {call.telefone_extraido && (
                <div className="flex justify-between">
                  <dt className="text-label text-text-tertiary">Telefone extraído</dt>
                  <dd className="text-body-strong text-text-primary">{call.telefone_extraido}</dd>
                </div>
              )}
            </dl>
          </div>
        </div>
      </div>
    </div>
  );
}
