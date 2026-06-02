#!/usr/bin/env tsx
import { createClient } from "@supabase/supabase-js";
import { config } from "dotenv";
import { gerarRonda } from "../lib/modules/gerador-ronda";

config({ path: ".env.local" });

async function main() {
  const supabase = createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY!,
    { auth: { autoRefreshToken: false, persistSession: false } },
  );

  const agora = new Date();
  const diaSemana = agora.getDay();
  const segundaAtual = new Date(agora);
  segundaAtual.setDate(agora.getDate() - ((diaSemana + 6) % 7));
  segundaAtual.setHours(0, 0, 0, 0);

  const semanas: Array<{ inicio: Date; fim: Date }> = [];
  for (let i = 5; i >= 1; i--) {
    const inicio = new Date(segundaAtual);
    inicio.setDate(segundaAtual.getDate() - 7 * i);
    const fim = new Date(inicio);
    fim.setDate(inicio.getDate() + 7);
    fim.setMilliseconds(-1);
    semanas.push({ inicio, fim });
  }

  console.log(`Gerando ${semanas.length} rondas anteriores para WhatsApp + Calls\n`);
  for (const { inicio, fim } of semanas) {
    const periodo = `${inicio.toISOString().slice(0, 10)} → ${fim.toISOString().slice(0, 10)}`;
    for (const tipo of ["whatsapp", "calls"] as const) {
      const res = await gerarRonda(tipo, inicio, fim, supabase);
      console.log(`[${tipo}] ${periodo} → ${res.rondaId} ${res.vazia ? "(vazia)" : ""}`);
    }
  }

  console.log("\nFeito.");
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
