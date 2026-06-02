import { Skeleton } from "@/components/ui/skeleton";

export default function WhatsappDetalheLoading() {
  return (
    <div className="space-y-4">
      <div className="flex items-start justify-between">
        <div className="space-y-2">
          <Skeleton className="h-3 w-20" />
          <Skeleton className="h-8 w-48" />
          <Skeleton className="h-4 w-32" />
        </div>
        <div className="flex items-center gap-2">
          <Skeleton className="h-6 w-16 rounded-full" />
          <Skeleton className="h-8 w-24" />
        </div>
      </div>

      <div className="grid gap-4 lg:grid-cols-3">
        <div className="lg:col-span-2">
          <div className="rounded-lg border border-border bg-surface shadow-sm">
            <div className="border-b border-border px-4 py-3">
              <Skeleton className="h-4 w-40" />
            </div>
            <div className="max-h-[60vh] space-y-3 overflow-hidden p-4">
              {Array.from({ length: 6 }).map((_, i) => (
                <div key={i} className={`flex ${i % 2 === 0 ? "justify-start" : "justify-end"}`}>
                  <Skeleton className="h-12 w-2/3 rounded-2xl" />
                </div>
              ))}
            </div>
          </div>
        </div>

        <div className="space-y-4">
          <div className="rounded-lg border border-border bg-surface p-4 shadow-sm">
            <div className="mb-3 flex items-center justify-between">
              <Skeleton className="h-5 w-20" />
              <Skeleton className="h-6 w-16 rounded-full" />
            </div>
            <div className="mb-3 flex gap-1">
              <Skeleton className="h-4 w-14 rounded" />
              <Skeleton className="h-4 w-16 rounded" />
            </div>
            <Skeleton className="mb-2 h-3 w-full" />
            <Skeleton className="mb-2 h-3 w-5/6" />
            <Skeleton className="h-12 w-full rounded-md" />
          </div>

          <div className="rounded-lg border border-border bg-surface p-4 shadow-sm">
            <Skeleton className="mb-3 h-5 w-12" />
            <div className="space-y-2.5">
              <Skeleton className="h-4 w-full" />
              <Skeleton className="h-4 w-full" />
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
