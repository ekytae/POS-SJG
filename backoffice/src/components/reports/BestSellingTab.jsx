import { useReport } from '../../hooks/useReport';
import { formatRupiah } from '../../utils/format';

export default function BestSellingTab({ from, to }) {
  const { data, loading, error } = useReport('/reports/best-selling-products', { from, to });

  if (loading) return <p className="text-sm text-text-muted">Memuat laporan...</p>;
  if (error) return <p className="text-sm text-danger">{error}</p>;

  const maxQty = data?.[0]?.total_qty ?? 1;

  return (
    <div className="bg-surface border border-border rounded-2xl overflow-hidden">
      <table className="w-full text-sm">
        <thead>
          <tr className="border-b border-border text-text-muted text-left">
            <th className="px-5 py-3 font-medium w-8">#</th>
            <th className="px-5 py-3 font-medium">Produk</th>
            <th className="px-5 py-3 font-medium">Terjual</th>
            <th className="px-5 py-3 font-medium">Omzet</th>
          </tr>
        </thead>
        <tbody>
          {data?.map((product, index) => (
            <tr key={product.product_id} className="border-b border-border last:border-0">
              <td className="px-5 py-3 text-text-muted">{index + 1}</td>
              <td className="px-5 py-3">
                <p className="text-text-primary">{product.product_name}</p>
                <div className="h-1 bg-white/5 rounded-full mt-1.5 overflow-hidden w-32">
                  <div
                    className="h-full bg-accent rounded-full"
                    style={{ width: `${(product.total_qty / maxQty) * 100}%` }}
                  />
                </div>
              </td>
              <td className="px-5 py-3 font-mono font-tabular text-text-primary">
                {product.total_qty}
              </td>
              <td className="px-5 py-3 font-mono font-tabular text-text-primary">
                {formatRupiah(product.total_revenue)}
              </td>
            </tr>
          ))}
          {data?.length === 0 && (
            <tr>
              <td colSpan={4} className="px-5 py-8 text-center text-text-muted text-sm">
                Tidak ada penjualan di periode ini
              </td>
            </tr>
          )}
        </tbody>
      </table>
    </div>
  );
}