import { cn } from "@/lib/utils";
import { FASES_LABEL, corPorScore, formatarTag } from "@/lib/format";

type CallsProps = {
  tipo: "calls";
  itens: { fase: string; score: number }[];
};

type WhatsappProps = {
  tipo: "whatsapp";
  itens: { tag: string; total: number }[];
  totalConversas: number;
};

export function ItensCriticosTable(props: CallsProps | WhatsappProps) {
  if (props.itens.length === 0) {
    return (
      <div className="rounded-lg border border-border bg-surface-muted p-6 text-center">
        <p className="text-body-strong text-text-primary">Sem itens críticos</p>
        <p className="text-caption mt-1 text-text-muted">
          Nenhum dado suficiente para ranquear os critérios desta ronda.
        </p>
      </div>
    );
  }

  return (
    <div className="overflow-hidden rounded-lg border border-border bg-surface shadow-sm">
      <table className="w-full text-sm">
        <thead>
          <tr className="border-b border-border bg-surface-muted">
            <th className="text-label w-12 px-4 py-3 text-left text-text-tertiary">#</th>
            <th className="text-label px-4 py-3 text-left text-text-tertiary">
              {props.tipo === "calls" ? "Fase" : "Tag negativa"}
            </th>
            <th className="text-label w-36 px-4 py-3 text-right text-text-tertiary">
              {props.tipo === "calls" ? "Score médio" : "Ocorrências"}
            </th>
          </tr>
        </thead>
        <tbody className="divide-y divide-border">
          {props.tipo === "calls"
            ? props.itens.map((it, idx) => {
                const cor = corPorScore(it.score);
                return (
                  <tr key={it.fase} className="hover:bg-surface-muted">
                    <td className="text-caption px-4 py-3 tabular-nums text-text-tertiary">
                      {idx + 1}
                    </td>
                    <td className="px-4 py-3 text-text-primary">
                      {FASES_LABEL[it.fase] ?? formatarTag(it.fase)}
                    </td>
                    <td className={cn("px-4 py-3 text-right font-semibold tabular-nums", cor.text)}>
                      {it.score.toFixed(1)}
                    </td>
                  </tr>
                );
              })
            : props.itens.map((it, idx) => {
                const pct =
                  props.totalConversas > 0
                    ? Math.round((it.total / props.totalConversas) * 100)
                    : 0;
                return (
                  <tr key={it.tag} className="hover:bg-surface-muted">
                    <td className="text-caption px-4 py-3 tabular-nums text-text-tertiary">
                      {idx + 1}
                    </td>
                    <td className="px-4 py-3 text-text-primary">{formatarTag(it.tag)}</td>
                    <td className="px-4 py-3 text-right text-text-primary">
                      <span className="font-semibold tabular-nums">{it.total}</span>
                      <span className="text-caption ml-1 text-text-muted">({pct}%)</span>
                    </td>
                  </tr>
                );
              })}
        </tbody>
      </table>
    </div>
  );
}
