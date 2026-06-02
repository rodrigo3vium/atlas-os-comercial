import { createServiceClient } from "@/lib/supabase/server";
import { ConfigForm } from "./config-form";
import { EvolutionInstancesPanel } from "./evolution-instances-panel";
import { EmailTesteButton } from "./email-teste-button";

export default async function ConfiguracoesPage() {
  const supabase = await createServiceClient();

  const [{ data: config }, { data: instances }] = await Promise.all([
    supabase
      .schema("comercial")
      .from("configuracoes")
      .select(
        "nome_clinica, destinatarios_whatsapp, destinatarios_calls, threshold_score_baixo, threshold_alerta_imediato_whatsapp, janela_analise_mensagens",
      )
      .eq("id", 1)
      .single()
      .throwOnError(),
    supabase
      .schema("comercial")
      .from("evolution_instances")
      .select("id, apelido, evolution_url, evolution_api_key, instance_name, webhook_secret, ativa")
      .order("created_at", { ascending: true }),
  ]);

  return (
    <div className="max-w-2xl space-y-6">
      <div>
        <h1 className="text-h1 text-text-primary">Configurações</h1>
        <p className="mt-1 text-sm text-text-secondary">
          Parâmetros gerais, destinatários e instâncias Evolution
        </p>
      </div>

      <section className="space-y-4 rounded-lg border border-border bg-surface p-6 shadow-sm">
        <h2 className="text-h3 text-text-primary">Parâmetros gerais</h2>
        <ConfigForm config={config!} />
      </section>

      <section className="space-y-4 rounded-lg border border-border bg-surface p-6 shadow-sm">
        <h2 className="text-h3 text-text-primary">Instâncias Evolution API</h2>
        <EvolutionInstancesPanel instances={instances ?? []} />
      </section>

      <section className="space-y-3 rounded-lg border border-border bg-surface p-6 shadow-sm">
        <h2 className="text-h3 text-text-primary">Testes</h2>
        <p className="text-caption text-text-muted">
          Envia um email de teste para todos os destinatários configurados.
        </p>
        <EmailTesteButton />
      </section>
    </div>
  );
}
