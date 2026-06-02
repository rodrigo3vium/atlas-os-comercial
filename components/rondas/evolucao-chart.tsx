import { cn } from "@/lib/utils";
import { corPorScore, type CorScore } from "@/lib/format";

type Item = {
  rotulo: string;
  score_medio: number | null;
};

type Props = {
  itens: Item[];
  escalaMax?: number;
  compact?: boolean;
};

export function EvolucaoChart({ itens, escalaMax = 100, compact = false }: Props) {
  if (itens.length === 0) return null;

  const scoresValidos = itens.map((i) => i.score_medio).filter((s): s is number => s !== null);
  const maxObservado = scoresValidos.length > 0 ? Math.max(...scoresValidos, 1) : 1;
  const topoEixo = Math.min(escalaMax, Math.ceil((maxObservado * 1.15) / 10) * 10);

  return (
    <div>
      <div
        className={cn(
          "flex items-end justify-around",
          compact ? "h-24 gap-1.5" : "h-48 gap-2 px-2 sm:gap-4 sm:px-4",
        )}
      >
        {itens.map((item, idx) => {
          const score = item.score_medio;
          const isUltimo = idx === itens.length - 1;
          const cor: CorScore = corPorScore(score);
          const alturaPct = score === null ? 0 : Math.max((score / topoEixo) * 100, 4);
          return (
            <div
              key={`${item.rotulo}-${idx}`}
              className="flex h-full flex-1 flex-col items-center justify-end gap-1"
            >
              <div className="relative flex w-full flex-1 items-end">
                <div
                  className={cn(
                    "w-full rounded-t-md transition-all",
                    score === null ? "bg-surface-muted" : cor.bg,
                    isUltimo &&
                      (compact
                        ? "ring-1 ring-teal ring-offset-1 ring-offset-surface"
                        : "ring-2 ring-teal ring-offset-2 ring-offset-surface"),
                  )}
                  style={{ height: `${alturaPct}%`, minHeight: compact ? "4px" : "6px" }}
                >
                  {!compact && score !== null && (
                    <span className="text-caption absolute -top-5 left-1/2 -translate-x-1/2 font-semibold tabular-nums text-text-primary">
                      {score.toFixed(0)}
                    </span>
                  )}
                </div>
              </div>
              <p
                className={cn(
                  "font-medium",
                  compact ? "text-[10px]" : "text-caption",
                  isUltimo ? "text-teal" : "text-text-secondary",
                )}
              >
                {item.rotulo}
              </p>
            </div>
          );
        })}
      </div>
    </div>
  );
}
