#!/usr/bin/env tsx
import { createClient } from "@supabase/supabase-js";
import { config } from "dotenv";

config({ path: ".env.local" });

async function main() {
  const supabase = createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY!,
    { auth: { autoRefreshToken: false, persistSession: false } },
  );

  const fim = new Date();
  const inicio = new Date(fim.getTime() - 7 * 86_400_000);

  console.log("Testando get_dashboard via schema comercial...");
  const { data, error } = await supabase
    .schema("comercial")
    .rpc("get_dashboard", { p_inicio: inicio.toISOString(), p_fim: fim.toISOString() });

  if (error) {
    console.error("ERRO RPC:", JSON.stringify(error, null, 2));
  } else {
    console.log("SUCESSO:", JSON.stringify(data, null, 2));
  }

  console.log("\nTestando contagem de leads direta...");
  const { count, error: e2 } = await supabase
    .schema("comercial")
    .from("leads")
    .select("*", { count: "exact", head: true });

  if (e2) console.error("ERRO leads:", JSON.stringify(e2, null, 2));
  else console.log("Total de leads:", count);
}

main().catch(console.error);
