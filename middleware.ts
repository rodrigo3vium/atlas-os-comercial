import { type NextRequest } from "next/server";
import { updateSession } from "@/lib/supabase/middleware";

export async function middleware(request: NextRequest) {
  return updateSession(request);
}

export const config = {
  matcher: [
    /*
     * Aplica middleware em todas as rotas exceto:
     * - _next/static (assets estáticos)
     * - _next/image (otimização de imagens)
     * - favicon.ico, sitemap.xml, robots.txt
     * - /api/webhooks/* (webhooks recebem sem auth de sessão)
     * - /api/cron/* (autenticados via CRON_SECRET no próprio handler)
     * - qualquer arquivo com extensão (.png, .svg, .jpg, .ico, .css, .js, .woff…)
     *   evita pagar custo do middleware em prefetches de assets do RSC
     */
    "/((?!_next/static|_next/image|favicon.ico|sitemap.xml|robots.txt|api/webhooks|api/cron|.*\\.[\\w]+$).*)",
  ],
};
