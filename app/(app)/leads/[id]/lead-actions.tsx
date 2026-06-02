"use client";

import { useState, useTransition } from "react";
import { useRouter } from "next/navigation";
import { Button } from "@/components/ui/button";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";

const STATUS_OPTS = [
  { value: "novo", label: "Novo" },
  { value: "em_atendimento", label: "Em atendimento" },
  { value: "sem_resposta", label: "Sem resposta" },
  { value: "agendou", label: "Agendou" },
  { value: "compareceu", label: "Compareceu" },
  { value: "perdido", label: "Perdido" },
  { value: "fechou", label: "Fechou" },
];

const ORIGEM_OPTS = [
  { value: "instagram", label: "Instagram" },
  { value: "facebook", label: "Facebook" },
  { value: "google", label: "Google" },
  { value: "indicacao", label: "Indicação" },
  { value: "organico", label: "Orgânico" },
  { value: "whatsapp_ativo", label: "WhatsApp ativo" },
  { value: "outro", label: "Outro" },
  { value: "desconhecido", label: "Desconhecido" },
];

type Props = {
  leadId: string;
  statusAtual: string;
  origemAtual: string | null;
};

export function LeadActions({ leadId, statusAtual, origemAtual }: Props) {
  const [novoStatus, setNovoStatus] = useState(statusAtual);
  const [novaOrigem, setNovaOrigem] = useState(origemAtual ?? "");
  const [fetching, setFetching] = useState(false);
  const [pending, startTransition] = useTransition();
  const router = useRouter();
  const loading = fetching || pending;

  async function salvarStatus() {
    if (novoStatus === statusAtual) return;
    setFetching(true);
    try {
      await fetch(`/api/leads/${leadId}/status`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ status: novoStatus }),
      });
    } finally {
      setFetching(false);
    }
    startTransition(() => router.refresh());
  }

  async function salvarOrigem() {
    if (!novaOrigem || novaOrigem === origemAtual) return;
    setFetching(true);
    try {
      await fetch(`/api/leads/${leadId}/classificar`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ origem: novaOrigem }),
      });
    } finally {
      setFetching(false);
    }
    startTransition(() => router.refresh());
  }

  return (
    <div className="space-y-3 rounded-lg border border-border bg-surface p-4 shadow-sm">
      <h2 className="text-h3 text-text-primary">Editar</h2>

      <div className="space-y-1.5">
        <label className="text-label text-text-tertiary">Status</label>
        <div className="flex gap-2">
          <Select value={novoStatus} onValueChange={setNovoStatus}>
            <SelectTrigger className="h-8 flex-1 text-xs">
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              {STATUS_OPTS.map((o) => (
                <SelectItem key={o.value} value={o.value} className="text-xs">
                  {o.label}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
          <Button
            size="sm"
            onClick={salvarStatus}
            disabled={loading}
            className="h-8 bg-teal px-3 text-xs text-white hover:bg-teal-hover"
          >
            Salvar
          </Button>
        </div>
      </div>

      <div className="space-y-1.5">
        <label className="text-label text-text-tertiary">Origem (manual)</label>
        <div className="flex gap-2">
          <Select value={novaOrigem} onValueChange={setNovaOrigem}>
            <SelectTrigger className="h-8 flex-1 text-xs">
              <SelectValue placeholder="Selecionar…" />
            </SelectTrigger>
            <SelectContent>
              {ORIGEM_OPTS.map((o) => (
                <SelectItem key={o.value} value={o.value} className="text-xs">
                  {o.label}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
          <Button
            size="sm"
            onClick={salvarOrigem}
            disabled={loading}
            className="h-8 bg-teal px-3 text-xs text-white hover:bg-teal-hover"
          >
            Salvar
          </Button>
        </div>
      </div>
    </div>
  );
}
