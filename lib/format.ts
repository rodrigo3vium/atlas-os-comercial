const MESES_CURTOS = [
  "Jan",
  "Fev",
  "Mar",
  "Abr",
  "Mai",
  "Jun",
  "Jul",
  "Ago",
  "Set",
  "Out",
  "Nov",
  "Dez",
];

function toDate(input: string | Date): Date {
  return input instanceof Date ? input : new Date(input);
}

export function formatDataHora(input: string | Date): string {
  const d = toDate(input);
  const dia = d.getDate();
  const mes = MESES_CURTOS[d.getMonth()];
  const hh = String(d.getHours()).padStart(2, "0");
  const mm = String(d.getMinutes()).padStart(2, "0");
  return `${dia} ${mes} · ${hh}:${mm}`;
}

export function formatDataLonga(input: string | Date): string {
  return new Intl.DateTimeFormat("pt-BR", {
    weekday: "long",
    day: "numeric",
    month: "long",
    year: "numeric",
  }).format(toDate(input));
}

export function formatDataCurta(input: string | Date): string {
  const d = toDate(input);
  return `${d.getDate()} ${MESES_CURTOS[d.getMonth()]}`;
}

export function formatRelativo(input: string | Date, agora: Date = new Date()): string {
  const d = toDate(input);
  const diffMs = agora.getTime() - d.getTime();
  const diffMin = Math.floor(diffMs / 60_000);
  const diffHr = Math.floor(diffMs / 3_600_000);
  const diffDia = Math.floor(diffMs / 86_400_000);

  if (diffMin < 1) return "agora mesmo";
  if (diffMin < 60) return `há ${diffMin} min`;
  if (diffHr < 24) return `há ${diffHr}h`;
  if (diffDia === 1) {
    const hh = String(d.getHours()).padStart(2, "0");
    const mm = String(d.getMinutes()).padStart(2, "0");
    return `ontem às ${hh}h${mm}`;
  }
  if (diffDia < 7) return `há ${diffDia} dias`;
  return formatDataCurta(d);
}

export function diasEntre(de: string | Date, ate: string | Date): number {
  const diff = toDate(ate).getTime() - toDate(de).getTime();
  return Math.floor(diff / 86_400_000);
}

export const FASES_LABEL: Record<string, string> = {
  preparacao: "Preparação",
  abertura: "Abertura",
  diagnostico: "Diagnóstico",
  apresentacao_clinica: "Apresentação clínica",
  apresentacao_investimento: "Apresentação investimento",
  fechamento: "Fechamento",
  objecoes: "Objeções",
  sabotadores: "Sabotadores",
};

export type CorScore = { text: string; bg: string };

export function corPorScore(score: number | null): CorScore {
  if (score === null) return { text: "text-text-muted", bg: "bg-surface-muted" };
  if (score >= 80) return { text: "text-status-success", bg: "bg-status-success" };
  if (score >= 60) return { text: "text-teal", bg: "bg-teal" };
  if (score >= 40) return { text: "text-status-warning", bg: "bg-status-warning" };
  return { text: "text-status-danger", bg: "bg-status-danger" };
}

export function formatarTag(tag: string): string {
  const trocado = tag.replace(/_/g, " ");
  return trocado.charAt(0).toUpperCase() + trocado.slice(1);
}
