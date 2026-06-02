import { Card } from "@/components/ui/card";
import { cn } from "@/lib/utils";

type Props = {
  titulo: string;
  valor: string | number | null;
  delta?: number | null;
  sufixo?: string;
  destaque?: boolean;
};

export function KpiCard({ titulo, valor, delta, sufixo }: Props) {
  const isEmpty = valor == null;
  const valorFormatado = isEmpty ? "—" : `${valor}${sufixo ?? ""}`;

  return (
    <Card className="flex flex-col gap-2 p-6">
      <span className="text-label text-text-tertiary">{titulo}</span>
      <div className="flex items-baseline gap-2">
        <span className={cn("text-kpi-lg text-text-primary", isEmpty && "text-text-muted")}>
          {valorFormatado}
        </span>
        {delta != null && (
          <span
            className={cn(
              "text-caption font-medium",
              delta >= 0 ? "text-status-success" : "text-status-danger",
            )}
          >
            {delta >= 0 ? "↑" : "↓"} {Math.abs(delta)}%
          </span>
        )}
      </div>
      {delta != null && <span className="text-caption text-text-muted">vs período anterior</span>}
    </Card>
  );
}
