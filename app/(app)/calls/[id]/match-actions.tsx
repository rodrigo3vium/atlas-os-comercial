"use client";

import { useState, useTransition } from "react";
import { useRouter } from "next/navigation";
import { Button } from "@/components/ui/button";

type Sugestao = {
  lead_id: string;
  nome: string;
  telefone: string;
  confidence: number;
};

type Props = {
  callId: string;
  matchStatus: string;
  leadAtual: { id: string; nome: string; telefone: string } | null;
  sugestoes: Sugestao[];
};

export function MatchActions({ callId, matchStatus, sugestoes }: Props) {
  const [fetching, setFetching] = useState(false);
  const [pending, startTransition] = useTransition();
  const router = useRouter();
  const loading = fetching || pending;

  const podeConfirmar = ["pendente", "sugerido"].includes(matchStatus);
  const podeMarcarsemLead = matchStatus !== "sem_lead";

  async function executar(acao: string, lead_id?: string) {
    setFetching(true);
    try {
      await fetch(`/api/calls/${callId}/match`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ acao, lead_id }),
      });
    } finally {
      setFetching(false);
    }
    startTransition(() => router.refresh());
  }

  if (!podeConfirmar && !podeMarcarsemLead) return null;

  return (
    <div className="space-y-2">
      {sugestoes.length > 0 && (
        <div className="space-y-1.5">
          <p className="text-label text-text-tertiary">Sugestões IA</p>
          {sugestoes.map((s) => (
            <div
              key={s.lead_id}
              className="flex items-center justify-between rounded-md bg-surface-muted px-2.5 py-2"
            >
              <div className="min-w-0">
                <p className="text-body-strong truncate text-text-primary">{s.nome}</p>
                <p className="text-caption text-text-muted">
                  {s.telefone} · {Math.round(s.confidence * 100)}%
                </p>
              </div>
              <Button
                size="sm"
                className="ml-2 h-6 shrink-0 bg-teal px-2 text-[10px] text-white hover:bg-teal-hover"
                onClick={() => executar("confirmar", s.lead_id)}
                disabled={loading}
              >
                Confirmar
              </Button>
            </div>
          ))}
        </div>
      )}

      {podeMarcarsemLead && (
        <Button
          variant="ghost"
          size="sm"
          className="text-caption w-full text-text-muted hover:bg-surface-muted hover:text-text-secondary"
          onClick={() => executar("sem_lead")}
          disabled={loading}
        >
          Marcar como sem lead
        </Button>
      )}
    </div>
  );
}
