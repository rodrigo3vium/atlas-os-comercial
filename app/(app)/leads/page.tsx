import Link from "next/link";
import { createServiceClient } from "@/lib/supabase/server";
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

const PAGE_SIZE = 50;

export default async function LeadsPage({
  searchParams,
}: {
  searchParams: Promise<{ status?: string; pagina?: string; origem?: string }>;
}) {
  const { status, pagina, origem } = await searchParams;
  const pag = Math.max(Number(pagina ?? "1"), 1);
  const from = (pag - 1) * PAGE_SIZE;
  const to = from + PAGE_SIZE - 1;

  const supabase = await createServiceClient();

  let query = supabase
    .schema("comercial")
    .from("leads")
    .select("id, nome, telefone, status, origem, origem_status, created_at", { count: "exact" })
    .order("created_at", { ascending: false })
    .range(from, to);

  if (status) query = query.eq("status", status);
  if (origem) query = query.eq("origem_status", origem);

  const { data: leads, count } = await query;
  const totalPaginas = Math.ceil((count ?? 0) / PAGE_SIZE);

  const STATUS_LISTA = [
    "novo",
    "em_atendimento",
    "sem_resposta",
    "agendou",
    "compareceu",
    "perdido",
    "fechou",
  ];

  return (
    <div className="space-y-6">
      <div className="flex items-start justify-between">
        <div>
          <h1 className="text-h1 text-text-primary">Leads</h1>
          <p className="mt-1 text-sm text-text-secondary">{count ?? 0} leads cadastrados</p>
        </div>
        <Link
          href="/leads/pendentes"
          className="text-caption hover:bg-teal/10 rounded-lg bg-teal-soft px-3 py-1.5 font-medium text-teal-soft-text transition-colors"
        >
          Classificar origens pendentes →
        </Link>
      </div>

      {/* Filtros de status */}
      <div className="flex flex-wrap gap-1.5">
        <Link
          href="/leads"
          className={cn(
            "text-caption rounded-md px-2.5 py-1 font-medium transition-colors",
            !status
              ? "bg-teal-soft text-teal-soft-text"
              : "text-text-tertiary hover:bg-surface-muted hover:text-text-primary",
          )}
        >
          Todos
        </Link>
        {STATUS_LISTA.map((s) => (
          <Link
            key={s}
            href={s === status ? "/leads" : `/leads?status=${s}`}
            className={cn(
              "text-caption rounded-md px-2.5 py-1 font-medium capitalize transition-colors",
              s === status
                ? "bg-teal-soft text-teal-soft-text"
                : "text-text-tertiary hover:bg-surface-muted hover:text-text-primary",
            )}
          >
            {s.replace("_", " ")}
          </Link>
        ))}
      </div>

      <div className="overflow-hidden rounded-lg border border-border bg-surface shadow-sm">
        <table className="w-full text-sm">
          <thead>
            <tr className="border-b border-border bg-surface-muted">
              <th className="text-label px-4 py-3 text-left text-text-tertiary">Nome</th>
              <th className="text-label px-4 py-3 text-left text-text-tertiary">Telefone</th>
              <th className="text-label px-4 py-3 text-left text-text-tertiary">Status</th>
              <th className="text-label px-4 py-3 text-left text-text-tertiary">Origem</th>
              <th className="text-label px-4 py-3 text-left text-text-tertiary">Cadastro</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-border">
            {(leads ?? []).length === 0 ? (
              <tr>
                <td colSpan={5} className="text-caption px-4 py-10 text-center text-text-muted">
                  Nenhum lead encontrado
                </td>
              </tr>
            ) : (
              (leads ?? []).map((l) => (
                <tr key={l.id} className="hover:bg-surface-muted">
                  <td className="px-4 py-3">
                    <Link
                      href={`/leads/${l.id}`}
                      className="font-medium text-text-primary hover:text-teal"
                    >
                      {l.nome}
                    </Link>
                  </td>
                  <td className="text-caption px-4 py-3 text-text-tertiary">{l.telefone}</td>
                  <td className="px-4 py-3">
                    <span
                      className={cn(
                        "rounded-full px-2 py-0.5 text-[11px] font-medium capitalize",
                        STATUS_COR[l.status] ?? "bg-surface-muted text-text-secondary",
                      )}
                    >
                      {l.status.replace("_", " ")}
                    </span>
                  </td>
                  <td className="px-4 py-3">
                    {l.origem ? (
                      <span className="text-caption text-text-tertiary">{l.origem}</span>
                    ) : (
                      <span className="text-caption text-text-muted">
                        {l.origem_status === "pendente" ? "pendente" : "—"}
                      </span>
                    )}
                  </td>
                  <td className="text-caption px-4 py-3 text-text-muted">
                    {new Intl.DateTimeFormat("pt-BR").format(new Date(l.created_at))}
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>

      {/* Paginação */}
      {totalPaginas > 1 && (
        <div className="flex justify-center gap-2">
          {pag > 1 && (
            <Link
              href={`/leads?pagina=${pag - 1}${status ? `&status=${status}` : ""}`}
              className="text-caption rounded-lg border border-border bg-surface px-3 py-1.5 text-text-secondary transition-colors hover:bg-surface-muted"
            >
              ← Anterior
            </Link>
          )}
          <span className="text-caption px-3 py-1.5 text-text-muted">
            {pag} / {totalPaginas}
          </span>
          {pag < totalPaginas && (
            <Link
              href={`/leads?pagina=${pag + 1}${status ? `&status=${status}` : ""}`}
              className="text-caption rounded-lg border border-border bg-surface px-3 py-1.5 text-text-secondary transition-colors hover:bg-surface-muted"
            >
              Próxima →
            </Link>
          )}
        </div>
      )}
    </div>
  );
}
