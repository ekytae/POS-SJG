import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  Tooltip,
  ResponsiveContainer,
  CartesianGrid,
} from 'recharts';
import { useReport } from '../../hooks/useReport';
import { formatRupiah, formatDateShort } from '../../utils/format';
import SummaryCard from '../dashboard/SummaryCard';

function ChartTooltip({ active, payload, label }) {
  if (!active || !payload?.length) return null;
  return (
    <div className="bg-surface border border-border rounded-lg px-3 py-2 text-xs">
      <p className="text-text-muted mb-1">{formatDateShort(label)}</p>
      <p className="text-accent font-mono">{formatRupiah(payload[0].value)}</p>
    </div>
  );
}

export default function SalesReportTab({ from, to }) {
  const { data, loading, error } = useReport('/reports/sales', { from, to });

  if (loading) return <p className="text-sm text-text-muted">Memuat laporan...</p>;
  if (error) return <p className="text-sm text-danger">{error}</p>;
  if (!data) return null;

  return (
    <div className="space-y-6">
      <div className="grid grid-cols-2 gap-4">
        <SummaryCard label="Total Omzet" value={formatRupiah(data.summary.total_revenue)} />
        <SummaryCard
          label="Total Transaksi"
          value={data.summary.total_transactions}
          accentClass="text-accent"
        />
      </div>

      <div className="bg-surface border border-border rounded-2xl p-5">
        <p className="text-sm text-text-muted mb-4">Omzet per Hari</p>
        <ResponsiveContainer width="100%" height={260}>
          <BarChart data={data.details}>
            <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.06)" />
            <XAxis
              dataKey="date"
              tickFormatter={formatDateShort}
              stroke="#8b8d98"
              fontSize={12}
              tickLine={false}
              axisLine={false}
            />
            <YAxis
              stroke="#8b8d98"
              fontSize={12}
              tickLine={false}
              axisLine={false}
              tickFormatter={(v) => `${v / 1000}k`}
            />
            <Tooltip content={<ChartTooltip />} cursor={{ fill: 'rgba(255,255,255,0.04)' }} />
            <Bar dataKey="total" fill="#d9822b" radius={[6, 6, 0, 0]} />
          </BarChart>
        </ResponsiveContainer>
      </div>

      <div className="bg-surface border border-border rounded-2xl overflow-hidden">
        <table className="w-full text-sm">
          <thead>
            <tr className="border-b border-border text-text-muted text-left">
              <th className="px-5 py-3 font-medium">Tanggal</th>
              <th className="px-5 py-3 font-medium">Jumlah Transaksi</th>
              <th className="px-5 py-3 font-medium">Omzet</th>
            </tr>
          </thead>
          <tbody>
            {data.details.map((row) => (
              <tr key={row.date} className="border-b border-border last:border-0">
                <td className="px-5 py-3 text-text-primary">{formatDateShort(row.date)}</td>
                <td className="px-5 py-3 text-text-muted">{row.transaction_count}</td>
                <td className="px-5 py-3 font-mono font-tabular text-text-primary">
                  {formatRupiah(row.total)}
                </td>
              </tr>
            ))}
            {data.details.length === 0 && (
              <tr>
                <td colSpan={3} className="px-5 py-8 text-center text-text-muted text-sm">
                  Tidak ada penjualan di periode ini
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}