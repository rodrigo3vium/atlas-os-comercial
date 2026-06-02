import { Skeleton } from "@/components/ui/skeleton";

export default function DashboardLoading() {
  return (
    <div className="space-y-8">
      <Skeleton className="h-9 w-40" />

      {/* KPI cards */}
      <div className="grid grid-cols-2 gap-4 lg:grid-cols-4">
        {Array.from({ length: 4 }).map((_, i) => (
          <div key={i} className="rounded-lg border border-border bg-surface p-6 shadow-sm">
            <Skeleton className="h-3 w-24" />
            <Skeleton className="mt-3 h-10 w-20" />
            <Skeleton className="mt-2 h-3 w-28" />
          </div>
        ))}
      </div>

      {/* Chart */}
      <div className="rounded-lg border border-border bg-surface p-6 shadow-sm">
        <Skeleton className="h-5 w-40" />
        <Skeleton className="mt-4 h-[220px] w-full" />
      </div>

      {/* Bottom lists */}
      <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
        {Array.from({ length: 2 }).map((_, i) => (
          <div key={i} className="rounded-lg border border-border bg-surface p-6 shadow-sm">
            <Skeleton className="h-5 w-36" />
            <Skeleton className="mt-1 h-3 w-48" />
            <div className="mt-4 space-y-3">
              {Array.from({ length: 4 }).map((_, j) => (
                <div key={j} className="flex items-center justify-between">
                  <Skeleton className="h-4 flex-1" />
                  <Skeleton className="ml-2 h-5 w-10 rounded-full" />
                </div>
              ))}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
