-- Adiciona a coluna estruturada `fases` em analises_whatsapp, espelhando
-- analises_calls.fases. A análise de WhatsApp passa a guardar o blob estruturado
-- (blocos A–G, leitura, flags, recomendações) e o score recalculado no código.
--
-- Colunas legadas (score, tags_*, resumo, diagnostico, acao_recomendada,
-- origem_*, prompt_versao) permanecem — são consumidas por dashboard/listas e
-- continuam sendo preenchidas pelo analyzer a partir do blob estruturado.

ALTER TABLE comercial.analises_whatsapp
  ADD COLUMN IF NOT EXISTS fases jsonb NOT NULL DEFAULT '{}';
