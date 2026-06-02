import { notFound } from "next/navigation";
import Link from "next/link";
import { createServiceClient } from "@/lib/supabase/server";
import { Progress } from "@/components/ui/progress";
import { MatchActions } from "./match-actions";
import { cn } from "@/lib/utils";

const FASES_LABELS: Record<string, string> = {
  preparacao: "Preparação",
  abertura: "Abertura",
  diagnostico: "Diagnóstico",
  apresentacao_clinica: "Apres. Clínica",
  apresentacao_investimento: "Apres. Investimento",
  fechamento: "Fechamento",
  objecoes: "Objeções",
  sabotadores: "Sabotadores",
};

function classificacaoCor(cls: string | null) {
  const mapa: Record<string, string> = {
    excelente: "bg-status-success-soft text-status-success",
    bom: "bg-teal-soft text-teal-soft-text",
    regular: "bg-status-warning-soft text-status-warning",
    insuficiente: "bg-status-danger-soft text-status-danger",
  };
  return cls
    ? (mapa[cls] ?? "bg-surface-muted text-text-secondary")
    : "bg-surface-muted text-text-secondary";
}

function faseScoreCor(score: number) {
  if (score >= 80) return "text-status-success";
  if (score >= 50) return "text-status-warning";
  return "text-status-danger";
}

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
  const fases = (analise?.fases ?? {}) as Record<string, { score: number; observacao: string }>;

  return (
    <div className="space-y-4">
      {/* Header */}
      <div className="flex items-start justify-between">
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
        {analise && (
          <span
            className={`text-caption rounded-full px-3 py-1 font-semibold capitalize ${classificacaoCor(analise.classificacao)}`}
          >
            {analise.classificacao}
          </span>
        )}
      </div>

      <div className="grid gap-4 lg:grid-cols-3">
        {/* Fases + diagnóstico */}
        <div className="space-y-4 lg:col-span-2">
          {analise ? (
            <>
              {/* Performance por fase */}
              <div className="rounded-lg border border-border bg-surface p-4 shadow-sm">
                <div className="mb-4 flex items-center justify-between">
                  <h2 className="text-h3 text-text-primary">Performance por fase</h2>
                  <div className="flex items-baseline gap-0.5">
                    <span className="text-kpi tabular-nums text-text-primary">
                      {analise.score_geral}
                    </span>
                    <span className="text-caption text-text-muted">/100</span>
                  </div>
                </div>
                <div className="space-y-3">
                  {Object.entries(FASES_LABELS).map(([key, label]) => {
                    const fase = fases[key];
                    if (!fase) return null;
                    return (
                      <div key={key}>
                        <div className="mb-1 flex items-center justify-between">
                          <span className="text-caption text-text-tertiary">{label}</span>
                          <span
                            className={cn("text-caption font-medium", faseScoreCor(fase.score))}
                          >
                            {fase.score}
                          </span>
                        </div>
                        <Progress value={fase.score} className="h-1.5" />
                        {fase.observacao && (
                          <p className="mt-0.5 text-[11px] text-text-muted">{fase.observacao}</p>
                        )}
                      </div>
                    );
                  })}
                </div>
              </div>

              {/* Diagnóstico + ação */}
              <div className="grid gap-3 sm:grid-cols-2">
                {analise.diagnostico && (
                  <div className="rounded-lg border border-border bg-surface p-4 shadow-sm">
                    <p className="text-label mb-1.5 text-text-tertiary">Diagnóstico</p>
                    <p className="text-sm text-text-primary">{analise.diagnostico}</p>
                  </div>
                )}
                {analise.acao_recomendada && (
                  <div className="rounded-lg border border-border bg-teal-soft p-4 shadow-sm">
                    <p className="text-label mb-1.5 text-teal">Ação recomendada</p>
                    <p className="text-sm text-teal-soft-text">{analise.acao_recomendada}</p>
                  </div>
                )}
              </div>
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
