-- =====================================================================
-- Seed DEMO — Atlas OS Comercial  (v2 — material robusto para análise)
-- Clínica fictícia: "Clínica Lumina — Odontologia & Harmonização"
--
-- Foco desta versão: conversas de WhatsApp e transcrições de call REAIS
-- e densas, para a ferramenta de análise ter substância de verdade.
-- Volume enxuto (12 leads), profundidade alta.
--
-- Rodar no banco DEMO (após as migrations):
--   psql "$DEMO_DATABASE_URL" -f supabase/seeds/_demo.sql
-- Idempotente (TRUNCATE guard no topo) — pode rerodar a vontade.
-- Strings longas usam dollar-quoting para apostrofos livres.
-- =====================================================================

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

-- 0. Configuracoes da clinica -----------------------------------------
UPDATE comercial.configuracoes
SET
  nome_clinica                       = 'Clínica Lumina — Odontologia & Harmonização',
  destinatarios_whatsapp             = ARRAY['gestao@clinicalumina.com.br','comercial@clinicalumina.com.br'],
  destinatarios_calls                = ARRAY['gestao@clinicalumina.com.br'],
  threshold_score_baixo              = 50,
  threshold_alerta_imediato_whatsapp = 30,
  janela_analise_mensagens           = 50,
  retencao_meses                     = 24
WHERE id = 1;

-- 1. Instancias Evolution ---------------------------------------------
INSERT INTO comercial.evolution_instances (apelido, evolution_url, evolution_api_key, instance_name, webhook_secret, ativa)
VALUES
  ('WhatsApp Recepção',  'https://evo-demo.benitesalbuquerque.com.br', 'demo-key-recepcao',  'lumina-recepcao',  'demo-secret-recepcao',  true),
  ('WhatsApp Comercial', 'https://evo-demo.benitesalbuquerque.com.br', 'demo-key-comercial', 'lumina-comercial', 'demo-secret-comercial', true)
ON CONFLICT DO NOTHING;

-- 2. Leads (12) -------------------------------------------------------
INSERT INTO comercial.leads (nome, telefone, email, status, origem, origem_status, origem_confidence, observacoes, created_at, status_atualizado_em)
VALUES
  ('Mariana Albuquerque', '+5567992000001', 'mariana.alb@gmail.com',     'fechou',         'instagram', 'detectado', 0.94, 'Protocolo superior + HOF. Fechou na consulta.',     now() - interval '46 days', now() - interval '39 days'),
  ('Gustavo Pereira',     '+5567992000002', NULL,                         'compareceu',     'google',    'detectado', 0.83, 'Protocolo. Objecao forte de preco; pediu condicao.', now() - interval '24 days', now() - interval '9 days'),
  ('Vanessa Klein',       '+5567992000003', NULL,                         'sem_resposta',   'instagram', 'detectado', 0.61, 'Lentes. Recebeu preco sem ancoragem e sumiu.',      now() - interval '18 days', now() - interval '12 days'),
  ('Larissa Fontes',      '+5567992000004', 'lari.fontes@gmail.com',     'fechou',         'instagram', 'detectado', 0.88, 'HOF botox + preenchimento labial. Fechou.',         now() - interval '15 days', now() - interval '5 days'),
  ('Cláudio Menezes',     '+5567992000005', NULL,                         'perdido',        'facebook',  'detectado', 0.66, 'Protocolo. Foi para concorrente mais barato.',      now() - interval '34 days', now() - interval '22 days'),
  ('Sabrina Duarte',      '+5567992000006', 'sabrina.d@gmail.com',       'em_atendimento', 'instagram', 'detectado', 0.86, 'Protocolo. Negociando parcelamento; call na fila.', now() - interval '6 days',  now() - interval '3 hours'),
  ('Aline Prado',         '+5567992000007', NULL,                         'em_atendimento', 'facebook',  'detectado', 0.55, 'Preenchimento. Achou caro; esfriando.',             now() - interval '9 days',  now() - interval '28 hours'),
  ('Felipe Andrade',      '+5567992000008', 'felipe.andrade@gmail.com',  'agendou',        'instagram', 'detectado', 0.87, 'Implante unitario. Agendou avaliacao.',             now() - interval '11 days', now() - interval '2 days'),
  ('Renato Capalbo',      '+5567992000009', 'renato.capalbo@outlook.com','fechou',         'indicacao', 'detectado', 0.90, 'Implante + enxerto. Indicacao. Fechou.',            now() - interval '40 days', now() - interval '31 days'),
  ('Camila Reis',         '+5567992000010', 'camila.reis@gmail.com',     'compareceu',     'google',    'detectado', 0.80, 'Protocolo. Decisor externo (marido); foi pensar.',  now() - interval '20 days', now() - interval '8 days'),
  ('Letícia Barros',      '+5567992000011', NULL,                         'novo',           'instagram', 'detectado', 0.88, 'Lentes. Lead novo e quente, veio de anuncio.',      now() - interval '20 hours', now() - interval '20 hours'),
  ('Daniel Figueiredo',   '+5567992000012', 'dani.fig@gmail.com',        'novo',           NULL,        'pendente',  NULL, 'Origem nao detectada - classificar manualmente.',   now() - interval '9 hours',  now() - interval '9 hours')
ON CONFLICT (telefone) DO NOTHING;

-- 3. Conversas --------------------------------------------------------
-- Sem score e sem ultima_analise_em: o sistema roda a analise ao vivo.
-- Todas 'ativa' para serem elegiveis a analise sob demanda.
INSERT INTO comercial.conversas (lead_id, evolution_instance_id, numero_whatsapp, status, ultimo_score, ultima_analise_em, ultima_mensagem_em, created_at)
SELECT l.id, ei.id, c.numero, 'ativa', NULL, NULL, c.ult, c.cri
FROM (VALUES
  ('+5567992000001', now() - interval '40 days',  now() - interval '46 days'),
  ('+5567992000002', now() - interval '9 days',   now() - interval '24 days'),
  ('+5567992000003', now() - interval '13 days',  now() - interval '18 days'),
  ('+5567992000004', now() - interval '5 days',   now() - interval '15 days'),
  ('+5567992000005', now() - interval '23 days',  now() - interval '34 days'),
  ('+5567992000006', now() - interval '3 hours',  now() - interval '6 days'),
  ('+5567992000007', now() - interval '28 hours', now() - interval '9 days'),
  ('+5567992000008', now() - interval '2 days',   now() - interval '11 days'),
  ('+5567992000011', now() - interval '18 hours', now() - interval '20 hours')
) AS c(numero, ult, cri)
JOIN comercial.leads l ON l.telefone = c.numero
JOIN comercial.evolution_instances ei ON ei.instance_name = 'lumina-recepcao'
ON CONFLICT DO NOTHING;

-- 4. Mensagens --------------------------------------------------------
-- Conteudo em dollar-quoting ($m$...$m$): apostrofos/aspas livres.

-- CONVERSA 1 — Mariana (+...001): protocolo, atendimento exemplar, fecha.
INSERT INTO comercial.mensagens (conversa_id, message_id_evolution, tipo, fonte, conteudo, remetente, enviada_em)
SELECT cv.id, m.mid, 'texto', 'humano', m.conteudo, m.remetente, m.enviada_em
FROM (VALUES
  ('+5567992000001','demo-w1-01','lead',    $m$Oi, boa tarde! Vi no instagram de vocês sobre a reabilitação do sorriso. Faz tempo que eu queria resolver meus dentes, mas tenho medo e também não faço ideia de quanto custa 😣$m$, now() - interval '46 days'),
  ('+5567992000001','demo-w1-02','clinica', $m$Boa tarde, Mariana! Que bom que você mandou mensagem 💙 Meu nome é Bruna, sou da recepção da Clínica Lumina. Primeiro, pode ficar tranquila: esse receio é super comum e a gente cuida de cada etapa com muito cuidado. Me conta uma coisa, pra eu te entender melhor: o que mais te incomoda hoje quando você se olha no espelho ou vai sorrir numa foto?$m$, now() - interval '46 days' + interval '9 minutes'),
  ('+5567992000001','demo-w1-03','lead',    $m$Ai, tudo né kkk. Meus dentes da frente estão desgastados, tenho uns escurecidos e dois que já fiz canal. Tenho 38 anos e evito sorrir de boca aberta, em foto eu sempre fecho a boca$m$, now() - interval '46 days' + interval '23 minutes'),
  ('+5567992000001','demo-w1-04','clinica', $m$Entendo perfeitamente, e olha, você não está sozinha nisso. A maioria das nossas pacientes chega exatamente com esse sentimento de esconder o sorriso. A boa notícia é que o seu caso tem solução, e normalmente o resultado muda completamente a forma como a pessoa se enxerga. Só pra eu te situar: você já tinha ouvido falar de protocolo ou reabilitação oral, ou seria a primeira vez avaliando isso?$m$, now() - interval '46 days' + interval '38 minutes'),
  ('+5567992000001','demo-w1-05','lead',    $m$Já ouvi, mas não entendo direito. É aquele de arrancar todos os dentes? Eu não queria tirar tudo não 😬$m$, now() - interval '46 days' + interval '52 minutes'),
  ('+5567992000001','demo-w1-06','clinica', $m$Ótima pergunta, e é importante esclarecer: nem todo caso precisa de extração total, viu? Vai desde reabilitação com lentes e coroas, preservando seus dentes, até o protocolo completo quando é realmente necessário. Quem define isso é a avaliação com a Dra. Helena, com raio-x e exame clínico. O que a gente nunca faz é indicar tratamento sem ver de perto. Por isso prefiro não te assustar com nada antes da Dra. olhar 😊$m$, now() - interval '46 days' + interval '70 minutes'),
  ('+5567992000001','demo-w1-07','lead',    $m$Faz sentido. E quanto custa mais ou menos? É só pra eu já ir me preparando psicologicamente kkk$m$, now() - interval '46 days' + interval '95 minutes'),
  ('+5567992000001','demo-w1-08','clinica', $m$Kkkk te entendo, ninguém quer levar susto 😄 Vou ser transparente: o investimento depende bastante do que o seu caso pede. Pode ir de uns R$ 12 mil numa reabilitação mais pontual até uns R$ 40 mil e poucos num protocolo completo com harmonização. Por isso a avaliação importa tanto: a Dra. monta o plano exato, o valor fechado, e a gente vê junto a melhor forma de parcelar pra caber no seu orçamento. A avaliação é leve e sem compromisso nenhum. Você prefere começo ou final de semana?$m$, now() - interval '46 days' + interval '112 minutes'),
  ('+5567992000001','demo-w1-09','lead',    $m$E a avaliação tem custo?$m$, now() - interval '45 days 20 hours'),
  ('+5567992000001','demo-w1-10','clinica', $m$A avaliação com raio-x panorâmico fica R$ 150, mas esse valor volta 100% como crédito no seu tratamento se você decidir fazer com a gente. Ou seja, seguindo com o tratamento, na prática ela sai de graça 😉$m$, now() - interval '45 days 20 hours' + interval '11 minutes'),
  ('+5567992000001','demo-w1-11','lead',    $m$Ah, que ótimo. Então pode ser! Eu queria muito resolver isso ainda esse ano$m$, now() - interval '45 days 19 hours'),
  ('+5567992000001','demo-w1-12','clinica', $m$Amei essa decisão, Mariana! 💙 Esse ano é totalmente possível. Deixa eu ver a agenda da Dra. Helena aqui... tenho quinta às 15h ou sexta às 10h. Qual fica melhor pra você?$m$, now() - interval '45 days 19 hours' + interval '8 minutes'),
  ('+5567992000001','demo-w1-13','lead',    $m$Quinta 15h$m$, now() - interval '45 days 18 hours'),
  ('+5567992000001','demo-w1-14','clinica', $m$Fechado! Quinta-feira, 15h, com a Dra. Helena 🗓️ Vou te mandar o endereço e na véspera te envio um lembrete, combinado? Ah, e se quiser, traz uma foto antiga em que você gostava do seu sorriso, ou alguma referência. Ajuda muito a Dra. a entender o que você deseja.$m$, now() - interval '45 days 18 hours' + interval '7 minutes'),
  ('+5567992000001','demo-w1-15','lead',    $m$Combinado! Obrigada, Bruna, já me sinto mais tranquila 🥹$m$, now() - interval '45 days 18 hours' + interval '16 minutes'),
  ('+5567992000001','demo-w1-16','clinica', $m$É pra isso que eu estou aqui 💙 Pode ficar tranquila, você está em ótimas mãos. Até quinta!$m$, now() - interval '45 days 18 hours' + interval '20 minutes'),
  ('+5567992000001','demo-w1-17','clinica', $m$Oi, Mariana! Passando pra confirmar sua avaliação amanhã às 15h com a Dra. Helena 😊 Posso confirmar?$m$, now() - interval '41 days'),
  ('+5567992000001','demo-w1-18','lead',    $m$Confirmadíssimo! Tô até ansiosa$m$, now() - interval '41 days' + interval '38 minutes'),
  ('+5567992000001','demo-w1-19','clinica', $m$Maravilha! Te espero amanhã então 💙 Qualquer coisa, é só me chamar por aqui.$m$, now() - interval '41 days' + interval '44 minutes'),
  ('+5567992000001','demo-w1-20','lead',    $m$Bruna, amei a Dra. Helena! Fechei o protocolo + a harmonização. Obrigada pela paciência desde o comecinho 🥰$m$, now() - interval '40 days'),
  ('+5567992000001','demo-w1-21','clinica', $m$Eu que agradeço a confiança, Mariana!! 🎉 Vai ficar lindo demais, você merece. Qualquer dúvida durante o processo é só me chamar aqui. Bem-vinda à família Lumina 💙$m$, now() - interval '40 days' + interval '25 minutes')
) AS m(numero, mid, remetente, conteudo, enviada_em)
JOIN comercial.conversas cv ON cv.numero_whatsapp = m.numero
ON CONFLICT (message_id_evolution) DO NOTHING;

-- CONVERSA 2 — Gustavo (+...002): objecao de preco; recuperado via follow-up.
INSERT INTO comercial.mensagens (conversa_id, message_id_evolution, tipo, fonte, conteudo, remetente, enviada_em)
SELECT cv.id, m.mid, 'texto', 'humano', m.conteudo, m.remetente, m.enviada_em
FROM (VALUES
  ('+5567992000002','demo-w2-01','lead',    $m$bom dia, queria saber o valor do protocolo$m$, now() - interval '24 days'),
  ('+5567992000002','demo-w2-02','clinica', $m$Bom dia! Aqui é a Bruna, da Clínica Lumina 😊 Claro, posso te ajudar. Pra eu te passar a informação certa: você já fez alguma avaliação antes ou está pesquisando agora? E o tratamento é pra você mesmo?$m$, now() - interval '24 days' + interval '14 minutes'),
  ('+5567992000002','demo-w2-03','lead',    $m$tô pesquisando. é pra mim. já sei que preciso, faltam alguns dentes embaixo e os de cima tão ruins$m$, now() - interval '24 days' + interval '31 minutes'),
  ('+5567992000002','demo-w2-04','clinica', $m$Entendi, Gustavo. Pelo que você descreve pode ser um caso de protocolo ou reabilitação parcial, mas só a Dra. consegue definir certinho com o raio-x. Sobre o investimento, pra ser transparente: o protocolo completo costuma ficar entre R$ 28 mil e R$ 42 mil, dependendo da complexidade. Na avaliação a gente fecha o valor exato e já vê o parcelamento.$m$, now() - interval '24 days' + interval '40 minutes'),
  ('+5567992000002','demo-w2-05','lead',    $m$nossa, bem salgado$m$, now() - interval '24 days' + interval '48 minutes'),
  ('+5567992000002','demo-w2-06','clinica', $m$Eu entendo que à primeira vista parece alto 😊 Mas pensa que é um tratamento que devolve sua mordida, sua saúde e seu sorriso pra vida inteira, e a gente parcela pra caber no orçamento. Muita gente acha que vai ser inviável e se surpreende quando vê as condições. Posso te mostrar isso numa avaliação?$m$, now() - interval '24 days' + interval '63 minutes'),
  ('+5567992000002','demo-w2-07','lead',    $m$parcela em quantas vezes?$m$, now() - interval '24 days' + interval '80 minutes'),
  ('+5567992000002','demo-w2-08','clinica', $m$Conseguimos em até 18x no cartão, ou com entrada e o saldo dividido. Tem também a opção de financiamento odontológico. Mas o plano certinho a Dra. monta vendo seu caso. Quer agendar a avaliação? É R$ 150 e vira crédito no tratamento.$m$, now() - interval '24 days' + interval '92 minutes'),
  ('+5567992000002','demo-w2-09','lead',    $m$deixa eu pensar. vou ver com a esposa o orçamento$m$, now() - interval '24 days' + interval '120 minutes'),
  ('+5567992000002','demo-w2-10','clinica', $m$Claro, Gustavo! Decisão importante mesmo 😊 Só uma coisa: a avaliação não te compromete com nada e já te dá clareza do valor real e das condições. Às vezes ajuda até na conversa com a esposa ter o número certo em mãos, né? Posso reservar um horário e você confirma depois?$m$, now() - interval '24 days' + interval '130 minutes'),
  ('+5567992000002','demo-w2-11','lead',    $m$pode deixar que eu te chamo$m$, now() - interval '24 days' + interval '150 minutes'),
  ('+5567992000002','demo-w2-12','clinica', $m$Oi, Gustavo! Tudo bem? 😊 Passando pra saber se você e sua esposa conseguiram conversar sobre a avaliação. Seu interesse em resolver os dentes continua de pé?$m$, now() - interval '16 days'),
  ('+5567992000002','demo-w2-13','lead',    $m$oi, continua sim. é que tá meio apertado agora$m$, now() - interval '16 days' + interval '55 minutes'),
  ('+5567992000002','demo-w2-14','clinica', $m$Entendo total, e é justamente por isso que a avaliação ajuda: a Dra. consegue montar um plano por etapas, priorizando o que é mais urgente, pra você começar sem precisar do valor todo de uma vez. Que tal marcarmos só a avaliação pra você ter o panorama? Sem compromisso de fechar nada.$m$, now() - interval '16 days' + interval '68 minutes'),
  ('+5567992000002','demo-w2-15','lead',    $m$por etapas como assim?$m$, now() - interval '16 days' + interval '85 minutes'),
  ('+5567992000002','demo-w2-16','clinica', $m$Por exemplo: primeiro a gente resolve a parte de baixo, que te incomoda mais e devolve a função de mastigar, e depois a parte estética de cima. Assim você dilui o investimento no tempo. Mas pra desenhar isso direitinho a Dra. precisa te examinar. Tenho terça 9h ou quarta 16h, qual prefere?$m$, now() - interval '16 days' + interval '95 minutes'),
  ('+5567992000002','demo-w2-17','lead',    $m$terça 9h então$m$, now() - interval '16 days' + interval '110 minutes'),
  ('+5567992000002','demo-w2-18','clinica', $m$Show! Terça, 9h, marcado 🗓️ Te mando o endereço e confirmo na véspera. Vai valer muito a pena ter clareza do seu caso, Gustavo 💙$m$, now() - interval '16 days' + interval '118 minutes'),
  ('+5567992000002','demo-w2-19','lead',    $m$blz, obrigado$m$, now() - interval '16 days' + interval '130 minutes'),
  ('+5567992000002','demo-w2-20','clinica', $m$Imagina! Até terça 😊$m$, now() - interval '9 days')
) AS m(numero, mid, remetente, conteudo, enviada_em)
JOIN comercial.conversas cv ON cv.numero_whatsapp = m.numero
ON CONFLICT (message_id_evolution) DO NOTHING;

-- CONVERSA 3 — Vanessa (+...003): atendimento RUIM, preco cru, lead some.
INSERT INTO comercial.mensagens (conversa_id, message_id_evolution, tipo, fonte, conteudo, remetente, enviada_em)
SELECT cv.id, m.mid, 'texto', 'humano', m.conteudo, m.remetente, m.enviada_em
FROM (VALUES
  ('+5567992000003','demo-w3-01','lead',    $m$Oi, quero saber sobre as lentes de contato dental$m$, now() - interval '18 days'),
  ('+5567992000003','demo-w3-02','clinica', $m$Oi! As lentes ficam R$ 2.500 por dente.$m$, now() - interval '18 days' + interval '40 minutes'),
  ('+5567992000003','demo-w3-03','lead',    $m$e pra fazer os da frente? uns 8 dentes$m$, now() - interval '18 days' + interval '52 minutes'),
  ('+5567992000003','demo-w3-04','clinica', $m$8 lentes daria R$ 20.000.$m$, now() - interval '18 days' + interval '70 minutes'),
  ('+5567992000003','demo-w3-05','lead',    $m$nossa$m$, now() - interval '18 days' + interval '78 minutes'),
  ('+5567992000003','demo-w3-06','clinica', $m$Sim, é um procedimento estético premium. Qualquer coisa estamos à disposição.$m$, now() - interval '18 days' + interval '95 minutes'),
  ('+5567992000003','demo-w3-07','lead',    $m$vcs parcelam?$m$, now() - interval '17 days'),
  ('+5567992000003','demo-w3-08','clinica', $m$Parcelamos em até 12x no cartão.$m$, now() - interval '17 days' + interval '180 minutes'),
  ('+5567992000003','demo-w3-09','lead',    $m$ah tá$m$, now() - interval '17 days' + interval '200 minutes'),
  ('+5567992000003','demo-w3-10','lead',    $m$vou ver aqui e qualquer coisa eu volto$m$, now() - interval '16 days'),
  ('+5567992000003','demo-w3-11','clinica', $m$Ok! Estamos à disposição.$m$, now() - interval '16 days' + interval '120 minutes'),
  ('+5567992000003','demo-w3-12','lead',    $m$obg$m$, now() - interval '13 days')
) AS m(numero, mid, remetente, conteudo, enviada_em)
JOIN comercial.conversas cv ON cv.numero_whatsapp = m.numero
ON CONFLICT (message_id_evolution) DO NOTHING;

-- CONVERSA 4 — Larissa (+...004): HOF, objecao de comparacao bem trabalhada, fecha.
INSERT INTO comercial.mensagens (conversa_id, message_id_evolution, tipo, fonte, conteudo, remetente, enviada_em)
SELECT cv.id, m.mid, 'texto', 'humano', m.conteudo, m.remetente, m.enviada_em
FROM (VALUES
  ('+5567992000004','demo-w4-01','lead',    $m$Oii! Vi os resultados de vocês de harmonização facial no insta e fiquei apaixonada 😍 queria fazer, mas tô insegura, já vi uns resultados estranhos por aí$m$, now() - interval '15 days'),
  ('+5567992000004','demo-w4-02','clinica', $m$Oii, Larissa! Que alegria 💙 Aqui é a Bruna. E olha, essa sua preocupação é a mais importante de todas, viu? Harmonização boa é aquela que ninguém percebe que foi feita, só percebe que você está mais bonita e descansada. Esse resultado estranho quase sempre vem de mão inexperiente ou produto de baixa qualidade. O que você gostaria de melhorar especificamente?$m$, now() - interval '15 days' + interval '12 minutes'),
  ('+5567992000004','demo-w4-03','lead',    $m$Queria dar uma levantada no rosto, tô achando ele meio caído, e meus lábios são bem finos, queria um preenchimento bem natural$m$, now() - interval '15 days' + interval '26 minutes'),
  ('+5567992000004','demo-w4-04','clinica', $m$Perfeito, são dois dos procedimentos mais procurados aqui 😊 Pro caído a gente costuma trabalhar com bioestimulador de colágeno e/ou botox estratégico, e pros lábios um preenchimento com ácido hialurônico, sempre num volume natural, respeitando a sua anatomia. Quem faz aqui é a Dra. Helena, referência em HOF na região, e usamos só produtos premium com registro. Você já fez algum procedimento antes ou seria a primeira vez?$m$, now() - interval '15 days' + interval '40 minutes'),
  ('+5567992000004','demo-w4-05','lead',    $m$Primeira vez! Por isso o medo kk. Quanto fica?$m$, now() - interval '15 days' + interval '55 minutes'),
  ('+5567992000004','demo-w4-06','clinica', $m$Que responsa gostosa ser a sua primeira experiência então 🥰 Vou te passar uma base: o preenchimento labial fica a partir de R$ 1.800, o botox a partir de R$ 1.200 a região, e o bioestimulador R$ 1.500 a sessão. Mas o ideal é a Dra. te avaliar pessoalmente, porque ela desenha o protocolo do seu rosto como um todo, e aí muitas vezes compensa um pacote, que sai com condição melhor do que avulso. Posso te marcar uma avaliação?$m$, now() - interval '15 days' + interval '72 minutes'),
  ('+5567992000004','demo-w4-07','lead',    $m$vi uma clínica que faz o labial por 900...$m$, now() - interval '14 days'),
  ('+5567992000004','demo-w4-08','clinica', $m$Entendo, e existe sim essa diferença no mercado 😊 Vou ser honesta com você porque acho que você merece: nesse tipo de procedimento, o que define o preço é principalmente a qualidade e a procedência do produto e a mão de quem aplica. Ácido hialurônico tem desde marcas premium importadas, com estudos e segurança comprovada, até produtos baratos sem rastreabilidade, que é justamente de onde vêm aqueles resultados estranhos e as complicações. No seu rosto, e sendo sua primeira vez, eu jamais te indicaria economizar nisso. Mas a decisão é sua, e a avaliação te ajuda a comparar com consciência.$m$, now() - interval '14 days' + interval '18 minutes'),
  ('+5567992000004','demo-w4-09','lead',    $m$Você tem razão, não quero arriscar meu rosto pra economizar 😅$m$, now() - interval '14 days' + interval '40 minutes'),
  ('+5567992000004','demo-w4-10','clinica', $m$É exatamente esse cuidado que vai fazer você amar o resultado 💙 E pode confiar: a Dra. é super criteriosa, ela inclusive desmarca procedimento quando acha que não vai ficar natural. Aqui a gente preza pelo natural acima de tudo. Quando seria bom pra você vir? Tenho quarta 14h ou quinta 11h.$m$, now() - interval '14 days' + interval '55 minutes'),
  ('+5567992000004','demo-w4-11','lead',    $m$Quinta 11h!$m$, now() - interval '14 days' + interval '70 minutes'),
  ('+5567992000004','demo-w4-12','clinica', $m$Anotado, quinta 11h com a Dra. Helena 🗓️ Vou te mandar o endereço. E fica tranquila que na avaliação ela te explica tudo, sem pressa e sem pressão, tá? Você decide no seu tempo 💙$m$, now() - interval '14 days' + interval '78 minutes'),
  ('+5567992000004','demo-w4-13','lead',    $m$Aaah que alívio. Obrigada, Bruna, você me deixou bem mais segura$m$, now() - interval '14 days' + interval '95 minutes'),
  ('+5567992000004','demo-w4-14','clinica', $m$Fico feliz demais em ler isso 🥰 Até quinta, Larissa!$m$, now() - interval '14 days' + interval '100 minutes'),
  ('+5567992000004','demo-w4-15','clinica', $m$Oi, Larissa! Confirmando sua avaliação amanhã 11h 😊$m$, now() - interval '6 days'),
  ('+5567992000004','demo-w4-16','lead',    $m$Confirmo! 💕$m$, now() - interval '6 days' + interval '30 minutes'),
  ('+5567992000004','demo-w4-17','lead',    $m$Bruna, fechei!! Vou fazer o labial + botox. A Dra. explicou tudinho e me senti super segura. Ansiosaa 🥰$m$, now() - interval '5 days'),
  ('+5567992000004','demo-w4-18','clinica', $m$Aeee, que felicidade!! 🎉 Você vai amar, e o melhor: vai continuar sendo você, só que ainda mais linda 💙 Sua sessão já está agendada. Qualquer dúvida, tô aqui!$m$, now() - interval '5 days' + interval '20 minutes')
) AS m(numero, mid, remetente, conteudo, enviada_em)
JOIN comercial.conversas cv ON cv.numero_whatsapp = m.numero
ON CONFLICT (message_id_evolution) DO NOTHING;

-- CONVERSA 5 — Cláudio (+...005): movido a preco, defesa de valor digna mas tardia, perde p/ concorrente.
INSERT INTO comercial.mensagens (conversa_id, message_id_evolution, tipo, fonte, conteudo, remetente, enviada_em)
SELECT cv.id, m.mid, 'texto', 'humano', m.conteudo, m.remetente, m.enviada_em
FROM (VALUES
  ('+5567992000005','demo-w5-01','lead',    $m$Boa tarde. Preciso fazer um protocolo na arcada superior. Gostaria de um orçamento.$m$, now() - interval '34 days'),
  ('+5567992000005','demo-w5-02','clinica', $m$Boa tarde, Cláudio! Aqui é a Bruna, da Clínica Lumina 😊 Claro! Pra eu te orientar melhor: você já tem algum exame recente, tipo um raio-x panorâmico, ou seria fazer a avaliação aqui com a gente?$m$, now() - interval '34 days' + interval '20 minutes'),
  ('+5567992000005','demo-w5-03','lead',    $m$Tenho um panorâmico recente sim, fiz numa avaliação em outra clínica. Eles me passaram um orçamento, mas quero comparar.$m$, now() - interval '34 days' + interval '35 minutes'),
  ('+5567992000005','demo-w5-04','clinica', $m$Perfeito, ter o exame ajuda bastante 👍 E faz todo sentido comparar, é uma decisão importante. Posso te perguntar: o que te fez querer buscar uma segunda opção? Foi valor, confiança, ou algo que não te deixou seguro lá?$m$, now() - interval '34 days' + interval '50 minutes'),
  ('+5567992000005','demo-w5-05','lead',    $m$Foi mais valor mesmo. Eles fizeram por 26 mil o protocolo superior. Queria ver se vocês fazem por menos.$m$, now() - interval '34 days' + interval '65 minutes'),
  ('+5567992000005','demo-w5-06','clinica', $m$Entendi, Cláudio. Vou ser bem transparente: aqui o protocolo superior fica na faixa de R$ 32 a R$ 38 mil, dependendo do material dos dentes e da necessidade de enxerto. Então provavelmente não vou conseguir ser o mais barato, e tudo bem 😊 O que posso te mostrar é o porquê dessa diferença, e aí você decide com clareza.$m$, now() - interval '34 days' + interval '80 minutes'),
  ('+5567992000005','demo-w5-07','lead',    $m$E qual seria a diferença? No fim é o mesmo protocolo né$m$, now() - interval '34 days' + interval '110 minutes'),
  ('+5567992000005','demo-w5-08','clinica', $m$Ótima pergunta. A diferença costuma estar no que não aparece no orçamento: a marca dos implantes (usamos implantes com garantia vitalícia, de marcas premium), o material da prótese, o planejamento digital e, principalmente, o acompanhamento pós, que aqui é de 24 meses incluso. Protocolo é uma cirurgia que você leva pra vida, então o barato às vezes sai caro se precisar refazer. Mas isso eu prefiro que a Dra. te explique olho no olho. Posso marcar uma avaliação?$m$, now() - interval '34 days' + interval '130 minutes'),
  ('+5567992000005','demo-w5-09','lead',    $m$Mas eu já tenho o exame, não precisaria de outra avaliação. Você não consegue me passar um valor fechado por aqui?$m$, now() - interval '33 days'),
  ('+5567992000005','demo-w5-10','clinica', $m$Entendo a praticidade que você quer, Cláudio 😊 Mas eu seria irresponsável em cravar um valor fechado sem a Dra. te examinar, porque cada caso tem particularidade que o raio-x sozinho não mostra. O que posso garantir é a faixa que te falei. Se fizer sentido, a avaliação é rápida e te dá o número exato + o plano.$m$, now() - interval '33 days' + interval '40 minutes'),
  ('+5567992000005','demo-w5-11','lead',    $m$Entendo. Vou pensar então, porque a diferença pro outro tá grande.$m$, now() - interval '33 days' + interval '90 minutes'),
  ('+5567992000005','demo-w5-12','clinica', $m$Claro, sem pressa 💙 Fico à disposição pra qualquer dúvida. E se quiser, posso te mandar alguns casos de pacientes nossos de protocolo superior, pra você ver o padrão de resultado. Quer?$m$, now() - interval '33 days' + interval '100 minutes'),
  ('+5567992000005','demo-w5-13','lead',    $m$Pode mandar.$m$, now() - interval '33 days' + interval '130 minutes'),
  ('+5567992000005','demo-w5-14','clinica', $m$Vou separar e te envio ainda hoje 😊$m$, now() - interval '33 days' + interval '140 minutes'),
  ('+5567992000005','demo-w5-15','clinica', $m$Oi, Cláudio! Tudo bem? Te enviei alguns casos semana passada 😊 Conseguiu dar uma olhada? Queria saber se ainda posso te ajudar a decidir.$m$, now() - interval '26 days'),
  ('+5567992000005','demo-w5-16','lead',    $m$Oi, Bruna. Olhei sim, ficaram bons. Mas, pra ser sincero, acabei fechando com a outra clínica. A diferença de valor pesou. Obrigado pela atenção.$m$, now() - interval '23 days'),
  ('+5567992000005','demo-w5-17','clinica', $m$Imagina, Cláudio! Agradeço a sinceridade 💙 Desejo de coração que dê tudo certo no seu tratamento. E se um dia precisar de qualquer coisa, ou de uma segunda opinião, a porta da Lumina está sempre aberta pra você 🙏$m$, now() - interval '23 days' + interval '30 minutes'),
  ('+5567992000005','demo-w5-18','lead',    $m$Obrigado! Abraço$m$, now() - interval '22 days')
) AS m(numero, mid, remetente, conteudo, enviada_em)
JOIN comercial.conversas cv ON cv.numero_whatsapp = m.numero
ON CONFLICT (message_id_evolution) DO NOTHING;

-- CONVERSA 6 — Sabrina (+...006): negociacao de parcelamento exemplar, lead quente, agenda.
INSERT INTO comercial.mensagens (conversa_id, message_id_evolution, tipo, fonte, conteudo, remetente, enviada_em)
SELECT cv.id, m.mid, 'texto', 'humano', m.conteudo, m.remetente, m.enviada_em
FROM (VALUES
  ('+5567992000006','demo-w6-01','lead',    $m$Oi! Vim pelo anúncio do protocolo. Já passei da fase de será que faço, eu QUERO fazer kkk. Só preciso entender se cabe no meu bolso$m$, now() - interval '6 days'),
  ('+5567992000006','demo-w6-02','clinica', $m$Oii, Sabrina! Adorei a energia 😄💙 Aqui é a Bruna. Então bora resolver isso! Me conta: você já sabe o que precisa fazer ou ainda não avaliou? E é arcada de cima, de baixo, as duas?$m$, now() - interval '6 days' + interval '10 minutes'),
  ('+5567992000006','demo-w6-03','lead',    $m$As duas. Já fiz avaliação ano passado em outro lugar, falaram protocolo nas duas. Não fiz na época por causa do valor, mas agora me organizei$m$, now() - interval '6 days' + interval '22 minutes'),
  ('+5567992000006','demo-w6-04','clinica', $m$Que bom que se organizou, isso muda tudo 🙌 Como já faz um tempo da sua avaliação, o ideal é a Dra. Helena reavaliar pra confirmar o plano e te dar o valor atual fechado. Mas já adianto a faixa pra você ir se planejando: protocolo nas duas arcadas costuma ficar entre R$ 55 e R$ 75 mil. Antes de você se assustar 😅 deixa eu já te falar das condições, porque é aí que vira realidade.$m$, now() - interval '6 days' + interval '33 minutes'),
  ('+5567992000006','demo-w6-05','lead',    $m$Pode falar que eu tô preparada kkk$m$, now() - interval '6 days' + interval '40 minutes'),
  ('+5567992000006','demo-w6-06','clinica', $m$Kkk amo 😄 A gente trabalha assim: uma entrada, normalmente 30%, e o saldo a gente divide. Dá pra parcelar em até 18x no cartão, ou usar financiamento odontológico, que estica mais o prazo e libera uma entrada menor. Tem gente que faz uma arcada agora e a outra em alguns meses, pra diluir. Na consulta a gente monta a simulação no seu nome, com número real. Mas me diz: o que ficaria mais confortável pra você, uma entrada menor ou uma parcela menor?$m$, now() - interval '6 days' + interval '52 minutes'),
  ('+5567992000006','demo-w6-07','lead',    $m$Parcela menor. A entrada eu consigo dar uns 15 mil$m$, now() - interval '6 days' + interval '65 minutes'),
  ('+5567992000006','demo-w6-08','clinica', $m$Perfeito, isso já facilita muito 🙌 Com uma entrada nessa faixa dá pra deixar a parcela bem mais leve. Deixa eu fazer uma conta rápida só pra te dar uma noção... num cenário de R$ 65 mil, com 15 de entrada, sobram 50, que em 18x daria por volta de R$ 2.800/mês, e num financiamento de prazo maior cairia pra faixa de R$ 1.600 a R$ 1.900. Tudo isso a gente fecha certinho na consulta, tá? Mas dá pra caber sim 😊$m$, now() - interval '6 days' + interval '78 minutes'),
  ('+5567992000006','demo-w6-09','lead',    $m$Caraca, isso é bem mais possível do que eu imaginava$m$, now() - interval '6 days' + interval '90 minutes'),
  ('+5567992000006','demo-w6-10','clinica', $m$É quase sempre assim 💙 As pessoas travam no valor cheio e nem imaginam que parcelado vira uma realidade tranquila. Bora marcar sua reavaliação então? Te dou o número fechado e já saio com a simulação pronta. Tenho segunda 16h ou terça 10h.$m$, now() - interval '6 days' + interval '100 minutes'),
  ('+5567992000006','demo-w6-11','lead',    $m$Terça 10h!$m$, now() - interval '6 days' + interval '115 minutes'),
  ('+5567992000006','demo-w6-12','clinica', $m$Fechadíssimo, terça 10h com a Dra. Helena 🗓️ Vou te mandar o endereço e te confirmo na véspera. Já deixo anotado pra Dra. que você quer focar em deixar a parcela leve, pode deixar 💙$m$, now() - interval '6 days' + interval '122 minutes'),
  ('+5567992000006','demo-w6-13','lead',    $m$Você é maravilhosa, obrigada!! Já tô empolgada$m$, now() - interval '6 days' + interval '135 minutes'),
  ('+5567992000006','demo-w6-14','clinica', $m$Aaah que delícia ler isso 🥰 Você vai sair de lá com um plano que cabe na sua vida. Até terça!$m$, now() - interval '6 days' + interval '140 minutes'),
  ('+5567992000006','demo-w6-15','lead',    $m$Bruna, esqueci de perguntar: a cirurgia dói muito? E quanto tempo fico sem dente kkk meu maior medo$m$, now() - interval '5 days'),
  ('+5567992000006','demo-w6-16','clinica', $m$Pergunta super válida 😊 Olha: a cirurgia é feita com anestesia, e com sedação se você quiser, então durante não dói nada. No pós tem um desconforto controlado com medicação, mas a maioria das pacientes se surpreende de como é tranquilo. E você NÃO fica sem dente: colocamos uma prótese provisória fixa no mesmo dia, então você sai já sorrindo. Esse é um dos maiores diferenciais do protocolo 💙$m$, now() - interval '5 days' + interval '25 minutes'),
  ('+5567992000006','demo-w6-17','lead',    $m$AAAH que alívio, era isso que me travava$m$, now() - interval '5 days' + interval '35 minutes'),
  ('+5567992000006','demo-w6-18','clinica', $m$Pois é, esse medo trava muita gente à toa 🥹 Pode ficar super tranquila. Anota suas dúvidas que na terça a Dra. responde todas, combinado?$m$, now() - interval '5 days' + interval '45 minutes'),
  ('+5567992000006','demo-w6-19','lead',    $m$Combinado! Obrigada de novo 💕$m$, now() - interval '5 days' + interval '60 minutes'),
  ('+5567992000006','demo-w6-20','clinica', $m$Oi, Sabrina! Tudo certo pra nossa consulta amanhã às 10h? 😊 Posso confirmar sua presença?$m$, now() - interval '3 hours' - interval '40 minutes'),
  ('+5567992000006','demo-w6-21','lead',    $m$Confirmo sim! Tô contando os dias kkk$m$, now() - interval '3 hours' - interval '20 minutes'),
  ('+5567992000006','demo-w6-22','clinica', $m$Aeee 🎉 Te espero amanhã então. Vai dar tudo certo 💙$m$, now() - interval '3 hours')
) AS m(numero, mid, remetente, conteudo, enviada_em)
JOIN comercial.conversas cv ON cv.numero_whatsapp = m.numero
ON CONFLICT (message_id_evolution) DO NOTHING;

-- CONVERSA 7 — Aline (+...007): atendimento fraco, objecao nao trabalhada, esfria. (contraste c/ Larissa)
INSERT INTO comercial.mensagens (conversa_id, message_id_evolution, tipo, fonte, conteudo, remetente, enviada_em)
SELECT cv.id, m.mid, 'texto', 'humano', m.conteudo, m.remetente, m.enviada_em
FROM (VALUES
  ('+5567992000007','demo-w7-01','lead',    $m$oi quanto custa o preenchimento labial?$m$, now() - interval '9 days'),
  ('+5567992000007','demo-w7-02','clinica', $m$Oi! O preenchimento labial fica a partir de R$ 1.800 😊$m$, now() - interval '9 days' + interval '35 minutes'),
  ('+5567992000007','demo-w7-03','lead',    $m$nossa achei caro$m$, now() - interval '9 days' + interval '50 minutes'),
  ('+5567992000007','demo-w7-04','clinica', $m$Entendo! Mas é um produto de qualidade, viu? Dura bastante.$m$, now() - interval '9 days' + interval '70 minutes'),
  ('+5567992000007','demo-w7-05','lead',    $m$tem desconto?$m$, now() - interval '9 days' + interval '85 minutes'),
  ('+5567992000007','demo-w7-06','clinica', $m$Pra fechar à vista a gente consegue ver uma condiçãozinha 😊$m$, now() - interval '9 days' + interval '110 minutes'),
  ('+5567992000007','demo-w7-07','lead',    $m$hmm vou pensar$m$, now() - interval '9 days' + interval '140 minutes'),
  ('+5567992000007','demo-w7-08','clinica', $m$Tá bom! Qualquer coisa estou aqui.$m$, now() - interval '9 days' + interval '150 minutes'),
  ('+5567992000007','demo-w7-09','clinica', $m$Oi, Aline! Pensou sobre o preenchimento? 😊$m$, now() - interval '7 days'),
  ('+5567992000007','demo-w7-10','lead',    $m$oi ainda tô pensando, tá meio caro pra mim agora$m$, now() - interval '7 days' + interval '120 minutes'),
  ('+5567992000007','demo-w7-11','clinica', $m$Imagina, sem problema! Quando quiser é só chamar 😊$m$, now() - interval '7 days' + interval '130 minutes'),
  ('+5567992000007','demo-w7-12','clinica', $m$Oi, Aline! Surgiu alguma novidade sobre o preenchimento? Tô à disposição 💙$m$, now() - interval '28 hours'),
  ('+5567992000007','demo-w7-13','lead',    $m$ainda não, depois eu vejo$m$, now() - interval '27 hours')
) AS m(numero, mid, remetente, conteudo, enviada_em)
JOIN comercial.conversas cv ON cv.numero_whatsapp = m.numero
ON CONFLICT (message_id_evolution) DO NOTHING;

-- CONVERSA 8 — Felipe (+...008): lead objetivo, atendimento eficiente, agenda rapido.
INSERT INTO comercial.mensagens (conversa_id, message_id_evolution, tipo, fonte, conteudo, remetente, enviada_em)
SELECT cv.id, m.mid, 'texto', 'humano', m.conteudo, m.remetente, m.enviada_em
FROM (VALUES
  ('+5567992000008','demo-w8-01','lead',    $m$Boa tarde, perdi um dente (pré-molar) e quero colocar implante. Vocês fazem? Qual valor e prazo?$m$, now() - interval '11 days'),
  ('+5567992000008','demo-w8-02','clinica', $m$Boa tarde, Felipe! Aqui é a Bruna 😊 Fazemos sim, implante é uma das nossas especialidades. Pra um implante unitário com a coroa, o investimento fica em torno de R$ 4.500 a R$ 5.500, dependendo do osso e do tipo de coroa. O processo leva em média de 3 a 5 meses, contando a cicatrização. O ideal é uma avaliação com raio-x pra confirmar se já dá pra implantar direto ou se precisa de algum preparo. Você tem exame recente?$m$, now() - interval '11 days' + interval '18 minutes'),
  ('+5567992000008','demo-w8-03','lead',    $m$Não tenho exame. Quanto é a avaliação?$m$, now() - interval '11 days' + interval '30 minutes'),
  ('+5567992000008','demo-w8-04','clinica', $m$A avaliação com raio-x fica R$ 150, e vira crédito no tratamento se você seguir com a gente 😊$m$, now() - interval '11 days' + interval '38 minutes'),
  ('+5567992000008','demo-w8-05','lead',    $m$Beleza. Tem horário essa semana?$m$, now() - interval '11 days' + interval '50 minutes'),
  ('+5567992000008','demo-w8-06','clinica', $m$Tenho! Quinta 9h ou sexta 14h. Qual prefere?$m$, now() - interval '11 days' + interval '58 minutes'),
  ('+5567992000008','demo-w8-07','lead',    $m$Quinta 9h.$m$, now() - interval '11 days' + interval '66 minutes'),
  ('+5567992000008','demo-w8-08','clinica', $m$Marcado, Felipe! Quinta 9h 🗓️ Te mando o endereço aqui. Na véspera eu confirmo com você. Qualquer coisa, só chamar 💙$m$, now() - interval '11 days' + interval '72 minutes'),
  ('+5567992000008','demo-w8-09','lead',    $m$Perfeito, obrigado.$m$, now() - interval '11 days' + interval '80 minutes'),
  ('+5567992000008','demo-w8-10','clinica', $m$Oi, Felipe! Confirmando sua avaliação amanhã 9h 😊$m$, now() - interval '2 days'),
  ('+5567992000008','demo-w8-11','lead',    $m$Confirmado 👍$m$, now() - interval '2 days' + interval '45 minutes')
) AS m(numero, mid, remetente, conteudo, enviada_em)
JOIN comercial.conversas cv ON cv.numero_whatsapp = m.numero
ON CONFLICT (message_id_evolution) DO NOTHING;

-- CONVERSA 9 — Letícia (+...011): lead novo quentissimo, recepcao surfa o entusiasmo.
INSERT INTO comercial.mensagens (conversa_id, message_id_evolution, tipo, fonte, conteudo, remetente, enviada_em)
SELECT cv.id, m.mid, 'texto', 'humano', m.conteudo, m.remetente, m.enviada_em
FROM (VALUES
  ('+5567992000011','demo-w9-01','lead',    $m$Oi!! Vi o anúncio das lentes de contato dental e AMEI os resultados das fotos 😍😍 quero muito fazer!!$m$, now() - interval '20 hours'),
  ('+5567992000011','demo-w9-02','clinica', $m$Oiii, Letícia! Que alegria ler isso 😍💙 Aqui é a Bruna. As lentes transformam o sorriso de um jeito lindo mesmo, e o melhor é quando fica natural e harmônico com o seu rosto. Me conta: o que você mais quer mudar no seu sorriso hoje?$m$, now() - interval '20 hours' + interval '15 minutes'),
  ('+5567992000011','demo-w9-03','lead',    $m$Meus dentes são meio amarelados e tortinhos na frente, e tenho um espacinho entre os dois da frente que me incomoda muito$m$, now() - interval '20 hours' + interval '30 minutes'),
  ('+5567992000011','demo-w9-04','clinica', $m$Ahh, sei exatamente o que você quer alcançar 😊 As lentes resolvem cor, formato e fecham esse espacinho de uma vez, num resultado super uniforme. Cada caso a Dra. Helena planeja digitalmente, então você consegue até ver uma prévia de como vai ficar antes de fazer. Você já tinha feito avaliação pra lentes antes ou seria a primeira vez?$m$, now() - interval '20 hours' + interval '45 minutes'),
  ('+5567992000011','demo-w9-05','lead',    $m$Primeira vez! Quanto custa mais ou menos? E dá pra ver essa prévia mesmo??$m$, now() - interval '19 hours'),
  ('+5567992000011','demo-w9-06','clinica', $m$Dá sim, e é uma das partes mais emocionantes 🥹 Sobre o investimento, as lentes ficam a partir de R$ 2.500 por dente, e geralmente a gente trabalha o conjunto da frente, os dentes que aparecem no sorriso, pra ficar harmônico. A Dra. fecha o número exato vendo seu caso, e a gente parcela. A avaliação com o planejamento é R$ 150 e vira crédito. Quer que eu já veja um horário pra você?$m$, now() - interval '19 hours' + interval '14 minutes'),
  ('+5567992000011','demo-w9-07','lead',    $m$Quero!! Pode ser amanhã? Tô muito animada kkk$m$, now() - interval '19 hours' + interval '25 minutes'),
  ('+5567992000011','demo-w9-08','clinica', $m$Amo essa empolgação 😄💙 Deixa eu ver... tenho amanhã às 16h, fechou? Te mando o endereço já já.$m$, now() - interval '18 hours' + interval '40 minutes'),
  ('+5567992000011','demo-w9-09','lead',    $m$FECHOU! Obrigada 🥰$m$, now() - interval '18 hours' + interval '50 minutes'),
  ('+5567992000011','demo-w9-10','clinica', $m$Aeee 🎉 Te espero amanhã, Letícia! Vai ser o primeiro passo pro sorriso que você sempre quis 💙$m$, now() - interval '18 hours' + interval '55 minutes')
) AS m(numero, mid, remetente, conteudo, enviada_em)
JOIN comercial.conversas cv ON cv.numero_whatsapp = m.numero
ON CONFLICT (message_id_evolution) DO NOTHING;

-- 5. Calls (transcricoes de consulta) ---------------------------------
-- Todas com analisada_em = NULL: entram na FILA para o sistema analisar ao vivo.
-- Transcricoes em dollar-quoting ($tx$...$tx$).

-- CALL 1 — Mariana (+...001): fechamento protocolo + HOF. Consulta modelo.
INSERT INTO comercial.calls
  (lead_id, titulo, duracao_segundos, plaud_id, transcricao, transcricao_origem,
   telefone_extraido, match_status, match_confirmado_em, realizada_em, analisada_em, created_at)
SELECT l.id, c.titulo, c.dur, c.plaud_id, c.transc, 'plaud', c.tel, c.match_status,
       CASE WHEN c.match_status IN ('confirmado','confirmado_auto') THEN c.realizada_em ELSE NULL END,
       c.realizada_em, NULL, c.realizada_em
FROM (VALUES
  ('+5567992000001', 'Consulta — Mariana Albuquerque (protocolo superior + HOF)', 2460, 'demo-call-0001',
$tx$[Consulta de avaliação e fechamento — Dra. Helena e a paciente Mariana]

Dra. Helena: Mariana, seja muito bem-vinda. A Bruna já me adiantou um pouquinho, mas eu gosto de ouvir da própria pessoa. Me conta: o que te trouxe até aqui?

Mariana: Então, doutora... é meio difícil falar. Eu tenho 38 anos e há uns bons anos eu evito sorrir. Nas fotos eu fecho a boca, no trabalho eu coloco a mão na frente quando rio. Meus dentes da frente estão desgastados, tenho uns escurecidos, e dois que eu já fiz canal há muito tempo. Eu sinto que isso me trava, sabe? Até em reunião eu falo menos.

Dra. Helena: Obrigada por confiar isso a mim. E olha, o que você acabou de descrever não é sobre dente, é sobre o quanto isso te impede de se mostrar pro mundo. Posso te perguntar: se a gente resolvesse isso, o que mudaria no seu dia a dia?

Mariana: Nossa... acho que eu voltaria a ser eu. Eu era de rir alto, de me jogar nas fotos. Eu sinto que perdi isso.

Dra. Helena: Então é isso que a gente vai buscar: te devolver. Deixa eu te examinar com calma agora, e a gente já tirou o raio-x panorâmico lá fora, então eu já consegui ver bastante coisa. Abre pra mim, por favor... isso. Pode fechar.

Mariana: E aí, é muito ruim?

Dra. Helena: Vou ser honesta e clara com você, que é como eu trabalho. O que eu vejo é o seguinte: na arcada de cima, seus dentes da frente têm desgaste importante, dois com tratamento de canal antigo que estão fragilizados e escurecidos, e a estrutura de alguns não comporta mais só uma restauração simples, porque ia quebrar de novo. Embaixo seus dentes estão muito melhores, a gente preserva. Então o seu caso não é arrancar tudo, tá? Longe disso.

Mariana: Ai que alívio, eu tinha pavor de perder tudo.

Dra. Helena: Imagina, eu jamais indicaria algo além do necessário. O que o seu caso pede é uma reabilitação da arcada superior, combinando coroas e a substituição dos dois dentes comprometidos, devolvendo formato, cor e proteção. E, como o que te incomoda é o conjunto do sorriso, eu sugiro também uma harmonização leve, porque quando a gente trata só o dente e esquece a moldura, o resultado não fica completo. No seu caso seria um pouquinho de preenchimento pra suavizar duas linhas que te envelhecem e equilibrar o sorriso. Mas isso é complementar, a decisão é sua.

Mariana: Eu sempre achei que o problema era só o dente, mas faz sentido o que a senhora diz.

Dra. Helena: Deixa eu te mostrar uma coisa. Esse aqui é o planejamento digital: a gente fotografa, escaneia e eu desenho o seu sorriso novo no computador antes de fazer qualquer coisa. Você vê a prévia e a gente ajusta junto, até você falar é isso. Olha aqui um caso de uma paciente com situação parecida com a sua... esse é o antes... e esse é o depois.

Mariana: Meu Deus. Isso é real? Ela ficou linda. E ficou natural, não parece dente falso.

Dra. Helena: É exatamente esse o nosso compromisso: natural. Ninguém vai olhar e pensar fez os dentes. Vão pensar como você está bem. E pra mim, sinceramente, o mais bonito é o que acontece com a pessoa por dentro, ela volta a sorrir solta, igual você me descreveu agora há pouco.

Mariana: É isso que eu quero. Mas eu preciso saber o valor, doutora, porque não adianta eu me apaixonar e não conseguir.

Dra. Helena: Justo, e eu vou te dar o número certinho. Antes só quero que você entenda o que está incluso, pra comparar peras com peras se um dia você comparar: implantes e materiais de marcas premium com garantia, o planejamento digital, todas as etapas clínicas, as provisórias pra você nunca ficar sem sorrir, a harmonização, e o acompanhamento por 24 meses depois de pronto. O investimento completo do seu caso, reabilitação superior mais a harmonização, fica em R$ 42 mil.

Mariana: [pausa] É bastante, né...

Dra. Helena: É um investimento sério, eu não vou fingir que não é. Mas deixa eu te mostrar como ele cabe, porque ninguém paga isso à vista de uma vez. A gente trabalha com uma entrada de 30%, que no seu caso seria R$ 12.600, e o restante a gente divide. Em 18x no cartão ficaria em torno de R$ 1.633 por mês. Se você preferir uma parcela menor, dá pra usar o financiamento odontológico e esticar o prazo, caindo pra faixa de R$ 950 a R$ 1.100 por mês. O que te deixa mais confortável?

Mariana: A parcela de mil e pouco eu consigo encaixar tranquilo. A entrada que me assusta um pouco agora.

Dra. Helena: Entendo. A gente tem duas saídas pra isso: ou a gente parcela parte da entrada também, ou a gente agenda o início do tratamento pra daqui a três semanas, te dando esse fôlego pra organizar a entrada com calma. Qual faz mais sentido pra sua vida?

Mariana: Se der pra começar em três semanas eu consigo me organizar direitinho pra entrada.

Dra. Helena: Perfeito, então é isso que a gente faz. Mariana, deixa eu te perguntar de coração: tirando a parte do dinheiro, que a gente já resolveu, tem mais alguma coisa te segurando? Algum medo?

Mariana: O medo da cirurgia, da dor.

Dra. Helena: Pergunta importantíssima. A parte cirúrgica é feita com anestesia e, se você quiser, com sedação, então durante o procedimento você não sente dor nenhuma. No pós você tem um desconforto, que a gente controla muito bem com medicação, e a maioria das minhas pacientes me diz foi bem mais tranquilo do que eu imaginava. E você não fica um dia sequer sem dente, porque eu coloco as provisórias fixas na mesma etapa. Você entra e sai daqui sorrindo. Isso te tranquiliza?

Mariana: Tranquiliza muito. Eu acho que é isso, doutora. Eu quero fazer.

Dra. Helena: Fico muito feliz, Mariana, de verdade. Você está tomando uma decisão por você, e isso é lindo. Então vamos fazer assim: eu já fecho aqui o seu plano, a Bruna prepara o contrato e a gente agenda o início pra daqui a três semanas. Hoje você não precisa desembolsar nada, a entrada fica pra data de início. Eu já vou pedir pra equipe começar o planejamento digital do seu sorriso, pra na próxima vez você já ver a sua prévia. Combinado?

Mariana: Combinado. Obrigada, doutora, eu vim aqui com o pé atrás e tô saindo emocionada.

Dra. Helena: É essa emoção que vai estar no seu rosto quando você se olhar no espelho no fim. Bem-vinda, Mariana. A gente vai cuidar muito bem de você.$tx$,
   'confirmado_auto', now() - interval '41 days'),

  ('+5567992000009', 'Consulta — Renato Capalbo (implante unitário + enxerto)', 1980, 'demo-call-0002',
$tx$[Consulta de avaliação e fechamento — Dr. Paulo e o paciente Renato]

Dr. Paulo: Renato, prazer. Vi aqui que você veio por indicação da Dra. Lima, é isso?

Renato: Isso, doutor. Ela é minha clínica geral e falou que aqui era o melhor lugar pra resolver o implante.

Dr. Paulo: Fico honrado, ela é excelente. Então me conta o que aconteceu.

Renato: Perdi um molar embaixo, do lado direito, faz uns oito meses. Extraí porque quebrou e inflamou. Desde então tô mastigando só de um lado e tá me incomodando, e quero resolver antes que estrague os outros.

Dr. Paulo: Você está absolutamente certo na sua preocupação, e isso mostra que você entende do assunto. Quando a gente perde um dente e não repõe, acontece duas coisas: o osso naquela região começa a reabsorver, encolher, e os dentes vizinhos tendem a inclinar pro espaço vazio. Então quanto antes resolver, melhor. Deixa eu examinar e olhar seu raio-x... pode abrir. Isso. Pode fechar.

Renato: E aí, dá pra fazer o implante?

Dr. Paulo: Dá, e vou te explicar com franqueza o que o seu caso pede, porque tem um detalhe. Como já faz oito meses da extração e teve aquela inflamação, o osso naquela região reabsorveu mais do que o ideal. Pra colocar o implante com segurança e durabilidade, a gente precisa primeiro de um enxerto ósseo, que é recompor essa base. Se eu colocar o implante num osso insuficiente só pra adiantar, eu estaria comprometendo a longevidade, e isso eu não faço.

Renato: Entendi. E isso encarece bastante?

Dr. Paulo: O enxerto entra como uma etapa a mais, sim, mas ele é o que garante que o seu implante vai durar décadas, e não que vai falhar em poucos anos. Vou te passar o investimento completo, com tudo incluso: o enxerto, o implante de uma marca com garantia vitalícia, a coroa de porcelana e todo o acompanhamento. Fica em R$ 14 mil.

Renato: Achei justo pra tudo isso. Dá pra parcelar?

Dr. Paulo: Claro. Entrada de 30%, que seriam R$ 4.200, e o restante em até 12x, ficando R$ 816 por mês. Ou à vista a gente consegue um desconto de 8%.

Renato: Vou de parcelado mesmo, prefiro não descapitalizar. Uma dúvida: quanto tempo demora tudo?

Dr. Paulo: Boa pergunta, é importante você ter a expectativa certa. O enxerto precisa de uns 4 meses pra integrar antes de eu colocar o implante. Depois do implante, mais uns 3 meses pra osseointegração antes da coroa definitiva. Então no total a gente fala em torno de 7 a 8 meses pra finalizar. Eu sei que parece longo, mas cada etapa tem um porquê biológico. Não dá pra apressar a natureza sem arriscar o resultado.

Renato: Não, isso eu prefiro fazer bem feito. Já perdi um, não quero perder de novo por pressa.

Dr. Paulo: Essa é exatamente a mentalidade certa, Renato. Então vamos fechar assim: eu já solicito o exame tomográfico pra eu planejar o enxerto com precisão, a recepção monta seu contrato com a entrada e o parcelamento que combinamos, e a gente agenda a primeira cirurgia, do enxerto, pras próximas duas semanas. Pode ser?

Renato: Pode sim, doutor. Confio na indicação da Dra. Lima e gostei da sua sinceridade sobre o enxerto. Muita gente ia só vender o implante rápido.

Dr. Paulo: É que pra mim o que importa é você mastigando bem daqui a dez anos, não a venda de hoje. Vamos cuidar disso direito. Bem-vindo.$tx$,
   'confirmado', now() - interval '36 days'),

  ('+5567992000004', 'Consulta — Larissa Fontes (HOF: botox + preenchimento labial)', 1500, 'demo-call-0003',
$tx$[Consulta de avaliação e fechamento — Dra. Helena e a paciente Larissa]

Dra. Helena: Larissa, que bom te conhecer pessoalmente. A Bruna me contou que é sua primeira vez com harmonização e que você tinha um receio com resultados artificiais. É isso?

Larissa: Exatamente, doutora. Eu quero muito, mas morro de medo de ficar com aquela cara de pato, ou o rosto durão. Já vi cada coisa...

Dra. Helena: E você está certíssima em ter esse cuidado. Eu vou te dizer uma coisa que talvez seja diferente do que você espera ouvir: o meu trabalho não é te deixar diferente, é te deixar parecendo você num dia muito bom. Descansada, harmônica. Se alguém olhar e perguntar o que você fez, pra mim foi exagerado. Pode me contar o que te incomoda?

Larissa: Eu acho meu rosto meio caído, principalmente aqui embaixo, e meus lábios sempre foram bem finos, eu queria um pouco mais de volume, mas com medo de ficar exagerado.

Dra. Helena: Deixa eu olhar de pertinho... faz uma expressão neutra pra mim, relaxa o rosto. Sorri. Obrigada. Tá, o que eu observo combina com o que você sentiu: você tem uma flacidez inicial no terço inferior, bem no começo, e os lábios com pouco volume e os cantos levemente caídos, o que dá uma impressão de cansaço mesmo. Nada grave, é o tempo fazendo o trabalho dele.

Larissa: Então o que a senhora sugere?

Dra. Helena: Pro seu caso eu proponho duas coisas, e olha que eu não vou empurrar nada além disso: um botox bem pontual pra suavizar e dar uma leve elevação, e um preenchimento labial com técnica de hidratação e contorno, num volume natural, pra dar vida sem mudar a sua identidade. O bioestimulador, que seria pra flacidez, eu não indico ainda, porque a sua é muito inicial e seria precipitado. Daqui a um ano a gente reavalia. Prefiro fazer o que você precisa, não o máximo que dá pra vender.

Larissa: Nossa, eu até esperava que a senhora fosse sugerir tudo.

Dra. Helena: Esse é o tipo de coisa que faz a diferença no longo prazo, e que faz você confiar em mim pra sempre. Sobre o produto: eu uso só ácido hialurônico de marca premium importada, com registro e rastreabilidade. É aqui que mora a diferença daqueles resultados ruins e das complicações que você viu por aí, quase sempre é produto barato e sem procedência, ou mão inexperiente.

Larissa: Faz total sentido. E o valor?

Dra. Helena: O preenchimento labial com esse produto fica R$ 1.800 e o botox da região R$ 1.200. Fechando os dois juntos hoje, como pacote, eu consigo fazer os dois por R$ 2.700, em vez de R$ 3 mil. Pode ser parcelado em até 6x sem juros.

Larissa: Ah, gostei. E dói?

Dra. Helena: O botox é praticamente indolor, picadinhas finas. No lábio a gente usa anestésico tópico e o produto já vem com anestésico, então é bem tranquilo, um leve desconforto só. Em uma hora você está indo embora e já pode tocar a vida normal, com uns cuidados simples que eu te explico.

Larissa: Sabe que eu vim super insegura e agora tô tranquila? Quero fazer.

Dra. Helena: Que alegria ouvir isso, Larissa. Então vamos fechar o pacote dos dois, e eu já consigo até começar hoje se você quiser, ou a gente agenda pra essa semana. A recepção resolve o pagamento e eu já te explico o pré e o pós. Combinado?

Larissa: Combinado! Vou marcar pra essa semana porque hoje vim de bermuda e quero vir arrumada kkk.

Dra. Helena: Kkk perfeito, fica à vontade. Você vai amar, e o melhor: vai continuar sendo você.$tx$,
   'confirmado_auto', now() - interval '5 days')
) AS c(tel, titulo, dur, plaud_id, transc, match_status, realizada_em)
LEFT JOIN comercial.leads l ON l.telefone = c.tel
ON CONFLICT (plaud_id) DO NOTHING;

-- CALL 4-7 — calls com falhas + fila de match.
INSERT INTO comercial.calls
  (lead_id, titulo, duracao_segundos, plaud_id, transcricao, transcricao_origem,
   telefone_extraido, match_status, match_confirmado_em, realizada_em, analisada_em, created_at)
SELECT l.id, c.titulo, c.dur, c.plaud_id, c.transc, 'plaud', c.tel, c.match_status,
       CASE WHEN c.match_status IN ('confirmado','confirmado_auto') THEN c.realizada_em ELSE NULL END,
       c.realizada_em, NULL, c.realizada_em
FROM (VALUES
  ('+5567992000002', 'Consulta — Gustavo Pereira (avaliação protocolo)', 1320, 'demo-call-0004',
$tx$[Consulta de avaliação — Dr. Paulo e o paciente Gustavo]

Dr. Paulo: Gustavo, então você falou com a Bruna que faltam alguns dentes embaixo e os de cima estão ruins. Deixa eu dar uma olhada. Abre a boca pra mim... pode fechar.

Gustavo: E aí, doutor?

Dr. Paulo: Você tem ausência de dois molares na arcada inferior e desgaste nos dentes da frente em cima. O ideal seria um protocolo na parte de baixo e uma reabilitação na de cima.

Gustavo: E quanto fica isso tudo?

Dr. Paulo: O protocolo inferior fica em torno de R$ 32 mil, e a reabilitação superior mais uns R$ 10 mil. Tudo junto a gente fala em R$ 42 mil.

Gustavo: Olha, doutor, sinceramente, tá muito acima do que eu posso pagar. Tá bem apertado pra mim no momento.

Dr. Paulo: A gente parcela, viu, Gustavo? Dá pra fazer uma entrada e dividir o restante em até 18 vezes.

Gustavo: Mas mesmo parcelado fica pesado pro meu bolso agora.

Dr. Paulo: Se você fechar à vista eu consigo ver um desconto pra você. Ou a gente pode fazer por partes, começar só pela parte de baixo, que é mais urgente, e a de cima você faz mais pra frente.

Gustavo: É... acho melhor eu pensar. Vou ver meu orçamento direitinho e conversar com a minha esposa.

Dr. Paulo: Tá bom, então. Qualquer coisa a gente está aqui à disposição, viu? Pensa com carinho.

Gustavo: Pode deixar, doutor. Obrigado.$tx$,
   'confirmado', now() - interval '9 days'),

  ('+5567992000010', 'Consulta — Camila Reis (avaliação protocolo)', 1140, 'demo-call-0005',
$tx$[Consulta de avaliação — Dra. Helena e a paciente Camila]

Dra. Helena: Camila, me conta o que te trouxe até aqui.

Camila: Doutora, eu quero fazer o protocolo na parte de cima. Meus dentes me incomodam demais, tenho vergonha de sorrir já faz tempo.

Dra. Helena: Entendo. Deixa eu examinar... abre pra mim, por favor. Pode fechar. Olha, seu caso é totalmente viável, Camila. Dá pra fazer uma reabilitação superior bonita, com um resultado bem natural. Eu te explico: a gente faz o planejamento digital, você vê a prévia, e o investimento completo fica em R$ 38 mil, com entrada e a gente parcela o restante.

Camila: Gostei muito, doutora. É exatamente o que eu queria, sério. Só que eu preciso conversar com meu marido antes, porque é ele que cuida das finanças lá em casa, a gente decide junto essas coisas.

Dra. Helena: Claro, Camila, imagina. Leva o orçamento, conversa com ele com calma em casa.

Camila: Tá ótimo. Então vou conversar com ele e te retorno, pode ser?

Dra. Helena: Perfeito. Fico à disposição pra qualquer dúvida que surgir. O orçamento fica reservado por 15 dias, tá bom?

Camila: Tá bom, doutora. Obrigada!

Dra. Helena: Eu que agradeço, Camila. Aguardo seu retorno então.$tx$,
   'confirmado', now() - interval '8 days'),

  ('+5567992000006', 'Ligação de qualificação — Sabrina Duarte (pré-consulta)', 540, 'demo-call-0006',
$tx$[Ligação de qualificação por telefone — atendente comercial e Sabrina]

Atendente: Sabrina? Oi, aqui é a Carol, da Clínica Lumina, tudo bem? Você conversou com a gente no WhatsApp sobre o protocolo, e eu estou te ligando pra confirmar sua consulta de terça e entender melhor seu caso, pra já deixar tudo preparado pra Dra. Helena.

Sabrina: Oi, Carol! Que ótimo, tô bem ansiosa pra terça.

Atendente: Que bom! Então me conta rapidinho: você já tinha feito uma avaliação antes, né? E foi protocolo nas duas arcadas?

Sabrina: Isso, no ano passado, em outra clínica. Falaram que eu precisava nas duas. Não fiz na época por causa do valor.

Atendente: Entendi. E hoje, o que mais te motiva a resolver isso agora?

Sabrina: Ah, eu me organizei financeiramente e cansei de esconder o sorriso, sabe? Quero fazer logo, já decidi.

Atendente: Amei essa decisão. Então a gente vai cuidar de tudo. Na terça a Dra. Helena reavalia pra confirmar o plano, e a gente já sai com a simulação do parcelamento pronta, focando em deixar a parcela leve, do jeitinho que você falou com a Bruna. Posso confirmar terça às 10h?

Sabrina: Confirmo, pode deixar!

Atendente: Maravilha, Sabrina. Então até terça. Qualquer coisa antes disso, é só me chamar.$tx$,
   'sugerido', now() - interval '2 days'),

  ('+5567999999999', 'Ligação sem identificação (a vincular)', 180, 'demo-call-0007',
$tx$[Ligação recebida — recepção]

Recepção: Clínica Lumina, bom dia!

Pessoa: Oi, bom dia. É sobre um orçamento de implante que eu pedi semana passada.

Recepção: Claro! Pra eu localizar seu cadastro, pode me passar seu nome completo, por favor?

Pessoa: Ah, depois eu ligo com mais calma, tô meio sem tempo agora. Obrigado.

Recepção: Sem problema, estamos à disposição quando quiser!$tx$,
   'sem_lead', now() - interval '1 days')
) AS c(tel, titulo, dur, plaud_id, transc, match_status, realizada_em)
LEFT JOIN comercial.leads l ON l.telefone = c.tel
ON CONFLICT (plaud_id) DO NOTHING;

-- match_sugestoes para a call da Sabrina (status 'sugerido')
UPDATE comercial.calls SET match_sugestoes = (
  SELECT jsonb_agg(jsonb_build_object('lead_id', l.id, 'nome', l.nome, 'telefone', l.telefone, 'confidence', x.conf))
  FROM (VALUES ('+5567992000006', 0.93), ('+5567992000011', 0.21)) AS x(tel, conf)
  JOIN comercial.leads l ON l.telefone = x.tel
) WHERE plaud_id = 'demo-call-0006';

-- 6. Timeline de eventos (factual; sem 'analise' — o sistema gera ao analisar)
INSERT INTO comercial.lead_eventos (lead_id, tipo, descricao, created_at)
SELECT l.id, e.tipo, e.descricao, e.created_at
FROM (VALUES
  ('+5567992000001','mensagem',      'Primeiro contato via WhatsApp (anúncio de protocolo).', now() - interval '46 days'),
  ('+5567992000001','call',          'Consulta de avaliação realizada com a Dra. Helena.',    now() - interval '41 days'),
  ('+5567992000001','status_change', 'Status alterado para "fechou" (protocolo + HOF).',      now() - interval '40 days'),
  ('+5567992000002','mensagem',      'Primeiro contato via WhatsApp (orçamento de protocolo).', now() - interval '24 days'),
  ('+5567992000002','call',          'Consulta de avaliação realizada.',                      now() - interval '9 days'),
  ('+5567992000002','status_change', 'Status alterado para "compareceu".',                    now() - interval '9 days'),
  ('+5567992000003','mensagem',      'Primeiro contato via WhatsApp (lentes).',               now() - interval '18 days'),
  ('+5567992000003','status_change', 'Status alterado para "sem resposta".',                  now() - interval '12 days'),
  ('+5567992000004','mensagem',      'Primeiro contato via WhatsApp (harmonização).',         now() - interval '15 days'),
  ('+5567992000004','call',          'Consulta de avaliação de HOF realizada.',               now() - interval '5 days'),
  ('+5567992000004','status_change', 'Status alterado para "fechou" (botox + preenchimento).', now() - interval '5 days'),
  ('+5567992000005','mensagem',      'Primeiro contato via WhatsApp (protocolo, comparando).', now() - interval '34 days'),
  ('+5567992000005','status_change', 'Status alterado para "perdido" (foi para concorrente).', now() - interval '22 days'),
  ('+5567992000006','mensagem',      'Primeiro contato via WhatsApp (protocolo).',            now() - interval '6 days'),
  ('+5567992000006','call',          'Ligação de qualificação realizada (pré-consulta).',     now() - interval '2 days'),
  ('+5567992000008','mensagem',      'Primeiro contato via WhatsApp (implante).',             now() - interval '11 days'),
  ('+5567992000008','status_change', 'Status alterado para "agendou".',                       now() - interval '2 days'),
  ('+5567992000009','call',          'Consulta de avaliação realizada (implante + enxerto).', now() - interval '36 days'),
  ('+5567992000009','status_change', 'Status alterado para "fechou".',                        now() - interval '31 days'),
  ('+5567992000010','call',          'Consulta de avaliação realizada (protocolo).',          now() - interval '8 days'),
  ('+5567992000010','status_change', 'Status alterado para "compareceu".',                    now() - interval '8 days'),
  ('+5567992000011','mensagem',      'Primeiro contato via WhatsApp (lentes, lead novo).',    now() - interval '20 hours')
) AS e(numero, tipo, descricao, created_at)
JOIN comercial.leads l ON l.telefone = e.numero
ON CONFLICT DO NOTHING;

-- =====================================================================
-- Fim do seed DEMO v2.
-- Material bruto carregado: 12 leads, 9 conversas (mensagens densas),
-- 7 calls com transcricao (5 vinculadas + 1 sugerida + 1 sem lead).
-- SEM analises e SEM rondas: rode a analise do sistema ao vivo sobre
-- as conversas/calls para gerar score, tags, diagnostico e fases.
-- =====================================================================
