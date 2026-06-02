import { cn } from "@/lib/utils";

type Props = {
  label: string;
  valor: string | number;
  subtitulo?: string;
  delta?: number | null;
  valorClassName?: string;
  destaque?: boolean;
};

export function ScoreKpiCard({
  label,
  valor,
  subtitulo,
  delta,
  valorClassName,
  destaque = false,
}: Props) {
  const temDelta = delta !== undefined && delta !== null;
  const positivo = temDelta && delta >= 0;
  return (
    <div
      className={cn(
        "rounded-lg border p-4 shadow-sm",
        destaque ? "border-teal bg-teal-soft" : "border-border bg-surface",
      )}
    >
      <p className={cn("text-label", destaque ? "text-teal-soft-text" : "text-text-tertiary")}>
        {label}
      </p>
      <p
        className={cn(
          "text-kpi mt-1 font-semibold tabular-nums",
          valorClassName ?? (destaque ? "text-teal-soft-text" : "text-text-primary"),
        )}
      >
        {valor}
      </p>
      {temDelta && (
        <p
          className={cn(
            "text-caption mt-1 font-medium",
            positivo ? "text-status-success" : "text-status-danger",
          )}
        >
          {positivo ? "↑" : "↓"} {Math.abs(delta).toFixed(1)}% vs ronda anterior
        </p>
      )}
      {!temDelta && subtitulo && <p className="text-caption mt-1 text-text-muted">{subtitulo}</p>}
    </div>
  );
}
