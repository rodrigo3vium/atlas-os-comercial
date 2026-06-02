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

  const { error: insertError } = await supabase
    .schema("comercial")
    .from("autorizados")
    .insert({ user_id: "97139d37-2f23-4ee4-aad4-d08a7251bb1e", role: "dono" });

  if (insertError) {
    console.error("Insert error:", insertError.message);
    process.exit(1);
  }
  console.log("✓ Inserido em comercial.autorizados como dono");

  const { data, error } = await supabase.auth.admin.generateLink({
    type: "recovery",
    email: "rodrigo@benitesalbuquerque.com.br",
    options: { redirectTo: "http://localhost:3001/auth/definir-senha" },
  });

  if (error || !data?.properties?.action_link) {
    console.error("Link error:", error?.message);
    process.exit(1);
  }
  console.log("\nLink de acesso:\n" + data.properties.action_link);
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
