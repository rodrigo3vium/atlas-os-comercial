import { createServerClient } from "@supabase/ssr";
import { type NextRequest, NextResponse } from "next/server";

export async function updateSession(request: NextRequest) {
  // Modo demo: libera acesso público sem login. Ativado só no deploy do demo
  // via env (DEMO_PUBLIC_ACCESS="true"). Forks de cliente nascem sem o flag,
  // portanto continuam protegidos por padrão. As rotas de escrita seguem
  // exigindo usuário (retornam 401), então o demo é efetivamente read-only.
  if (process.env.DEMO_PUBLIC_ACCESS === "true") {
    return NextResponse.next({ request });
  }

  const pathname = request.nextUrl.pathname;
  const isAuthRoute = pathname.startsWith("/auth");
  const isLoginRoute = pathname === "/login";
  const isPublicRoute = isAuthRoute || isLoginRoute;

  let supabaseResponse = NextResponse.next({ request });

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return request.cookies.getAll();
        },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value }) => request.cookies.set(name, value));
          supabaseResponse = NextResponse.next({ request });
          cookiesToSet.forEach(({ name, value, options }) =>
            supabaseResponse.cookies.set(name, value, options),
          );
        },
      },
    },
  );

  // getClaims valida o JWT localmente (JWKS em cache) — sem round-trip à API Auth.
  // É a recomendação atual para middleware, no lugar de getUser, que faz fetch a cada chamada.
  const { data } = await supabase.auth.getClaims();
  const isAuthenticated = !!data?.claims;

  if (!isAuthenticated && !isPublicRoute) {
    const url = request.nextUrl.clone();
    url.pathname = "/login";
    return NextResponse.redirect(url);
  }

  if (isAuthenticated && isLoginRoute) {
    const url = request.nextUrl.clone();
    url.pathname = "/dashboard";
    return NextResponse.redirect(url);
  }

  return supabaseResponse;
}
