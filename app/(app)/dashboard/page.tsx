import { Suspense } from "react";
import Link from "next/link";
import { MessageSquare, Phone } from "lucide-react";
import { createServiceClient } from "@/lib/supabase/server";
import { KpiCard } from "@/components/dashboard/kpi-card";
import { ScoreChart } from "@/components/dashboard/score-chart";
import { PeriodoSelector } from "@/components/dashboard/periodo-selector";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent } from "@/components/ui/card";
import { cn } from "@/lib/utils";

function calcularPeriodo(dias: number) {
  const fim = new Date();
  const inicio = new Date(fim.getTime() - dias * 86_400_000);
  return { inicio: inicio.toISOString(), fim: fim.toISOString() };
}

function scoreBadgeVariant(score: number | null): "default" | "secondary" | "destructive" {
  if (score == null) return "secondary";
  if (score >= 70) return "default";
  if (score >= 40) return "secondary";
  return "destructive";
}

type DashboardData = {
  kpis: {
    leads_ativos: number;
    score_medio_whatsapp: number | null;
    score_medio_calls: number | null;
    taxa_fechamento: number | null;
    delta_score_whatsapp: number | null;
    delta_score_calls: number | null;
  };
  serie_temporal: Array<{
    semana: string;
    score_whatsapp: number | null;
    score_calls: number | null;
  }>;
  conversas_recentes: Array<{
    id: string;
    lead_nome: string | null;
    lead_telefone: string;
    ultimo_score: number | null;
    ultima_mensagem_em: string;
    ultimo_resumo: string | null;
    tags_negativas: string[];
  }>;
  calls_recentes: Array<{
    id: string;
    titulo: string | null;
    lead_nome: string | null;
    realizada_em: string | null;
    match_status: string;
    classificacao: string | null;
    score_geral: number | null;
  }>;
};

async function DashboardConteudo({ dias }: { dias: number }) {
  const supabase = await createServiceClient();
  const { inicio, fim } = calcularPeriodo(dias);

  const { data } = await supabase
    .schema("comercial")
    .rpc("get_dashboard", { p_inicio: inicio, p_fim: fim });

  const d = (data as DashboardData | null) ?? {
    kpis: {
      leads_ativos: 0,
      score_medio_whatsapp: null,
      score_medio_calls: null,
      taxa_fechamento: null,
      delta_score_whatsapp: null,
      delta_score_calls: null,
    },
    serie_temporal: [],
    conversas_recentes: [],
    calls_recentes: [],
  };

  return (
    <div className="space-y-6">
      {/* KPIs */}
      <div className="grid grid-cols-2 gap-4 lg:grid-cols-4">
        <KpiCard titulo="Leads ativos" valor={d.kpis.leads_ativos} />
        <KpiCard
          titulo="Score médio WhatsApp"
          valor={d.kpis.score_medio_whatsapp}
          delta={d.kpis.delta_score_whatsapp}
          sufixo="/100"
        />
        <KpiCard
          titulo="Score médio Calls"
          valor={d.kpis.score_medio_calls}
          delta={d.kpis.delta_score_calls}
          sufixo="/100"
        />
        <KpiCard titulo="Taxa de fechamento" valor={d.kpis.taxa_fechamento} sufixo="%" />
      </div>

      {/* Gráfico */}
      {d.serie_temporal.length > 0 && (
        <Card>
          <div className="flex flex-col gap-1 p-6 pb-4">
            <h2 className="text-h3 text-text-primary">Evolução de scores</h2>
            <p className="text-caption text-text-tertiary">Últimas 12 semanas</p>
          </div>
          <CardContent>
            <ScoreChart dados={d.serie_temporal} />
          </CardContent>
        </Card>
      )}

      <div className="grid gap-6 lg:grid-cols-2">
        {/* Conversas recentes */}
        <Card>
          <div className="flex items-start justify-between p-6 pb-4">
            <div>
              <h2 className="text-h3 text-text-primary">Conversas recentes</h2>
              <p className="text-caption mt-1 text-text-tertiary">
                Últimas conversas WhatsApp analisadas
              </p>
            </div>
            <Link
              href="/whatsapp"
              className="text-caption font-medium text-teal transition-colors hover:text-teal-hover"
            >
              Ver todas →
            </Link>
          </div>
          <CardContent>
            {d.conversas_recentes.length === 0 ? (
              <div className="flex flex-col items-center justify-center px-6 py-10 text-center">
                <div className="mb-3 flex h-12 w-12 items-center justify-center rounded-full bg-surface-muted">
                  <MessageSquare className="h-6 w-6 text-text-muted" />
                </div>
                <p className="text-body-strong text-text-primary">Nenhuma conversa no período</p>
                <p className="text-caption mt-1 max-w-xs text-text-muted">
                  As conversas dos últimos {dias} dias aparecerão aqui assim que houver atividade.
                </p>
              </div>
            ) : (
              <ul className="space-y-1">
                {d.conversas_recentes.map((c) => (
                  <li key={c.id}>
                    <Link
                      href={`/whatsapp/${c.id}`}
                      className="flex items-center justify-between rounded-md px-2 py-2 transition-colors hover:bg-surface-muted"
                    >
                      <div className="min-w-0">
                        <p className="text-body-strong truncate text-text-primary">
                          {c.lead_nome ?? c.lead_telefone}
                        </p>
                        {c.ultimo_resumo && (
                          <p className="text-caption truncate text-text-muted">{c.ultimo_resumo}</p>
                        )}
                      </div>
                      {c.ultimo_score != null && (
                        <Badge
                          variant={scoreBadgeVariant(c.ultimo_score)}
                          className="ml-2 shrink-0"
                        >
                          {c.ultimo_score}
                        </Badge>
                      )}
                    </Link>
                  </li>
                ))}
              </ul>
            )}
          </CardContent>
        </Card>

        {/* Calls recentes */}
        <Card>
          <div className="flex items-start justify-between p-6 pb-4">
            <div>
              <h2 className="text-h3 text-text-primary">Calls recentes</h2>
              <p className="text-caption mt-1 text-text-tertiary">Transcrições Plaud analisadas</p>
            </div>
            <Link
              href="/calls"
              className="text-caption font-medium text-teal transition-colors hover:text-teal-hover"
            >
              Ver todas →
            </Link>
          </div>
          <CardContent>
            {d.calls_recentes.length === 0 ? (
              <div className="flex flex-col items-center justify-center px-6 py-10 text-center">
                <div className="mb-3 flex h-12 w-12 items-center justify-center rounded-full bg-surface-muted">
                  <Phone className="h-6 w-6 text-text-muted" />
                </div>
                <p className="text-body-strong text-text-primary">Nenhuma call no período</p>
                <p className="text-caption mt-1 max-w-xs text-text-muted">
                  As calls dos últimos {dias} dias aparecerão aqui assim que forem processadas.
                </p>
              </div>
            ) : (
              <ul className="space-y-1">
                {d.calls_recentes.map((c) => (
                  <li key={c.id}>
                    <Link
                      href={`/calls/${c.id}`}
                      className="flex items-center justify-between rounded-md px-2 py-2 transition-colors hover:bg-surface-muted"
                    >
                      <div className="min-w-0">
                        <p className="text-body-strong truncate text-text-primary">
                          {c.lead_nome ?? c.titulo ?? "Call sem título"}
                        </p>
                        <p className="text-caption text-text-muted">
                          {c.classificacao ?? "—"} · {c.match_status}
                        </p>
                      </div>
                      {c.score_geral != null && (
                        <Badge variant={scoreBadgeVariant(c.score_geral)} className="ml-2 shrink-0">
                          {c.score_geral}
                        </Badge>
                      )}
                    </Link>
                  </li>
                ))}
              </ul>
            )}
          </CardContent>
        </Card>
      </div>
    </div>
  );
}

export default async function DashboardPage({
  searchParams,
}: {
  searchParams: Promise<{ dias?: string }>;
}) {
  const { dias: diasParam } = await searchParams;
  const dias = Math.min(Math.max(Number(diasParam ?? "7"), 7), 90) || 7;

  return (
    <div className="space-y-8">
      <div className="flex items-start justify-between">
        <div>
          <h1 className="text-h1 text-text-primary">Dashboard</h1>
          <p className="mt-1 text-sm text-text-secondary">Visão consolidada do comercial</p>
        </div>
        <Suspense>
          <PeriodoSelector />
        </Suspense>
      </div>

      <Suspense
        fallback={
          <div className="space-y-6">
            <div className="grid grid-cols-2 gap-4 lg:grid-cols-4">
              {[...Array(4)].map((_, i) => (
                <div
                  key={i}
                  className="h-32 animate-pulse rounded-lg border border-border bg-surface-muted"
                />
              ))}
            </div>
          </div>
        }
      >
        <DashboardConteudo dias={dias} />
      </Suspense>
    </div>
  );
}
