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

  const { data } = await supabase
    .schema("comercial")
    .from("rondas")
    .select("id, tipo, periodo_inicio, snapshot")
    .order("periodo_inicio", { ascending: false })
    .limit(2);

  for (const r of data ?? []) {
    console.log(`=== ${r.tipo} · ${r.periodo_inicio} · ${r.id}`);
    const snap = r.snapshot as Record<string, unknown>;
    console.log({
      score_medio: snap.score_medio,
      score_anterior: snap.score_anterior,
      delta_pct: snap.delta_pct,
      numero_ronda: snap.numero_ronda,
      historico_recente: snap.historico_recente,
    });
  }
}

main().catch(console.error);
