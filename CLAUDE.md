# CLAUDE.md — Atlas OS Comercial

Guia de comportamento para o Claude Code neste repositório. Leia antes de qualquer tarefa.

---

## Contexto do Projeto

Sistema de inteligência comercial **single-tenant** para clínicas médicas brasileiras. Cada cliente é um fork isolado deste repositório com Vercel + Supabase próprios. Sem multi-tenancy. Sem SaaS.

**BA Consultoria** mantém conta `admin` em `autorizados` por cliente. Transferência de repositório + infra acontece no kickoff.

---

## Stack — Decisões Travadas

| Decisão | Regra |
|---|---|
| ORM | **Supabase JS direto**. Sem Drizzle, sem Prisma, sem query builders |
| Schema | **`comercial`** em todas as queries: `.schema("comercial").from(...)` |
| Erros | **`.throwOnError()`** obrigatório em toda query. Sem `if (error)` manual |
| Queries complexas | Viram RPC (função Postgres). Não criar queries SQL inline longas no TS |
| Tailwind | **v3.4**. Não migrar para v4 |
| Modelo IA | **`claude-sonnet-4-6`** em todas as análises. Não trocar sem motivo explícito |
| Prompt caching | **`cache_control: { type: "ephemeral" }`** em todos os system prompts |
| Timestamps | **`timestamptz`** no banco. Nunca `timestamp without time zone` |
| Telefone | **E.164** (`+5511...`). Normalizar via `lib/phone.ts` |
| Migrations | Arquivos em `supabase/migrations/`. Nunca editar migration já aplicada — criar nova |
| Tipos | Gerados em `lib/supabase/types.ts`. Atualizar após cada migration |

---

## Padrões de Código

### Queries Supabase

```ts
// Correto
const { data } = await supabase
  .schema("comercial")
  .from("leads")
  .select("id, nome, status")
  .eq("id", id)
  .single()
  .throwOnError();

// Errado — nunca omitir .throwOnError() nem usar .schema sem "comercial"
const { data, error } = await supabase.from("leads").select("*");
```

### Crons

Toda rota de cron valida `Authorization: Bearer $CRON_SECRET` antes de executar. O Vercel injeta o header automaticamente; não remover essa validação.

### Webhooks

Padrão ack-first obrigatório: valida secret → insere em `eventos_brutos` → responde `200`. O processamento acontece no cron `processar-eventos`. Nunca processar inline no webhook.

### Server vs Client

- Queries ao banco: sempre em Server Components ou Route Handlers com `createServiceClient()` (service role, bypassa RLS)
- Frontend autenticado: `createBrowserClient()` via `lib/supabase/client.ts`
- Middleware: `lib/supabase/middleware.ts`

---

## Design System — Tokens Travados

Tema único: **BA Hub IDV v2 — dark operacional de precisão** (canvas `#05090B`, card `#0B1114`, accent **ciano `#20DDEB`**). Sempre dark, sem toggle. Profundidade por **camadas de fundo + bordas white-alpha**, nunca por sombra dura. Texto sobre ciano usa **escuro `#05090B`** (contraste AA), nunca branco.

### Cores: sempre semânticas, nunca paleta Tailwind crua

Os nomes de token foram mantidos da v1 — só os **valores** foram remapeados para dark. Toda definição mora em `app/globals.css` (`:root`) + `tailwind.config.ts`.

| Uso | Token |
|---|---|
| Fundos | `bg-surface` (`#0B1114`), `bg-surface-muted` (`#11171A`), `bg-surface-hover` (`#161D21`) |
| Texto | `text-text-primary` (`#F2EDE4`), `text-text-secondary` (`#C8C0B2`), `text-text-tertiary`/`-muted` (`#7D827D`) |
| Accent | `bg-teal`/`text-teal` (ciano `#20DDEB`), `bg-teal-soft` (ciano 12%), `text-teal-soft-text` (ciano), `hover:bg-teal-hover` (`#38F3FF`) |
| Status | `bg-status-{success,warning,danger,info}` + `-soft` (alpha 12%) para fundos; mesmo nome com `text-` para texto. `info` = ciano (não há azul concorrente) |
| Bordas | `border-border` (white-alpha 6%), `border-strong` (white-alpha 14%) |

Hardcoded de paleta Tailwind (`bg-slate-700`, `text-cyan-400`, `bg-red-500/20`, etc.) é **proibido** — fere contraste e foge do token system. Único acento é o ciano: **sem azul, roxo ou dourado** concorrendo.

### Tipografia: fontes + utilitários

Fontes (carregadas em `app/layout.tsx` via `next/font`): `font-display` (Plus Jakarta Sans — títulos), `font-sans` (Inter — corpo/UI), `font-mono` (IBM Plex Mono — labels/dados/chips, sempre uppercase + tracking `0.12–0.14em`), `font-stat` (Bebas Neue — **somente** números grandes de KPI, nunca texto corrido).

Utilitários de tamanho em `globals.css`: `text-h1` (28px), `text-h2` (22px), `text-h3` (18px), `text-body-strong` (14px/500), `text-caption` (13px), `text-label` (12px uppercase tracking), `text-kpi` (32px tabular), `text-kpi-lg` (40px tabular). Nunca usar `text-xl font-semibold` quando há `text-h*` equivalente.

### Raios e profundidade

Raio **máx 8px**: `rounded-sm` (4px), `rounded-md` (6px, padrão), `rounded-lg` (8px). Sem `box-shadow` dura. Para destaque, usar `.surface-sheen` (gradiente branco sutil no topo) e `.glow-cyan` (ring + halo ciano) — opt-in, nunca global.

### Padrões de componente

- **Cards de seção**: `rounded-lg border border-border bg-surface p-4` (+ `.surface-sheen` em cards de destaque). Sem sombra dura.
- **Empty states**: ícone circular `bg-surface-muted` + `text-body-strong text-text-primary` título + `text-caption text-text-muted` descrição
- **Badges/chips de status**: `rounded-full px-2 py-0.5 text-[11px] font-medium` + token de status; labels de dado em `font-mono uppercase tracking-[0.1em]`
- **Botão primário**: `bg-teal text-primary-foreground hover:bg-teal-hover` (texto escuro sobre ciano)
- **Logo/badge de acento**: `bg-teal` sólido + ícone `text-primary-foreground` + `.glow-cyan`
- **Links de navegação** (back, "ver mais"): `text-teal font-medium hover:text-teal-hover`
- **Bubbles de chat**: lead `bg-surface-muted border border-border text-text-primary` · clínica `bg-teal-soft text-teal-soft-text`
- **Charts (Recharts)**: paleta ciano `#20DDEB` → verde `#34D399` → âmbar `#F2BD3B` → vermelho `#E44935`; grid `rgba(255,255,255,0.06)` só horizontal; tooltip `bg #11171A` borda white-alpha; eixos `#7D827D` sem axis/tick line

---

## Estrutura de Arquivos

```
app/
  (app)/          # Telas autenticadas (protegidas por middleware)
  (auth)/         # Login, definir-senha, redefinir-senha
  api/
    cron/         # 7 crons (protegidos por CRON_SECRET)
    webhooks/     # evolution + zapier-plaud
lib/
  modules/        # Lógica de negócio (sem dependências de framework)
  prompts/        # System prompts Claude (analyze-call, analyze-whatsapp)
  supabase/       # Clientes (client, server, middleware) + types.ts
  phone.ts        # Normalização E.164
  log.ts          # Logger estruturado JSON
  format.ts       # Formatação de data pt-BR (formatDataHora, formatRelativo, diasEntre)
supabase/
  migrations/     # SQL versionado (nunca editar o que já foi aplicado)
  seeds/          # seed.sql para dev local; _template.sql para kickoff de cliente
  templates/      # Emails auth pt-BR (invite.html, recovery.html)
```

---

## Armadilhas Conhecidas

| Problema | Causa | Fix |
|---|---|---|
| Dashboard mostra zeros, sem erro no console | Schema `comercial` não exposto no Supabase | Dashboard → Settings → Data API → Exposed schemas → adicionar `comercial` |
| `admin:create-user` falha com "table not found" | Script usa `.from("autorizados")` que cai em `public` | Já corrigido: usa `.schema("comercial").from("autorizados")` |
| `get_dashboard` retorna erro `42803` | `avg()` aninhado dentro de `jsonb_agg()` não é permitido no PostgreSQL | Já corrigido em `20260516000001_melhorias.sql`: avg() movido para subquery |
| Seed não roda via `supabase db seed` | Schema `comercial` não está no `search_path` padrão do CLI | Rodar o `seed.sql` manualmente no SQL Editor do Supabase |

---

## O Que Não Fazer

- **Não adicionar multi-tenancy** (`clinic_id`, row por cliente, etc.) — decisão YAGNI explícita
- **Não criar abstrações preventivas** — três linhas repetidas é melhor que abstração prematura
- **Não implementar LGPD** (consentimento automático, pseudonimização, right-to-forget) — adiado para v2
- **Não adicionar 2FA, dark mode, exportação CSV** — fora de escopo v1
- **Não reabrir decisões arquiteturais** listadas neste arquivo sem motivo concreto novo
- **Não commitar `.env.local`** — está no `.gitignore` via `.env*`

---

## RLS e Permissões

- **`service_role`** bypassa RLS automaticamente (usado em server-side e crons)
- **`authenticated`** passa por RLS — políticas verificam `comercial.is_authorized()`
- **`anon`** não tem acesso a nada no schema `comercial`

Toda tabela nova precisa de: `ENABLE ROW LEVEL SECURITY` + policy + `GRANT` para `service_role` e `authenticated`.

---

## Variáveis de Ambiente Necessárias

Ver `.env.example` na raiz. Resumo das críticas:

| Variável | Onde usar |
|---|---|
| `SUPABASE_SERVICE_ROLE_KEY` | Somente server-side/crons. Nunca expor ao cliente |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | Frontend (safe to expose) |
| `CRON_SECRET` | Validar header nas rotas `/api/cron/*` |
| `EVOLUTION_WEBHOOK_SECRET` | Validar HMAC nos webhooks Evolution |
| `ZAPIER_WEBHOOK_SECRET` | Validar token nos webhooks Zapier |
| `ANTHROPIC_API_KEY` | Somente server-side |

---

## Fluxo de Deploy (por cliente)

1. Fork do template → `comercial-os-clinica-XYZ`
2. Criar projeto Supabase `sa-east-1` na conta do cliente
3. `supabase db push` (ou SQL Editor para redes restritas)
4. **Expor schema `comercial`** no Supabase Dashboard → Settings → Data API → Exposed schemas. Sem isso, nenhuma chamada `.schema("comercial")` funciona — o app abre mas mostra zeros/vazio sem erros visíveis.
5. Criar projeto Vercel, conectar repo, preencher env vars
6. Configurar Resend como SMTP do Supabase Auth
7. `npm run admin:create-user` para dono, head e admin BA
8. Configurar Evolution instance em `/configuracoes`
9. Validar end-to-end com 1 mensagem + 1 call reais

### Seeds de desenvolvimento

```bash
# Roda o seed completo no SQL Editor do Supabase (não via CLI — schema comercial não está no search_path padrão)
# Arquivo: supabase/seeds/seed.sql
# Cria 25 leads, 12 conversas, ~60 mensagens, 10 calls, 12 análises WhatsApp, 8 análises calls
```
