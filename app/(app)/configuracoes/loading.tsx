import { Skeleton } from "@/components/ui/skeleton";

export default function ConfiguracoesLoading() {
  return (
    <div className="max-w-2xl space-y-6">
      <div className="space-y-2">
        <Skeleton className="h-8 w-48" />
        <Skeleton className="h-4 w-72" />
      </div>

      <section className="space-y-4 rounded-lg border border-border bg-surface p-6 shadow-sm">
        <Skeleton className="h-5 w-44" />
        {Array.from({ length: 6 }).map((_, i) => (
          <div key={i} className="space-y-1.5">
            <Skeleton className="h-3 w-32" />
            <Skeleton className="h-8 w-full" />
          </div>
        ))}
        <Skeleton className="h-8 w-40" />
      </section>

      <section className="space-y-4 rounded-lg border border-border bg-surface p-6 shadow-sm">
        <Skeleton className="h-5 w-48" />
        {Array.from({ length: 2 }).map((_, i) => (
          <div key={i} className="space-y-2 rounded-lg border border-slate-700 p-3">
            <div className="flex items-center justify-between">
              <div className="space-y-1.5">
                <Skeleton className="h-4 w-32" />
                <Skeleton className="h-3 w-48" />
              </div>
              <Skeleton className="h-4 w-12 rounded-full" />
            </div>
            <div className="flex gap-1.5">
              <Skeleton className="h-6 w-24" />
              <Skeleton className="h-6 w-16" />
              <Skeleton className="h-6 w-16" />
            </div>
          </div>
        ))}
        <Skeleton className="h-7 w-40" />
      </section>

      <section className="space-y-3 rounded-lg border border-border bg-surface p-6 shadow-sm">
        <Skeleton className="h-5 w-16" />
        <Skeleton className="h-4 w-3/4" />
        <Skeleton className="h-8 w-44" />
      </section>
    </div>
  );
}
