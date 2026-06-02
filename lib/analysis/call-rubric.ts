// Régua de avaliação de calls (Método Vitor Balduino Oliveira) — fonte única de
// pesos, nomes, tipos, cálculo de score e tokens de cor. Importado pelo analyzer
// (lib/modules/analisador-calls.ts) e pela página (app/(app)/calls/[id]/page.tsx).
//
// Regra de ouro: o MODELO devolve apenas nota_0_10 por bloco + texto. O score
// global é calculado AQUI, no código (ponderado), nunca pelo modelo.

export const RUBRIC_VERSION = "fechamento-v1";

export type BlocoId = "A" | "B" | "C" | "D" | "E" | "F" | "G";

// Régua de FECHAMENTO (calls). Soma dos pesos = 100. O bônus "crenças do closer"
// (rapport_0_10) fica FORA da soma — é diagnóstico extra, não pontua o global.
export const PESOS_FECHAMENTO: Record<BlocoId, number> = {
  A: 10,
  B: 15,
  C: 15,
  D: 15,
  E: 20,
  F: 15,
  G: 10,
};

export const NOMES_FECHAMENTO: Record<BlocoId, string> = {
  A: "Previsibilidade e abertura",
  B: "Descoberta de dor",
  C: "Apresentação de resultado",
  D: "Validação + Calibração",
  E: "Oferta de decisão",
  F: "Contorno de objeção",
  G: "Pagamento da entrada",
};

export const ORDEM_BLOCOS: BlocoId[] = ["A", "B", "C", "D", "E", "F", "G"];

// Vocabulário controlado — o modelo só pode escolher destes slugs.
export const FLAGS_POSITIVAS = [
  "rapport_genuino",
  "diagnostico_em_camadas",
  "apresentou_resultado_nao_procedimento",
  "validou_antes_do_preco",
  "ancoragem_de_valor",
  "cta_direto_com_silencio",
  "contornou_objecao",
  "entrada_30_completa",
] as const;

export const SINAIS_VERMELHOS = [
  "orcamento_tecnico",
  "durabilidade_antecipada",
  "vou_pensar_sem_retomada",
  "reduziu_preco_sem_provocacao",
  "pediu_sinal_simbolico",
  "aceitou_sinal_do_paciente",
  "prejulgou_capacidade_financeira",
  "preco_sem_ancoragem",
] as const;

// Rótulos legíveis para os slugs do vocabulário controlado (UI).
export const FLAG_LABELS: Record<string, string> = {
  // positivas
  rapport_genuino: "Rapport genuíno",
  diagnostico_em_camadas: "Diagnóstico em camadas",
  apresentou_resultado_nao_procedimento: "Vendeu resultado, não procedimento",
  validou_antes_do_preco: "Validou antes do preço",
  ancoragem_de_valor: "Ancoragem de valor",
  cta_direto_com_silencio: "CTA direto + silêncio",
  contornou_objecao: "Contornou objeção",
  entrada_30_completa: "Entrada de 30% completa",
  // vermelhos
  orcamento_tecnico: "Orçamento técnico (ml/seringas)",
  durabilidade_antecipada: "Durabilidade antecipada",
  vou_pensar_sem_retomada: "“Vou pensar” sem retomada",
  reduziu_preco_sem_provocacao: "Reduziu preço sem ser provocado",
  pediu_sinal_simbolico: "Pediu sinal simbólico",
  aceitou_sinal_do_paciente: "Aceitou sinal sugerido pelo paciente",
  prejulgou_capacidade_financeira: "Pré-julgou capacidade financeira",
  preco_sem_ancoragem: "Preço sem ancoragem",
};

export function flagLabel(slug: string): string {
  return FLAG_LABELS[slug] ?? slug.replace(/_/g, " ");
}

// ---------------------------------------------------------------------------
// Tipos
// ---------------------------------------------------------------------------

export type Citacao = { ts?: string; speaker?: string; quote: string };

export type BlocoNota = {
  id: BlocoId;
  nota_0_10: number;
  analise: string;
  citacoes?: Citacao[];
};

export type Recomendacao = {
  gatilho: string;
  racional: string;
  script: string;
  bloco_ref?: BlocoId;
};

// O QUE O MODELO RETORNA (sem peso, sem score_global, sem nome de bloco).
export type CallAnalysisModel = {
  etapa: "diagnostico" | "sinal_marcacao" | "fechamento";
  leitura: string;
  flags_positivas: string[];
  sinais_vermelhos: string[];
  blocos: BlocoNota[];
  rapport_0_10?: number; // bônus "crenças do closer", fora da soma
  recomendacoes: Recomendacao[];
};

// O QUE FICA PERSISTIDO em analises_calls.fases (modelo + campos calculados).
export type CallAnalysisResult = CallAnalysisModel & {
  rubric_version: string;
  score_global: number;
};

// ---------------------------------------------------------------------------
// Cálculo
// ---------------------------------------------------------------------------

export function computeScoreGlobal(blocos: BlocoNota[]): number {
  const soma = blocos.reduce((s, b) => {
    const peso = PESOS_FECHAMENTO[b.id];
    if (peso === undefined) return s; // ignora ids fora da régua de fechamento
    const nota = Math.max(0, Math.min(10, b.nota_0_10 ?? 0));
    return s + (nota * peso) / 10;
  }, 0);
  return Math.round(soma); // máx teórico = soma dos pesos = 100
}

export type Tier = "elite" | "bom" | "regular" | "critico";
export type Classificacao = "excelente" | "bom" | "regular" | "insuficiente";

export type TierInfo = {
  tier: Tier;
  label: string;
  classificacao: Classificacao;
  cssVar: string; // para stroke do anel SVG
  badgeClass: string; // classes Tailwind literais (chip)
};

export function tierFromScore(score: number): TierInfo {
  if (score >= 85)
    return {
      tier: "elite",
      label: "Elite",
      classificacao: "excelente",
      cssVar: "var(--status-success)",
      badgeClass: "bg-status-success-soft text-status-success",
    };
  if (score >= 70)
    return {
      tier: "bom",
      label: "Bom",
      classificacao: "bom",
      cssVar: "var(--accent-teal)",
      badgeClass: "bg-teal-soft text-teal-soft-text",
    };
  if (score >= 50)
    return {
      tier: "regular",
      label: "Regular",
      classificacao: "regular",
      cssVar: "var(--status-warning)",
      badgeClass: "bg-status-warning-soft text-status-warning",
    };
  return {
    tier: "critico",
    label: "Crítico",
    classificacao: "insuficiente",
    cssVar: "var(--status-danger)",
    badgeClass: "bg-status-danger-soft text-status-danger",
  };
}

// Cor da barra/nota por bloco (0–10). Retorna classes Tailwind literais.
export function notaCor(n: number): { bar: string; text: string } {
  if (n >= 7) return { bar: "bg-status-success", text: "text-status-success" };
  if (n >= 4) return { bar: "bg-status-warning", text: "text-status-warning" };
  return { bar: "bg-status-danger", text: "text-status-danger" };
}

// Type guard: distingue o blob novo (estruturado) do formato antigo de `fases`.
export function isStructuredResult(fases: unknown): fases is CallAnalysisResult {
  return (
    typeof fases === "object" &&
    fases !== null &&
    Array.isArray((fases as { blocos?: unknown }).blocos)
  );
}

// Rótulos de etapa (badge).
export const ETAPA_LABELS: Record<CallAnalysisModel["etapa"], string> = {
  diagnostico: "Diagnóstico",
  sinal_marcacao: "Sinal / Marcação",
  fechamento: "Fechamento",
};
