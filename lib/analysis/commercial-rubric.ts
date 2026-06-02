// Régua de avaliação comercial (Método Vitor Balduino Oliveira) — fonte única de
// pesos, nomes, tipos, cálculo de score e tokens de cor. Serve as DUAS fatias:
//   - FECHAMENTO (calls):    analisador-calls.ts + app/(app)/calls/[id]/page.tsx
//   - DIAGNÓSTICO (whatsapp): analisador-whatsapp.ts + app/(app)/whatsapp/[id]/page.tsx
//
// Regra de ouro: o MODELO devolve apenas nota_0_10 por bloco + texto. O score
// global é calculado AQUI, no código (ponderado), nunca pelo modelo.

export const RUBRIC_VERSION = "fechamento-v1";
export const RUBRIC_VERSION_DIAGNOSTICO = "diagnostico-v1";

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

// Régua de DIAGNÓSTICO (whatsapp). Soma dos pesos = 100. NÃO tem bônus de
// crenças/rapport — isso é exclusivo da etapa de fechamento (calls).
export const PESOS_DIAGNOSTICO: Record<BlocoId, number> = {
  A: 10,
  B: 20,
  C: 15,
  D: 10,
  E: 25,
  F: 15,
  G: 5,
};

export const NOMES_DIAGNOSTICO: Record<BlocoId, string> = {
  A: "Abertura e previsibilidade",
  B: "Diagnóstico do caso",
  C: "Construção de autoridade",
  D: "Explicação do processo",
  E: "Agendamento + Pagamento",
  F: "Contorno de objeção",
  G: "Antecipação de comparecimento",
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

// Vocabulário controlado da régua de DIAGNÓSTICO (whatsapp). Slugs distintos dos
// de fechamento — podem coexistir no mesmo FLAG_LABELS sem colidir.
export const FLAGS_POSITIVAS_DIAGNOSTICO = [
  "abertura_com_autoridade",
  "diagnostico_completo",
  "construcao_de_autoridade",
  "prova_social",
  "eliminacao_de_risco",
  "explicou_consulta",
  "agendamento_realizado",
  "pagamento_da_consulta_confirmado",
  "contorno_de_objecao",
  "follow_up_ativo",
  "rapport_genuino",
  "qualificacao_financeira",
  "ancoragem_de_valor",
  "identificou_decisor",
] as const;

export const FLAGS_NEGATIVAS_DIAGNOSTICO = [
  "sem_diagnostico",
  "preco_cru",
  "sem_ancoragem",
  "agendou_sem_pagamento",
  "objecao_sem_contorno",
  "sem_follow_up",
  "lead_sem_qualificacao",
  "abandono_da_conversa",
  "resposta_robotica",
  "resposta_lenta",
  "apresentou_procedimento_tecnico",
  "nao_identificou_decisor",
] as const;

// Rótulos legíveis para os slugs do vocabulário controlado (UI). Mapa único para
// as duas réguas — slugs de fechamento e diagnóstico não colidem.
export const FLAG_LABELS: Record<string, string> = {
  // --- fechamento (calls) ---
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
  // --- diagnóstico (whatsapp) ---
  // positivas
  abertura_com_autoridade: "Abertura com autoridade",
  diagnostico_completo: "Diagnóstico completo",
  construcao_de_autoridade: "Construção de autoridade",
  prova_social: "Prova social",
  eliminacao_de_risco: "Eliminação de risco",
  explicou_consulta: "Explicou a consulta",
  agendamento_realizado: "Agendamento realizado",
  pagamento_da_consulta_confirmado: "Pagamento da consulta confirmado",
  contorno_de_objecao: "Contorno de objeção",
  follow_up_ativo: "Follow-up ativo",
  qualificacao_financeira: "Qualificação financeira",
  identificou_decisor: "Identificou o decisor",
  // negativas
  sem_diagnostico: "Sem diagnóstico",
  preco_cru: "Preço cru (sem contexto)",
  sem_ancoragem: "Sem ancoragem de valor",
  agendou_sem_pagamento: "Agendou sem cobrar consulta",
  objecao_sem_contorno: "Objeção sem contorno",
  sem_follow_up: "Sem follow-up",
  lead_sem_qualificacao: "Lead sem qualificação",
  abandono_da_conversa: "Abandono da conversa",
  resposta_robotica: "Resposta robótica",
  resposta_lenta: "Resposta lenta",
  apresentou_procedimento_tecnico: "Apresentou procedimento técnico",
  nao_identificou_decisor: "Não identificou o decisor",
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

// O QUE O MODELO RETORNA na etapa de DIAGNÓSTICO (whatsapp). Sem peso, sem
// score, sem rapport — mas COM os campos de negócio que o WhatsApp usa downstream
// (status do lead e detecção de origem).
export type WhatsappAnalysisModel = {
  leitura: string;
  flags_positivas: string[];
  flags_negativas: string[]; // = sinais vermelhos (vermelho no render)
  blocos: BlocoNota[];
  recomendacoes: Recomendacao[];
  lead_status: string;
  origem_detectada: string | null;
  origem_confidence: number | null;
};

// O QUE FICA PERSISTIDO em analises_whatsapp.fases (modelo + campos calculados).
export type WhatsappAnalysisResult = WhatsappAnalysisModel & {
  rubric_version: string;
  score_global: number;
};

// ---------------------------------------------------------------------------
// Cálculo
// ---------------------------------------------------------------------------

// Score global ponderado. Recebe o mapa de pesos da régua aplicável (fechamento
// ou diagnóstico). Default = PESOS_FECHAMENTO por retrocompatibilidade.
export function computeScoreGlobal(
  blocos: BlocoNota[],
  pesos: Record<BlocoId, number> = PESOS_FECHAMENTO,
): number {
  const soma = blocos.reduce((s, b) => {
    const peso = pesos[b.id];
    if (peso === undefined) return s; // ignora ids fora da régua
    const nota = Math.max(0, Math.min(10, b.nota_0_10 ?? 0));
    return s + (nota * peso) / 10;
  }, 0);
  return Math.round(soma); // máx teórico = soma dos pesos = 100
}

// Serializa as recomendações estruturadas em texto curto para preencher a coluna
// legada `acao_recomendada` (consumida por dashboard/rondas/listas). Compartilhado
// pelos dois analyzers (calls e whatsapp).
export function recomendacoesParaTexto(recomendacoes: Recomendacao[]): string | null {
  if (!recomendacoes?.length) return null;
  return recomendacoes.map((r, i) => `${i + 1}) [${r.gatilho}] ${r.script}`).join("\n");
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

// Type guard: distingue o blob novo (estruturado, com array `blocos`) do formato
// antigo de `fases`. Genérico — serve a calls e whatsapp (a página faz o cast
// para o tipo de resultado concreto).
export function isStructuredResult(
  fases: unknown,
): fases is { blocos: BlocoNota[]; score_global: number } {
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
