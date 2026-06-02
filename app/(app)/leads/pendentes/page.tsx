import { createServiceClient } from "@/lib/supabase/server";
import { ClassificarCard } from "./classificar-card";

export default async function LeadsPendentesPage() {
  const supabase = await createServiceClient();

  const { data: leads } = await supabase
    .schema("comercial")
    .from("leads")
    .select(
      "id, nome, telefone, origem_confidence, origem_detectada:analises_whatsapp(origem_detectada, origem_confidence)",
    )
    .eq("origem_status", "pendente")
    .order("created_at", { ascending: true })
    .limit(50);

  // Para cada lead, buscar as primeiras mensagens
  const leadsComMensagens = await Promise.all(
    (leads ?? []).map(async (lead) => {
      const { data: conversas } = await supabase
        .schema("comercial")
        .from("conversas")
        .select("id")
        .eq("lead_id", lead.id)
        .limit(1);

      const conversaId = conversas?.[0]?.id;
      if (!conversaId) return { ...lead, primeirasMensagens: [] };

      const { data: mensagens } = await supabase
        .schema("comercial")
        .from("mensagens")
        .select("conteudo, remetente, enviada_em")
        .eq("conversa_id", conversaId)
        .order("enviada_em", { ascending: true })
        .limit(3);

      return { ...lead, primeirasMensagens: mensagens ?? [] };
    }),
  );

  const analisesPorLead = Object.fromEntries(
    (leads ?? []).map((l) => {
      const analises = Array.isArray(l.origem_detectada) ? l.origem_detectada : [];
      const melhor = analises.sort(
        (a: { origem_confidence: number }, b: { origem_confidence: number }) =>
          (b.origem_confidence ?? 0) - (a.origem_confidence ?? 0),
      )[0];
      return [l.id, melhor ?? null];
    }),
  );

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-h1 text-text-primary">Leads pendentes de classificação</h1>
        <p className="mt-1 text-sm text-text-secondary">
          {leadsComMensagens.length} leads aguardando classificação de origem
        </p>
      </div>

      {leadsComMensagens.length === 0 ? (
        <div className="rounded-lg border border-border bg-surface p-10 text-center shadow-sm">
          <p className="text-body-strong text-text-primary">Tudo classificado!</p>
          <p className="text-caption mt-1 text-text-muted">
            Nenhum lead pendente de classificação de origem.
          </p>
        </div>
      ) : (
        <div className="space-y-3">
          {leadsComMensagens.map((lead) => (
            <ClassificarCard
              key={lead.id}
              lead={{
                id: lead.id,
                nome: lead.nome,
                telefone: lead.telefone,
                primeirasMensagens: lead.primeirasMensagens,
                sugestaoIA: analisesPorLead[lead.id] ?? null,
              }}
            />
          ))}
        </div>
      )}
    </div>
  );
}
