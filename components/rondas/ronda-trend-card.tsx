import Link from "next/link";
import { cn } from "@/lib/utils";
import { corPorScore } from "@/lib/format";
import { EvolucaoChart } from "./evolucao-chart";
import type { HistoricoRondaItem, TipoRonda } from "@/lib/modules/gerador-ronda";

type Props = {
  tipo: TipoRonda;
  scoreAtual: number | null;
  delta: number | null;
  historico: HistoricoRondaItem[];
};

const TITULO: Record<TipoRonda, string> = {
  whatsapp: "WhatsApp",
  calls: "Calls",
};

export function RondaTrendCard({ tipo, scoreAtual, delta, historico }: Props) {
  const corScore = corPorScore(scoreAtual);
  const temDelta = delta !== null;
  const positivo = temDelta && delta >= 0;

  return (
    <div className="rounded-lg border border-border bg-surface p-4 shadow-sm">
      <div className="mb-3 flex items-center justify-between">
        <h2 className="text-label text-text-tertiary">{TITULO[tipo]}</h2>
        <Link
          href={`/rondas?tipo=${tipo}`}
          className="text-caption font-medium text-teal hover:text-teal-hover"
        >
          Ver todas →
        </Link>
      </div>

      {historico.length === 0 ? (
        <div className="flex h-24 items-center justify-center rounded-md bg-surface-muted">
          <p className="text-caption text-text-muted">Sem rondas ainda</p>
        </div>
      ) : (
        <div className="flex items-stretch gap-4">
          <div className="flex shrink-0 flex-col justify-center">
            <p className={cn("text-kpi-lg font-semibold tabular-nums leading-none", corScore.text)}>
              {scoreAtual !== null ? scoreAtual.toFixed(1) : "—"}
            </p>
            <p
              className={cn(
                "text-caption mt-2 font-medium tabular-nums",
                !temDelta
                  ? "text-text-muted"
                  : positivo
                    ? "text-status-success"
                    : "text-status-danger",
              )}
            >
              {!temDelta
                ? "Sem ronda anterior"
                : `${positivo ? "↑" : "↓"} ${Math.abs(delta).toFixed(1)}% vs anterior`}
            </p>
          </div>
          <div className="min-w-0 flex-1">
            <EvolucaoChart itens={historico} compact />
          </div>
        </div>
      )}
    </div>
  );
}
