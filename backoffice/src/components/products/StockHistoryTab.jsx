import { useCrud } from '../../hooks/useCrud';
import StockMovementForm from './StockMovementForm';

const typeLabels = {
  production_in: { label: 'Stok Masuk', className: 'text-positive bg-positive/10' },
  sale: { label: 'Terjual', className: 'text-text-muted bg-white/5' },
  adjustment: { label: 'Penyesuaian', className: 'text-accent bg-accent-soft' },
  void_return: { label: 'Void', className: 'text-danger bg-danger/10' },
};

export default function StockHistoryTab({ products }) {
  const { items, loading, refetch } = useCrud('/stock-movements');

  return (
    <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <div className="lg:col-span-1">
        <StockMovementForm products={products} onSuccess={refetch} />
      </div>

      <div className="lg:col-span-2">
        <p className="text-sm font-semibold text-text-primary mb-4">Riwayat Perubahan Stok</p>

        {loading && <p className="text-sm text-text-muted">Memuat...</p>}

        <div className="bg-surface border border-border rounded-2xl overflow-hidden">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-border text-text-muted text-left">
                <th className="px-5 py-3 font-medium">Produk</th>
                <th className="px-5 py-3 font-medium">Tipe</th>
                <th className="px-5 py-3 font-medium">Jumlah</th>
                <th className="px-5 py-3 font-medium">Catatan</th>
                <th className="px-5 py-3 font-medium">Waktu</th>
              </tr>
            </thead>
            <tbody>
              {items.map((movement) => {
                const typeInfo = typeLabels[movement.type] ?? {
                  label: movement.type,
                  className: 'text-text-muted bg-white/5',
                };

                return (
                  <tr key={movement.id} className="border-b border-border last:border-0">
                    <td className="px-5 py-3 text-text-primary">{movement.product?.name}</td>
                    <td className="px-5 py-3">
                      <span className={`text-xs px-2 py-0.5 rounded-full ${typeInfo.className}`}>
                        {typeInfo.label}
                      </span>
                    </td>
                    <td
                      className={`px-5 py-3 font-mono font-tabular ${
                        movement.quantity >= 0 ? 'text-positive' : 'text-danger'
                      }`}
                    >
                      {movement.quantity >= 0 ? '+' : ''}
                      {movement.quantity}
                    </td>
                    <td className="px-5 py-3 text-text-muted">{movement.note ?? '-'}</td>
                    <td className="px-5 py-3 text-text-muted text-xs">
                      {new Date(movement.created_at).toLocaleString('id-ID')}
                    </td>
                  </tr>
                );
              })}
              {items.length === 0 && !loading && (
                <tr>
                  <td colSpan={5} className="px-5 py-8 text-center text-text-muted text-sm">
                    Belum ada riwayat
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}