import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  Tooltip,
  ResponsiveContainer,
  CartesianGrid,
} from 'recharts';
import { useDashboard } from '../hooks/useDashboard';
import SummaryCard from '../components/dashboard/SummaryCard';
import { formatRupiah, formatDateShort } from '../utils/format';

function ChartTooltip({ active, payload, label }) {
  if (!active || !payload?.length) return null;

  return (
    <div className="bg-surface border border-border rounded-lg px-3 py-2 text-xs">
      <p className="text-text-muted mb-1">{formatDateShort(label)}</p>
      <p className="text-accent font-mono">{formatRupiah(payload[0].value)}</p>
    </div>
  );
}

export default function Dashboard() {
  const { data, loading, error } = useDashboard();

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <p className="text-text-muted text-sm">Memuat data dashboard...</p>
      </div>
    );
  }

  if (error) {
    return (
      <div className="bg-danger/10 border border-danger/20 rounded-xl p-4 text-sm text-danger">
        {error}
      </div>
    );
  }

  const isProfitPositive = data.profit_simple >= 0;

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-xl font-semibold text-text-primary">Dashboard</h1>
        <p className="text-sm text-text-muted mt-1">Ringkasan performa toko Anda</p>
      </div>

      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        <SummaryCard label="Omzet Hari Ini" value={formatRupiah(data.revenue_today)} />
        <SummaryCard label="Omzet Bulan Ini" value={formatRupiah(data.revenue_this_month)} />
        <SummaryCard
          label="Transaksi Hari Ini"
          value={data.transaction_count_today}
          accentClass="text-accent"
        />
        <SummaryCard label="Produk Terjual Hari Ini" value={data.products_sold_today} />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-4">
        <div className="lg:col-span-2 bg-surface border border-border rounded-2xl p-5">
          <p className="text-sm text-text-muted mb-4">Grafik Penjualan (7 Hari Terakhir)</p>
          <ResponsiveContainer width="100%" height={220}>
            <LineChart data={data.sales_chart}>
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
              <Tooltip content={<ChartTooltip />} />
              <Line
                type="monotone"
                dataKey="total"
                stroke="#d9822b"
                strokeWidth={2}
                dot={{ fill: '#d9822b', r: 3 }}
              />
            </LineChart>
          </ResponsiveContainer>
        </div>

        <div className="bg-surface border border-border rounded-2xl p-5 space-y-4">
          <p className="text-sm text-text-muted">Ringkasan Bulan Ini</p>

          <div>
            <p className="text-xs text-text-muted mb-1">Pengeluaran</p>
            <p className="text-lg font-mono font-tabular text-danger">
              {formatRupiah(data.expenses_this_month)}
            </p>
          </div>

          <div className="border-t border-border pt-4">
            <p className="text-xs text-text-muted mb-1">Profit Sederhana</p>
            <p
              className={`text-lg font-mono font-tabular ${
                isProfitPositive ? 'text-positive' : 'text-danger'
              }`}
            >
              {formatRupiah(data.profit_simple)}
            </p>
            <p className="text-xs text-text-muted mt-1">
              *Belum dikurangi harga modal produk
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}