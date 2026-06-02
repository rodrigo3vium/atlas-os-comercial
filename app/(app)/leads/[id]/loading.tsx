import { Skeleton } from "@/components/ui/skeleton";

export default function LeadDetalheLoading() {
  return (
    <div className="space-y-4">
      <div className="flex items-start justify-between">
        <div className="space-y-2">
          <Skeleton className="h-3 w-16" />
          <Skeleton className="h-8 w-56" />
          <Skeleton className="h-4 w-36" />
        </div>
        <Skeleton className="h-7 w-24 rounded-full" />
      </div>

      <div className="grid gap-4 lg:grid-cols-3">
        <div className="space-y-4">
          <div className="rounded-lg border border-border bg-surface p-4 shadow-sm">
            <Skeleton className="mb-3 h-5 w-32" />
            <div className="space-y-2.5">
              {Array.from({ length: 4 }).map((_, i) => (
                <div key={i} className="space-y-1">
                  <Skeleton className="h-3 w-20" />
                  <Skeleton className="h-4 w-40" />
                </div>
              ))}
            </div>
          </div>
          <div className="rounded-lg border border-border bg-surface p-4 shadow-sm">
            <Skeleton className="mb-3 h-5 w-16" />
            <div className="space-y-3">
              <Skeleton className="h-8 w-full" />
              <Skeleton className="h-8 w-full" />
            </div>
          </div>
        </div>

        <div className="lg:col-span-2">
          <div className="rounded-lg border border-border bg-surface p-6 shadow-sm">
            <Skeleton className="mb-6 h-5 w-40" />
            <div className="space-y-5">
              {Array.from({ length: 4 }).map((_, i) => (
                <div key={i} className="flex gap-4">
                  <Skeleton className="h-8 w-8 shrink-0 rounded-full" />
                  <div className="flex-1 space-y-2">
                    <Skeleton className="h-3 w-24" />
                    <Skeleton className="h-4 w-3/4" />
                    <Skeleton className="h-3 w-1/2" />
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
