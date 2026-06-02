import { notFound } from "next/navigation";
import Link from "next/link";
import { createServiceClient } from "@/lib/supabase/server";
import { LeadActions } from "./lead-actions";
import { JourneyTimeline, type Marco } from "@/components/leads/journey-timeline";
import { formatDataHora } from "@/lib/format";
import { cn } from "@/lib/utils";

const STATUS_COR: Record<string, string> = {
  novo: "bg-surface-muted text-text-secondary",
  em_atendimento: "bg-teal-soft text-teal-soft-text",
  sem_resposta: "bg-status-warning-soft text-status-warning",
  agendou: "bg-status-info-soft text-status-info",
  compareceu: "bg-status-info-soft text-status-info",
  perdido: "bg-status-danger-soft text-status-danger",
  fechou: "bg-status-success-soft text-status-success",
};

type ConversaLista = {
  id: string;
  status: string;
  ultimo_score: number | null;
  ultima_mensagem_em: string | null;
  ultima_analise_em: string | null;
};

type CallLista = {
  id: string;
  titulo: string | null;
  realizada_em: string | null;
  match_status: string;
  analise:
    | { classificacao: string | null; score_geral: number | null }
    | { classificacao: string | null; score_geral: number | null }[]
    | null;
};

type LeadParaTimeline = {
  status: string;
  status_atualizado_em: string | null;
  status_origem: string | null;
  origem: string | null;
  observacoes: string | null;
  created_at: string;
  updated_at: string;
};

function rotularOrigem(origem: string | null): string {
  if (!origem) return "desconhecida";
  return origem.replace(/_/g, " ");
}

function construirMarcos({
  lead,
  conversas,
  calls,
}: {
  lead: LeadParaTimeline;
  conversas: ConversaLista[];
  calls: CallLista[];
}): Marco[] {
  const marcos: Marco[] = [];

  const criadoAt = new Date(lead.created_at);
  marcos.push({
    id: "criado",
    at: criadoAt,
    icone: "user-plus",
    timestamp: formatDataHora(criadoAt),
    headline: `Lead cadastrado · origem ${rotularOrigem(lead.origem)}`,
    detalhe: lead.observacoes ?? undefined,
  });

  for (const c of conversas) {
    const quando = c.ultima_mensagem_em ?? c.ultima_analise_em;
    if (!quando) continue;
    const at = new Date(quando);
    marcos.push({
      id: `conv-${c.id}`,
      at,
      icone: "message",
      timestamp: formatDataHora(at),
      headline: `Conversa WhatsApp · ${c.status}`,
      detalhe:
        c.ultimo_score != null ? (
          <>
            Score atendimento:{" "}
            <span className="font-medium text-text-primary">{c.ultimo_score}/100</span>
          </>
        ) : (
          "Sem análise ainda"
        ),
      body: (
        <Link
          href={`/whatsapp/${c.id}`}
          className="text-caption font-medium text-teal hover:text-teal-hover"
        >
          Ver conversa →
        </Link>
      ),
    });
  }

  for (const call of calls) {
    if (!call.realizada_em) continue;
    const at = new Date(call.realizada_em);
    const analise = Array.isArray(call.analise) ? call.analise[0] : call.analise;
    marcos.push({
      id: `call-${call.id}`,
      at,
      icone: "phone",
      timestamp: formatDataHora(at),
      headline: call.titulo ? `Call · ${call.titulo}` : "Call gravada",
      detalhe: analise ? (
        <>
          Classificação{" "}
          <span className="font-medium capitalize text-text-primary">{analise.classificacao}</span>{" "}
          · Score {analise.score_geral}/100
        </>
      ) : (
        `Match: ${call.match_status}`
      ),
      body: (
        <Link
          href={`/calls/${call.id}`}
          className="text-caption font-medium text-teal hover:text-teal-hover"
        >
          Ver análise →
        </Link>
      ),
    });
  }

  const statusFinalAt = lead.status_atualizado_em ?? lead.updated_at;
  if (lead.status === "fechou" || lead.status === "perdido") {
    const at = new Date(statusFinalAt);
    marcos.push({
      id: "final",
      at,
      icone: lead.status === "fechou" ? "check" : "x",
      variante: lead.status === "fechou" ? "sucesso" : "perda",
      timestamp: formatDataHora(at),
      headline: lead.status === "fechou" ? "Venda fechada" : "Lead perdido",
      detalhe:
        lead.status_origem === "manual" ? "Atualizado manualmente" : "Atualizado automaticamente",
    });
  } else if (lead.status === "agendou" || lead.status === "compareceu") {
    const at = new Date(statusFinalAt);
    marcos.push({
      id: `status-${lead.status}`,
      at,
      icone: lead.status === "agendou" ? "calendar" : "clipboard",
      timestamp: formatDataHora(at),
      headline: lead.status === "agendou" ? "Avaliação agendada" : "Compareceu à avaliação",
    });
  }

  return marcos.sort((a, b) => a.at.getTime() - b.at.getTime());
}

export default async function LeadDetalhe({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const supabase = await createServiceClient();

  const [{ data: lead }, { data: conversas }, { data: calls }] = await Promise.all([
    supabase.schema("comercial").from("leads").select("*").eq("id", id).single(),
    supabase
      .schema("comercial")
      .from("conversas")
      .select("id, status, ultimo_score, ultima_mensagem_em, ultima_analise_em")
      .eq("lead_id", id)
      .order("ultima_mensagem_em", { ascending: false }),
    supabase
      .schema("comercial")
      .from("calls")
      .select(
        "id, titulo, realizada_em, match_status, analise:analises_calls(classificacao, score_geral)",
      )
      .eq("lead_id", id)
      .order("realizada_em", { ascending: false, nullsFirst: false }),
  ]);

  if (!lead) notFound();

  return (
    <div className="space-y-4">
      {/* Header */}
      <div className="flex items-start justify-between">
        <div>
          <Link href="/leads" className="text-caption font-medium text-teal hover:text-teal-hover">
            ← Leads
          </Link>
          <h1 className="text-h1 mt-1 text-text-primary">{lead.nome}</h1>
          <p className="text-sm text-text-secondary">{lead.telefone}</p>
        </div>
        <span
          className={cn(
            "text-caption rounded-full px-3 py-1 font-semibold capitalize",
            STATUS_COR[lead.status] ?? "bg-surface-muted text-text-secondary",
          )}
        >
          {lead.status.replace("_", " ")}
        </span>
      </div>

      <div className="grid gap-4 lg:grid-cols-3">
        {/* Info + ações */}
        <div className="space-y-4">
          <div className="rounded-lg border border-border bg-surface p-4 shadow-sm">
            <h2 className="text-h3 mb-3 text-text-primary">Informações</h2>
            <dl className="space-y-2.5">
              {lead.email && (
                <div>
                  <dt className="text-label text-text-tertiary">Email</dt>
                  <dd className="text-body-strong text-text-primary">{lead.email}</dd>
                </div>
              )}
              <div>
                <dt className="text-label text-text-tertiary">Origem</dt>
                <dd className="flex items-center gap-1.5">
                  <span className="text-body-strong text-text-primary">{lead.origem ?? "—"}</span>
                  {lead.origem_status === "pendente" && (
                    <span className="rounded-full bg-status-warning-soft px-1.5 py-0.5 text-[10px] font-medium text-status-warning">
                      pendente
                    </span>
                  )}
                  {lead.origem_status === "manual" && (
                    <span className="rounded-full bg-surface-muted px-1.5 py-0.5 text-[10px] font-medium text-text-tertiary">
                      manual
                    </span>
                  )}
                </dd>
              </div>
              {lead.origem_confidence && (
                <div>
                  <dt className="text-label text-text-tertiary">Confiança origem</dt>
                  <dd className="text-body-strong text-text-primary">
                    {Math.round(Number(lead.origem_confidence) * 100)}%
                  </dd>
                </div>
              )}
              <div>
                <dt className="text-label text-text-tertiary">Cadastrado em</dt>
                <dd className="text-body-strong text-text-primary">
                  {new Intl.DateTimeFormat("pt-BR").format(new Date(lead.created_at))}
                </dd>
              </div>
            </dl>
            {lead.observacoes && (
              <div className="mt-3 border-t border-border pt-3">
                <p className="text-label text-text-tertiary">Observações</p>
                <p className="text-caption mt-1 text-text-secondary">{lead.observacoes}</p>
              </div>
            )}
          </div>

          <LeadActions leadId={id} statusAtual={lead.status} origemAtual={lead.origem} />
        </div>

        {/* Timeline */}
        <div className="lg:col-span-2">
          <div className="rounded-lg border border-border bg-surface p-6 shadow-sm">
            <h2 className="text-h3 mb-6 text-text-primary">Jornada do lead</h2>
            <JourneyTimeline
              marcos={construirMarcos({
                lead: {
                  status: lead.status,
                  status_atualizado_em: lead.status_atualizado_em ?? null,
                  status_origem: lead.status_origem ?? null,
                  origem: lead.origem ?? null,
                  observacoes: lead.observacoes ?? null,
                  created_at: lead.created_at,
                  updated_at: lead.updated_at,
                },
                conversas: conversas ?? [],
                calls: calls ?? [],
              })}
            />
          </div>
        </div>
      </div>
    </div>
  );
}
