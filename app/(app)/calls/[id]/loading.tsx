import { Skeleton } from "@/components/ui/skeleton";

export default function CallDetalheLoading() {
  return (
    <div className="space-y-4">
      <div className="flex items-start justify-between">
        <div className="space-y-2">
          <Skeleton className="h-3 w-12" />
          <Skeleton className="h-8 w-64" />
          <Skeleton className="h-4 w-24" />
        </div>
        <Skeleton className="h-7 w-24 rounded-full" />
      </div>

      <div className="grid gap-4 lg:grid-cols-3">
        <div className="space-y-4 lg:col-span-2">
          <div className="rounded-lg border border-border bg-surface p-4 shadow-sm">
            <div className="mb-4 flex items-center justify-between">
              <Skeleton className="h-5 w-44" />
              <Skeleton className="h-8 w-16" />
            </div>
            <div className="space-y-3">
              {Array.from({ length: 6 }).map((_, i) => (
                <div key={i}>
                  <div className="mb-1 flex items-center justify-between">
                    <Skeleton className="h-3 w-28" />
                    <Skeleton className="h-3 w-8" />
                  </div>
                  <Skeleton className="h-1.5 w-full" />
                </div>
              ))}
            </div>
          </div>

          <div className="grid gap-3 sm:grid-cols-2">
            <div className="rounded-lg border border-border bg-surface p-4 shadow-sm">
              <Skeleton className="mb-1.5 h-3 w-20" />
              <Skeleton className="h-12 w-full" />
            </div>
            <div className="rounded-lg border border-border bg-surface p-4 shadow-sm">
              <Skeleton className="mb-1.5 h-3 w-24" />
              <Skeleton className="h-12 w-full" />
            </div>
          </div>
        </div>

        <div className="space-y-4">
          <div className="rounded-lg border border-border bg-surface p-4 shadow-sm">
            <Skeleton className="mb-3 h-5 w-16" />
            <Skeleton className="mb-3 h-6 w-20 rounded-full" />
            <Skeleton className="h-8 w-full" />
          </div>
          <div className="rounded-lg border border-border bg-surface p-4 shadow-sm">
            <Skeleton className="mb-3 h-5 w-20" />
            <div className="space-y-2">
              <Skeleton className="h-4 w-full" />
              <Skeleton className="h-4 w-full" />
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
