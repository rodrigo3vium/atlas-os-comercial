import {
  Calendar,
  CheckCircle2,
  ClipboardCheck,
  MessageCircle,
  PhoneCall,
  UserPlus,
  XCircle,
} from "lucide-react";
import type { ReactNode } from "react";
import { cn } from "@/lib/utils";

export type MarcoIcone =
  | "user-plus"
  | "message"
  | "phone"
  | "calendar"
  | "clipboard"
  | "check"
  | "x";

const ICONES = {
  "user-plus": UserPlus,
  message: MessageCircle,
  phone: PhoneCall,
  calendar: Calendar,
  clipboard: ClipboardCheck,
  check: CheckCircle2,
  x: XCircle,
} as const;

export type Marco = {
  id: string;
  at: Date;
  icone: MarcoIcone;
  variante?: "default" | "sucesso" | "perda";
  timestamp: string;
  headline: string;
  detalhe?: ReactNode;
  body?: ReactNode;
};

export function JourneyTimeline({ marcos }: { marcos: Marco[] }) {
  if (marcos.length === 0) {
    return <p className="text-caption text-text-tertiary">Sem eventos registrados ainda.</p>;
  }

  return (
    <div className="relative space-y-10 pl-14">
      <span
        aria-hidden
        className="absolute bottom-2 left-[18px] top-2 w-px"
        style={{
          backgroundImage:
            "linear-gradient(to bottom, rgba(15, 118, 110, 0), rgba(15, 118, 110, 0.4), rgba(15, 118, 110, 0))",
        }}
      />
      {marcos.map((m, idx) => {
        const Icon = ICONES[m.icone];
        const variant = m.variante ?? "default";
        return (
          <section
            key={m.id}
            className="relative duration-500 animate-in fade-in slide-in-from-bottom-2"
            style={{ animationDelay: `${idx * 60}ms`, animationFillMode: "both" }}
          >
            <span
              aria-hidden
              className={cn(
                "absolute -left-14 top-1 flex h-9 w-9 items-center justify-center rounded-full border-2",
                variant === "sucesso" &&
                  "border-status-success bg-status-success text-white shadow-md",
                variant === "perda" && "border-status-danger bg-surface text-status-danger",
                variant === "default" && "border-teal bg-surface text-teal",
              )}
            >
              <Icon className="h-4 w-4" strokeWidth={1.8} />
            </span>
            <div className="text-label text-text-tertiary">{m.timestamp}</div>
            <h3 className="text-h3 mt-1 text-text-primary">{m.headline}</h3>
            {m.detalhe && <div className="text-caption mt-2 text-text-secondary">{m.detalhe}</div>}
            {m.body && <div className="mt-3">{m.body}</div>}
          </section>
        );
      })}
    </div>
  );
}
