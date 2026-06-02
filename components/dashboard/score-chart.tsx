"use client";

import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
} from "recharts";

type SerieSemana = {
  semana: string;
  score_whatsapp: number | null;
  score_calls: number | null;
};

type Props = {
  dados: SerieSemana[];
};

function formatarSemana(iso: string) {
  const d = new Date(iso);
  return `${d.getDate()}/${d.getMonth() + 1}`;
}

export function ScoreChart({ dados }: Props) {
  const data = dados.map((d) => ({
    semana: formatarSemana(d.semana),
    WhatsApp: d.score_whatsapp,
    Calls: d.score_calls,
  }));

  return (
    <ResponsiveContainer width="100%" height={220}>
      <LineChart data={data} margin={{ top: 4, right: 16, left: -8, bottom: 0 }}>
        <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.06)" vertical={false} />
        <XAxis
          dataKey="semana"
          tick={{ fontSize: 11, fill: "#7D827D" }}
          axisLine={false}
          tickLine={false}
        />
        <YAxis
          domain={[0, 100]}
          tick={{ fontSize: 11, fill: "#7D827D" }}
          axisLine={false}
          tickLine={false}
        />
        <Tooltip
          contentStyle={{
            background: "#11171A",
            border: "1px solid rgba(255,255,255,0.08)",
            borderRadius: 6,
            fontSize: 12,
            color: "#F2EDE4",
          }}
          labelStyle={{ color: "#F2EDE4", fontWeight: 500 }}
        />
        <Legend wrapperStyle={{ fontSize: 12, color: "#7D827D" }} />
        <Line
          type="monotone"
          dataKey="WhatsApp"
          stroke="#20DDEB"
          strokeWidth={2}
          dot={false}
          connectNulls
        />
        <Line
          type="monotone"
          dataKey="Calls"
          stroke="#34D399"
          strokeWidth={2}
          dot={false}
          connectNulls
        />
      </LineChart>
    </ResponsiveContainer>
  );
}
