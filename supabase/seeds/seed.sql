-- =====================================================================
-- Seed de desenvolvimento — Atlas OS Comercial
-- Executado no SQL Editor do Supabase (schema comercial)
-- =====================================================================

-- Limpar dados existentes (ordem inversa de dependências)
TRUNCATE comercial.auditoria          CASCADE;
TRUNCATE comercial.lead_eventos       CASCADE;
TRUNCATE comercial.analises_calls     CASCADE;
TRUNCATE comercial.analises_whatsapp  CASCADE;
TRUNCATE comercial.mensagens          CASCADE;
TRUNCATE comercial.conversas          CASCADE;
TRUNCATE comercial.calls              CASCADE;
TRUNCATE comercial.leads              CASCADE;
TRUNCATE comercial.rondas             CASCADE;
TRUNCATE comercial.evolution_instances CASCADE;

-- Configuração da clínica
UPDATE comercial.configuracoes SET
  nome_clinica                       = 'Clínica Estética Lumina',
  destinatarios_whatsapp             = ARRAY['rodrigo@benitesalbuquerque.com.br'],
  destinatarios_calls                = ARRAY['rodrigo@benitesalbuquerque.com.br'],
  threshold_score_baixo              = 50,
  threshold_alerta_imediato_whatsapp = 30,
  janela_analise_mensagens           = 50,
  retencao_meses                     = 24
WHERE id = 1;

-- Evolution instance
INSERT INTO comercial.evolution_instances (id, apelido, evolution_url, evolution_api_key, instance_name, webhook_secret, ativa)
VALUES (
  'aaaaaaaa-0000-0000-0000-000000000001',
  'WhatsApp Lumina',
  'https://evolution.lumina.com.br',
  'evo-key-placeholder',
  'lumina-comercial',
  'wh-secret-placeholder',
  true
);

-- =====================================================================
-- LEADS (25)
-- =====================================================================
INSERT INTO comercial.leads (id, nome, telefone, email, status, status_origem, status_atualizado_em, origem, origem_confidence, origem_status, observacoes, created_at)
VALUES
  ('bbbbbbbb-0001-0000-0000-000000000001', 'Ana Paula Costa',       '+5511991110001', 'ana.costa@gmail.com',        'fechou',          'sistema', now()-'2 days'::interval,  'instagram',  0.92, 'detectado', 'Fechou pacote completo de harmonização facial.',  now()-'30 days'::interval),
  ('bbbbbbbb-0002-0000-0000-000000000002', 'Bruno Henrique Lima',   '+5511991110002', null,                         'compareceu',      'sistema', now()-'1 day'::interval,   'google',     0.87, 'detectado', null,                                             now()-'25 days'::interval),
  ('bbbbbbbb-0003-0000-0000-000000000003', 'Carla Nunes Silveira',  '+5511991110003', 'carla.nunes@outlook.com',    'agendou',         'sistema', now()-'3 hours'::interval, 'instagram',  0.79, 'detectado', 'Interessada em botox e preenchimento.',           now()-'20 days'::interval),
  ('bbbbbbbb-0004-0000-0000-000000000004', 'Diego Ferreira Alves',  '+5511991110004', null,                         'em_atendimento',  'sistema', now()-'5 hours'::interval, 'indicacao',  0.95, 'detectado', 'Indicado pela Ana Paula.',                        now()-'15 days'::interval),
  ('bbbbbbbb-0005-0000-0000-000000000005', 'Elaine Souza Mendes',   '+5511991110005', 'elaine.m@gmail.com',         'perdido',         'manual',  now()-'5 days'::interval,  'facebook',   0.61, 'detectado', 'Preferiu clínica mais próxima de casa.',          now()-'40 days'::interval),
  ('bbbbbbbb-0006-0000-0000-000000000006', 'Fábio Moraes Torres',   '+5511991110006', null,                         'sem_resposta',    'sistema', now()-'7 days'::interval,  'google',     0.73, 'detectado', null,                                             now()-'35 days'::interval),
  ('bbbbbbbb-0007-0000-0000-000000000007', 'Gabriela Ramos Pinto',  '+5511991110007', 'gabriela.r@gmail.com',       'fechou',          'sistema', now()-'1 day'::interval,   'instagram',  0.88, 'detectado', 'Fechou limpeza de pele + peeling.',              now()-'18 days'::interval),
  ('bbbbbbbb-0008-0000-0000-000000000008', 'Henrique Dias Cunha',   '+5511991110008', null,                         'novo',            'sistema', now(),                     'whatsapp_ativo', null, 'pendente', null,                                           now()-'1 hour'::interval),
  ('bbbbbbbb-0009-0000-0000-000000000009', 'Isabela Martins Cruz',  '+5511991110009', 'isa.martins@gmail.com',      'agendou',         'sistema', now()-'2 hours'::interval, 'instagram',  0.84, 'detectado', 'Quer agendar para o sábado.',                     now()-'10 days'::interval),
  ('bbbbbbbb-0010-0000-0000-000000000010', 'João Victor Souza',     '+5511991110010', null,                         'em_atendimento',  'sistema', now()-'1 hour'::interval,  'google',     0.66, 'detectado', null,                                             now()-'8 days'::interval),
  ('bbbbbbbb-0011-0000-0000-000000000011', 'Karina Lima Barros',    '+5511991110011', 'karina.lb@hotmail.com',      'compareceu',      'sistema', now()-'3 days'::interval,  'indicacao',  0.97, 'detectado', 'Veio com a irmã na consulta.',                    now()-'22 days'::interval),
  ('bbbbbbbb-0012-0000-0000-000000000012', 'Lucas Pereira Santos',  '+5511991110012', null,                         'perdido',         'manual',  now()-'10 days'::interval, 'facebook',   0.55, 'detectado', 'Achou o preço alto, não retornou.',              now()-'45 days'::interval),
  ('bbbbbbbb-0013-0000-0000-000000000013', 'Mariana Oliveira Reis', '+5511991110013', 'mari.reis@gmail.com',        'fechou',          'sistema', now()-'3 days'::interval,  'instagram',  0.91, 'detectado', 'Fechou rinoplastia não-cirúrgica.',               now()-'28 days'::interval),
  ('bbbbbbbb-0014-0000-0000-000000000014', 'Natalia Rodrigues Melo','+5511991110014', null,                         'sem_resposta',    'sistema', now()-'4 days'::interval,  'google',     0.70, 'detectado', null,                                             now()-'12 days'::interval),
  ('bbbbbbbb-0015-0000-0000-000000000015', 'Otávio Gomes Farias',   '+5511991110015', 'otavio.gomes@gmail.com',     'em_atendimento',  'sistema', now()-'30 min'::interval,  'organico',   null, 'pendente',  null,                                             now()-'3 days'::interval),
  ('bbbbbbbb-0016-0000-0000-000000000016', 'Paula Vieira Campos',   '+5511991110016', 'paula.vc@gmail.com',         'agendou',         'sistema', now()-'6 hours'::interval, 'instagram',  0.82, 'detectado', 'Interessada em skinbooster.',                     now()-'6 days'::interval),
  ('bbbbbbbb-0017-0000-0000-000000000017', 'Rafael Carvalho Neto',  '+5511991110017', null,                         'novo',            'sistema', now()-'2 hours'::interval, 'google',     0.74, 'detectado', null,                                             now()-'2 hours'::interval),
  ('bbbbbbbb-0018-0000-0000-000000000018', 'Sandra Alves Monteiro', '+5511991110018', 'sandra.am@outlook.com',      'compareceu',      'sistema', now()-'2 days'::interval,  'facebook',   0.58, 'detectado', 'Veio mas ainda não decidiu.',                     now()-'16 days'::interval),
  ('bbbbbbbb-0019-0000-0000-000000000019', 'Thiago Rocha Duarte',   '+5511991110019', null,                         'fechou',          'sistema', now()-'1 day'::interval,   'indicacao',  0.99, 'detectado', 'Indicado por 3 clientes. Fechou na 1ª consulta.', now()-'14 days'::interval),
  ('bbbbbbbb-0020-0000-0000-000000000020', 'Ursula Fernandes Lima', '+5511991110020', 'ursula.fl@gmail.com',        'sem_resposta',    'sistema', now()-'8 days'::interval,  'instagram',  0.76, 'detectado', null,                                             now()-'20 days'::interval),
  ('bbbbbbbb-0021-0000-0000-000000000021', 'Vitor Nascimento Pires','+5511991110021', null,                         'em_atendimento',  'sistema', now()-'45 min'::interval,  'organico',   null, 'pendente',  null,                                             now()-'1 day'::interval),
  ('bbbbbbbb-0022-0000-0000-000000000022', 'Wanda Correia Batista', '+5511991110022', 'wanda.cb@gmail.com',         'agendou',         'sistema', now()-'1 hour'::interval,  'google',     0.69, 'detectado', 'Perguntou bastante sobre recuperação.',           now()-'5 days'::interval),
  ('bbbbbbbb-0023-0000-0000-000000000023', 'Xavier Lopes Mendes',   '+5511991110023', null,                         'perdido',         'manual',  now()-'6 days'::interval,  'facebook',   0.50, 'detectado', 'Não respondeu após 5 tentativas.',               now()-'50 days'::interval),
  ('bbbbbbbb-0024-0000-0000-000000000024', 'Yasmin Torres Aguiar',  '+5511991110024', 'yasmin.ta@gmail.com',        'compareceu',      'sistema', now()-'1 day'::interval,   'instagram',  0.89, 'detectado', 'Veio à consulta, quer pensar antes de fechar.',   now()-'9 days'::interval),
  ('bbbbbbbb-0025-0000-0000-000000000025', 'Zélia Pacheco Ramos',   '+5511991110025', null,                         'novo',            'sistema', now(),                     'whatsapp_ativo', null, 'pendente', null,                                           now()-'30 min'::interval);

-- =====================================================================
-- CONVERSAS (12)
-- =====================================================================
INSERT INTO comercial.conversas (id, lead_id, evolution_instance_id, numero_whatsapp, status, ultimo_score, ultima_analise_em, ultima_mensagem_em, created_at)
VALUES
  ('cccccccc-0001-0000-0000-000000000001', 'bbbbbbbb-0001-0000-0000-000000000001', 'aaaaaaaa-0000-0000-0000-000000000001', '+5511991110001', 'encerrada', 88.5, now()-'2 days'::interval,  now()-'2 days'::interval,  now()-'30 days'::interval),
  ('cccccccc-0002-0000-0000-000000000002', 'bbbbbbbb-0002-0000-0000-000000000002', 'aaaaaaaa-0000-0000-0000-000000000001', '+5511991110002', 'encerrada', 72.0, now()-'3 days'::interval,  now()-'3 days'::interval,  now()-'25 days'::interval),
  ('cccccccc-0003-0000-0000-000000000003', 'bbbbbbbb-0003-0000-0000-000000000003', 'aaaaaaaa-0000-0000-0000-000000000001', '+5511991110003', 'aguardando',76.5, now()-'1 day'::interval,   now()-'3 hours'::interval, now()-'20 days'::interval),
  ('cccccccc-0004-0000-0000-000000000004', 'bbbbbbbb-0004-0000-0000-000000000004', 'aaaaaaaa-0000-0000-0000-000000000001', '+5511991110004', 'ativa',     81.0, now()-'2 hours'::interval, now()-'1 hour'::interval,  now()-'15 days'::interval),
  ('cccccccc-0005-0000-0000-000000000005', 'bbbbbbbb-0005-0000-0000-000000000005', 'aaaaaaaa-0000-0000-0000-000000000001', '+5511991110005', 'encerrada', 28.0, now()-'5 days'::interval,  now()-'5 days'::interval,  now()-'40 days'::interval),
  ('cccccccc-0006-0000-0000-000000000006', 'bbbbbbbb-0007-0000-0000-000000000007', 'aaaaaaaa-0000-0000-0000-000000000001', '+5511991110007', 'encerrada', 91.0, now()-'2 days'::interval,  now()-'2 days'::interval,  now()-'18 days'::interval),
  ('cccccccc-0007-0000-0000-000000000007', 'bbbbbbbb-0009-0000-0000-000000000009', 'aaaaaaaa-0000-0000-0000-000000000001', '+5511991110009', 'aguardando',79.5, now()-'1 day'::interval,   now()-'2 hours'::interval, now()-'10 days'::interval),
  ('cccccccc-0008-0000-0000-000000000008', 'bbbbbbbb-0010-0000-0000-000000000010', 'aaaaaaaa-0000-0000-0000-000000000001', '+5511991110010', 'ativa',     63.0, now()-'4 hours'::interval, now()-'1 hour'::interval,  now()-'8 days'::interval),
  ('cccccccc-0009-0000-0000-000000000009', 'bbbbbbbb-0013-0000-0000-000000000013', 'aaaaaaaa-0000-0000-0000-000000000001', '+5511991110013', 'encerrada', 94.0, now()-'4 days'::interval,  now()-'4 days'::interval,  now()-'28 days'::interval),
  ('cccccccc-0010-0000-0000-000000000010', 'bbbbbbbb-0016-0000-0000-000000000016', 'aaaaaaaa-0000-0000-0000-000000000001', '+5511991110016', 'aguardando',77.0, now()-'6 hours'::interval, now()-'2 hours'::interval, now()-'6 days'::interval),
  ('cccccccc-0011-0000-0000-000000000011', 'bbbbbbbb-0019-0000-0000-000000000019', 'aaaaaaaa-0000-0000-0000-000000000001', '+5511991110019', 'encerrada', 96.0, now()-'2 days'::interval,  now()-'2 days'::interval,  now()-'14 days'::interval),
  ('cccccccc-0012-0000-0000-000000000012', 'bbbbbbbb-0021-0000-0000-000000000021', 'aaaaaaaa-0000-0000-0000-000000000001', '+5511991110021', 'ativa',     58.0, now()-'30 min'::interval,  now()-'20 min'::interval,  now()-'1 day'::interval);

-- =====================================================================
-- MENSAGENS (amostra representativa por conversa)
-- =====================================================================
INSERT INTO comercial.mensagens (conversa_id, tipo, fonte, conteudo, remetente, enviada_em)
VALUES
  -- Conversa 1 (Ana Paula — fechou)
  ('cccccccc-0001-0000-0000-000000000001', 'texto', 'humano',   'Oi! Vi o post de vocês no Instagram sobre harmonização facial. Queria saber mais sobre os preços.', 'lead',    now()-'30 days'::interval),
  ('cccccccc-0001-0000-0000-000000000001', 'texto', 'humano',   'Olá Ana Paula! Que bom que nos encontrou. Posso te passar todas as informações. Qual procedimento te interessa mais?', 'atendente', now()-'30 days'::interval + '2 min'::interval),
  ('cccccccc-0001-0000-0000-000000000001', 'texto', 'humano',   'Estou pensando em botox e talvez preenchimento labial. Já fiz botox antes mas aqui perto de casa a doutora fechou o consultório.', 'lead', now()-'29 days'::interval),
  ('cccccccc-0001-0000-0000-000000000001', 'texto', 'humano',   'Entendo! Nossa médica Dra. Fernanda é especialista em harmonização. A avaliação inicial é gratuita. Posso agendar pra você?', 'atendente', now()-'29 days'::interval + '5 min'::interval),
  ('cccccccc-0001-0000-0000-000000000001', 'texto', 'humano',   'Sim! Que dias têm disponibilidade?', 'lead', now()-'29 days'::interval + '10 min'::interval),
  ('cccccccc-0001-0000-0000-000000000001', 'texto', 'humano',   'Temos terça às 14h ou quinta às 10h. Qual prefere?', 'atendente', now()-'29 days'::interval + '12 min'::interval),
  ('cccccccc-0001-0000-0000-000000000001', 'texto', 'humano',   'Quinta às 10h perfeito!', 'lead', now()-'29 days'::interval + '15 min'::interval),
  ('cccccccc-0001-0000-0000-000000000001', 'texto', 'humano',   'Agendado! Te mando o endereço e confirmação por aqui. Até quinta!', 'atendente', now()-'29 days'::interval + '17 min'::interval),

  -- Conversa 3 (Carla — agendou, aguardando)
  ('cccccccc-0003-0000-0000-000000000003', 'texto', 'humano',   'Boa tarde! Vocês fazem botox e preenchimento?', 'lead',      now()-'20 days'::interval),
  ('cccccccc-0003-0000-0000-000000000003', 'texto', 'humano',   'Boa tarde, Carla! Sim, fazemos os dois. Quer marcar uma avaliação gratuita?', 'atendente', now()-'20 days'::interval + '3 min'::interval),
  ('cccccccc-0003-0000-0000-000000000003', 'texto', 'humano',   'Quanto custa mais ou menos o botox?', 'lead',      now()-'20 days'::interval + '8 min'::interval),
  ('cccccccc-0003-0000-0000-000000000003', 'texto', 'humano',   'Varia com a quantidade de pontos. Na avaliação a doutora indica o que é necessário e passa o orçamento exato.', 'atendente', now()-'20 days'::interval + '11 min'::interval),
  ('cccccccc-0003-0000-0000-000000000003', 'texto', 'humano',   'Tá bom, posso ir no sábado?', 'lead',      now()-'5 days'::interval),
  ('cccccccc-0003-0000-0000-000000000003', 'texto', 'humano',   'Temos sábado às 9h ou 11h. Qual prefere?', 'atendente', now()-'5 days'::interval + '4 min'::interval),
  ('cccccccc-0003-0000-0000-000000000003', 'texto', 'humano',   'Às 9h!', 'lead',      now()-'5 days'::interval + '6 min'::interval),
  ('cccccccc-0003-0000-0000-000000000003', 'texto', 'humano',   'Perfeito! Confirmado para sábado às 9h. Qualquer dúvida é só falar aqui!', 'atendente', now()-'5 days'::interval + '8 min'::interval),

  -- Conversa 4 (Diego — em atendimento)
  ('cccccccc-0004-0000-0000-000000000004', 'texto', 'humano',   'Oi, a Ana Paula me indicou a clínica de vocês. Ela ficou muito bem!', 'lead',      now()-'15 days'::interval),
  ('cccccccc-0004-0000-0000-000000000004', 'texto', 'humano',   'Que legal, fico feliz! A Ana Paula ficou linda mesmo. O que você tem interesse em fazer?', 'atendente', now()-'15 days'::interval + '3 min'::interval),
  ('cccccccc-0004-0000-0000-000000000004', 'texto', 'humano',   'Nunca fiz nada mas tô curioso sobre o que dá pra fazer pra parecer mais descansado. Tenho olheira profunda.', 'lead', now()-'15 days'::interval + '10 min'::interval),
  ('cccccccc-0004-0000-0000-000000000004', 'texto', 'humano',   'Para olheiras temos preenchimento com ácido hialurônico, que dá resultado incrível. Quer agendar avaliação?', 'atendente', now()-'15 days'::interval + '13 min'::interval),
  ('cccccccc-0004-0000-0000-000000000004', 'texto', 'humano',   'Tenho um pouco de medo de agulha, dói muito?', 'lead',      now()-'14 days'::interval),
  ('cccccccc-0004-0000-0000-000000000004', 'texto', 'humano',   'É bem tranquilo! Usamos anestésico tópico antes. A maioria dos clientes se surpreende com o quanto é confortável.', 'atendente', now()-'14 days'::interval + '5 min'::interval),
  ('cccccccc-0004-0000-0000-000000000004', 'texto', 'humano',   'Que bom. Vou pensar e te falo!', 'lead',      now()-'10 days'::interval),
  ('cccccccc-0004-0000-0000-000000000004', 'texto', 'humano',   'Claro Diego! Qualquer dúvida estou aqui. 😊', 'atendente', now()-'10 days'::interval + '2 min'::interval),
  ('cccccccc-0004-0000-0000-000000000004', 'texto', 'humano',   'Oi! Decidi quero agendar. Como funciona?', 'lead',      now()-'2 hours'::interval),

  -- Conversa 5 (Elaine — perdido, score baixo)
  ('cccccccc-0005-0000-0000-000000000005', 'texto', 'humano',   'Oi queria saber sobre procedimentos', 'lead',      now()-'40 days'::interval),
  ('cccccccc-0005-0000-0000-000000000005', 'texto', 'humano',   'Olá! Qual procedimento te interessa?', 'atendente', now()-'40 days'::interval + '5 min'::interval),
  ('cccccccc-0005-0000-0000-000000000005', 'texto', 'humano',   'tudo bem obrigada', 'lead',      now()-'38 days'::interval),
  ('cccccccc-0005-0000-0000-000000000005', 'texto', 'humano',   'Posso te ajudar com informações sobre qualquer procedimento! Quer agendar uma avaliação gratuita?', 'atendente', now()-'38 days'::interval + '2 min'::interval),
  ('cccccccc-0005-0000-0000-000000000005', 'texto', 'humano',   'prefiro uma clínica mais perto de casa mesmo, obrigada', 'lead', now()-'36 days'::interval),

  -- Conversa 6 (Gabriela — fechou, score alto)
  ('cccccccc-0006-0000-0000-000000000006', 'texto', 'humano',   'Meninas do Instagram falaram muito bem de vocês! Fazem limpeza de pele?', 'lead',      now()-'18 days'::interval),
  ('cccccccc-0006-0000-0000-000000000006', 'texto', 'humano',   'Olá Gabriela! Sim, temos limpeza de pele e peeling. Quer saber mais?', 'atendente', now()-'18 days'::interval + '2 min'::interval),
  ('cccccccc-0006-0000-0000-000000000006', 'texto', 'humano',   'Quanto custa a limpeza?', 'lead',      now()-'18 days'::interval + '8 min'::interval),
  ('cccccccc-0006-0000-0000-000000000006', 'texto', 'humano',   'A limpeza de pele profunda é R$180. Temos também o combo limpeza + peeling por R$280.', 'atendente', now()-'18 days'::interval + '10 min'::interval),
  ('cccccccc-0006-0000-0000-000000000006', 'texto', 'humano',   'Quero o combo! Que horários têm?', 'lead',      now()-'18 days'::interval + '15 min'::interval),
  ('cccccccc-0006-0000-0000-000000000006', 'texto', 'humano',   'Segunda às 15h ou quarta às 10h. Qual prefere?', 'atendente', now()-'18 days'::interval + '17 min'::interval),
  ('cccccccc-0006-0000-0000-000000000006', 'texto', 'humano',   'Segunda às 15h! Pago na hora?', 'lead',      now()-'18 days'::interval + '20 min'::interval),
  ('cccccccc-0006-0000-0000-000000000006', 'texto', 'humano',   'Sim, aceitamos PIX e cartão. Agendado! Te vejo segunda. 🌟', 'atendente', now()-'18 days'::interval + '22 min'::interval),

  -- Conversa 8 (João — em atendimento, dúvidas)
  ('cccccccc-0008-0000-0000-000000000008', 'texto', 'humano',   'Oi, encontrei vocês no Google. Fazem tratamento para rugas?', 'lead',      now()-'8 days'::interval),
  ('cccccccc-0008-0000-0000-000000000008', 'texto', 'humano',   'Olá João! Sim, temos botox e skincare. Qual região te preocupa mais?', 'atendente', now()-'8 days'::interval + '5 min'::interval),
  ('cccccccc-0008-0000-0000-000000000008', 'texto', 'humano',   'Testa e ao redor dos olhos. Já tenho 42 anos e começou a marcar bastante.', 'lead', now()-'8 days'::interval + '12 min'::interval),
  ('cccccccc-0008-0000-0000-000000000008', 'texto', 'humano',   'Para essa área o botox é excelente! O efeito dura 4-6 meses. Quer agendar avaliação gratuita?', 'atendente', now()-'8 days'::interval + '15 min'::interval),
  ('cccccccc-0008-0000-0000-000000000008', 'texto', 'humano',   'Pode sim. Mas qual é o preço médio?', 'lead',      now()-'8 days'::interval + '20 min'::interval),
  ('cccccccc-0008-0000-0000-000000000008', 'texto', 'humano',   'Depende da quantidade de áreas. Em média R$600-R$900 para testa + olhos. Na avaliação passa o valor exato.', 'atendente', now()-'8 days'::interval + '22 min'::interval),
  ('cccccccc-0008-0000-0000-000000000008', 'texto', 'humano',   'Ok, vou pensar. Quanto tempo dura o procedimento?', 'lead',      now()-'4 hours'::interval),
  ('cccccccc-0008-0000-0000-000000000008', 'texto', 'humano',   'O procedimento em si são cerca de 20 minutos. Rápido e sem recuperação!', 'atendente', now()-'3 hours'::interval),

  -- Conversa 11 (Thiago — fechou, score máximo)
  ('cccccccc-0011-0000-0000-000000000011', 'texto', 'humano',   'Boa noite! Três amigos meus fizeram procedimentos aí e todos adoraram. Quero marcar!', 'lead',      now()-'14 days'::interval),
  ('cccccccc-0011-0000-0000-000000000011', 'texto', 'humano',   'Que incrível, Thiago! Fico muito feliz! O que você quer fazer?', 'atendente', now()-'14 days'::interval + '3 min'::interval),
  ('cccccccc-0011-0000-0000-000000000011', 'texto', 'humano',   'Harmonização facial completa. Botox, preenchimento, o pacote completo mesmo.', 'lead', now()-'14 days'::interval + '8 min'::interval),
  ('cccccccc-0011-0000-0000-000000000011', 'texto', 'humano',   'Perfeito! Temos um pacote completo de harmonização. A avaliação já inclui o plano de tratamento personalizado.', 'atendente', now()-'14 days'::interval + '10 min'::interval),
  ('cccccccc-0011-0000-0000-000000000011', 'texto', 'humano',   'Pode marcar pra amanhã?', 'lead',      now()-'14 days'::interval + '15 min'::interval),
  ('cccccccc-0011-0000-0000-000000000011', 'texto', 'humano',   'Amanhã às 14h está ótimo! Te confirmo por aqui.', 'atendente', now()-'14 days'::interval + '17 min'::interval),
  ('cccccccc-0011-0000-0000-000000000011', 'texto', 'humano',   'Fechado! Obrigado pela atenção.', 'lead',      now()-'14 days'::interval + '20 min'::interval),

  -- Conversa 12 (Vitor — em atendimento, score médio)
  ('cccccccc-0012-0000-0000-000000000012', 'texto', 'humano',   'Oi! Queria informações sobre skinbooster', 'lead',      now()-'1 day'::interval),
  ('cccccccc-0012-0000-0000-000000000012', 'texto', 'humano',   'Olá! O skinbooster é um hidratante profundo injetável, ótimo para pele opaca. Quer saber mais?', 'atendente', now()-'1 day'::interval + '10 min'::interval),
  ('cccccccc-0012-0000-0000-000000000012', 'texto', 'humano',   'Sim! Funciona bem para pele oleosa também?', 'lead',      now()-'23 hours'::interval),
  ('cccccccc-0012-0000-0000-000000000012', 'texto', 'humano',   'Funciona! Para pele oleosa recomendamos o protocolo com ácido hialurônico não-reticulado. Quer agendar?', 'atendente', now()-'22 hours'::interval),
  ('cccccccc-0012-0000-0000-000000000012', 'texto', 'humano',   'Quanto custa?', 'lead',      now()-'20 min'::interval);

-- =====================================================================
-- CALLS (10)
-- =====================================================================
INSERT INTO comercial.calls (id, lead_id, titulo, duracao_segundos, transcricao, transcricao_origem, telefone_extraido, match_status, match_sugestoes, realizada_em, created_at)
VALUES
  ('dddddddd-0001-0000-0000-000000000001', 'bbbbbbbb-0001-0000-0000-000000000001',
   'Consulta Ana Paula — Harmonização', 1842,
   'Atendente: Bom dia, clínica Lumina. Ana Paula: Bom dia! Vim fazer a avaliação que agendei pelo WhatsApp. ... [transcrição completa] ... Ana Paula: Adorei, vou fechar o pacote completo! Quanto fica no PIX? Atendente: No PIX fica R$2.800. Ótima escolha!',
   'plaud', '+5511991110001', 'confirmado', null, now()-'27 days'::interval, now()-'27 days'::interval),

  ('dddddddd-0002-0000-0000-000000000002', 'bbbbbbbb-0002-0000-0000-000000000002',
   'Consulta Bruno — Avaliação Inicial', 1120,
   'Atendente: Boa tarde! Bruno: Boa tarde, vim fazer avaliação sobre botox. ... Bruno: Deixa eu pensar e ligo de volta.',
   'plaud', '+5511991110002', 'confirmado', null, now()-'22 days'::interval, now()-'22 days'::interval),

  ('dddddddd-0003-0000-0000-000000000003', 'bbbbbbbb-0007-0000-0000-000000000007',
   'Consulta Gabriela — Limpeza e Peeling', 860,
   'Atendente: Olá Gabriela! Gabriela: Oi, vim pro combo de limpeza! Atendente: Ótimo! ... Gabriela: Ficou incrível, quero marcar de novo daqui 30 dias.',
   'plaud', '+5511991110007', 'confirmado', null, now()-'15 days'::interval, now()-'15 days'::interval),

  ('dddddddd-0004-0000-0000-000000000004', 'bbbbbbbb-0013-0000-0000-000000000013',
   'Consulta Mariana — Rinoplastia Não-cirúrgica', 2240,
   'Atendente: Mariana, bom dia! Mariana: Bom dia! Queria entender melhor como funciona a rinoplastia sem cirurgia. ... [extensa explicação] ... Mariana: Ok, decidi. Vou fazer!',
   'plaud', '+5511991110013', 'confirmado', null, now()-'24 days'::interval, now()-'24 days'::interval),

  ('dddddddd-0005-0000-0000-000000000005', 'bbbbbbbb-0019-0000-0000-000000000019',
   'Consulta Thiago — Harmonização Completa', 2680,
   'Atendente: Thiago! Thiago: Oi boa tarde. Vim fazer a harmonização que marcamos. ... Thiago: Cara ficou muito bom mesmo. Vou indicar pra mais amigos.',
   'plaud', '+5511991110019', 'confirmado', null, now()-'12 days'::interval, now()-'12 days'::interval),

  ('dddddddd-0006-0000-0000-000000000006', 'bbbbbbbb-0011-0000-0000-000000000011',
   'Consulta Karina — Retorno', 970,
   'Atendente: Karina, boa tarde! Karina: Boa tarde! Voltei com minha irmã, ela quer fazer o mesmo que eu fiz. ...',
   'plaud', '+5511991110011', 'confirmado', null, now()-'18 days'::interval, now()-'18 days'::interval),

  ('dddddddd-0007-0000-0000-000000000007', null,
   'Ligação não identificada — 55119', 340,
   'Atendente: Clínica Lumina, bom dia! Desconhecido: Oi queria saber sobre preços de botox. Atendente: Claro! Pode me dizer seu nome? Desconhecido: É Patricia. Atendente: Patricia, vou te passar as informações...',
   'plaud', '+5511999887766', 'sugerido',
   '[{"lead_id":"bbbbbbbb-0016-0000-0000-000000000016","nome":"Paula Vieira Campos","telefone":"+5511991110016","confidence":0.42},{"lead_id":"bbbbbbbb-0020-0000-0000-000000000020","nome":"Ursula Fernandes Lima","telefone":"+5511991110020","confidence":0.31}]',
   now()-'4 days'::interval, now()-'4 days'::interval),

  ('dddddddd-0008-0000-0000-000000000008', 'bbbbbbbb-0018-0000-0000-000000000018',
   'Consulta Sandra — Primeira Avaliação', 1540,
   'Atendente: Sandra, bem-vinda! Sandra: Obrigada. Nunca fiz nada assim antes, estou um pouco nervosa. Atendente: Relaxa, é só uma conversa! ... Sandra: Preciso pensar, mas gostei muito da explicação.',
   'plaud', '+5511991110018', 'confirmado', null, now()-'13 days'::interval, now()-'13 days'::interval),

  ('dddddddd-0009-0000-0000-000000000009', null,
   'Ligação sem transcrição — Zapier', 180,
   null, null, null, 'pendente', null,
   now()-'1 day'::interval, now()-'1 day'::interval),

  ('dddddddd-0010-0000-0000-000000000010', 'bbbbbbbb-0024-0000-0000-000000000024',
   'Consulta Yasmin — Avaliação Facial', 1320,
   'Atendente: Yasmin, boa tarde! Yasmin: Boa tarde! Queria muito fazer alguma coisa, mas confesso que estou com medo do resultado ficar artificial. Atendente: Entendo totalmente! Nossa filosofia é resultado natural. ... Yasmin: Vou pensar mais um pouco.',
   'plaud', '+5511991110024', 'confirmado', null, now()-'6 days'::interval, now()-'6 days'::interval);

-- =====================================================================
-- ANÁLISES WHATSAPP (12)
-- =====================================================================
INSERT INTO comercial.analises_whatsapp (conversa_id, score, tags_positivas, tags_negativas, resumo, diagnostico, acao_recomendada, origem_detectada, origem_confidence, total_mensagens_analisadas, modelo, prompt_versao, tokens_entrada, tokens_saida, created_at)
VALUES
  ('cccccccc-0001-0000-0000-000000000001', 88.5,
   ARRAY['interesse_alto','agendou','receptiva','sem_objecao_preco'],
   ARRAY[]::text[],
   'Lead demonstrou interesse imediato após ver post no Instagram. Agendou consulta sem resistência, boa experiência prévia com botox.',
   'Lead quente com alta intenção de compra. Histórico positivo com procedimentos estéticos facilita conversão.',
   'Confirmar consulta no dia anterior. Alta probabilidade de fechamento.',
   'instagram', 0.92, 8, 'claude-sonnet-4-6', 'v1', 1240, 380, now()-'28 days'::interval),

  ('cccccccc-0002-0000-0000-000000000002', 72.0,
   ARRAY['interesse_moderado','sem_objecao_clara'],
   ARRAY['indeciso','precisou_pensar'],
   'Lead chegou pelo Google, mostrou interesse em botox mas foi evasivo sobre agendamento.',
   'Lead morno. Sem objeção clara mas sem urgência. Possível comparação com concorrentes.',
   'Fazer follow-up em 3 dias oferecendo avaliação gratuita com bônus.',
   'google', 0.87, 6, 'claude-sonnet-4-6', 'v1', 980, 290, now()-'23 days'::interval),

  ('cccccccc-0003-0000-0000-000000000003', 76.5,
   ARRAY['interesse_alto','agendou','perguntou_preco'],
   ARRAY['demorou_responder'],
   'Lead interessada em botox e preenchimento. Pediu informações de preço mas aceitou avaliação gratuita e agendou.',
   'Lead com bom potencial. Demorou 15 dias para agendar, o que pode indicar pesquisa de preço em concorrentes.',
   'Confirmar presença na véspera. Preparar proposta com pacote combo.',
   'instagram', 0.79, 8, 'claude-sonnet-4-6', 'v1', 1100, 320, now()-'1 day'::interval),

  ('cccccccc-0004-0000-0000-000000000004', 81.0,
   ARRAY['indicacao_forte','interesse_real','suprimiu_objecao_dor'],
   ARRAY['medo_agulha','indeciso_inicialmente'],
   'Lead indicado por cliente satisfeita (Ana Paula). Manifestou medo de agulha mas foi bem conduzido. Retornou após 10 dias querendo agendar.',
   'Indicação qualificada. O retorno espontâneo após 10 dias confirma intenção real. A objeção de dor foi tratada.',
   'Agendar com urgência. Aproveitar o momento de retorno.',
   'indicacao', 0.95, 10, 'claude-sonnet-4-6', 'v1', 1560, 420, now()-'2 hours'::interval),

  ('cccccccc-0005-0000-0000-000000000005', 28.0,
   ARRAY[]::text[],
   ARRAY['desinteressada','concorrente_preferido','resposta_curta','sem_engajamento'],
   'Lead demonstrou interesse mínimo. Saiu da conversa dizendo preferir clínica mais perto de casa.',
   'Lead perdida. Objeção geográfica forte. Respostas curtas desde o início indicavam baixo engajamento.',
   'Marcar como perdida. Sem ação necessária.',
   'facebook', 0.61, 5, 'claude-sonnet-4-6', 'v1', 720, 210, now()-'5 days'::interval),

  ('cccccccc-0006-0000-0000-000000000006', 91.0,
   ARRAY['interesse_imediato','fechou_no_chat','sem_objecao','preco_aceito'],
   ARRAY[]::text[],
   'Lead altamente qualificada. Veio por indicação de amigas do Instagram, perguntou preço e fechou o combo na mesma conversa.',
   'Lead de altíssima qualidade. Fechamento ocorreu em menos de 30 minutos. Indicação social é o canal de maior conversão.',
   'Cliente fidelizada. Solicitar avaliação de satisfação após o procedimento.',
   'instagram', 0.88, 8, 'claude-sonnet-4-6', 'v1', 1080, 310, now()-'2 days'::interval),

  ('cccccccc-0007-0000-0000-000000000007', 79.5,
   ARRAY['interesse_alto','agendou','horario_especifico'],
   ARRAY['demorou_voltar'],
   'Lead interessada em botox/preenchimento. Levou tempo para decidir mas agendou para o sábado.',
   'Lead com potencial. Retorno após longa pausa indica que manteve o interesse.',
   'Confirmar sábado. Ter pacotes prontos para apresentar na consulta.',
   'instagram', 0.84, 8, 'claude-sonnet-4-6', 'v1', 1150, 340, now()-'1 day'::interval),

  ('cccccccc-0008-0000-0000-000000000008', 63.0,
   ARRAY['interesse_moderado','perguntou_preco','perguntou_duracao'],
   ARRAY['pesquisando_opcoes','sem_agendamento'],
   'Lead pesquisando informações detalhadas sobre botox. Várias perguntas técnicas. Ainda não agendou.',
   'Lead em fase de pesquisa. Alto volume de perguntas técnicas sugere que está comparando com outros serviços.',
   'Enviar material de apoio com depoimentos. Oferecer desconto de primeira vez para estimular decisão.',
   'google', 0.66, 8, 'claude-sonnet-4-6', 'v1', 1420, 390, now()-'4 hours'::interval),

  ('cccccccc-0009-0000-0000-000000000009', 94.0,
   ARRAY['interesse_imediato','fechou_no_chat','perguntou_preco','preco_aceito'],
   ARRAY[]::text[],
   'Lead decidida desde o início. Entrou perguntando sobre rinoplastia não-cirúrgica e fechou na mesma sessão.',
   'Lead excepcional. Alta clareza sobre o que quer, sem objeções. Procedimento de ticket alto.',
   'Fidelizar com protocolo de acompanhamento pós-procedimento.',
   'instagram', 0.91, 6, 'claude-sonnet-4-6', 'v1', 920, 280, now()-'4 days'::interval),

  ('cccccccc-0010-0000-0000-000000000010', 77.0,
   ARRAY['interesse_moderado','pergunta_tecnica','skinbooster'],
   ARRAY['perguntou_preco_ao_final'],
   'Lead interessada em skinbooster, fazendo perguntas técnicas específicas. Perguntou preço no final.',
   'Lead qualificada tecnicamente. Demonstra pesquisa prévia. A pergunta de preço ao final pode ser objeção.',
   'Responder preço e oferecer avaliação gratuita com demo do produto.',
   'instagram', 0.82, 5, 'claude-sonnet-4-6', 'v1', 890, 260, now()-'6 hours'::interval),

  ('cccccccc-0011-0000-0000-000000000011', 96.0,
   ARRAY['indicacao_multipla','interesse_imediato','pacote_completo','fechou_rapido'],
   ARRAY[]::text[],
   'Lead indicado por 3 clientes simultâneos. Queria harmonização completa e fechou em menos de 20 minutos.',
   'Lead de altíssima qualidade. Indicação múltipla com forte prova social. Ticket alto, decisão rápida.',
   'Pedir indicação ativa após o procedimento. Oferecer bônus de indicação.',
   'indicacao', 0.99, 7, 'claude-sonnet-4-6', 'v1', 1050, 300, now()-'2 days'::interval),

  ('cccccccc-0012-0000-0000-000000000012', 58.0,
   ARRAY['interesse_real','pergunta_tecnica'],
   ARRAY['perguntou_preco','sem_agendamento','nova_lead'],
   'Lead nova, ainda na fase inicial. Perguntou sobre skinbooster para pele oleosa. Ainda não respondeu sobre preço.',
   'Lead em fase inicial de decisão. Boa qualidade de pergunta mas sem indicadores de urgência.',
   'Responder sobre preço de forma consultiva. Oferecer avaliação gratuita.',
   'organico', null, 5, 'claude-sonnet-4-6', 'v1', 780, 230, now()-'30 min'::interval);

-- =====================================================================
-- ANÁLISES CALLS (8)
-- =====================================================================
INSERT INTO comercial.analises_calls (call_id, classificacao, score_geral, fases, diagnostico, acao_recomendada, modelo, prompt_versao, tokens_entrada, tokens_saida, created_at)
VALUES
  ('dddddddd-0001-0000-0000-000000000001', 'excelente', 92.0,
   '{"rapport":{"score":95,"observacao":"Conexão imediata, cliente muito receptiva"},"identificacao_necessidade":{"score":90,"observacao":"Necessidade clara desde o início"},"apresentacao_solucao":{"score":92,"observacao":"Solução apresentada de forma personalizada"},"manejo_objecao":{"score":88,"observacao":"Sem objeções significativas"},"fechamento":{"score":95,"observacao":"Fechamento natural e rápido, cliente comprometida"}}',
   'Atendimento excelente. A consultora construiu rapport rapidamente e apresentou soluções personalizadas. Fechamento no primeiro contato com ticket de R$2.800.',
   'Usar como case de treinamento para a equipe. Padrão de excelência.',
   'claude-sonnet-4-6', 'v1', 3840, 680, now()-'27 days'::interval),

  ('dddddddd-0002-0000-0000-000000000002', 'bom', 71.0,
   '{"rapport":{"score":78,"observacao":"Bom rapport inicial"},"identificacao_necessidade":{"score":72,"observacao":"Necessidade identificada mas superficialmente"},"apresentacao_solucao":{"score":70,"observacao":"Apresentação padrão sem personalização"},"manejo_objecao":{"score":65,"observacao":"Cliente indeciso, sem técnica de fechamento aplicada"},"fechamento":{"score":68,"observacao":"Sem tentativa de fechamento ativo"}}',
   'Atendimento bom mas perdeu oportunidade de fechamento. O cliente ficou indeciso e não foi guiado para uma decisão. Faltou proposta de follow-up estruturada.',
   'Treinar técnica de fechamento consultivo. Sempre oferecer próximo passo concreto antes de encerrar.',
   'claude-sonnet-4-6', 'v1', 2680, 540, now()-'22 days'::interval),

  ('dddddddd-0003-0000-0000-000000000003', 'excelente', 89.0,
   '{"rapport":{"score":92,"observacao":"Atendimento acolhedor e profissional"},"identificacao_necessidade":{"score":88,"observacao":"Necessidade clara e bem explorada"},"apresentacao_solucao":{"score":90,"observacao":"Combo apresentado com valor claro"},"manejo_objecao":{"score":85,"observacao":"Sem objeções relevantes"},"fechamento":{"score":90,"observacao":"Cliente satisfeita e já planejando retorno"}}',
   'Atendimento excelente. Cliente convertida e já sinalizando fidelização ao planejar nova sessão.',
   'Implementar programa de fidelidade para clientes como Gabriela.',
   'claude-sonnet-4-6', 'v1', 2240, 480, now()-'15 days'::interval),

  ('dddddddd-0004-0000-0000-000000000004', 'excelente', 94.0,
   '{"rapport":{"score":90,"observacao":"Atendimento técnico e confiável"},"identificacao_necessidade":{"score":96,"observacao":"Exploração detalhada do caso e expectativas"},"apresentacao_solucao":{"score":95,"observacao":"Apresentação técnica convincente"},"manejo_objecao":{"score":92,"observacao":"Medo de resultado artificial foi eliminado com exemplos"},"fechamento":{"score":95,"observacao":"Decisão tomada na consulta"}}',
   'Consulta de alto nível técnico. A médica eliminou todas as objeções de forma consultiva. Fechamento de procedimento de ticket alto.',
   'Replicar abordagem técnica com leads que têm medo de resultado artificial.',
   'claude-sonnet-4-6', 'v1', 4480, 720, now()-'24 days'::interval),

  ('dddddddd-0005-0000-0000-000000000005', 'excelente', 97.0,
   '{"rapport":{"score":98,"observacao":"Lead veio extremamente motivado por indicações múltiplas"},"identificacao_necessidade":{"score":96,"observacao":"Necessidade completa, sem hesitação"},"apresentacao_solucao":{"score":97,"observacao":"Plano completo apresentado e aprovado"},"manejo_objecao":{"score":96,"observacao":"Nenhuma objeção"},"fechamento":{"score":98,"observacao":"Fechamento imediato e entusiasmado"}}',
   'Atendimento perfeito em todas as dimensões. Lead com múltiplas indicações garantiu conversão. Cliente saiu como promotor da clínica.',
   'Ativar programa de indicação estruturado com Thiago.',
   'claude-sonnet-4-6', 'v1', 4920, 780, now()-'12 days'::interval),

  ('dddddddd-0006-0000-0000-000000000006', 'bom', 78.0,
   '{"rapport":{"score":88,"observacao":"Ótima recepção, cliente trouxe familiar"},"identificacao_necessidade":{"score":80,"observacao":"Necessidade da irmã ainda não completamente mapeada"},"apresentacao_solucao":{"score":75,"observacao":"Foco na cliente principal, irmã ficou em segundo plano"},"manejo_objecao":{"score":72,"observacao":"Irmã com dúvidas não exploradas"},"fechamento":{"score":76,"observacao":"Consulta encerrada sem agenda para a irmã"}}',
   'Oportunidade perdida com a irmã. A consultora focou na cliente retornante e não explorou a nova lead presente.',
   'Sempre tratar acompanhantes como novas oportunidades. Oferecer avaliação na hora.',
   'claude-sonnet-4-6', 'v1', 2560, 510, now()-'18 days'::interval),

  ('dddddddd-0008-0000-0000-000000000008', 'regular', 58.0,
   '{"rapport":{"score":72,"observacao":"Bom acolhimento para cliente ansiosa"},"identificacao_necessidade":{"score":60,"observacao":"Necessidade explorada mas timidamente"},"apresentacao_solucao":{"score":55,"observacao":"Apresentação genérica sem plano personalizado"},"manejo_objecao":{"score":50,"observacao":"Ansiedade da cliente não tratada adequadamente"},"fechamento":{"score":52,"observacao":"Cliente saiu sem decisão e sem data de retorno"}}',
   'Atendimento abaixo do esperado para uma primeira consulta de cliente ansiosa. Faltou criar um ambiente mais seguro e propor plano de acompanhamento.',
   'Retreinar abordagem para perfis de clientes ansiosas. Oferecer follow-up estruturado em 24-48h.',
   'claude-sonnet-4-6', 'v1', 3240, 580, now()-'13 days'::interval),

  ('dddddddd-0010-0000-0000-000000000010', 'bom', 74.0,
   '{"rapport":{"score":82,"observacao":"Atendimento gentil e acolhedor"},"identificacao_necessidade":{"score":76,"observacao":"Preocupação com resultado artificial identificada"},"apresentacao_solucao":{"score":74,"observacao":"Filosofia da clínica apresentada mas sem exemplos visuais"},"manejo_objecao":{"score":70,"observacao":"Objeção de resultado artificial parcialmente tratada"},"fechamento":{"score":68,"observacao":"Cliente saiu sem decidir, sem data de retorno"}}',
   'Atendimento bom mas a objeção central (medo de resultado artificial) não foi totalmente resolvida. Faltaram fotos de antes/depois e depoimentos.',
   'Preparar portfolio de resultados naturais para usar em consultas. Criar follow-up com cases visuais.',
   'claude-sonnet-4-6', 'v1', 3080, 560, now()-'6 days'::interval);

-- =====================================================================
-- LEAD EVENTOS (timeline)
-- =====================================================================
INSERT INTO comercial.lead_eventos (lead_id, tipo, descricao, payload, created_at)
VALUES
  -- Ana Paula (fechou)
  ('bbbbbbbb-0001-0000-0000-000000000001', 'mensagem',     'Primeiro contato via WhatsApp — veio pelo Instagram', '{"canal":"whatsapp"}', now()-'30 days'::interval),
  ('bbbbbbbb-0001-0000-0000-000000000001', 'status_change','Status: novo → em_atendimento',                       '{"de":"novo","para":"em_atendimento"}', now()-'30 days'::interval + '5 min'::interval),
  ('bbbbbbbb-0001-0000-0000-000000000001', 'status_change','Status: em_atendimento → agendou',                    '{"de":"em_atendimento","para":"agendou"}', now()-'29 days'::interval),
  ('bbbbbbbb-0001-0000-0000-000000000001', 'call',         'Consulta presencial realizada — 30 min',               '{"duracao_segundos":1842}', now()-'27 days'::interval),
  ('bbbbbbbb-0001-0000-0000-000000000001', 'status_change','Status: agendou → compareceu',                        '{"de":"agendou","para":"compareceu"}', now()-'27 days'::interval + '30 min'::interval),
  ('bbbbbbbb-0001-0000-0000-000000000001', 'status_change','Status: compareceu → fechou',                         '{"de":"compareceu","para":"fechou"}', now()-'27 days'::interval + '45 min'::interval),

  -- Carla (agendou)
  ('bbbbbbbb-0003-0000-0000-000000000003', 'mensagem',     'Primeiro contato via WhatsApp',                       '{"canal":"whatsapp"}', now()-'20 days'::interval),
  ('bbbbbbbb-0003-0000-0000-000000000003', 'status_change','Status: novo → em_atendimento',                       '{"de":"novo","para":"em_atendimento"}', now()-'20 days'::interval + '3 min'::interval),
  ('bbbbbbbb-0003-0000-0000-000000000003', 'analise',      'Análise IA: score 76.5 — lead com bom potencial',     '{"score":76.5}', now()-'1 day'::interval),
  ('bbbbbbbb-0003-0000-0000-000000000003', 'status_change','Status: em_atendimento → agendou',                    '{"de":"em_atendimento","para":"agendou"}', now()-'5 days'::interval),

  -- Diego (em atendimento, retornou)
  ('bbbbbbbb-0004-0000-0000-000000000004', 'mensagem',     'Primeiro contato — indicado por Ana Paula Costa',     '{"canal":"whatsapp","indicado_por":"Ana Paula Costa"}', now()-'15 days'::interval),
  ('bbbbbbbb-0004-0000-0000-000000000004', 'status_change','Status: novo → em_atendimento',                       '{"de":"novo","para":"em_atendimento"}', now()-'15 days'::interval + '3 min'::interval),
  ('bbbbbbbb-0004-0000-0000-000000000004', 'nota',         'Cliente com medo de agulha — objeção tratada no chat', '{}', now()-'14 days'::interval),
  ('bbbbbbbb-0004-0000-0000-000000000004', 'mensagem',     'Retornou após 10 dias querendo agendar',              '{"canal":"whatsapp"}', now()-'2 hours'::interval),

  -- Elaine (perdida)
  ('bbbbbbbb-0005-0000-0000-000000000005', 'mensagem',     'Primeiro contato via WhatsApp',                       '{"canal":"whatsapp"}', now()-'40 days'::interval),
  ('bbbbbbbb-0005-0000-0000-000000000005', 'status_change','Status: novo → em_atendimento',                       '{"de":"novo","para":"em_atendimento"}', now()-'40 days'::interval + '5 min'::interval),
  ('bbbbbbbb-0005-0000-0000-000000000005', 'analise',      'Análise IA: score 28 — alerta, lead desengajada',     '{"score":28}', now()-'5 days'::interval),
  ('bbbbbbbb-0005-0000-0000-000000000005', 'status_change','Status: em_atendimento → perdido',                    '{"de":"em_atendimento","para":"perdido","motivo":"Preferiu clínica mais próxima"}', now()-'5 days'::interval),

  -- Gabriela (fechou)
  ('bbbbbbbb-0007-0000-0000-000000000007', 'mensagem',     'Primeiro contato — veio por indicação do Instagram',  '{"canal":"whatsapp"}', now()-'18 days'::interval),
  ('bbbbbbbb-0007-0000-0000-000000000007', 'status_change','Status: novo → em_atendimento',                       '{"de":"novo","para":"em_atendimento"}', now()-'18 days'::interval + '2 min'::interval),
  ('bbbbbbbb-0007-0000-0000-000000000007', 'status_change','Status: em_atendimento → agendou',                    '{"de":"em_atendimento","para":"agendou"}', now()-'18 days'::interval + '25 min'::interval),
  ('bbbbbbbb-0007-0000-0000-000000000007', 'call',         'Sessão de limpeza + peeling realizada',               '{"duracao_segundos":860}', now()-'15 days'::interval),
  ('bbbbbbbb-0007-0000-0000-000000000007', 'status_change','Status: agendou → compareceu',                        '{"de":"agendou","para":"compareceu"}', now()-'15 days'::interval + '15 min'::interval),
  ('bbbbbbbb-0007-0000-0000-000000000007', 'status_change','Status: compareceu → fechou',                         '{"de":"compareceu","para":"fechou"}', now()-'15 days'::interval + '20 min'::interval),

  -- Thiago (fechou, indicação múltipla)
  ('bbbbbbbb-0019-0000-0000-000000000019', 'mensagem',     'Primeiro contato — indicado por 3 clientes',         '{"canal":"whatsapp","indicacoes":3}', now()-'14 days'::interval),
  ('bbbbbbbb-0019-0000-0000-000000000019', 'status_change','Status: novo → em_atendimento',                       '{"de":"novo","para":"em_atendimento"}', now()-'14 days'::interval + '3 min'::interval),
  ('bbbbbbbb-0019-0000-0000-000000000019', 'status_change','Status: em_atendimento → agendou',                    '{"de":"em_atendimento","para":"agendou"}', now()-'14 days'::interval + '20 min'::interval),
  ('bbbbbbbb-0019-0000-0000-000000000019', 'call',         'Harmonização completa realizada',                     '{"duracao_segundos":2680}', now()-'12 days'::interval),
  ('bbbbbbbb-0019-0000-0000-000000000019', 'status_change','Status: agendou → compareceu',                        '{"de":"agendou","para":"compareceu"}', now()-'12 days'::interval + '30 min'::interval),
  ('bbbbbbbb-0019-0000-0000-000000000019', 'status_change','Status: compareceu → fechou',                         '{"de":"compareceu","para":"fechou"}', now()-'12 days'::interval + '45 min'::interval),

  -- Mariana (fechou)
  ('bbbbbbbb-0013-0000-0000-000000000013', 'mensagem',     'Primeiro contato via Instagram',                      '{"canal":"whatsapp"}', now()-'28 days'::interval),
  ('bbbbbbbb-0013-0000-0000-000000000013', 'status_change','Status: novo → em_atendimento',                       '{"de":"novo","para":"em_atendimento"}', now()-'28 days'::interval + '2 min'::interval),
  ('bbbbbbbb-0013-0000-0000-000000000013', 'status_change','Status: em_atendimento → agendou',                    '{"de":"em_atendimento","para":"agendou"}', now()-'26 days'::interval),
  ('bbbbbbbb-0013-0000-0000-000000000013', 'call',         'Consulta de rinoplastia não-cirúrgica',               '{"duracao_segundos":2240}', now()-'24 days'::interval),
  ('bbbbbbbb-0013-0000-0000-000000000013', 'status_change','Status: agendou → compareceu',                        '{"de":"agendou","para":"compareceu"}', now()-'24 days'::interval + '37 min'::interval),
  ('bbbbbbbb-0013-0000-0000-000000000013', 'status_change','Status: compareceu → fechou',                         '{"de":"compareceu","para":"fechou"}', now()-'24 days'::interval + '40 min'::interval);

-- =====================================================================
-- RONDAS (5 semanas de histórico — whatsapp + calls)
-- =====================================================================
INSERT INTO comercial.rondas (id, tipo, periodo_inicio, periodo_fim, snapshot, vazia, status, enviada_em, destinatarios, reenvios, created_at)
VALUES
  -- Semana -5 (whatsapp)
  ('eeeeeeee-0001-0000-0000-000000000001', 'whatsapp',
   now()-'35 days'::interval, now()-'28 days'::interval,
   '{"tipo":"whatsapp","periodo":{"inicio":"2026-04-12T00:00:00Z","fim":"2026-04-19T00:00:00Z"},"total_conversas":3,"score_medio":63.8,"score_mais_alto":88.5,"score_mais_baixo":28.0,"distribuicao_score":[{"faixa":"80-100","total":1},{"faixa":"60-79","total":1},{"faixa":"0-59","total":1}],"top_tags_negativas":[{"tag":"desinteressada","total":1},{"tag":"sem_engajamento","total":1},{"tag":"resposta_curta","total":1}],"top_tags_positivas":[{"tag":"interesse_alto","total":1},{"tag":"agendou","total":1},{"tag":"receptiva","total":1}],"conversas_criticas":[{"conversa_id":"cccccccc-0005-0000-0000-000000000005","lead_nome":"Elaine Souza Mendes","score":28.0,"resumo":"Lead demonstrou interesse mínimo. Saiu da conversa dizendo preferir clínica mais perto de casa."}],"origens":[{"origem":"instagram","total":1},{"origem":"facebook","total":1},{"origem":"indicacao","total":1}]}',
   false, 'enviada', now()-'28 days'::interval + '8 hours'::interval,
   '["rodrigo@benitesalbuquerque.com.br"]', 0, now()-'28 days'::interval),

  -- Semana -5 (calls)
  ('eeeeeeee-0002-0000-0000-000000000002', 'calls',
   now()-'35 days'::interval, now()-'28 days'::interval,
   '{"tipo":"calls","periodo":{"inicio":"2026-04-12T00:00:00Z","fim":"2026-04-19T00:00:00Z"},"total_calls":2,"score_medio":81.5,"distribuicao_classificacao":[{"classificacao":"excelente","total":1},{"classificacao":"bom","total":1}],"media_por_fase":{"rapport":86.5,"identificacao_necessidade":81.0,"apresentacao_solucao":81.0,"manejo_objecao":76.5,"fechamento":81.5},"calls_insuficientes":[]}',
   false, 'enviada', now()-'28 days'::interval + '8 hours'::interval,
   '["rodrigo@benitesalbuquerque.com.br"]', 0, now()-'28 days'::interval),

  -- Semana -4 (whatsapp)
  ('eeeeeeee-0003-0000-0000-000000000003', 'whatsapp',
   now()-'28 days'::interval, now()-'21 days'::interval,
   '{"tipo":"whatsapp","periodo":{"inicio":"2026-04-19T00:00:00Z","fim":"2026-04-26T00:00:00Z"},"total_conversas":5,"score_medio":76.2,"score_mais_alto":94.0,"score_mais_baixo":63.0,"distribuicao_score":[{"faixa":"80-100","total":2},{"faixa":"60-79","total":3}],"top_tags_negativas":[{"tag":"medo_agulha","total":1},{"tag":"indeciso_inicialmente","total":1},{"tag":"pesquisando_opcoes","total":1}],"top_tags_positivas":[{"tag":"indicacao_forte","total":1},{"tag":"interesse_real","total":2},{"tag":"agendou","total":2}],"conversas_criticas":[],"origens":[{"origem":"indicacao","total":1},{"origem":"instagram","total":2},{"origem":"google","total":2}]}',
   false, 'enviada', now()-'21 days'::interval + '8 hours'::interval,
   '["rodrigo@benitesalbuquerque.com.br"]', 0, now()-'21 days'::interval),

  -- Semana -4 (calls)
  ('eeeeeeee-0004-0000-0000-000000000004', 'calls',
   now()-'28 days'::interval, now()-'21 days'::interval,
   '{"tipo":"calls","periodo":{"inicio":"2026-04-19T00:00:00Z","fim":"2026-04-26T00:00:00Z"},"total_calls":3,"score_medio":84.7,"distribuicao_classificacao":[{"classificacao":"excelente","total":2},{"classificacao":"bom","total":1}],"media_por_fase":{"rapport":88.7,"identificacao_necessidade":86.0,"apresentacao_solucao":85.7,"manejo_objecao":81.7,"fechamento":84.3},"calls_insuficientes":[]}',
   false, 'enviada', now()-'21 days'::interval + '8 hours'::interval,
   '["rodrigo@benitesalbuquerque.com.br"]', 0, now()-'21 days'::interval),

  -- Semana -3 (whatsapp)
  ('eeeeeeee-0005-0000-0000-000000000005', 'whatsapp',
   now()-'21 days'::interval, now()-'14 days'::interval,
   '{"tipo":"whatsapp","periodo":{"inicio":"2026-04-26T00:00:00Z","fim":"2026-05-03T00:00:00Z"},"total_conversas":4,"score_medio":71.5,"score_mais_alto":91.0,"score_mais_baixo":28.0,"distribuicao_score":[{"faixa":"80-100","total":1},{"faixa":"60-79","total":2},{"faixa":"0-59","total":1}],"top_tags_negativas":[{"tag":"desinteressada","total":1},{"tag":"concorrente_preferido","total":1},{"tag":"demorou_responder","total":1}],"top_tags_positivas":[{"tag":"interesse_imediato","total":1},{"tag":"fechou_no_chat","total":1},{"tag":"agendou","total":1}],"conversas_criticas":[{"conversa_id":"cccccccc-0005-0000-0000-000000000005","lead_nome":"Elaine Souza Mendes","score":28.0,"resumo":"Lead perdida. Objeção geográfica forte."}],"origens":[{"origem":"instagram","total":2},{"origem":"facebook","total":1},{"origem":"indicacao","total":1}]}',
   false, 'enviada', now()-'14 days'::interval + '8 hours'::interval,
   '["rodrigo@benitesalbuquerque.com.br"]', 0, now()-'14 days'::interval),

  -- Semana -3 (calls) — erro de envio
  ('eeeeeeee-0006-0000-0000-000000000006', 'calls',
   now()-'21 days'::interval, now()-'14 days'::interval,
   '{"tipo":"calls","periodo":{"inicio":"2026-04-26T00:00:00Z","fim":"2026-05-03T00:00:00Z"},"total_calls":2,"score_medio":78.0,"distribuicao_classificacao":[{"classificacao":"excelente","total":1},{"classificacao":"bom","total":1}],"media_por_fase":{"rapport":84.0,"identificacao_necessidade":80.0,"apresentacao_solucao":82.5,"manejo_objecao":78.0,"fechamento":66.0},"calls_insuficientes":[]}',
   false, 'erro', null,
   '["rodrigo@benitesalbuquerque.com.br"]', 1, now()-'14 days'::interval),

  -- Semana -2 (whatsapp)
  ('eeeeeeee-0007-0000-0000-000000000007', 'whatsapp',
   now()-'14 days'::interval, now()-'7 days'::interval,
   '{"tipo":"whatsapp","periodo":{"inicio":"2026-05-03T00:00:00Z","fim":"2026-05-10T00:00:00Z"},"total_conversas":6,"score_medio":82.3,"score_mais_alto":96.0,"score_mais_baixo":63.0,"distribuicao_score":[{"faixa":"80-100","total":4},{"faixa":"60-79","total":2}],"top_tags_negativas":[{"tag":"pesquisando_opcoes","total":1},{"tag":"sem_agendamento","total":1}],"top_tags_positivas":[{"tag":"indicacao_multipla","total":1},{"tag":"fechou_rapido","total":1},{"tag":"agendou","total":3}],"conversas_criticas":[],"origens":[{"origem":"instagram","total":2},{"origem":"indicacao","total":2},{"origem":"google","total":1},{"origem":"organico","total":1}]}',
   false, 'enviada', now()-'7 days'::interval + '8 hours'::interval,
   '["rodrigo@benitesalbuquerque.com.br"]', 0, now()-'7 days'::interval),

  -- Semana -2 (calls)
  ('eeeeeeee-0008-0000-0000-000000000008', 'calls',
   now()-'14 days'::interval, now()-'7 days'::interval,
   '{"tipo":"calls","periodo":{"inicio":"2026-05-03T00:00:00Z","fim":"2026-05-10T00:00:00Z"},"total_calls":4,"score_medio":82.0,"distribuicao_classificacao":[{"classificacao":"excelente","total":2},{"classificacao":"bom","total":1},{"classificacao":"regular","total":1}],"media_por_fase":{"rapport":85.0,"identificacao_necessidade":80.5,"apresentacao_solucao":79.0,"manejo_objecao":73.5,"fechamento":74.0},"calls_insuficientes":[{"call_id":"dddddddd-0008-0000-0000-000000000008","lead_nome":"Sandra Alves Monteiro","score":58.0,"diagnostico":"Atendimento abaixo do esperado para cliente ansiosa. Faltou criar ambiente mais seguro."}]}',
   false, 'enviada', now()-'7 days'::interval + '8 hours'::interval,
   '["rodrigo@benitesalbuquerque.com.br"]', 0, now()-'7 days'::interval),

  -- Semana atual (whatsapp) — gerada, ainda não enviada
  ('eeeeeeee-0009-0000-0000-000000000009', 'whatsapp',
   now()-'7 days'::interval, now(),
   '{"tipo":"whatsapp","periodo":{"inicio":"2026-05-10T00:00:00Z","fim":"2026-05-17T00:00:00Z"},"total_conversas":4,"score_medio":73.6,"score_mais_alto":81.0,"score_mais_baixo":58.0,"distribuicao_score":[{"faixa":"80-100","total":1},{"faixa":"60-79","total":2},{"faixa":"0-59","total":1}],"top_tags_negativas":[{"tag":"pesquisando_opcoes","total":1},{"tag":"sem_agendamento","total":2},{"tag":"perguntou_preco","total":2}],"top_tags_positivas":[{"tag":"interesse_moderado","total":2},{"tag":"pergunta_tecnica","total":2},{"tag":"interesse_real","total":1}],"conversas_criticas":[],"origens":[{"origem":"google","total":1},{"origem":"instagram","total":2},{"origem":"organico","total":1}]}',
   false, 'gerada', null,
   '["rodrigo@benitesalbuquerque.com.br"]', 0, now()-'1 hour'::interval),

  -- Semana atual (calls) — pendente
  ('eeeeeeee-0010-0000-0000-000000000010', 'calls',
   now()-'7 days'::interval, now(),
   '{"tipo":"calls","periodo":{"inicio":"2026-05-10T00:00:00Z","fim":"2026-05-17T00:00:00Z"},"total_calls":0,"score_medio":null,"distribuicao_classificacao":[],"media_por_fase":{},"calls_insuficientes":[]}',
   true, 'pendente', null,
   null, 0, now()-'30 min'::interval);
