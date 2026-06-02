"use client";

import { useTransition } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import { cn } from "@/lib/utils";

const PERIODOS = [
  { label: "7 dias", value: "7" },
  { label: "30 dias", value: "30" },
  { label: "90 dias", value: "90" },
] as const;

export function PeriodoSelector() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const [pending, startTransition] = useTransition();
  const atual = searchParams.get("dias") ?? "7";

  function selecionar(dias: string) {
    if (dias === atual) return;
    const params = new URLSearchParams(searchParams.toString());
    params.set("dias", dias);
    startTransition(() => router.push(`/dashboard?${params.toString()}`));
  }

  return (
    <div
      className={cn(
        "inline-flex items-center gap-1 rounded-md border border-border bg-surface-muted p-1 transition-opacity",
        pending && "opacity-60",
      )}
      aria-busy={pending}
    >
      {PERIODOS.map((p) => (
        <button
          key={p.value}
          onClick={() => selecionar(p.value)}
          disabled={pending}
          className={cn(
            "text-caption rounded-sm px-3 py-1.5 font-medium transition-colors disabled:cursor-wait",
            atual === p.value
              ? "bg-surface text-text-primary shadow-sm"
              : "text-text-tertiary hover:text-text-primary",
          )}
        >
          {p.label}
        </button>
      ))}
    </div>
  );
}
