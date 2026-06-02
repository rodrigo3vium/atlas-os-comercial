import { Activity } from "lucide-react";
import { SidebarNav } from "./sidebar-nav";

export function AppShell({ children }: { children: React.ReactNode }) {
  return (
    <div className="flex min-h-screen bg-background">
      <aside className="hidden w-60 shrink-0 flex-col border-r border-border bg-surface md:flex">
        <div className="flex items-center gap-3 border-b border-border p-6">
          <div className="glow-cyan flex h-9 w-9 items-center justify-center rounded-md bg-teal">
            <Activity className="h-5 w-5 text-primary-foreground" aria-hidden />
          </div>
          <div className="flex flex-col leading-tight">
            <span className="text-body-strong font-display font-bold text-text-primary">
              Atlas OS
            </span>
            <span className="font-mono text-[0.6875rem] uppercase tracking-[0.12em] text-text-tertiary">
              Comercial
            </span>
          </div>
        </div>
        <SidebarNav />
      </aside>
      <main className="flex flex-1 flex-col overflow-auto">
        <div className="flex-1 p-8">{children}</div>
      </main>
    </div>
  );
}
