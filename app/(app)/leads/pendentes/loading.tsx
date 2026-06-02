import { Skeleton } from "@/components/ui/skeleton";

export default function LeadsPendentesLoading() {
  return (
    <div className="space-y-6">
      <div className="space-y-2">
        <Skeleton className="h-8 w-80" />
        <Skeleton className="h-4 w-56" />
      </div>

      <div className="space-y-3">
        {Array.from({ length: 5 }).map((_, i) => (
          <div key={i} className="rounded-lg border border-border bg-surface p-5 shadow-sm">
            <div className="mb-3 flex items-start justify-between">
              <div className="space-y-2">
                <Skeleton className="h-4 w-40" />
                <Skeleton className="h-3 w-32" />
              </div>
              <div className="space-y-1 text-right">
                <Skeleton className="ml-auto h-3 w-20" />
                <Skeleton className="ml-auto h-3 w-16" />
              </div>
            </div>
            <div className="mb-3 space-y-2 rounded-md bg-surface-muted p-3">
              <Skeleton className="h-3 w-full" />
              <Skeleton className="h-3 w-5/6" />
              <Skeleton className="h-3 w-2/3" />
            </div>
            <div className="flex flex-wrap gap-1.5">
              {Array.from({ length: 7 }).map((_, j) => (
                <Skeleton key={j} className="h-7 w-20 rounded" />
              ))}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
