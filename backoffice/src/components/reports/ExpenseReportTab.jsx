import { useReport } from '../../hooks/useReport';
import { formatRupiah } from '../../utils/format';
import SummaryCard from '../dashboard/SummaryCard';

export default function ExpenseReportTab({ from, to }) {
  const { data, loading, error } = useReport('/reports/expenses', { from, to });

  if (loading) return <p className="text-sm text-text-muted">Memuat laporan...</p>;
  if (error) return <p className="text-sm text-danger">{error}</p>;
  if (!data) return null;

  return (
    <div className="space-y-6">
      <SummaryCard
        label="Total Pengeluaran"
        value={formatRupiah(data.summary.total_expenses)}
        accentClass="text-danger"
      />

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
        <div className="bg-surface border border-border rounded-2xl p-5">
          <p className="text-sm text-text-muted mb-4">Breakdown per Kategori</p>
          <div className="space-y-3">
            {data.by_category.map((item) => (
              <div key={item.category} className="flex justify-between text-sm">
                <span className="text-text-primary">{item.category}</span>
                <span className="font-mono font-tabular text-danger">
                  {formatRupiah(item.total)}
                </span>
              </div>
            ))}
            {data.by_category.length === 0 && (
              <p className="text-sm text-text-muted">Tidak ada data</p>
            )}
          </div>
        </div>

        <div className="bg-surface border border-border rounded-2xl overflow-hidden lg:col-span-1">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-border text-text-muted text-left">
                <th className="px-4 py-3 font-medium">Tanggal</th>
                <th className="px-4 py-3 font-medium">Jumlah</th>
              </tr>
            </thead>
            <tbody>
              {data.details.slice(0, 8).map((expense) => (
                <tr key={expense.id} className="border-b border-border last:border-0">
                  <td className="px-4 py-2.5 text-text-muted">
                    {new Date(expense.date).toLocaleDateString('id-ID', {
                      day: 'numeric',
                      month: 'short',
                    })}
                  </td>
                  <td className="px-4 py-2.5 font-mono font-tabular text-danger">
                    {formatRupiah(expense.amount)}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}