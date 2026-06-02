#!/usr/bin/env tsx
// Reconstrói as análises da DEMO rodando o MESMO motor de produção uma vez.
//
// Em produção quem dispara a análise é o cron (analise-whatsapp / analise-calls).
// Na demo o cron fica zerado de propósito, então este script roda os motores
// `analisarConversasPendentes` / `analisarCallsPendentes` manualmente sobre os
// dados seedados, congelando análises reais (score, diagnóstico, fases, tags).
//
// Uso: export $(grep -v '^#' .env.demo | xargs) && npm run demo:analises
import { createClient } from "@supabase/supabase-js";
import { config } from "dotenv";
import { analisarConversasPendentes } from "../lib/modules/analisador-whatsapp";
import { analisarCallsPendentes } from "../lib/modules/analisador-calls";

config({ path: ".env.demo" });

// Neutraliza o Resend no rebuild: alertas de score baixo não devem enviar email
// a endereços fictícios da demo. notificarScoreBaixo já trata a falha em silêncio
// (try/catch interno, nunca lança), então remover a key só impede o envio real.
delete process.env.RESEND_API_KEY;

function exigir(nome: string): string {
  const valor = process.env[nome];
  if (!valor) {
    console.error(`Erro: variável de ambiente ${nome} é obrigatória (.env.demo).`);
    process.exit(1);
  }
  return valor;
}

async function main() {
  const url = exigir("NEXT_PUBLIC_SUPABASE_URL");
  const serviceKey = exigir("SUPABASE_SERVICE_ROLE_KEY");
  // A análise é gerada pela API Anthropic — a key precisa ser REAL, não placeholder.
  exigir("ANTHROPIC_API_KEY");

  const supabase = createClient(url, serviceKey, {
    auth: { autoRefreshToken: false, persistSession: false },
  });

  // --- WhatsApp: drena a fila em lotes (BATCH_SIZE=10 no motor) ---
  console.log("\n=== Análise de conversas WhatsApp ===");
  let waTotal = 0;
  let waErros = 0;
  for (;;) {
    const r = await analisarConversasPendentes(supabase);
    waTotal += r.analisadas;
    waErros += r.erros;
    console.log(`  lote: analisadas=${r.analisadas} erros=${r.erros}`);
    if (r.analisadas === 0) break;
  }
  console.log(`WhatsApp concluído: ${waTotal} analisadas, ${waErros} erros.`);

  // --- Calls: mesmo padrão ---
  console.log("\n=== Análise de calls ===");
  let callTotal = 0;
  let callErros = 0;
  for (;;) {
    const r = await analisarCallsPendentes(supabase);
    callTotal += r.analisadas;
    callErros += r.erros;
    console.log(`  lote: analisadas=${r.analisadas} erros=${r.erros}`);
    if (r.analisadas === 0) break;
  }
  console.log(`Calls concluído: ${callTotal} analisadas, ${callErros} erros.`);

  // --- Resumo de contagens (read-only) ---
  console.log("\n=== Contagens finais (banco demo) ===");
  const tabelas = [
    "leads",
    "conversas",
    "mensagens",
    "calls",
    "analises_whatsapp",
    "analises_calls",
  ];
  for (const t of tabelas) {
    const { count } = await supabase
      .schema("comercial")
      .from(t)
      .select("*", { count: "exact", head: true })
      .throwOnError();
    console.log(`  ${t}=${count}`);
  }
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
