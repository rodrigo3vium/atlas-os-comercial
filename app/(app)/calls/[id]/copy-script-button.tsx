"use client";

import { useState } from "react";
import { cn } from "@/lib/utils";

export function CopyScriptButton({ texto }: { texto: string }) {
  const [copiado, setCopiado] = useState(false);

  async function copiar() {
    try {
      await navigator.clipboard.writeText(texto);
      setCopiado(true);
      setTimeout(() => setCopiado(false), 2000);
    } catch {
      // clipboard indisponível (contexto inseguro) — ignora silenciosamente
    }
  }

  return (
    <button
      type="button"
      onClick={copiar}
      className={cn(
        "text-label rounded-md px-2.5 py-1 font-medium transition-colors",
        copiado
          ? "bg-status-success-soft text-status-success"
          : "bg-teal-soft text-teal-soft-text hover:bg-teal hover:text-primary-foreground",
      )}
    >
      {copiado ? "Copiado!" : "Copiar"}
    </button>
  );
}
