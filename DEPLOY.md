# DEPLOY.md — Atlas OS Comercial

Guia de deploy e operações para o ambiente de **demonstração comercial** e para kickoff de novos clientes.

---

## Ambientes

| Ambiente | Repo / Branch | Supabase | Vercel | URL |
|---|---|---|---|---|
| Demo | este repo, branch **`demo`** | projeto `atlas-os-demo` | projeto `atlas-os-comercial-demo` | `.vercel.app` (subdomínio próprio depois) |
| Cliente XYZ | fork `comercial-os-clinica-xyz` | projeto próprio | projeto próprio | acordado no kickoff |

### Estratégia de branch da demo

A demo roda do branch **`demo`**, não do `main`. A única diferença de código entre
os dois branches é o `vercel.json`:

- **`main`** — os 7 crons reais (processar eventos, análises, rondas ao vivo).
- **`demo`** — `{ "crons": [] }`. A demo navega **dados estáticos seedados**; não
  entra WhatsApp/call real, então nenhum cron faz sentido. Zerar os crons também
  mantém a demo dentro do limite do plano **Hobby** da Vercel (que não permite os
  7 crons de produção).

No projeto Vercel da demo, **Settings → Git → Production Branch = `demo`**. Ao
sincronizar a demo com novidades do `main`, faça merge de `main` em `demo` e
**resolva o `vercel.json` mantendo `{ "crons": [] }`**.

---

## Variáveis de Ambiente

Todas as variáveis abaixo são obrigatórias. Faltar qualquer `NEXT_PUBLIC_SUPABASE_*` quebra o build no Vercel (prerender falha silenciosamente).

| Variável | Obrigatório | Descrição |
|---|---|---|
| `NEXT_PUBLIC_SUPABASE_URL` | Sim | Project URL do Supabase (Settings → API) |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | Sim | Chave anon/public do Supabase |
| `SUPABASE_SERVICE_ROLE_KEY` | Sim | Chave service_role — **nunca expor ao cliente** |
| `DEMO_DATABASE_URL` | Só demo | Connection string completa (usado para rodar seed via psql) |
| `NEXT_PUBLIC_APP_URL` | Sim | URL pública do app (ex: `https://demo-comercial.benitesalbuquerque.com.br`) |
| `ANTHROPIC_API_KEY` | Sim | Chave da API Anthropic para análises de IA |
| `CRON_SECRET` | Sim | Segredo para autenticar rotas `/api/cron/*` |
| `EVOLUTION_WEBHOOK_SECRET` | Sim | Segredo HMAC para webhooks Evolution API |
| `ZAPIER_WEBHOOK_SECRET` | Sim | Token para webhooks Zapier/Plaud |
| `RESEND_API_KEY` | Sim | Chave Resend para e-mails transacionais de auth |
| `SENTRY_DSN` / `NEXT_PUBLIC_SENTRY_DSN` | Opcional | Monitoramento de erros |

Para a **demo**, análise live e webhooks reais são opcionais — os dados já estão seedados. `ANTHROPIC_API_KEY` pode ser deixada como placeholder se não for testar análise ao vivo.

---

## Provisionando a Demo

### 1. Criar projeto Supabase

No [console Supabase](https://supabase.com/dashboard), criar projeto `atlas-os-demo` na região `sa-east-1`. Aguardar provisionamento (~2 min).

### 2. Expor schema `comercial`

**Crítico — sem isso o app abre mas mostra zeros sem erros no console.**

Dashboard → Settings → Data API → Exposed schemas → adicionar `comercial`.

### 3. Aplicar migrations

Via CLI (requer conexão direta):
```bash
supabase db push --db-url "$DEMO_DATABASE_URL"
```

Ou cole os arquivos no SQL Editor do Supabase (ordem obrigatória):
1. `supabase/migrations/20260516000000_initial_schema.sql`
2. `supabase/migrations/20260516000001_melhorias.sql`

### 4. Rodar seed de demonstração + gerar análises

O seed carrega só os **dados brutos** (leads, conversas, calls). As análises
(`analises_whatsapp`, `analises_calls`) ficam vazias — em produção quem as gera é
o cron, que na demo fica zerado. Por isso a demo tem um comando que faz as duas
etapas de uma vez:

```bash
# Preencha DEMO_DATABASE_URL no .env.demo primeiro
export $(grep -v '^#' .env.demo | xargs)
npm run demo:rebuild        # = db:seed-demo (psql) + demo:analises (motor real)
```

- `db:seed-demo` recarrega o seed bruto via `psql` (precisa de `DEMO_DATABASE_URL`).
- `demo:analises` roda o **mesmo motor de análise da produção** uma vez, via HTTPS
  (precisa de `ANTHROPIC_API_KEY` real + `SUPABASE_SERVICE_ROLE_KEY`), populando
  score, diagnóstico, fases e tags sobre os dados seedados.

Ambos são **idempotentes** (o seed faz `TRUNCATE ... RESTART IDENTITY CASCADE`),
então `demo:rebuild` sempre converge ao mesmo estado — ideal para resetar antes de
uma gravação.

> **Atenção à connection string do `psql`:** muitas redes não roteiam a conexão
> **direta** do Supabase (`db.<ref>.supabase.co:5432`, IPv6) e o `psql` dá timeout.
> Nesse caso, use a string do **pooler** (Session mode, `aws-0-<region>.pooler.supabase.com:5432`)
> em `DEMO_DATABASE_URL`, ou cole `supabase/seeds/_demo.sql` no SQL Editor e rode só
> `npm run demo:analises` (a análise usa HTTPS e não depende do `psql`).

### 5. Validar contagens

No SQL Editor do projeto demo:
```sql
SELECT
  (SELECT COUNT(*) FROM comercial.leads)              AS leads,
  (SELECT COUNT(*) FROM comercial.conversas)          AS conversas,
  (SELECT COUNT(*) FROM comercial.mensagens)          AS mensagens,
  (SELECT COUNT(*) FROM comercial.calls)              AS calls,
  (SELECT COUNT(*) FROM comercial.analises_whatsapp)  AS analises_whatsapp,
  (SELECT COUNT(*) FROM comercial.analises_calls)     AS analises_calls,
  (SELECT COUNT(*) FROM comercial.rondas)             AS rondas;
-- Pós-seed (db:seed-demo):  leads=12, conversas=9, mensagens=145, calls=7,
--                           analises_whatsapp=0, analises_calls=0, rondas=0
-- Pós-análise (demo:analises): analises_whatsapp=9, analises_calls=7
--                           (rondas seguem 0 — geração de ronda fora do rebuild)
```

### 6. Criar usuário admin

```bash
# Com .env.demo carregado (ou .env.local apontando para o banco demo):
npm run admin:create-user
# Informe: email, senha e perfil "admin"
```

### 7. Deploy na Vercel

1. Novo projeto Vercel → conectar este repo.
2. **Settings → Git → Production Branch = `demo`** (mantém os crons fora — ver
   "Estratégia de branch da demo" acima).
3. Preencher **todas** as env vars (da tabela acima) **antes do primeiro build**.
   Não subir `DEMO_DATABASE_URL` (uso local) nem secrets de Evolution/Zapier
   (a demo não recebe webhook).
4. Primeiro deploy gera a URL `.vercel.app`. Setar `NEXT_PUBLIC_APP_URL` com essa
   URL e fazer **redeploy** (os redirects de auth dependem dela).
5. (Opcional) Configurar domínio customizado:
   `demo-comercial.benitesalbuquerque.com.br`.
6. Verificar build local antes de qualquer push:
   ```bash
   npm run typecheck && npm run build
   ```

---

## Resetando a Demo

Para restaurar os dados fictícios ao estado original (antes de uma gravação de vídeo, por exemplo):

```bash
export $(grep -v '^#' .env.demo | xargs)
npm run demo:rebuild     # reseta os dados brutos e regenera as análises reais
```

O TRUNCATE no topo do seed limpa apenas tabelas de dados — preserva `configuracoes` e `autorizados` (usuários). Após o rebuild, faça login e confirme que o dashboard mostra KPIs e que conversas/calls já têm score e diagnóstico. (Se o `psql` não conectar nesta rede, veja a nota do passo 4 sobre o pooler / rodar só `npm run demo:analises`.)

---

## Kickoff de Novo Cliente

1. Fork do template → `comercial-os-clinica-XYZ` (conta do cliente ou BA).
2. Criar projeto Supabase `sa-east-1` na conta do cliente.
3. Expor schema `comercial` (Settings → Data API → Exposed schemas).
4. `supabase db push --db-url "$DATABASE_URL"` (ou SQL Editor).
5. Criar projeto Vercel, conectar repo, preencher env vars.
6. Configurar Resend como SMTP do Supabase Auth (Settings → Auth → SMTP).
7. `npm run admin:create-user` — criar usuário dono, head e admin BA.
8. Configurar Evolution instance em `/configuracoes`.
9. Validar end-to-end com 1 mensagem + 1 call reais.

**Não rodar `db:seed-demo` em banco de cliente real.**

---

## Armadilhas Conhecidas

| Sintoma | Causa | Fix |
|---|---|---|
| Dashboard mostra zeros, sem erro no console | Schema `comercial` não exposto | Settings → Data API → Exposed schemas → `comercial` |
| Build quebra no Vercel sem mensagem clara | Faltam `NEXT_PUBLIC_SUPABASE_*` nas env vars | Preencher todas antes do build |
| `db:seed-demo` falha com "connection refused" | `DEMO_DATABASE_URL` não preenchido ou sessão SSL necessária | Checar connection string; adicionar `?sslmode=require` se necessário |
| `admin:create-user` falha com "table not found" | `.env.local` aponta para banco errado | Garantir que `SUPABASE_SERVICE_ROLE_KEY` e `NEXT_PUBLIC_SUPABASE_URL` são do banco correto |
