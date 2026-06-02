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

  const { error } = await supabase.auth.admin.updateUserById(
    "97139d37-2f23-4ee4-aad4-d08a7251bb1e",
    { password: "Atlas@2026" },
  );

  if (error) {
    console.error("Erro:", error.message);
    process.exit(1);
  }
  console.log("✓ Senha definida com sucesso.");
  console.log("  Email: rodrigo@benitesalbuquerque.com.br");
  console.log("  Senha: Atlas@2026");
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
