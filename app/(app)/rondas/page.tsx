import Link from "next/link";
import { createServiceClient } from "@/lib/supabase/server";
import { cn } from "@/lib/utils";
import { corPorScore } from "@/lib/format";
import { RondaTrendCard } from "@/components/rondas/ronda-trend-card";
import type { HistoricoRondaItem, TipoRonda } from "@/lib/modules/gerador-ronda";

const STATUS_COR: Record<string, string> = {
  pendente: "bg-surface-muted text-text-tertiary",
  gerada: "bg-status-info-soft text-status-info",
  enviada: "bg-status-success-soft text-status-success",
  erro: "bg-status-danger-soft text-status-danger",
};

type SnapshotResumo = {
  score_medio?: number | null;
  delta_pct?: number | null;
  numero_ronda?: number | null;
};

type TrendData = {
  scoreAtual: number | null;
  delta: number | null;
  historico: HistoricoRondaItem[];
};

async function buscarTrend(
  tipo: TipoRonda,
  supabase: Awaited<ReturnType<typeof createServiceClient>>,
): Promise<TrendData> {
  const { data } = await supabase
    .schema("comercial")
    .from("rondas")
    .select("periodo_inicio, periodo_fim, snapshot")
    .eq("tipo", tipo)
    .order("periodo_inicio", { ascending: false })
    .limit(6);

  const recentesDesc = data ?? [];
  if (recentesDesc.length === 0) {
    return { scoreAtual: null, delta: null, historico: [] };
  }

  const ultimoSnap = (recentesDesc[0].snapshot ?? {}) as SnapshotResumo;
  const numeroUltimo = ultimoSnap.numero_ronda ?? recentesDesc.length;

  const historico: HistoricoRondaItem[] = recentesDesc
    .slice()
    .reverse()
    .map((r, idx) => {
      const snap = (r.snapshot ?? {}) as SnapshotResumo;
      const baseNumero = numeroUltimo - (recentesDesc.length - 1);
      const numero = snap.numero_ronda ?? baseNumero + idx;
      return {
        periodo_inicio: r.periodo_inicio as string,
        periodo_fim: r.periodo_fim as string,
        score_medio: snap.score_medio ?? null,
        rotulo: `R${numero}`,
      };
    });

  return {
    scoreAtual: ultimoSnap.score_medio ?? null,
    delta: ultimoSnap.delta_pct ?? null,
    historico,
  };
}

export default async function RondasPage({
  searchParams,
}: {
  searchParams: Promise<{ tipo?: string }>;
}) {
  const { tipo } = await searchParams;
  const supabase = await createServiceClient();

  let query = supabase
    .schema("comercial")
    .from("rondas")
    .select(
      "id, tipo, periodo_inicio, periodo_fim, status, enviada_em, vazia, erro_envio, snapshot",
    )
    .order("periodo_inicio", { ascending: false })
    .limit(60);

  if (tipo === "whatsapp" || tipo === "calls") {
    query = query.eq("tipo", tipo);
  }

  const [{ data: rondas }, trendWhatsapp, trendCalls] = await Promise.all([
    query,
    buscarTrend("whatsapp", supabase),
    buscarTrend("calls", supabase),
  ]);

  const temHero = trendWhatsapp.historico.length > 0 || trendCalls.historico.length > 0;

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-h1 text-text-primary">Rondas semanais</h1>
        <p className="mt-1 text-sm text-text-secondary">Histórico das rondas WhatsApp e Calls</p>
      </div>

      {temHero && (
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
          <RondaTrendCard
            tipo="whatsapp"
            scoreAtual={trendWhatsapp.scoreAtual}
            delta={trendWhatsapp.delta}
            historico={trendWhatsapp.historico}
          />
          <RondaTrendCard
            tipo="calls"
            scoreAtual={trendCalls.scoreAtual}
            delta={trendCalls.delta}
            historico={trendCalls.historico}
          />
        </div>
      )}

      <div className="flex gap-1.5">
        {[
          { label: "Todas", href: "/rondas", active: !tipo },
          { label: "WhatsApp", href: "/rondas?tipo=whatsapp", active: tipo === "whatsapp" },
          { label: "Calls", href: "/rondas?tipo=calls", active: tipo === "calls" },
        ].map((item) => (
          <Link
            key={item.href}
            href={item.href}
            className={cn(
              "text-caption rounded-md px-2.5 py-1 font-medium transition-colors",
              item.active
                ? "bg-teal-soft text-teal-soft-text"
                : "text-text-tertiary hover:bg-surface-muted hover:text-text-primary",
            )}
          >
            {item.label}
          </Link>
        ))}
      </div>

      <div className="overflow-hidden rounded-lg border border-border bg-surface shadow-sm">
        <table className="w-full text-sm">
          <thead>
            <tr className="border-b border-border bg-surface-muted">
              <th className="text-label px-4 py-3 text-left text-text-tertiary">Período</th>
              <th className="text-label px-4 py-3 text-left text-text-tertiary">Tipo</th>
              <th className="text-label px-4 py-3 text-right text-text-tertiary">Score</th>
              <th className="text-label px-4 py-3 text-right text-text-tertiary">Δ</th>
              <th className="text-label px-4 py-3 text-left text-text-tertiary">Status</th>
              <th className="text-label px-4 py-3 text-left text-text-tertiary">Enviada em</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-border">
            {(rondas ?? []).length === 0 ? (
              <tr>
                <td colSpan={6} className="text-caption px-4 py-10 text-center text-text-muted">
                  Nenhuma ronda encontrada
                </td>
              </tr>
            ) : (
              (rondas ?? []).map((r) => {
                const inicio = new Intl.DateTimeFormat("pt-BR").format(new Date(r.periodo_inicio));
                const fim = new Intl.DateTimeFormat("pt-BR").format(new Date(r.periodo_fim));
                const snap = (r.snapshot ?? {}) as SnapshotResumo;
                const score = snap.score_medio ?? null;
                const corScore = corPorScore(score);
                const delta = snap.delta_pct ?? null;
                return (
                  <tr key={r.id} className="hover:bg-surface-muted">
                    <td className="px-4 py-3">
                      <Link
                        href={`/rondas/${r.id}`}
                        className="font-medium text-text-primary hover:text-teal"
                      >
                        {inicio} — {fim}
                      </Link>
                      {r.vazia && <span className="ml-2 text-[11px] text-text-muted">(vazia)</span>}
                    </td>
                    <td className="px-4 py-3">
                      <span
                        className={cn(
                          "rounded-full px-2 py-0.5 text-[11px] font-medium",
                          r.tipo === "whatsapp"
                            ? "bg-teal-soft text-teal-soft-text"
                            : "bg-status-info-soft text-status-info",
                        )}
                      >
                        {r.tipo}
                      </span>
                    </td>
                    <td
                      className={cn(
                        "px-4 py-3 text-right font-semibold tabular-nums",
                        corScore.text,
                      )}
                    >
                      {score !== null ? score.toFixed(1) : "—"}
                    </td>
                    <td
                      className={cn(
                        "text-caption px-4 py-3 text-right font-medium tabular-nums",
                        delta === null
                          ? "text-text-muted"
                          : delta >= 0
                            ? "text-status-success"
                            : "text-status-danger",
                      )}
                    >
                      {delta === null
                        ? "—"
                        : `${delta >= 0 ? "↑" : "↓"} ${Math.abs(delta).toFixed(1)}%`}
                    </td>
                    <td className="px-4 py-3">
                      <span
                        className={cn(
                          "rounded-full px-2 py-0.5 text-[11px] font-medium",
                          STATUS_COR[r.status] ?? "bg-surface-muted text-text-tertiary",
                        )}
                      >
                        {r.status}
                      </span>
                      {r.erro_envio && (
                        <p
                          className="mt-0.5 max-w-[200px] truncate text-[11px] text-status-danger"
                          title={r.erro_envio}
                        >
                          {r.erro_envio}
                        </p>
                      )}
                    </td>
                    <td className="text-caption px-4 py-3 text-text-muted">
                      {r.enviada_em
                        ? new Intl.DateTimeFormat("pt-BR", {
                            dateStyle: "short",
                            timeStyle: "short",
                          }).format(new Date(r.enviada_em))
                        : "—"}
                    </td>
                  </tr>
                );
              })
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}
