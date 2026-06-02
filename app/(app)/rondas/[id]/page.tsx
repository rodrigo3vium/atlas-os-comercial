import { notFound } from "next/navigation";
import Link from "next/link";
import { createServiceClient } from "@/lib/supabase/server";
import { cn } from "@/lib/utils";
import { corPorScore } from "@/lib/format";
import { ScoreKpiCard } from "@/components/rondas/score-kpi-card";
import { EvolucaoChart } from "@/components/rondas/evolucao-chart";
import { ItensCriticosTable } from "@/components/rondas/itens-criticos-table";
import type { SnapshotWhatsapp, SnapshotCalls } from "@/lib/modules/gerador-ronda";

function BarChart({
  label,
  value,
  max,
  color,
}: {
  label: string;
  value: number;
  max: number;
  color: string;
}) {
  const pct = max > 0 ? Math.round((value / max) * 100) : 0;
  return (
    <div className="flex items-center gap-2">
      <span className="text-caption w-28 shrink-0 truncate text-text-tertiary">{label}</span>
      <div className="h-2 flex-1 overflow-hidden rounded-full bg-border">
        <div className={cn("h-full rounded-full", color)} style={{ width: `${pct}%` }} />
      </div>
      <span className="text-caption w-8 text-right text-text-secondary">{value}</span>
    </div>
  );
}

function SectionCard({
  titulo,
  hint,
  children,
}: {
  titulo: string;
  hint?: string;
  children: React.ReactNode;
}) {
  return (
    <section className="rounded-lg border border-border bg-surface p-4 shadow-sm">
      <div className="mb-3 flex items-baseline justify-between gap-3">
        <h3 className="text-label text-text-tertiary">{titulo}</h3>
        {hint && <span className="text-caption text-text-muted">{hint}</span>}
      </div>
      {children}
    </section>
  );
}

function RondaWhatsapp({ snap }: { snap: SnapshotWhatsapp }) {
  const scoreMedio = snap.score_medio;
  const corScore = corPorScore(scoreMedio);
  const historico = snap.historico_recente ?? [];
  const topNegativas = snap.top_tags_negativas.slice(0, 5);
  const maxDist = Math.max(...snap.distribuicao_score.map((d) => d.total), 1);
  const maxPositivas = Math.max(...snap.top_tags_positivas.map((t) => t.total), 1);

  return (
    <div className="space-y-5">
      <div className="grid grid-cols-2 gap-3 sm:grid-cols-4">
        <ScoreKpiCard
          label={snap.numero_ronda ? `Score Global · R${snap.numero_ronda}` : "Score Global"}
          valor={scoreMedio !== null ? `${scoreMedio.toFixed(1)}/100` : "—"}
          valorClassName={corScore.text}
          delta={snap.delta_pct ?? undefined}
          destaque
        />
        <ScoreKpiCard label="Conversas" valor={snap.total_conversas} />
        <ScoreKpiCard
          label="Score +alto"
          valor={snap.score_mais_alto ?? "—"}
          valorClassName="text-status-success"
        />
        <ScoreKpiCard
          label="Score +baixo"
          valor={snap.score_mais_baixo ?? "—"}
          valorClassName="text-status-danger"
        />
      </div>

      {snap.total_conversas === 0 && (
        <div className="rounded-lg border border-border bg-surface-muted p-8 text-center">
          <p className="text-body-strong text-text-primary">Nenhuma conversa analisada</p>
          <p className="text-caption mt-1 text-text-muted">
            Nenhuma conversa foi analisada neste período.
          </p>
        </div>
      )}

      {historico.length >= 2 && (
        <SectionCard
          titulo="Evolução da ronda"
          hint={`Últimas ${historico.length} rondas WhatsApp`}
        >
          <EvolucaoChart itens={historico} />
        </SectionCard>
      )}

      {topNegativas.length > 0 && (
        <SectionCard titulo="Itens com menor score" hint="Top tags negativas mais frequentes">
          <ItensCriticosTable
            tipo="whatsapp"
            itens={topNegativas}
            totalConversas={snap.total_conversas}
          />
        </SectionCard>
      )}

      {snap.distribuicao_score.length > 0 && (
        <SectionCard titulo="Distribuição de scores">
          <div className="space-y-2">
            {snap.distribuicao_score.map((d) => (
              <BarChart
                key={d.faixa}
                label={d.faixa}
                value={d.total}
                max={maxDist}
                color="bg-teal"
              />
            ))}
          </div>
        </SectionCard>
      )}

      {snap.conversas_criticas.length > 0 && (
        <SectionCard titulo="Conversas críticas" hint="Score < 40">
          <ul className="divide-y divide-border">
            {snap.conversas_criticas.map((c) => (
              <li
                key={c.conversa_id}
                className="flex items-start justify-between py-2.5 first:pt-0 last:pb-0"
              >
                <div>
                  <p className="text-body-strong text-text-primary">
                    {c.lead_nome ?? "Lead sem nome"}
                  </p>
                  {c.resumo && <p className="text-caption mt-0.5 text-text-muted">{c.resumo}</p>}
                </div>
                <span className="text-kpi ml-4 shrink-0 font-bold text-status-danger">
                  {c.score}
                </span>
              </li>
            ))}
          </ul>
        </SectionCard>
      )}

      {snap.top_tags_positivas.length > 0 && (
        <SectionCard titulo="Pontos positivos">
          <div className="space-y-2">
            {snap.top_tags_positivas.slice(0, 8).map((t) => (
              <BarChart
                key={t.tag}
                label={t.tag.replace(/_/g, " ")}
                value={t.total}
                max={maxPositivas}
                color="bg-status-success"
              />
            ))}
          </div>
        </SectionCard>
      )}

      {snap.origens.length > 0 && (
        <SectionCard titulo="Origens">
          <div className="flex flex-wrap gap-2">
            {snap.origens.map((o) => (
              <span
                key={o.origem}
                className="text-caption rounded-full bg-teal-soft px-3 py-1 font-medium text-teal-soft-text"
              >
                {o.origem}: <span className="font-semibold">{o.total}</span>
              </span>
            ))}
          </div>
        </SectionCard>
      )}
    </div>
  );
}

function RondaCalls({ snap }: { snap: SnapshotCalls }) {
  const classColors: Record<string, string> = {
    excelente: "bg-status-success-soft text-status-success",
    bom: "bg-teal-soft text-teal-soft-text",
    regular: "bg-status-warning-soft text-status-warning",
    insuficiente: "bg-status-danger-soft text-status-danger",
  };

  const countPor = (c: string) =>
    snap.distribuicao_classificacao.find((d) => d.classificacao === c)?.total ?? 0;

  const fasesOrdenadas = Object.entries(snap.media_por_fase)
    .filter((entry): entry is [string, number] => entry[1] !== null)
    .map(([fase, score]) => ({ fase, score }))
    .sort((a, b) => a.score - b.score);

  const corScore = corPorScore(snap.score_medio);
  const historico = snap.historico_recente ?? [];

  return (
    <div className="space-y-5">
      <div className="grid grid-cols-2 gap-3 sm:grid-cols-4">
        <ScoreKpiCard
          label={snap.numero_ronda ? `Score Global · R${snap.numero_ronda}` : "Score Global"}
          valor={snap.score_medio !== null ? `${snap.score_medio.toFixed(1)}/100` : "—"}
          valorClassName={corScore.text}
          delta={snap.delta_pct ?? undefined}
          destaque
        />
        <ScoreKpiCard label="Calls analisadas" valor={snap.total_calls} />
        <ScoreKpiCard
          label="Excelentes"
          valor={countPor("excelente")}
          valorClassName="text-status-success"
        />
        <ScoreKpiCard
          label="Insuficientes"
          valor={countPor("insuficiente")}
          valorClassName="text-status-danger"
        />
      </div>

      {snap.total_calls === 0 && (
        <div className="rounded-lg border border-border bg-surface-muted p-8 text-center">
          <p className="text-body-strong text-text-primary">Nenhuma call analisada</p>
          <p className="text-caption mt-1 text-text-muted">
            Nenhuma call foi analisada neste período.
          </p>
        </div>
      )}

      {historico.length >= 2 && (
        <SectionCard titulo="Evolução da ronda" hint={`Últimas ${historico.length} rondas Calls`}>
          <EvolucaoChart itens={historico} />
        </SectionCard>
      )}

      {fasesOrdenadas.length > 0 && (
        <SectionCard titulo="Itens com menor score" hint="Fases ranqueadas pelo score médio">
          <ItensCriticosTable tipo="calls" itens={fasesOrdenadas} />
        </SectionCard>
      )}

      {snap.distribuicao_classificacao.length > 0 && (
        <SectionCard titulo="Distribuição por classificação">
          <div className="flex flex-wrap gap-2">
            {snap.distribuicao_classificacao.map((d) => (
              <span
                key={d.classificacao}
                className={cn(
                  "text-caption rounded-full px-3 py-1 font-medium capitalize",
                  classColors[d.classificacao] ?? "bg-surface-muted text-text-secondary",
                )}
              >
                {d.classificacao}: {d.total}
              </span>
            ))}
          </div>
        </SectionCard>
      )}

      {snap.calls_insuficientes.length > 0 && (
        <SectionCard titulo="Calls insuficientes">
          <ul className="divide-y divide-border">
            {snap.calls_insuficientes.map((c) => (
              <li
                key={c.call_id}
                className="flex items-start justify-between py-2.5 first:pt-0 last:pb-0"
              >
                <div>
                  <p className="text-body-strong text-text-primary">{c.lead_nome ?? "Sem match"}</p>
                  {c.diagnostico && (
                    <p className="text-caption mt-0.5 text-text-muted">{c.diagnostico}</p>
                  )}
                </div>
                <span className="text-kpi ml-4 shrink-0 font-bold text-status-danger">
                  {c.score}
                </span>
              </li>
            ))}
          </ul>
        </SectionCard>
      )}
    </div>
  );
}

export default async function RondaDetalhe({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const supabase = await createServiceClient();

  const { data: ronda } = await supabase
    .schema("comercial")
    .from("rondas")
    .select(
      "id, tipo, periodo_inicio, periodo_fim, status, snapshot, vazia, enviada_em, destinatarios",
    )
    .eq("id", id)
    .single();

  if (!ronda) notFound();

  const inicio = new Intl.DateTimeFormat("pt-BR").format(new Date(ronda.periodo_inicio));
  const fim = new Intl.DateTimeFormat("pt-BR").format(new Date(ronda.periodo_fim));
  const tipoLabel = ronda.tipo === "whatsapp" ? "WhatsApp" : "Calls";

  const statusCor =
    ronda.status === "enviada"
      ? "bg-status-success-soft text-status-success"
      : ronda.status === "erro"
        ? "bg-status-danger-soft text-status-danger"
        : "bg-surface-muted text-text-secondary";

  return (
    <div className="max-w-3xl space-y-5">
      <div>
        <Link href="/rondas" className="text-caption font-medium text-teal hover:text-teal-hover">
          ← Rondas
        </Link>
        <h1 className="text-h1 mt-1 text-text-primary">
          Ronda {tipoLabel} — {inicio} a {fim}
        </h1>
        <div className="mt-2 flex items-center gap-3">
          <span className={cn("rounded-full px-2 py-0.5 text-[11px] font-medium", statusCor)}>
            {ronda.status}
          </span>
          {ronda.enviada_em && (
            <span className="text-caption text-text-muted">
              Enviada em{" "}
              {new Intl.DateTimeFormat("pt-BR", {
                dateStyle: "short",
                timeStyle: "short",
              }).format(new Date(ronda.enviada_em))}
            </span>
          )}
          {ronda.vazia && <span className="text-caption text-text-muted">Período vazio</span>}
        </div>
      </div>

      {ronda.tipo === "whatsapp" ? (
        <RondaWhatsapp snap={ronda.snapshot as SnapshotWhatsapp} />
      ) : (
        <RondaCalls snap={ronda.snapshot as SnapshotCalls} />
      )}

      {Array.isArray(ronda.destinatarios) && (ronda.destinatarios as string[]).length > 0 && (
        <p className="text-caption text-text-muted">
          Enviada para: {(ronda.destinatarios as string[]).join(", ")}
        </p>
      )}
    </div>
  );
}
