-- =====================================================================
-- Seed DEMO — Atlas OS Comercial
-- Ambiente de demonstração comercial (cliente fictício).
-- Roda APÓS as migrations, num projeto Supabase dedicado à demo.
--   psql "$DATABASE_URL" -f supabase/seeds/_demo.sql
-- ou cole no SQL Editor do projeto demo.
--
-- Clínica fictícia: "Clínica Lumina — Odontologia & Harmonização"
-- (troque o nome no bloco configuracoes se quiser outro rótulo)
--
-- Volume: 24 leads em todos os status, 14 conversas WhatsApp com análise,
-- 16 calls (13 analisadas + 3 na fila), 2 rondas semanais, timeline de eventos.
-- Datas espalhadas nas últimas 12 semanas para popular série temporal e KPIs.
--
-- Idempotente: pode rodar mais de uma vez (ON CONFLICT / chaves naturais).
-- =====================================================================

-- ---------------------------------------------------------------------
-- Reset de dados de demonstração (idempotência real).
-- Limpa apenas tabelas de DADOS. Preserva: configuracoes (singleton,
-- atualizada via UPDATE abaixo) e autorizados (usuários de acesso).
-- Seguro para rodar quantas vezes quiser — sempre converge ao mesmo estado.
-- ---------------------------------------------------------------------
TRUNCATE
  comercial.lead_eventos,
  comercial.analises_calls,
  comercial.analises_whatsapp,
  comercial.mensagens,
  comercial.calls,
  comercial.conversas,
  comercial.leads,
  comercial.rondas,
  comercial.eventos_brutos,
  comercial.evolution_instances,
  comercial.auditoria
RESTART IDENTITY CASCADE;

-- ---------------------------------------------------------------------
-- 0. Configurações da clínica (singleton id=1)
-- ---------------------------------------------------------------------
UPDATE comercial.configuracoes
SET
  nome_clinica                       = 'Clínica Lumina — Odontologia & Harmonização',
  destinatarios_whatsapp             = ARRAY['gestao@clinicalumina.com.br', 'comercial@clinicalumina.com.br'],
  destinatarios_calls                = ARRAY['gestao@clinicalumina.com.br'],
  threshold_score_baixo              = 50,
  threshold_alerta_imediato_whatsapp = 30,
  janela_analise_mensagens           = 50,
  retencao_meses                     = 24,
  zapier_plaud_mapping               = '{
    "transcript_field": "transcript",
    "title_field": "title",
    "duration_field": "duration",
    "plaud_id_field": "id",
    "phone_field": "phone",
    "recorded_at_field": "created_at"
  }'::jsonb
WHERE id = 1;

-- ---------------------------------------------------------------------
-- 1. Instâncias Evolution (2 números: recepção e comercial)
-- ---------------------------------------------------------------------
INSERT INTO comercial.evolution_instances (apelido, evolution_url, evolution_api_key, instance_name, webhook_secret, ativa)
VALUES
  ('WhatsApp Recepção',  'https://evo-demo.benitesalbuquerque.com.br', 'demo-key-recepcao',  'lumina-recepcao',  'demo-secret-recepcao',  true),
  ('WhatsApp Comercial', 'https://evo-demo.benitesalbuquerque.com.br', 'demo-key-comercial', 'lumina-comercial', 'demo-secret-comercial', true)
ON CONFLICT DO NOTHING;

-- ---------------------------------------------------------------------
-- 2. Leads (24) — todos os status, origens variadas, datas espalhadas
--    Telefone (E.164) é chave natural usada nas referências abaixo.
-- ---------------------------------------------------------------------
INSERT INTO comercial.leads (nome, telefone, email, status, origem, origem_status, origem_confidence, observacoes, created_at, status_atualizado_em)
VALUES
  -- fechados (receita)
  ('Mariana Albuquerque', '+5567991110001', 'mariana.alb@gmail.com',      'fechou',         'instagram',      'detectado', 0.94, 'Protocolo superior + HOF. Fechou na consulta.',            now() - interval '70 days', now() - interval '58 days'),
  ('Renato Capalbo',      '+5567991110002', 'renato.capalbo@outlook.com', 'fechou',         'indicacao',      'detectado', 0.88, 'Implante unitário + enxerto. Indicação da Dra. Lima.',     now() - interval '52 days', now() - interval '41 days'),
  ('Patrícia Vasquez',    '+5567991110003', 'pativasquez@gmail.com',      'fechou',         'google',         'detectado', 0.91, 'Lentes de contato dental (16 dentes).',                    now() - interval '33 days', now() - interval '22 days'),
  ('Eduardo Tanaka',      '+5567991110004', NULL,                          'fechou',         'instagram',      'detectado', 0.85, 'Harmonização facial — full face.',                         now() - interval '14 days', now() - interval '6 days'),
  -- compareceram (consulta paga feita, decisão pendente)
  ('Camila Reis',         '+5567991110005', 'camila.reis@gmail.com',      'compareceu',     'facebook',       'detectado', 0.80, 'Compareceu, levou orçamento pra pensar com o marido.',     now() - interval '48 days', now() - interval '12 days'),
  ('Gustavo Pereira',     '+5567991110006', NULL,                          'compareceu',     'google',         'detectado', 0.83, 'Avaliou protocolo. Achou caro, pediu parcelamento.',       now() - interval '40 days', now() - interval '9 days'),
  ('Larissa Fontes',      '+5567991110007', 'lari.fontes@gmail.com',      'compareceu',     'instagram',      'detectado', 0.77, 'HOF — botox + preenchimento labial.',                      now() - interval '27 days', now() - interval '5 days'),
  ('Bianca Moreno',       '+5567991110008', NULL,                          'compareceu',     'organico',       'detectado', 0.72, 'Clareamento + limpeza. Ticket baixo.',                     now() - interval '19 days', now() - interval '3 days'),
  -- agendaram (consulta marcada)
  ('Felipe Andrade',      '+5567991110009', 'felipe.andrade@gmail.com',   'agendou',        'instagram',      'detectado', 0.86, 'Agendado p/ avaliação de implante. Confirmar véspera.',    now() - interval '11 days', now() - interval '2 days'),
  ('Juliana Castro',      '+5567991110010', NULL,                          'agendou',        'google',         'detectado', 0.81, 'Agendou HOF. Veio de anúncio de preenchimento.',           now() - interval '9 days',  now() - interval '2 days'),
  ('Marcos Vinícius',     '+5567991110011', 'marcosv@hotmail.com',        'agendou',        'indicacao',      'detectado', 0.79, 'Indicação de paciente. Quer protocolo inferior.',          now() - interval '7 days',  now() - interval '1 days'),
  ('Tatiane Lopes',       '+5567991110012', NULL,                          'agendou',        'facebook',       'detectado', 0.68, 'Agendou mas hesitante no telefone.',                       now() - interval '5 days',  now() - interval '1 days'),
  ('Otávio Bernardes',    '+5567991110013', 'otavio.b@gmail.com',         'agendou',        'whatsapp_ativo', 'detectado', 0.74, 'Recuperado de lista antiga via disparo ativo.',            now() - interval '4 days',  now() - interval '1 days'),
  -- em atendimento (conversa quente em andamento)
  ('Sabrina Duarte',      '+5567991110014', NULL,                          'em_atendimento', 'instagram',      'detectado', 0.82, 'Negociando valor do protocolo. Score alto.',               now() - interval '6 days',  now() - interval '4 hours'),
  ('Rodrigo Salles',      '+5567991110015', 'rodrigo.salles@gmail.com',   'em_atendimento', 'google',         'detectado', 0.78, 'Pediu detalhe das parcelas. Recepção respondendo.',        now() - interval '3 days',  now() - interval '3 hours'),
  ('Aline Prado',         '+5567991110016', NULL,                          'em_atendimento', 'facebook',       'detectado', 0.59, 'Demorou pra responder. Esfriando.',                        now() - interval '8 days',  now() - interval '26 hours'),
  -- sem resposta (lead sumiu)
  ('Vanessa Klein',       '+5567991110017', NULL,                          'sem_resposta',   'instagram',      'detectado', 0.61, 'Parou de responder após receber valor.',                   now() - interval '15 days', now() - interval '10 days'),
  ('Henrique Sá',         '+5567991110018', 'henrique.sa@gmail.com',      'sem_resposta',   'google',         'detectado', 0.55, 'Sumiu depois do primeiro contato.',                        now() - interval '21 days', now() - interval '16 days'),
  -- novos (recém-chegados; 2 com origem PENDENTE p/ tela de classificação)
  ('Letícia Barros',      '+5567991110019', NULL,                          'novo',           'instagram',      'detectado', 0.88, 'Chegou hoje via anúncio de lentes.',                       now() - interval '20 hours', now() - interval '20 hours'),
  ('Daniel Figueiredo',   '+5567991110020', 'dani.fig@gmail.com',         'novo',           NULL,             'pendente',  NULL, 'Origem não detectada — classificar manualmente.',          now() - interval '14 hours', now() - interval '14 hours'),
  ('Priscila Tavares',    '+5567991110021', NULL,                          'novo',           NULL,             'pendente',  NULL, 'Origem não detectada — classificar manualmente.',          now() - interval '5 hours',  now() - interval '5 hours'),
  -- perdidos
  ('Cláudio Menezes',     '+5567991110022', NULL,                          'perdido',        'facebook',       'detectado', 0.66, 'Foi fechar com concorrente. Preço.',                       now() - interval '44 days', now() - interval '30 days'),
  ('Fernanda Rocha',      '+5567991110023', 'fe.rocha@gmail.com',         'perdido',        'google',         'detectado', 0.58, 'Desistiu do tratamento por ora.',                          now() - interval '36 days', now() - interval '25 days'),
  ('Ricardo Nogueira',    '+5567991110024', NULL,                          'perdido',        'organico',       'detectado', 0.52, 'Só queria orçamento, sem intenção real.',                  now() - interval '29 days', now() - interval '24 days')
ON CONFLICT (telefone) DO NOTHING;

-- ---------------------------------------------------------------------
-- 3. Conversas (14) — vinculadas a leads via telefone
--    numero_whatsapp = telefone do lead (chave natural p/ mensagens).
-- ---------------------------------------------------------------------
INSERT INTO comercial.conversas (lead_id, evolution_instance_id, numero_whatsapp, status, ultimo_score, ultima_analise_em, ultima_mensagem_em, created_at)
SELECT l.id, ei.id, c.numero, c.status, c.ultimo_score, c.ultima_analise_em, c.ultima_mensagem_em, c.created_at
FROM (VALUES
  ('+5567991110014', 'ativa',      88.0, now() - interval '4 hours',  now() - interval '4 hours',  now() - interval '6 days'),
  ('+5567991110015', 'ativa',      72.0, now() - interval '3 hours',  now() - interval '3 hours',  now() - interval '3 days'),
  ('+5567991110016', 'ativa',      38.0, now() - interval '25 hours', now() - interval '26 hours', now() - interval '8 days'),
  ('+5567991110005', 'aguardando', 64.0, now() - interval '12 days',  now() - interval '12 days',  now() - interval '48 days'),
  ('+5567991110006', 'aguardando', 47.0, now() - interval '9 days',   now() - interval '9 days',   now() - interval '40 days'),
  ('+5567991110009', 'ativa',      81.0, now() - interval '2 days',   now() - interval '2 days',   now() - interval '11 days'),
  ('+5567991110010', 'ativa',      69.0, now() - interval '2 days',   now() - interval '2 days',   now() - interval '9 days'),
  ('+5567991110012', 'ativa',      44.0, now() - interval '30 hours', now() - interval '30 hours', now() - interval '5 days'),
  ('+5567991110017', 'encerrada',  29.0, now() - interval '10 days',  now() - interval '11 days',  now() - interval '15 days'),
  ('+5567991110018', 'encerrada',  33.0, now() - interval '16 days',  now() - interval '17 days',  now() - interval '21 days'),
  ('+5567991110001', 'encerrada',  92.0, now() - interval '58 days',  now() - interval '59 days',  now() - interval '70 days'),
  ('+5567991110007', 'aguardando', 76.0, now() - interval '5 days',   now() - interval '5 days',   now() - interval '27 days'),
  ('+5567991110022', 'encerrada',  41.0, now() - interval '30 days',  now() - interval '31 days',  now() - interval '44 days'),
  ('+5567991110019', 'ativa',      85.0, now() - interval '18 hours', now() - interval '18 hours', now() - interval '20 hours')
) AS c(numero, status, ultimo_score, ultima_analise_em, ultima_mensagem_em, created_at)
JOIN comercial.leads l ON l.telefone = c.numero
JOIN comercial.evolution_instances ei ON ei.instance_name = 'lumina-recepcao'
ON CONFLICT DO NOTHING;

-- ---------------------------------------------------------------------
-- 4. Mensagens — threads realistas. Detalhadas nas conversas de destaque.
--    Referência da conversa via numero_whatsapp.
-- ---------------------------------------------------------------------

-- Sabrina Duarte (score 88 — quente, negociando)
INSERT INTO comercial.mensagens (conversa_id, message_id_evolution, tipo, fonte, conteudo, remetente, enviada_em)
SELECT cv.id, m.mid, 'texto', m.fonte, m.conteudo, m.remetente, m.enviada_em
FROM (VALUES
  ('demo-msg-0001', 'humano', 'lead',    'Oi! Vi o anúncio de vocês sobre protocolo. Queria entender como funciona', now() - interval '6 days'  + interval '0 min'),
  ('demo-msg-0002', 'humano', 'clinica', 'Olá, Sabrina! Que bom seu contato 😊 O protocolo é a reabilitação completa do sorriso. Posso te explicar e já deixar uma avaliação marcada com a Dra. Helena. Você prefere manhã ou tarde?', now() - interval '6 days' + interval '7 min'),
  ('demo-msg-0003', 'humano', 'lead',    'Tarde é melhor. Mas antes queria ter ideia de valor, pra não perder a viagem', now() - interval '6 days' + interval '20 min'),
  ('demo-msg-0004', 'humano', 'clinica', 'Entendo perfeitamente! O investimento varia conforme o caso, mas o protocolo completo costuma ficar entre R$ 28 mil e R$ 45 mil, com entrada e parcelamento. Na avaliação a Dra. fecha o plano exato. Posso reservar quinta 15h?', now() - interval '6 days' + interval '35 min'),
  ('demo-msg-0005', 'humano', 'lead',    'Consigo parcelar em quantas vezes?', now() - interval '5 days' + interval '2 hours'),
  ('demo-msg-0006', 'humano', 'clinica', 'Conseguimos em até 18x no cartão ou condição especial com entrada de 30%. Na consulta a gente monta a melhor forma pro seu orçamento. Reservei quinta 15h pra você 💙', now() - interval '5 days' + interval '2 hours' + interval '10 min'),
  ('demo-msg-0007', 'humano', 'lead',    'Perfeito, pode marcar! Quinta 15h tá ótimo', now() - interval '4 hours')
) AS m(mid, fonte, remetente, conteudo, enviada_em)
JOIN comercial.conversas cv ON cv.numero_whatsapp = '+5567991110014'
ON CONFLICT (message_id_evolution) DO NOTHING;

-- Aline Prado (score 38 — esfriando, demora)
INSERT INTO comercial.mensagens (conversa_id, message_id_evolution, tipo, fonte, conteudo, remetente, enviada_em)
SELECT cv.id, m.mid, 'texto', m.fonte, m.conteudo, m.remetente, m.enviada_em
FROM (VALUES
  ('demo-msg-0010', 'humano', 'lead',    'quanto fica o preenchimento labial?', now() - interval '8 days'),
  ('demo-msg-0011', 'humano', 'clinica', 'Oi, Aline! O preenchimento labial fica R$ 1.800 a sessão. Quer agendar uma avaliação?', now() - interval '8 days' + interval '3 hours'),
  ('demo-msg-0012', 'humano', 'lead',    'nossa achei caro', now() - interval '7 days'),
  ('demo-msg-0013', 'humano', 'clinica', 'Entendo! Temos protocolos com valores diferentes dependendo do produto. Posso te explicar melhor numa avaliação rápida, sem compromisso 😊', now() - interval '7 days' + interval '5 hours'),
  ('demo-msg-0014', 'humano', 'lead',    'vou ver e te aviso', now() - interval '26 hours')
) AS m(mid, fonte, remetente, conteudo, enviada_em)
JOIN comercial.conversas cv ON cv.numero_whatsapp = '+5567991110016'
ON CONFLICT (message_id_evolution) DO NOTHING;

-- Vanessa Klein (score 29 — alerta imediato, sumiu após preço)
INSERT INTO comercial.mensagens (conversa_id, message_id_evolution, tipo, fonte, conteudo, remetente, enviada_em)
SELECT cv.id, m.mid, 'texto', m.fonte, m.conteudo, m.remetente, m.enviada_em
FROM (VALUES
  ('demo-msg-0020', 'humano', 'lead',    'Oi, queria saber sobre lentes de contato dental', now() - interval '15 days'),
  ('demo-msg-0021', 'humano', 'clinica', 'Oi! As lentes ficam R$ 2.500 por dente. Pra 10 dentes daria R$ 25 mil. Quer agendar?', now() - interval '15 days' + interval '6 hours'),
  ('demo-msg-0022', 'humano', 'lead',    'ah entendi obrigada', now() - interval '14 days')
) AS m(mid, fonte, remetente, conteudo, enviada_em)
JOIN comercial.conversas cv ON cv.numero_whatsapp = '+5567991110017'
ON CONFLICT (message_id_evolution) DO NOTHING;

-- Felipe Andrade (score 81 — agendou, fluxo bom)
INSERT INTO comercial.mensagens (conversa_id, message_id_evolution, tipo, fonte, conteudo, remetente, enviada_em)
SELECT cv.id, m.mid, 'texto', m.fonte, m.conteudo, m.remetente, m.enviada_em
FROM (VALUES
  ('demo-msg-0030', 'humano', 'lead',    'Boa tarde, perdi um dente e queria avaliar implante', now() - interval '11 days'),
  ('demo-msg-0031', 'humano', 'clinica', 'Boa tarde, Felipe! Sinto muito, mas isso tem solução 😊 O implante unitário devolve o dente com aparência natural. A avaliação com raio-x é gratuita. Você tem disponibilidade essa semana?', now() - interval '11 days' + interval '40 min'),
  ('demo-msg-0032', 'humano', 'lead',    'Tenho sim. Quinta de manhã dá?', now() - interval '11 days' + interval '1 hours'),
  ('demo-msg-0033', 'humano', 'clinica', 'Dá sim! Marquei quinta 9h. Te mando o endereço e um lembrete na véspera. Qualquer dúvida estou aqui 💙', now() - interval '2 days')
) AS m(mid, fonte, remetente, conteudo, enviada_em)
JOIN comercial.conversas cv ON cv.numero_whatsapp = '+5567991110009'
ON CONFLICT (message_id_evolution) DO NOTHING;

-- Letícia Barros (score 85 — lead novo quente)
INSERT INTO comercial.mensagens (conversa_id, message_id_evolution, tipo, fonte, conteudo, remetente, enviada_em)
SELECT cv.id, m.mid, 'texto', m.fonte, m.conteudo, m.remetente, m.enviada_em
FROM (VALUES
  ('demo-msg-0040', 'humano', 'lead',    'Oi! Vi o anúncio das lentes e amei o resultado das fotos 😍 quero muito fazer', now() - interval '20 hours'),
  ('demo-msg-0041', 'humano', 'clinica', 'Oiii, Letícia! Que delícia ler isso 😊 As lentes transformam mesmo o sorriso. Vou te explicar rapidinho e a gente marca sua avaliação. Você já tem alguma data em mente?', now() - interval '19 hours'),
  ('demo-msg-0042', 'humano', 'lead',    'Quanto antes melhor! Pode ser amanhã?', now() - interval '18 hours')
) AS m(mid, fonte, remetente, conteudo, enviada_em)
JOIN comercial.conversas cv ON cv.numero_whatsapp = '+5567991110019'
ON CONFLICT (message_id_evolution) DO NOTHING;

-- Conversas leves (2-3 mensagens) p/ as demais terem conteúdo mínimo
INSERT INTO comercial.mensagens (conversa_id, message_id_evolution, tipo, fonte, conteudo, remetente, enviada_em)
SELECT cv.id, m.mid, 'texto', 'humano', m.conteudo, m.remetente, m.enviada_em
FROM (VALUES
  ('+5567991110015', 'demo-msg-0050', 'lead',    'Me explica como funciona o parcelamento do protocolo?', now() - interval '3 days'),
  ('+5567991110015', 'demo-msg-0051', 'clinica', 'Claro, Rodrigo! Entrada de 30% e o restante em até 18x. Te mando a simulação 😊', now() - interval '3 hours'),
  ('+5567991110005', 'demo-msg-0052', 'lead',    'Vou conversar com meu marido e te retorno', now() - interval '12 days'),
  ('+5567991110005', 'demo-msg-0053', 'clinica', 'Sem problema, Camila! Fico à disposição. O orçamento fica reservado por 15 dias 💙', now() - interval '12 days' + interval '20 min'),
  ('+5567991110010', 'demo-msg-0054', 'lead',    'Confirmo a avaliação de HOF de quinta', now() - interval '2 days'),
  ('+5567991110010', 'demo-msg-0055', 'clinica', 'Confirmadíssimo, Juliana! Te espero 😊', now() - interval '2 days' + interval '15 min'),
  ('+5567991110012', 'demo-msg-0056', 'lead',    'ainda não sei se vou conseguir ir', now() - interval '30 hours'),
  ('+5567991110012', 'demo-msg-0057', 'clinica', 'Tudo bem, Tatiane! Se precisar remarcar é só avisar 😊', now() - interval '30 hours' + interval '10 min'),
  ('+5567991110007', 'demo-msg-0058', 'lead',    'Adorei a avaliação! Vou fechar o botox + preenchimento', now() - interval '5 days'),
  ('+5567991110007', 'demo-msg-0059', 'clinica', 'Maravilha, Larissa! 🎉 Já deixo sua sessão agendada', now() - interval '5 days' + interval '30 min'),
  ('+5567991110018', 'demo-msg-0060', 'lead',    'oi quero saber valores', now() - interval '21 days'),
  ('+5567991110018', 'demo-msg-0061', 'clinica', 'Oi, Henrique! Depende do tratamento. Qual seria seu objetivo?', now() - interval '21 days' + interval '4 hours'),
  ('+5567991110001', 'demo-msg-0062', 'lead',    'Fechei e estou amando o resultado, obrigada equipe Lumina!', now() - interval '58 days'),
  ('+5567991110001', 'demo-msg-0063', 'clinica', 'Nós que agradecemos a confiança, Mariana! 💙 Seu sorriso ficou perfeito', now() - interval '58 days' + interval '1 hours'),
  ('+5567991110006', 'demo-msg-0064', 'lead',    'achei o protocolo caro, tem como melhorar?', now() - interval '9 days'),
  ('+5567991110006', 'demo-msg-0065', 'clinica', 'Posso ver uma condição especial pra você, Gustavo. Deixa eu falar com a gestão 😊', now() - interval '9 days' + interval '2 hours'),
  ('+5567991110022', 'demo-msg-0066', 'lead',    'recebi proposta de outra clínica mais barata', now() - interval '31 days'),
  ('+5567991110022', 'demo-msg-0067', 'clinica', 'Entendo, Cláudio. Nosso diferencial é o acompanhamento e a garantia. Posso te mostrar?', now() - interval '31 days' + interval '3 hours')
) AS m(numero, mid, remetente, conteudo, enviada_em)
JOIN comercial.conversas cv ON cv.numero_whatsapp = m.numero
ON CONFLICT (message_id_evolution) DO NOTHING;

-- ---------------------------------------------------------------------
-- 5. Análises de WhatsApp (14) — uma por conversa, created_at espalhado.
--    Scores cobrem todas as faixas (alerta imediato <30, baixo <50, etc).
-- ---------------------------------------------------------------------
INSERT INTO comercial.analises_whatsapp
  (conversa_id, score, tags_positivas, tags_negativas, resumo, diagnostico, acao_recomendada,
   origem_detectada, origem_confidence, total_mensagens_analisadas, modelo, prompt_versao, tokens_entrada, tokens_saida, created_at)
SELECT cv.id, a.score, a.tp, a.tn, a.resumo, a.diag, a.acao, a.origem, a.oconf, a.totalmsg,
       'claude-sonnet-4-6', 'v1', a.ti, a.ts, a.created_at
FROM (VALUES
  ('+5567991110014', 88.0, ARRAY['interesse_alto','resposta_rapida','agendou'], ARRAY[]::text[],
     'Lead pediu valores, recebeu faixa e parcelamento, e fechou agendamento para quinta.',
     'Condução exemplar: recepção ancorou valor, ofereceu data e converteu sem fricção.',
     'Confirmar presença na véspera e preparar Dra. Helena para fechamento de protocolo.',
     'instagram', 0.94, 7, 1180, 240, now() - interval '4 hours'),
  ('+5567991110015', 72.0, ARRAY['interesse_medio','pediu_parcelamento'], ARRAY['decisao_pendente'],
     'Lead quer entender parcelamento do protocolo antes de avançar.',
     'Interesse real, mas preso na barreira financeira. Falta enviar a simulação prometida.',
     'Enviar simulação de parcelamento ainda hoje e propor data de avaliação.',
     'google', 0.78, 4, 760, 180, now() - interval '3 hours'),
  ('+5567991110016', 38.0, ARRAY[]::text[], ARRAY['objecao_preco','demora_resposta','esfriando'],
     'Lead achou preenchimento caro e disse que "vai ver e avisa".',
     'Objeção de preço não tratada. Recepção não reancorou valor nem criou urgência.',
     'Resgatar com prova social + condição. Não deixar morrer no "vou ver".',
     'facebook', 0.59, 5, 690, 160, now() - interval '25 hours'),
  ('+5567991110005', 64.0, ARRAY['compareceu','interesse_medio'], ARRAY['decisao_terceiros'],
     'Compareceu à consulta, levou orçamento para decidir com o marido.',
     'Decisor externo não estava presente. Risco clássico de esfriamento.',
     'Follow-up incluindo o cônjuge na conversa. Reforçar prazo do orçamento.',
     'facebook', 0.80, 2, 420, 120, now() - interval '12 days'),
  ('+5567991110006', 47.0, ARRAY['compareceu'], ARRAY['objecao_preco','pediu_desconto'],
     'Compareceu mas achou o protocolo caro e pediu condição especial.',
     'Sensibilidade a preço alta. Valor não foi suficientemente justificado.',
     'Apresentar condição com entrada de 30% e reforçar diferenciais clínicos.',
     'google', 0.83, 2, 410, 130, now() - interval '9 days'),
  ('+5567991110009', 81.0, ARRAY['interesse_alto','agendou','resposta_rapida'], ARRAY[]::text[],
     'Lead com dente perdido agendou avaliação de implante para quinta.',
     'Boa condução empática + oferta de avaliação gratuita destravou o agendamento.',
     'Garantir comparecimento e preparar plano de implante com raio-x.',
     'instagram', 0.86, 4, 720, 170, now() - interval '2 days'),
  ('+5567991110010', 69.0, ARRAY['agendou','interesse_medio'], ARRAY[]::text[],
     'Lead confirmou avaliação de HOF para quinta.',
     'Agendamento confirmado. Veio de anúncio de preenchimento, intenção clara.',
     'Confirmar na véspera e preparar protocolo de HOF.',
     'google', 0.81, 2, 380, 110, now() - interval '2 days'),
  ('+5567991110012', 44.0, ARRAY[]::text[], ARRAY['hesitante','risco_no_show'],
     'Lead agendou mas demonstrou incerteza sobre comparecer.',
     'Alto risco de no-show. Não há compromisso real firmado.',
     'Ligar para confirmar e oferecer reagendamento ativo antes do horário.',
     'facebook', 0.68, 2, 360, 100, now() - interval '30 hours'),
  ('+5567991110017', 29.0, ARRAY[]::text[], ARRAY['objecao_preco','abandonou','sem_followup'],
     'Lead pediu valor de lentes, recebeu R$ 25 mil e encerrou com "obrigada".',
     'Preço entregue de forma seca, sem ancoragem nem oferta de avaliação. Lead perdido.',
     'Resgate imediato: criar valor antes do preço e oferecer consulta sem compromisso.',
     'instagram', 0.61, 3, 480, 140, now() - interval '11 days'),
  ('+5567991110018', 33.0, ARRAY[]::text[], ARRAY['sem_qualificacao','sumiu'],
     'Lead pediu valores genéricos e não respondeu à pergunta de qualificação.',
     'Lead frio, sem objetivo definido. Recepção tentou qualificar mas não houve retorno.',
     'Um follow-up de resgate. Se não responder, marcar como sem resposta.',
     'google', 0.55, 2, 340, 95, now() - interval '17 days'),
  ('+5567991110001', 92.0, ARRAY['fechou','satisfeito','indicacao_potencial'], ARRAY[]::text[],
     'Cliente fechou protocolo superior + HOF e relatou satisfação com o resultado.',
     'Caso de sucesso completo. Potencial de indicação e depoimento.',
     'Solicitar depoimento e pedir indicação. Incluir em campanha de prova social.',
     'instagram', 0.94, 2, 400, 110, now() - interval '58 days'),
  ('+5567991110007', 76.0, ARRAY['compareceu','fechou_parcial','satisfeito'], ARRAY[]::text[],
     'Compareceu, gostou da avaliação e fechou botox + preenchimento.',
     'Conversão de HOF bem conduzida após avaliação presencial.',
     'Agendar sessão e oferecer pacote de manutenção semestral.',
     'instagram', 0.77, 2, 390, 105, now() - interval '5 days'),
  ('+5567991110022', 41.0, ARRAY[]::text[], ARRAY['objecao_preco','concorrente'],
     'Lead recebeu proposta mais barata de concorrente e sinalizou comparação.',
     'Guerra de preço. Diferenciais não foram apresentados a tempo.',
     'Reforçar garantia e acompanhamento. Se não houver fit de valor, liberar.',
     'facebook', 0.66, 2, 360, 100, now() - interval '31 days'),
  ('+5567991110019', 85.0, ARRAY['interesse_alto','urgencia','resposta_rapida'], ARRAY[]::text[],
     'Lead novo, empolgada com lentes, quer agendar o quanto antes.',
     'Lead extremamente quente vinda de anúncio. Momento ideal para agendar já.',
     'Agendar avaliação para amanhã imediatamente. Não deixar esfriar.',
     'instagram', 0.88, 3, 520, 150, now() - interval '18 hours')
) AS a(numero, score, tp, tn, resumo, diag, acao, origem, oconf, totalmsg, ti, ts, created_at)
JOIN comercial.conversas cv ON cv.numero_whatsapp = a.numero
ON CONFLICT DO NOTHING;

-- ---------------------------------------------------------------------
-- 6. Calls (16) — transcrições de fechamento (estilo Método Vitor).
--    plaud_id = chave natural. match_status variado.
--    13 com analisada_em preenchido + 3 NULL (fila de análise).
-- ---------------------------------------------------------------------
INSERT INTO comercial.calls
  (lead_id, titulo, duracao_segundos, plaud_id, transcricao, transcricao_origem,
   telefone_extraido, match_status, match_confirmado_em, realizada_em, analisada_em, created_at)
SELECT l.id, c.titulo, c.dur, c.plaud_id, c.transc, 'plaud',
       c.tel, c.match_status,
       CASE WHEN c.match_status IN ('confirmado','confirmado_auto') THEN c.realizada_em ELSE NULL END,
       c.realizada_em, ae.analisada_em, c.realizada_em
FROM (VALUES
  ('+5567991110001', 'Fechamento — Mariana (protocolo + HOF)', 2280, 'demo-call-0001',
     'Dra. Helena: Mariana, com base na sua avaliação, o ideal é o protocolo superior com harmonização do terço inferior. Mariana: Eu sei que preciso, só me assusta o valor. Dra. Helena: Entendo. Deixa eu te mostrar o antes e depois de casos parecidos com o seu. [...] O investimento completo fica em R$ 42 mil. Podemos fazer com entrada de 30% e o restante em 18x. Mariana: E a garantia? Dra. Helena: Acompanhamento por 24 meses incluído. Mariana: Então vamos fechar. Dra. Helena: Maravilha! Vou preparar o contrato e já agendamos a primeira etapa.',
     '+5567991110001', 'confirmado_auto', now() - interval '58 days', now() - interval '58 days'),
  ('+5567991110002', 'Fechamento — Renato (implante + enxerto)', 1860, 'demo-call-0002',
     'Dr. Paulo: Renato, seu caso pede um enxerto antes do implante. Renato: Isso encarece muito? Dr. Paulo: O enxerto entra como etapa, mas garante a longevidade. Total de R$ 14 mil. Renato: Posso parcelar? Dr. Paulo: Entrada de 30% e 12x. Renato: Fechado, confio na indicação da Dra. Lima.',
     '+5567991110002', 'confirmado', now() - interval '41 days', now() - interval '41 days'),
  ('+5567991110003', 'Fechamento — Patrícia (lentes 16 dentes)', 2040, 'demo-call-0003',
     'Dra. Helena: Patrícia, pra simetria que você quer, são 16 lentes. Patrícia: Já pesquisei bastante, sei o valor de mercado. Dra. Helena: Aqui fica R$ 40 mil, com planejamento digital incluso. Patrícia: O planejamento digital eu não vi nos outros lugares. Dra. Helena: É o nosso diferencial. Patrícia: Por isso prefiro fechar com vocês.',
     '+5567991110003', 'confirmado', now() - interval '22 days', now() - interval '22 days'),
  ('+5567991110004', 'Fechamento — Eduardo (HOF full face)', 1500, 'demo-call-0004',
     'Dra. Helena: Eduardo, o full face inclui botox, preenchimento e bioestimulador. Eduardo: Quero um resultado natural, sem exageros. Dra. Helena: É exatamente nossa filosofia. Investimento de R$ 9.500 a sessão completa. Eduardo: Beleza, pode marcar.',
     '+5567991110004', 'confirmado_auto', now() - interval '6 days', now() - interval '6 days'),
  ('+5567991110005', 'Avaliação — Camila (protocolo)', 1680, 'demo-call-0005',
     'Dra. Helena: Camila, seu caso é totalmente viável. Camila: Gostei, mas preciso conversar com meu marido sobre o valor. Dra. Helena: Claro. Posso deixar o orçamento reservado por 15 dias. Camila: Perfeito, te retorno.',
     '+5567991110005', 'confirmado', now() - interval '12 days', now() - interval '12 days'),
  ('+5567991110006', 'Avaliação — Gustavo (protocolo inferior)', 1440, 'demo-call-0006',
     'Dr. Paulo: Gustavo, o protocolo inferior resolve sua mordida. Gustavo: O valor tá acima do que eu esperava. Dr. Paulo: Posso ver uma condição com a gestão. Gustavo: Se melhorar o parcelamento eu penso.',
     '+5567991110006', 'confirmado', now() - interval '9 days', now() - interval '9 days'),
  ('+5567991110022', 'Fechamento — Cláudio (perdido p/ concorrente)', 1260, 'demo-call-0007',
     'Dr. Paulo: Cláudio, nosso protocolo tem garantia de 24 meses. Cláudio: Recebi proposta R$ 8 mil mais barata. Dr. Paulo: Posso explicar o que justifica a diferença? Cláudio: Sinceramente já decidi pela outra. Dr. Paulo: Entendo, fico à disposição se mudar de ideia.',
     '+5567991110022', 'confirmado', now() - interval '30 days', now() - interval '30 days'),
  ('+5567991110007', 'Fechamento — Larissa (HOF)', 960, 'demo-call-0008',
     'Dra. Helena: Larissa, pro seu objetivo botox e preenchimento labial já entregam bastante. Larissa: Adorei, quanto fica? Dra. Helena: R$ 3.200 o pacote. Larissa: Fechado!',
     '+5567991110007', 'confirmado_auto', now() - interval '5 days', now() - interval '5 days'),
  ('+5567991110009', 'Avaliação — Felipe (implante)', 1080, 'demo-call-0009',
     'Dr. Paulo: Felipe, o implante unitário é o indicado. Felipe: Demora quanto tempo? Dr. Paulo: Cerca de 4 meses no total. Felipe: E o valor? Dr. Paulo: R$ 4.800 com a coroa. Felipe: Vou avaliar e te falo na consulta.',
     '+5567991110009', 'confirmado', now() - interval '2 days', now() - interval '2 days'),
  ('+5567991110017', 'Avaliação — Vanessa (lentes, sem fechamento)', 720, 'demo-call-0010',
     'Dra. Helena: Vanessa, as lentes vão te dar o sorriso que você quer. Vanessa: É bastante dinheiro. Dra. Helena: Posso te mostrar o parcelamento? Vanessa: Deixa eu pensar, depois te procuro.',
     '+5567991110017', 'confirmado', now() - interval '11 days', now() - interval '11 days'),
  ('+5567991110023', 'Avaliação — Fernanda (desistiu)', 840, 'demo-call-0011',
     'Dra. Helena: Fernanda, podemos começar quando você quiser. Fernanda: Vou deixar pra mais pra frente, agora não é o momento. Dra. Helena: Sem problema, te mantenho no acompanhamento.',
     '+5567991110023', 'confirmado', now() - interval '25 days', now() - interval '25 days'),
  ('+5567991110011', 'Avaliação — Marcos (protocolo inferior)', 1320, 'demo-call-0012',
     'Dr. Paulo: Marcos, seu caso é tranquilo. Marcos: Quero entender as etapas. Dr. Paulo: São quatro etapas ao longo de cinco meses. Marcos: E posso começar mês que vem? Dr. Paulo: Pode sim, vamos agendar a primeira.',
     '+5567991110011', 'confirmado', now() - interval '13 days', now() - interval '13 days'),
  ('+5567991110013', 'Avaliação — Otávio (reativado)', 600, 'demo-call-0013',
     'Dra. Helena: Otávio, que bom que retornou. Otávio: Recebi a mensagem de vocês e resolvi voltar. Dra. Helena: Vamos retomar de onde paramos.',
     '+5567991110013', 'confirmado', now() - interval '4 days', now() - interval '4 days'),
  -- 3 calls SEM análise (fila) + match em estados diferentes
  ('+5567991110014', 'Avaliação — Sabrina (a analisar)', 1140, 'demo-call-0014',
     'Dra. Helena: Sabrina, seu protocolo é viável e o resultado vai ser excelente. Sabrina: Quero muito, só preciso fechar o parcelamento. Dra. Helena: Vamos montar agora a melhor condição pra você.',
     '+5567991110014', 'sugerido', now() - interval '4 hours', now() - interval '4 hours'),
  (NULL, 'Call sem identificação (a analisar)', 540, 'demo-call-0015',
     'Atendente: Clínica Lumina, bom dia! Pessoa: Oi, é sobre um orçamento que pedi semana passada. Atendente: Claro, pode me passar seu nome? Pessoa: Depois eu retorno, obrigado.',
     '+5567999999999', 'sem_lead', now() - interval '1 days', now() - interval '1 days'),
  (NULL, 'Avaliação — telefone a confirmar (a analisar)', 900, 'demo-call-0016',
     'Dr. Paulo: O senhor tem indicação de implante duplo. Pessoa: Entendi, e o valor? Dr. Paulo: Fica em R$ 9 mil os dois. Pessoa: Vou pensar e retorno.',
     '+5567991110099', 'pendente', now() - interval '2 days', now() - interval '2 days')
) AS c(tel, titulo, dur, plaud_id, transc, tel_extra, match_status, realizada_em, created_dup)
LEFT JOIN comercial.leads l ON l.telefone = c.tel
-- analisada_em: NULL nas 3 últimas (fila), preenchido nas demais
CROSS JOIN LATERAL (SELECT CASE WHEN c.plaud_id IN ('demo-call-0014','demo-call-0015','demo-call-0016')
                                THEN NULL::timestamptz ELSE c.realizada_em END AS analisada_em) ae
ON CONFLICT (plaud_id) DO NOTHING;

-- match_sugestoes para a call "sugerido" (Sabrina) e "pendente"
UPDATE comercial.calls SET match_sugestoes = (
  SELECT jsonb_agg(jsonb_build_object('lead_id', l.id, 'nome', l.nome, 'telefone', l.telefone, 'confidence', x.conf))
  FROM (VALUES ('+5567991110014', 0.91), ('+5567991110015', 0.34)) AS x(tel, conf)
  JOIN comercial.leads l ON l.telefone = x.tel
) WHERE plaud_id = 'demo-call-0014';

UPDATE comercial.calls SET match_sugestoes = (
  SELECT jsonb_agg(jsonb_build_object('lead_id', l.id, 'nome', l.nome, 'telefone', l.telefone, 'confidence', x.conf))
  FROM (VALUES ('+5567991110011', 0.42), ('+5567991110013', 0.28)) AS x(tel, conf)
  JOIN comercial.leads l ON l.telefone = x.tel
) WHERE plaud_id = 'demo-call-0016';

-- ---------------------------------------------------------------------
-- 7. Análises de Calls (13) — 8 fases (Método Vitor) com score+observação.
--    Distribuição: excelente / bom / regular / insuficiente.
-- ---------------------------------------------------------------------
INSERT INTO comercial.analises_calls
  (call_id, classificacao, score_geral, fases, diagnostico, acao_recomendada, modelo, prompt_versao, tokens_entrada, tokens_saida, created_at)
SELECT ca.id, a.cls, a.score, a.fases::jsonb, a.diag, a.acao, 'claude-sonnet-4-6', 'v1', a.ti, a.ts, ca.realizada_em
FROM (VALUES
  ('demo-call-0001', 'excelente', 91.0,
     '{"preparacao":{"score":88,"observacao":"Chegou com casos análogos preparados."},"abertura":{"score":85,"observacao":"Rapport sólido e empático."},"diagnostico":{"score":92,"observacao":"Necessidade ampliada com clareza."},"apresentacao_clinica":{"score":94,"observacao":"Plano explicado com prova visual."},"apresentacao_investimento":{"score":90,"observacao":"Ancorou valor antes do preço."},"fechamento":{"score":95,"observacao":"Pediu o fechamento com naturalidade."},"objecoes":{"score":88,"observacao":"Garantia tratou a objeção principal."},"sabotadores":{"score":86,"observacao":"Nenhum sabotador deixado em aberto."}}',
     'Call modelo. Diagnóstico, valor e fechamento conduzidos com método.',
     'Usar como referência de treinamento para a equipe.', 1900, 420),
  ('demo-call-0002', 'bom', 78.0,
     '{"preparacao":{"score":75,"observacao":"Bom domínio do caso clínico."},"abertura":{"score":80,"observacao":"Aproveitou a indicação como prova."},"diagnostico":{"score":82,"observacao":"Explicou bem a necessidade do enxerto."},"apresentacao_clinica":{"score":79,"observacao":"Clareza nas etapas."},"apresentacao_investimento":{"score":72,"observacao":"Preço apresentado um pouco cedo."},"fechamento":{"score":80,"observacao":"Fechou com base na confiança."},"objecoes":{"score":74,"observacao":"Objeção de preço resolvida com parcelamento."},"sabotadores":{"score":76,"observacao":"Tempo de tratamento poderia ter sido reforçado."}}',
     'Boa call. Investimento poderia ter sido apresentado após mais ancoragem.',
     'Treinar sequência diagnóstico → valor → preço.', 1500, 360),
  ('demo-call-0003', 'excelente', 89.0,
     '{"preparacao":{"score":90,"observacao":"Planejamento digital pronto."},"abertura":{"score":84,"observacao":"Reconheceu o conhecimento da paciente."},"diagnostico":{"score":88,"observacao":"Alinhou expectativa de simetria."},"apresentacao_clinica":{"score":92,"observacao":"Diferencial do planejamento digital destacado."},"apresentacao_investimento":{"score":87,"observacao":"Valor justificado pelo diferencial."},"fechamento":{"score":91,"observacao":"Paciente fechou pelo diferencial percebido."},"objecoes":{"score":85,"observacao":"Comparação de mercado neutralizada."},"sabotadores":{"score":88,"observacao":"Sem pontas soltas."}}',
     'Diferencial clínico foi o fator decisivo. Excelente uso de prova.',
     'Padronizar a fala de planejamento digital nas demais calls.', 1700, 400),
  ('demo-call-0004', 'bom', 74.0,
     '{"preparacao":{"score":70,"observacao":"Caso simples, pouca preparação necessária."},"abertura":{"score":78,"observacao":"Sintonizou com o desejo de naturalidade."},"diagnostico":{"score":72,"observacao":"Diagnóstico rápido."},"apresentacao_clinica":{"score":76,"observacao":"Explicou os três procedimentos do full face."},"apresentacao_investimento":{"score":70,"observacao":"Preço direto, sem muita ancoragem."},"fechamento":{"score":80,"observacao":"Fechou rápido por baixa resistência."},"objecoes":{"score":72,"observacao":"Sem objeções relevantes."},"sabotadores":{"score":74,"observacao":"Manutenção futura não foi mencionada."}}',
     'Fechou pela baixa resistência do lead, não pelo método.',
     'Aproveitar leads fáceis para oferecer pacote de manutenção.', 1300, 320),
  ('demo-call-0005', 'regular', 58.0,
     '{"preparacao":{"score":62,"observacao":"Preparada para o caso."},"abertura":{"score":60,"observacao":"Boa, mas não mapeou o decisor."},"diagnostico":{"score":64,"observacao":"Necessidade clara."},"apresentacao_clinica":{"score":60,"observacao":"Plano apresentado de forma competente."},"apresentacao_investimento":{"score":55,"observacao":"Valor entregue sem checar orçamento da paciente."},"fechamento":{"score":48,"observacao":"Não tentou fechar; aceitou o ''vou pensar''."},"objecoes":{"score":52,"observacao":"Decisor externo não foi endereçado."},"sabotadores":{"score":56,"observacao":"Risco de esfriamento ignorado."}}',
     'Faltou identificar e incluir o decisor (marido). Fechamento não foi tentado.',
     'Treinar pergunta de decisor no diagnóstico e tentativa de fechamento.', 1400, 350),
  ('demo-call-0006', 'regular', 54.0,
     '{"preparacao":{"score":58,"observacao":"Conhecia o caso."},"abertura":{"score":56,"observacao":"Aproximação ok."},"diagnostico":{"score":60,"observacao":"Necessidade identificada."},"apresentacao_clinica":{"score":55,"observacao":"Plano explicado sem entusiasmo."},"apresentacao_investimento":{"score":48,"observacao":"Cedeu à objeção de preço cedo demais."},"fechamento":{"score":45,"observacao":"Empurrou decisão para a gestão."},"objecoes":{"score":50,"observacao":"Objeção de preço dominou a call."},"sabotadores":{"score":58,"observacao":"Sabotador financeiro não trabalhado."}}',
     'Objeção de preço assumiu o controle. Faltou defender o valor.',
     'Treinar ancoragem de valor antes do preço e técnicas de objeção.', 1250, 310),
  ('demo-call-0007', 'insuficiente', 36.0,
     '{"preparacao":{"score":45,"observacao":"Pouca preparação para a objeção de concorrência."},"abertura":{"score":42,"observacao":"Aproximação fraca."},"diagnostico":{"score":40,"observacao":"Diagnóstico raso."},"apresentacao_clinica":{"score":38,"observacao":"Diferenciais apresentados tarde demais."},"apresentacao_investimento":{"score":30,"observacao":"Entrou direto no preço contra o concorrente."},"fechamento":{"score":28,"observacao":"Desistiu ao primeiro ''já decidi''."},"objecoes":{"score":32,"observacao":"Não trabalhou a objeção de concorrência."},"sabotadores":{"score":35,"observacao":"Comparação de preço dominou tudo."}}',
     'Perdido para concorrente por falha em construir valor antes do preço.',
     'Treinar abordagem de diferenciação e defesa de valor vs concorrência.', 1050, 280),
  ('demo-call-0008', 'bom', 71.0,
     '{"preparacao":{"score":68,"observacao":"Caso simples de HOF."},"abertura":{"score":74,"observacao":"Boa empatia."},"diagnostico":{"score":70,"observacao":"Objetivo claro da paciente."},"apresentacao_clinica":{"score":72,"observacao":"Pacote bem explicado."},"apresentacao_investimento":{"score":68,"observacao":"Preço aceito sem resistência."},"fechamento":{"score":78,"observacao":"Fechamento rápido e natural."},"objecoes":{"score":70,"observacao":"Sem objeções."},"sabotadores":{"score":69,"observacao":"Ok."}}',
     'Conversão limpa de ticket menor. Boa fluidez.',
     'Oferecer upgrade/pacote de manutenção em casos assim.', 900, 240),
  ('demo-call-0009', 'regular', 61.0,
     '{"preparacao":{"score":64,"observacao":"Preparado para o caso de implante."},"abertura":{"score":62,"observacao":"Boa abertura."},"diagnostico":{"score":66,"observacao":"Explicou bem o procedimento."},"apresentacao_clinica":{"score":63,"observacao":"Etapas e prazos claros."},"apresentacao_investimento":{"score":58,"observacao":"Valor apresentado, sem fechamento."},"fechamento":{"score":52,"observacao":"Aceitou ''vou avaliar'' sem avançar."},"objecoes":{"score":60,"observacao":"Sem objeções fortes."},"sabotadores":{"score":62,"observacao":"Urgência não foi criada."}}',
     'Avaliação tecnicamente boa, mas sem tentativa de fechamento na consulta.',
     'Criar próximo passo concreto ao fim da avaliação.', 1100, 290),
  ('demo-call-0010', 'insuficiente', 39.0,
     '{"preparacao":{"score":44,"observacao":"Preparação mínima."},"abertura":{"score":46,"observacao":"Aproximação genérica."},"diagnostico":{"score":42,"observacao":"Não aprofundou o desejo da paciente."},"apresentacao_clinica":{"score":40,"observacao":"Plano superficial."},"apresentacao_investimento":{"score":34,"observacao":"Preço sem ancoragem."},"fechamento":{"score":30,"observacao":"Encerrou com ''depois te procuro''."},"objecoes":{"score":36,"observacao":"Objeção financeira não tratada."},"sabotadores":{"score":40,"observacao":"Deixou a paciente sair sem compromisso."}}',
     'Call fraca. Paciente saiu sem próximo passo. Risco de perda total.',
     'Resgate ativo + treinar fechamento com próximo passo obrigatório.', 700, 200),
  ('demo-call-0011', 'regular', 56.0,
     '{"preparacao":{"score":58,"observacao":"Ok."},"abertura":{"score":60,"observacao":"Cordial."},"diagnostico":{"score":54,"observacao":"Pouco aprofundamento."},"apresentacao_clinica":{"score":56,"observacao":"Plano apresentado."},"apresentacao_investimento":{"score":50,"observacao":"Sem ancoragem."},"fechamento":{"score":52,"observacao":"Aceitou adiamento."},"objecoes":{"score":58,"observacao":"Adiamento não foi questionado."},"sabotadores":{"score":60,"observacao":"Momento (''agora não'') não trabalhado."}}',
     'Lead adiou e a call aceitou sem explorar o motivo real.',
     'Treinar exploração de objeção de tempo/momento.', 780, 220),
  ('demo-call-0012', 'bom', 73.0,
     '{"preparacao":{"score":72,"observacao":"Caso tranquilo, bem preparado."},"abertura":{"score":74,"observacao":"Boa conexão."},"diagnostico":{"score":75,"observacao":"Etapas bem mapeadas."},"apresentacao_clinica":{"score":73,"observacao":"Plano claro em 4 etapas."},"apresentacao_investimento":{"score":70,"observacao":"Valor bem posicionado."},"fechamento":{"score":76,"observacao":"Agendou início para o mês seguinte."},"objecoes":{"score":72,"observacao":"Sem objeções."},"sabotadores":{"score":71,"observacao":"Ok."}}',
     'Boa condução de avaliação que gerou compromisso de início.',
     'Confirmar início agendado com lembrete ativo.', 1000, 270),
  ('demo-call-0013', 'regular', 60.0,
     '{"preparacao":{"score":62,"observacao":"Retomada de lead reativado."},"abertura":{"score":66,"observacao":"Acolheu bem o retorno."},"diagnostico":{"score":58,"observacao":"Retomou histórico anterior."},"apresentacao_clinica":{"score":60,"observacao":"Recapitulou o plano."},"apresentacao_investimento":{"score":56,"observacao":"Não reapresentou valor atualizado."},"fechamento":{"score":58,"observacao":"Retomou sem fechar."},"objecoes":{"score":60,"observacao":"Sem objeções nesta etapa."},"sabotadores":{"score":62,"observacao":"Inércia anterior pode voltar."}}',
     'Reativação bem acolhida, mas sem avançar para fechamento.',
     'Definir próximo passo com data para não reabrir a inércia.', 560, 160)
) AS a(plaud, cls, score, fases, diag, acao, ti, ts)
JOIN comercial.calls ca ON ca.plaud_id = a.plaud
ON CONFLICT DO NOTHING;

-- ---------------------------------------------------------------------
-- 8. Rondas semanais (2) — snapshot congelado no shape do gerador-ronda.
--    Período: semana passada (segunda a domingo aproximado).
-- ---------------------------------------------------------------------
INSERT INTO comercial.rondas (tipo, periodo_inicio, periodo_fim, snapshot, vazia, status, enviada_em, destinatarios, created_at)
VALUES
(
  'whatsapp',
  date_trunc('week', now()) - interval '7 days',
  date_trunc('week', now()) - interval '1 second',
  jsonb_build_object(
    'tipo', 'whatsapp',
    'periodo', jsonb_build_object(
      'inicio', (date_trunc('week', now()) - interval '7 days')::text,
      'fim', (date_trunc('week', now()) - interval '1 second')::text),
    'total_conversas', 9,
    'score_medio', 58.4,
    'score_mais_alto', 88,
    'score_mais_baixo', 29,
    'distribuicao_score', jsonb_build_array(
      jsonb_build_object('faixa','0-30','total',1),
      jsonb_build_object('faixa','31-50','total',3),
      jsonb_build_object('faixa','51-70','total',2),
      jsonb_build_object('faixa','71-85','total',2),
      jsonb_build_object('faixa','86-100','total',1)),
    'top_tags_negativas', jsonb_build_array(
      jsonb_build_object('tag','objecao_preco','total',4),
      jsonb_build_object('tag','demora_resposta','total',2),
      jsonb_build_object('tag','decisao_terceiros','total',1)),
    'top_tags_positivas', jsonb_build_array(
      jsonb_build_object('tag','interesse_alto','total',3),
      jsonb_build_object('tag','agendou','total',3),
      jsonb_build_object('tag','resposta_rapida','total',2)),
    'conversas_criticas', jsonb_build_array(
      jsonb_build_object('conversa_id','', 'lead_nome','Vanessa Klein','score',29,'resumo','Recebeu preço sem ancoragem e abandonou.'),
      jsonb_build_object('conversa_id','', 'lead_nome','Aline Prado','score',38,'resumo','Objeção de preço não tratada; esfriando.')),
    'origens', jsonb_build_array(
      jsonb_build_object('origem','instagram','total',4),
      jsonb_build_object('origem','google','total',3),
      jsonb_build_object('origem','facebook','total',2))
  ),
  false, 'enviada', date_trunc('week', now()) + interval '9 hours',
  jsonb_build_array('gestao@clinicalumina.com.br','comercial@clinicalumina.com.br'),
  date_trunc('week', now()) + interval '9 hours'
),
(
  'calls',
  date_trunc('week', now()) - interval '7 days',
  date_trunc('week', now()) - interval '1 second',
  jsonb_build_object(
    'tipo', 'calls',
    'periodo', jsonb_build_object(
      'inicio', (date_trunc('week', now()) - interval '7 days')::text,
      'fim', (date_trunc('week', now()) - interval '1 second')::text),
    'total_calls', 6,
    'score_medio', 62.5,
    'distribuicao_classificacao', jsonb_build_array(
      jsonb_build_object('classificacao','excelente','total',1),
      jsonb_build_object('classificacao','bom','total',2),
      jsonb_build_object('classificacao','regular','total',2),
      jsonb_build_object('classificacao','insuficiente','total',1)),
    'media_por_fase', jsonb_build_object(
      'preparacao',68.2,'abertura',69.0,'diagnostico',67.5,'apresentacao_clinica',68.8,
      'apresentacao_investimento',60.3,'fechamento',58.7,'objecoes',61.0,'sabotadores',63.4),
    'calls_insuficientes', jsonb_build_array(
      jsonb_build_object('call_id','', 'lead_nome','Cláudio Menezes','score',36,'diagnostico','Perdido para concorrente por falha em construir valor antes do preço.'))
  ),
  false, 'enviada', date_trunc('week', now()) + interval '9 hours' + interval '5 min',
  jsonb_build_array('gestao@clinicalumina.com.br'),
  date_trunc('week', now()) + interval '9 hours' + interval '5 min'
)
ON CONFLICT (tipo, periodo_inicio) DO NOTHING;

-- ---------------------------------------------------------------------
-- 9. Timeline de eventos do lead (lead_eventos) — enriquece tela de detalhe
-- ---------------------------------------------------------------------
INSERT INTO comercial.lead_eventos (lead_id, tipo, descricao, created_at)
SELECT l.id, e.tipo, e.descricao, e.created_at
FROM (VALUES
  ('+5567991110014', 'mensagem',      'Primeiro contato via WhatsApp (anúncio de protocolo).', now() - interval '6 days'),
  ('+5567991110014', 'analise',       'Conversa analisada: score 88 (interesse alto).',         now() - interval '4 hours'),
  ('+5567991110014', 'call',          'Avaliação realizada — protocolo viável.',                now() - interval '4 hours'),
  ('+5567991110001', 'mensagem',      'Primeiro contato via Instagram.',                        now() - interval '70 days'),
  ('+5567991110001', 'call',          'Call de fechamento — protocolo + HOF.',                  now() - interval '58 days'),
  ('+5567991110001', 'status_change', 'Status alterado para "fechou".',                         now() - interval '58 days'),
  ('+5567991110001', 'analise',       'Conversa analisada: score 92 (cliente satisfeito).',     now() - interval '58 days'),
  ('+5567991110017', 'mensagem',      'Pediu valor de lentes via Instagram.',                   now() - interval '15 days'),
  ('+5567991110017', 'analise',       'Conversa analisada: score 29 (ALERTA — abandonou).',     now() - interval '11 days'),
  ('+5567991110017', 'status_change', 'Status alterado para "sem resposta".',                   now() - interval '10 days'),
  ('+5567991110009', 'mensagem',      'Contato sobre implante via Instagram.',                  now() - interval '11 days'),
  ('+5567991110009', 'status_change', 'Status alterado para "agendou".',                        now() - interval '2 days'),
  ('+5567991110022', 'call',          'Call de fechamento — comparou com concorrente.',         now() - interval '30 days'),
  ('+5567991110022', 'status_change', 'Status alterado para "perdido".',                        now() - interval '30 days')
) AS e(numero, tipo, descricao, created_at)
JOIN comercial.leads l ON l.telefone = e.numero
ON CONFLICT DO NOTHING;

-- =====================================================================
-- Fim do seed DEMO.
-- Próximo passo após rodar: criar usuário admin de demonstração com
--   npm run admin:create-user
-- e logar para navegar dashboard / leads / calls / whatsapp / rondas.
-- =====================================================================
