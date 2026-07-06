import { useState } from 'react';
import { useReport } from '../../hooks/useReport';
import { useCrud } from '../../hooks/useCrud';

export default function StockCardTab({ from, to }) {
  const { items: products } = useCrud('/products');
  const [productId, setProductId] = useState('');

  const { data, loading, error } = useReport(
    '/reports/stock-card',
    { product_id: productId, from, to },
    !!productId
  );

  return (
    <div>
      <div className="mb-4">
        <label className="block text-xs text-text-muted mb-1.5">Pilih Produk</label>
        <select
          value={productId}
          onChange={(e) => setProductId(e.target.value)}
          className="bg-base border border-border rounded-lg px-3 py-2 text-sm text-text-primary focus:outline-none focus:ring-2 focus:ring-accent/40 w-64"
        >
          <option value="">Pilih produk</option>
          {products.map((p) => (
            <option key={p.id} value={p.id}>
              {p.name}
            </option>
          ))}
        </select>
      </div>

      {!productId && <p className="text-sm text-text-muted">Pilih produk untuk melihat kartu stok</p>}
      {loading && <p className="text-sm text-text-muted">Memuat...</p>}
      {error && <p className="text-sm text-danger">{error}</p>}

      {data && (
        <>
          <div className="grid grid-cols-2 gap-4 mb-4">
            <div className="bg-surface border border-border rounded-xl p-4">
              <p className="text-xs text-text-muted mb-1">Saldo Awal</p>
              <p className="text-lg font-mono font-tabular text-text-primary">{data.opening_stock}</p>
            </div>
            <div className="bg-surface border border-border rounded-xl p-4">
              <p className="text-xs text-text-muted mb-1">Saldo Akhir</p>
              <p className="text-lg font-mono font-tabular text-text-primary">{data.ending_stock}</p>
            </div>
          </div>

          <div className="bg-surface border border-border rounded-2xl overflow-hidden">
            <table className="w-full text-sm">
              <thead>
                <tr className="border-b border-border text-text-muted text-left">
                  <th className="px-5 py-3 font-medium">Waktu</th>
                  <th className="px-5 py-3 font-medium">Tipe</th>
                  <th className="px-5 py-3 font-medium">Jumlah</th>
                  <th className="px-5 py-3 font-medium">Catatan</th>
                </tr>
              </thead>
              <tbody>
                {data.movements.map((m) => (
                  <tr key={m.id} className="border-b border-border last:border-0">
                    <td className="px-5 py-3 text-text-muted text-xs">
                      {new Date(m.created_at).toLocaleString('id-ID')}
                    </td>
                    <td className="px-5 py-3 text-text-primary">{m.type}</td>
                    <td
                      className={`px-5 py-3 font-mono font-tabular ${
                        m.quantity >= 0 ? 'text-positive' : 'text-danger'
                      }`}
                    >
                      {m.quantity >= 0 ? '+' : ''}
                      {m.quantity}
                    </td>
                    <td className="px-5 py-3 text-text-muted">{m.note ?? '-'}</td>
                  </tr>
                ))}
                {data.movements.length === 0 && (
                  <tr>
                    <td colSpan={4} className="px-5 py-8 text-center text-text-muted text-sm">
                      Tidak ada pergerakan di periode ini
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </>
      )}
    </div>
  );
}