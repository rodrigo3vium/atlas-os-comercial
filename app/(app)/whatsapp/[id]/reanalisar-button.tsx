"use client";

import { useState, useTransition } from "react";
import { Button } from "@/components/ui/button";
import { useRouter } from "next/navigation";

export function ReanalisarButton({ conversaId }: { conversaId: string }) {
  const [fetching, setFetching] = useState(false);
  const [pending, startTransition] = useTransition();
  const router = useRouter();
  const loading = fetching || pending;

  async function reanalisar() {
    setFetching(true);
    try {
      await fetch(`/api/conversas/${conversaId}/reanalisar`, { method: "POST" });
    } finally {
      setFetching(false);
    }
    startTransition(() => router.refresh());
  }

  return (
    <Button variant="outline" size="sm" onClick={reanalisar} disabled={loading} className="text-xs">
      {loading ? "Analisando…" : "Re-analisar"}
    </Button>
  );
}
