import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { analisarCallsPendentes } from "@/lib/modules/analisador-calls";
import { getTestClient, limparDb } from "./setup";

// Notas A=7,B=7,C=7,D=7,E=7,F=7,G=9 → score = (70+105+105+105+140+105+90)/10 = 72 → "bom"
const MOCK_ANALISE_CALL = {
  etapa: "fechamento",
  leitura: "Call competente mas com oportunidades de melhoria no fechamento.",
  flags_positivas: ["rapport_genuino", "diagnostico_em_camadas"],
  sinais_vermelhos: ["preco_sem_ancoragem"],
  blocos: [
    { id: "A", nota_0_10: 7, analise: "Abertura com autoridade razoável.", citacoes: [] },
    { id: "B", nota_0_10: 7, analise: "Diagnóstico em camadas parcialmente feito.", citacoes: [] },
    {
      id: "C",
      nota_0_10: 7,
      analise: "Apresentou resultado, mas citou procedimento.",
      citacoes: [],
    },
    { id: "D", nota_0_10: 7, analise: "Validou antes do preço.", citacoes: [] },
    { id: "E", nota_0_10: 7, analise: "Oferta feita sem silêncio.", citacoes: [] },
    { id: "F", nota_0_10: 7, analise: "Contornou objeção parcialmente.", citacoes: [] },
    { id: "G", nota_0_10: 9, analise: "Entrada de 30% concluída.", citacoes: [] },
  ],
  rapport_0_10: 7,
  recomendacoes: [
    {
      gatilho: "Após apresentar o preço",
      racional: "Silêncio após CTA aumenta taxa de fechamento.",
      script: "Então, vamos agendar para a semana que vem?",
      bloco_ref: "E",
    },
  ],
};

vi.mock("openai", () => ({
  default: vi.fn().mockImplementation(() => ({
    chat: {
      completions: {
        create: vi.fn().mockResolvedValue({
          choices: [{ message: { content: JSON.stringify(MOCK_ANALISE_CALL) } }],
          usage: { prompt_tokens: 1000, completion_tokens: 200 },
        }),
      },
    },
  })),
}));

// Isola o matcher para não depender do RPC de fuzzy
vi.mock("@/lib/modules/matcher-call-lead", () => ({
  matchCallLead: vi.fn().mockResolvedValue(undefined),
  classificarCandidatos: vi.fn(),
}));

const supabase = getTestClient();

beforeEach(async () => {
  await limparDb(supabase);
});

afterEach(async () => {
  await limparDb(supabase);
  vi.clearAllMocks();
});

async function criarCallComTranscricao(overrides: Record<string, unknown> = {}) {
  const { data: call } = await supabase
    .schema("comercial")
    .from("calls")
    .insert({
      titulo: "Call Fechamento — João Silva",
      transcricao: "Olá João, vamos falar sobre o investimento no procedimento...",
      transcricao_origem: "plaud",
      duracao_segundos: 1800,
      match_status: "pendente",
      ...overrides,
    })
    .select("id")
    .single()
    .throwOnError();

  return call!;
}

describe("analisarCallsPendentes", () => {
  it("cria analise_call para call com transcricao não analisada", async () => {
    await criarCallComTranscricao();

    const resultado = await analisarCallsPendentes(supabase);

    expect(resultado.analisadas).toBe(1);
    expect(resultado.erros).toBe(0);

    const { data: analises } = await supabase
      .schema("comercial")
      .from("analises_calls")
      .select("*")
      .throwOnError();

    expect(analises).toHaveLength(1);
    expect(analises![0].classificacao).toBe("bom");
    expect(analises![0].score_geral).toBe(72);
    expect(analises![0].modelo).toBe("gpt-4o");
    expect(analises![0].prompt_versao).toBe("v3-estruturado");
  });

  it("marca analisada_em na call após análise", async () => {
    const call = await criarCallComTranscricao();

    await analisarCallsPendentes(supabase);

    const { data } = await supabase
      .schema("comercial")
      .from("calls")
      .select("analisada_em")
      .eq("id", call.id)
      .single()
      .throwOnError();

    expect(data!.analisada_em).not.toBeNull();
  });

  it("não re-analisa call já analisada", async () => {
    await criarCallComTranscricao({ analisada_em: new Date().toISOString() });

    const resultado = await analisarCallsPendentes(supabase);

    expect(resultado.analisadas).toBe(0);

    const { data: analises } = await supabase
      .schema("comercial")
      .from("analises_calls")
      .select("id")
      .throwOnError();

    expect(analises).toHaveLength(0);
  });

  it("não analisa call sem transcricao", async () => {
    await supabase
      .schema("comercial")
      .from("calls")
      .insert({
        titulo: "Call sem transcrição",
        match_status: "pendente",
      })
      .throwOnError();

    const resultado = await analisarCallsPendentes(supabase);

    expect(resultado.analisadas).toBe(0);
  });

  it("chama matchCallLead em paralelo com a análise", async () => {
    const { matchCallLead } = await import("@/lib/modules/matcher-call-lead");
    const call = await criarCallComTranscricao();

    await analisarCallsPendentes(supabase);

    expect(matchCallLead).toHaveBeenCalledWith(call.id, supabase);
  });
});
