import Link from "next/link";
import { createServiceClient } from "@/lib/supabase/server";
import { Badge } from "@/components/ui/badge";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { cn } from "@/lib/utils";

function classificacaoCor(cls: string | null) {
  const mapa: Record<string, string> = {
    excelente: "text-status-success",
    bom: "text-teal",
    regular: "text-status-warning",
    insuficiente: "text-status-danger",
  };
  return cls ? (mapa[cls] ?? "text-text-tertiary") : "text-text-muted";
}

function formatarData(iso: string | null) {
  if (!iso) return "—";
  return new Intl.DateTimeFormat("pt-BR", {
    day: "2-digit",
    month: "2-digit",
    year: "2-digit",
  }).format(new Date(iso));
}

export default async function CallsPage() {
  const supabase = await createServiceClient();

  const [{ data: aguardando }, { data: analisadas }] = await Promise.all([
    supabase
      .schema("comercial")
      .from("calls")
      .select("id, titulo, realizada_em, match_status, match_sugestoes, lead:leads(nome, telefone)")
      .in("match_status", ["pendente", "sugerido"])
      .is("analisada_em", null)
      .order("created_at", { ascending: false })
      .limit(50),
    supabase
      .schema("comercial")
      .from("calls")
      .select(
        "id, titulo, realizada_em, match_status, lead:leads(nome, telefone), analise:analises_calls(classificacao, score_geral)",
      )
      .not("analisada_em", "is", null)
      .order("realizada_em", { ascending: false, nullsFirst: false })
      .limit(100),
  ]);

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-h1 text-text-primary">Calls</h1>
        <p className="mt-1 text-sm text-text-secondary">
          Transcrições Plaud com análise de performance
        </p>
      </div>

      <Tabs defaultValue="aguardando">
        <TabsList>
          <TabsTrigger value="aguardando">
            Aguardando match
            {(aguardando?.length ?? 0) > 0 && (
              <span className="ml-1.5 rounded-full bg-teal-soft px-1.5 py-0.5 text-[10px] text-teal-soft-text">
                {aguardando?.length}
              </span>
            )}
          </TabsTrigger>
          <TabsTrigger value="analisadas">Analisadas</TabsTrigger>
        </TabsList>

        <TabsContent value="aguardando" className="mt-4">
          {(aguardando ?? []).length === 0 ? (
            <div className="rounded-lg border border-border bg-surface p-10 text-center shadow-sm">
              <p className="text-caption text-text-muted">Nenhuma call aguardando match</p>
            </div>
          ) : (
            <div className="overflow-hidden rounded-lg border border-border bg-surface shadow-sm">
              <table className="w-full text-sm">
                <thead>
                  <tr className="border-b border-border bg-surface-muted">
                    <th className="text-label px-4 py-3 text-left text-text-tertiary">Call</th>
                    <th className="text-label px-4 py-3 text-left text-text-tertiary">Data</th>
                    <th className="text-label px-4 py-3 text-left text-text-tertiary">Status</th>
                    <th className="text-label px-4 py-3 text-left text-text-tertiary">Ação</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-border">
                  {(aguardando ?? []).map((c) => (
                    <tr key={c.id} className="hover:bg-surface-muted">
                      <td className="px-4 py-3">
                        <Link
                          href={`/calls/${c.id}`}
                          className="font-medium text-text-primary hover:text-teal"
                        >
                          {c.titulo ?? "Call sem título"}
                        </Link>
                      </td>
                      <td className="text-caption px-4 py-3 text-text-tertiary">
                        {formatarData(c.realizada_em)}
                      </td>
                      <td className="px-4 py-3">
                        <Badge variant="secondary">{c.match_status}</Badge>
                      </td>
                      <td className="px-4 py-3">
                        <Link
                          href={`/calls/${c.id}`}
                          className="text-caption font-medium text-teal transition-colors hover:text-teal-hover"
                        >
                          Confirmar match →
                        </Link>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </TabsContent>

        <TabsContent value="analisadas" className="mt-4">
          <div className="overflow-hidden rounded-lg border border-border bg-surface shadow-sm">
            <table className="w-full text-sm">
              <thead>
                <tr className="border-b border-border bg-surface-muted">
                  <th className="text-label px-4 py-3 text-left text-text-tertiary">Call</th>
                  <th className="text-label px-4 py-3 text-left text-text-tertiary">Lead</th>
                  <th className="text-label px-4 py-3 text-left text-text-tertiary">Data</th>
                  <th className="text-label px-4 py-3 text-left text-text-tertiary">
                    Classificação
                  </th>
                  <th className="text-label px-4 py-3 text-left text-text-tertiary">Score</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-border">
                {(analisadas ?? []).length === 0 ? (
                  <tr>
                    <td colSpan={5} className="text-caption px-4 py-10 text-center text-text-muted">
                      Nenhuma call analisada
                    </td>
                  </tr>
                ) : (
                  (analisadas ?? []).map((c) => {
                    const lead = Array.isArray(c.lead) ? c.lead[0] : c.lead;
                    const analise = Array.isArray(c.analise) ? c.analise[0] : c.analise;
                    return (
                      <tr key={c.id} className="hover:bg-surface-muted">
                        <td className="px-4 py-3">
                          <Link
                            href={`/calls/${c.id}`}
                            className="font-medium text-text-primary hover:text-teal"
                          >
                            {c.titulo ?? "Call sem título"}
                          </Link>
                        </td>
                        <td className="text-caption px-4 py-3 text-text-tertiary">
                          {lead?.nome ?? lead?.telefone ?? "—"}
                        </td>
                        <td className="text-caption px-4 py-3 text-text-tertiary">
                          {formatarData(c.realizada_em)}
                        </td>
                        <td className="px-4 py-3">
                          <span
                            className={cn(
                              "text-caption font-medium capitalize",
                              classificacaoCor(analise?.classificacao ?? null),
                            )}
                          >
                            {analise?.classificacao ?? "—"}
                          </span>
                        </td>
                        <td className="px-4 py-3 text-sm font-semibold tabular-nums text-text-primary">
                          {analise?.score_geral ?? "—"}
                        </td>
                      </tr>
                    );
                  })
                )}
              </tbody>
            </table>
          </div>
        </TabsContent>
      </Tabs>
    </div>
  );
}
