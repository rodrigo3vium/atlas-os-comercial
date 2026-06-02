import Link from "next/link";
import { createServiceClient } from "@/lib/supabase/server";
import { Badge } from "@/components/ui/badge";
import { cn } from "@/lib/utils";

function scoreColor(score: number | null) {
  if (score == null) return "text-text-muted";
  if (score >= 70) return "text-status-success";
  if (score >= 40) return "text-status-warning";
  return "text-status-danger";
}

function formatarData(iso: string | null) {
  if (!iso) return "—";
  return new Intl.DateTimeFormat("pt-BR", {
    day: "2-digit",
    month: "2-digit",
    hour: "2-digit",
    minute: "2-digit",
  }).format(new Date(iso));
}

export default async function WhatsappPage({
  searchParams,
}: {
  searchParams: Promise<{ status?: string }>;
}) {
  const { status } = await searchParams;
  const supabase = await createServiceClient();

  let query = supabase
    .schema("comercial")
    .from("conversas")
    .select(
      "id, status, ultimo_score, ultima_mensagem_em, ultima_analise_em, lead:leads(nome, telefone)",
    )
    .order("ultima_mensagem_em", { ascending: false, nullsFirst: false })
    .limit(100);

  if (status) query = query.eq("status", status);

  const { data: conversas } = await query;

  const statusLabels: Record<string, string> = {
    ativa: "Ativa",
    aguardando: "Aguardando",
    encerrada: "Encerrada",
  };

  return (
    <div className="space-y-6">
      <div className="flex items-start justify-between">
        <div>
          <h1 className="text-h1 text-text-primary">Conversas WhatsApp</h1>
          <p className="mt-1 text-sm text-text-secondary">{conversas?.length ?? 0} conversas</p>
        </div>
        <div className="flex gap-1.5">
          <Link
            href="/whatsapp"
            className={cn(
              "text-caption rounded-md px-3 py-1.5 font-medium transition-colors",
              !status
                ? "bg-teal-soft text-teal-soft-text"
                : "text-text-tertiary hover:bg-surface-muted hover:text-text-primary",
            )}
          >
            Todas
          </Link>
          {Object.entries(statusLabels).map(([s, label]) => (
            <Link
              key={s}
              href={s === status ? "/whatsapp" : `/whatsapp?status=${s}`}
              className={cn(
                "text-caption rounded-md px-3 py-1.5 font-medium transition-colors",
                s === status
                  ? "bg-teal-soft text-teal-soft-text"
                  : "text-text-tertiary hover:bg-surface-muted hover:text-text-primary",
              )}
            >
              {label}
            </Link>
          ))}
        </div>
      </div>

      <div className="overflow-hidden rounded-lg border border-border bg-surface shadow-sm">
        <table className="w-full text-sm">
          <thead>
            <tr className="border-b border-border bg-surface-muted">
              <th className="text-label px-4 py-3 text-left text-text-tertiary">Lead</th>
              <th className="text-label px-4 py-3 text-left text-text-tertiary">Status</th>
              <th className="text-label px-4 py-3 text-left text-text-tertiary">Score</th>
              <th className="text-label px-4 py-3 text-left text-text-tertiary">Última mensagem</th>
              <th className="text-label px-4 py-3 text-left text-text-tertiary">Analisada</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-border">
            {(conversas ?? []).length === 0 ? (
              <tr>
                <td colSpan={5} className="text-caption px-4 py-10 text-center text-text-muted">
                  Nenhuma conversa encontrada
                </td>
              </tr>
            ) : (
              (conversas ?? []).map((c) => {
                const lead = Array.isArray(c.lead) ? c.lead[0] : c.lead;
                return (
                  <tr key={c.id} className="hover:bg-surface-muted">
                    <td className="px-4 py-3">
                      <Link
                        href={`/whatsapp/${c.id}`}
                        className="font-medium text-text-primary hover:text-teal"
                      >
                        {lead?.nome ?? lead?.telefone ?? "—"}
                      </Link>
                      {lead?.telefone && (
                        <p className="text-caption text-text-muted">{lead.telefone}</p>
                      )}
                    </td>
                    <td className="px-4 py-3">
                      <Badge variant="secondary" className="capitalize">
                        {c.status}
                      </Badge>
                    </td>
                    <td className="px-4 py-3">
                      <span
                        className={cn(
                          "text-sm font-semibold tabular-nums",
                          scoreColor(c.ultimo_score),
                        )}
                      >
                        {c.ultimo_score ?? "—"}
                      </span>
                    </td>
                    <td className="text-caption px-4 py-3 text-text-tertiary">
                      {formatarData(c.ultima_mensagem_em)}
                    </td>
                    <td className="text-caption px-4 py-3 text-text-tertiary">
                      {formatarData(c.ultima_analise_em)}
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
