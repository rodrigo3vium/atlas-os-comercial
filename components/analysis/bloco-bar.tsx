// Barra expansível de um bloco (A–G) — agnóstica de régua. Recebe o nome e o peso
// já resolvidos pela página (NOMES_FECHAMENTO/PESOS_FECHAMENTO em calls,
// NOMES_DIAGNOSTICO/PESOS_DIAGNOSTICO em whatsapp). A cor da nota vem de notaCor.

import { cn } from "@/lib/utils";
import { notaCor, type BlocoNota } from "@/lib/analysis/commercial-rubric";

export function BlocoBar({ bloco, nome, peso }: { bloco: BlocoNota; nome: string; peso: number }) {
  const cor = notaCor(bloco.nota_0_10);
  return (
    <details className="group rounded-md border border-border bg-surface-muted">
      <summary className="cursor-pointer list-none px-3 py-2.5 hover:bg-surface-hover">
        <div className="mb-1.5 flex items-center justify-between gap-3">
          <div className="flex items-center gap-2">
            <span className="font-mono text-[11px] text-text-tertiary">{bloco.id}</span>
            <span className="text-caption text-text-primary">{nome}</span>
            <span className="font-mono text-[10px] uppercase tracking-[0.1em] text-text-muted">
              Peso {peso}%
            </span>
          </div>
          <span className={cn("text-body-strong tabular-nums", cor.text)}>
            {bloco.nota_0_10}
            <span className="text-text-muted">/10</span>
          </span>
        </div>
        <div className="h-1.5 w-full overflow-hidden rounded-full bg-surface">
          <div
            className={cn("h-full rounded-full", cor.bar)}
            style={{ width: `${bloco.nota_0_10 * 10}%` }}
          />
        </div>
      </summary>
      <div className="space-y-2 border-t border-border px-3 py-3">
        <p className="text-caption leading-relaxed text-text-secondary">{bloco.analise}</p>
        {bloco.citacoes?.map((cit, i) => (
          <blockquote key={i} className="rounded-md border-l-2 border-teal bg-surface px-3 py-2">
            <p className="text-caption italic text-text-primary">“{cit.quote}”</p>
            {(cit.speaker || cit.ts) && (
              <p className="mt-1 font-mono text-[10px] uppercase tracking-[0.1em] text-text-muted">
                {[cit.speaker, cit.ts].filter(Boolean).join(" · ")}
              </p>
            )}
          </blockquote>
        ))}
      </div>
    </details>
  );
}
