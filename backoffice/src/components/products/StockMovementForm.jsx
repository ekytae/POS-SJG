import { useState } from 'react';
import apiClient from '../../api/client';
import Button from '../ui/Button';

export default function StockMovementForm({ products, onSuccess }) {
  const [type, setType] = useState('production_in');
  const [productId, setProductId] = useState('');
  const [quantity, setQuantity] = useState('');
  const [note, setNote] = useState('');
  const [error, setError] = useState(null);
  const [success, setSuccess] = useState(null);
  const [submitting, setSubmitting] = useState(false);

  async function handleSubmit(e) {
    e.preventDefault();
    setError(null);
    setSuccess(null);
    setSubmitting(true);

    try {
      const finalQty =
        type === 'adjustment' && quantity.startsWith('-')
          ? Number(quantity)
          : Math.abs(Number(quantity)) * (type === 'adjustment' && isReducing ? -1 : 1);

      await apiClient.post('/stock-movements', {
        product_id: productId,
        type,
        quantity: type === 'production_in' ? Math.abs(Number(quantity)) : finalQty,
        note,
      });

      setSuccess('Pergerakan stok berhasil dicatat');
      setQuantity('');
      setNote('');
      onSuccess?.();
    } catch (err) {
      setError(err.response?.data?.errors?.quantity?.[0] ?? err.response?.data?.message ?? 'Gagal mencatat');
    } finally {
      setSubmitting(false);
    }
  }

  const [isReducing, setIsReducing] = useState(false);

  return (
    <form onSubmit={handleSubmit} className="bg-surface border border-border rounded-2xl p-5 space-y-4">
      <p className="text-sm font-semibold text-text-primary">Catat Pergerakan Stok</p>

      {error && <p className="text-sm text-danger">{error}</p>}
      {success && <p className="text-sm text-positive">{success}</p>}

      <div className="flex gap-2">
        <button
          type="button"
          onClick={() => setType('production_in')}
          className={`flex-1 py-2 rounded-lg text-sm border transition-colors ${
            type === 'production_in'
              ? 'bg-accent-soft border-accent text-accent'
              : 'border-border text-text-muted'
          }`}
        >
          Stok Masuk
        </button>
        <button
          type="button"
          onClick={() => setType('adjustment')}
          className={`flex-1 py-2 rounded-lg text-sm border transition-colors ${
            type === 'adjustment'
              ? 'bg-accent-soft border-accent text-accent'
              : 'border-border text-text-muted'
          }`}
        >
          Penyesuaian
        </button>
      </div>

      <div>
        <label className="block text-sm text-text-muted mb-1.5">Produk</label>
        <select
          value={productId}
          onChange={(e) => setProductId(e.target.value)}
          required
          className="w-full bg-base border border-border rounded-lg px-3 py-2 text-sm text-text-primary focus:outline-none focus:ring-2 focus:ring-accent/40"
        >
          <option value="">Pilih produk</option>
          {products.map((p) => (
            <option key={p.id} value={p.id}>
              {p.name} (stok: {p.stock})
            </option>
          ))}
        </select>
      </div>

      {type === 'adjustment' && (
        <div className="flex gap-2">
          <button
            type="button"
            onClick={() => setIsReducing(false)}
            className={`flex-1 py-1.5 rounded-lg text-xs border ${
              !isReducing ? 'bg-positive/10 border-positive text-positive' : 'border-border text-text-muted'
            }`}
          >
            Tambah
          </button>
          <button
            type="button"
            onClick={() => setIsReducing(true)}
            className={`flex-1 py-1.5 rounded-lg text-xs border ${
              isReducing ? 'bg-danger/10 border-danger text-danger' : 'border-border text-text-muted'
            }`}
          >
            Kurangi
          </button>
        </div>
      )}

      <div>
        <label className="block text-sm text-text-muted mb-1.5">Jumlah</label>
        <input
          type="number"
          min="1"
          value={quantity}
          onChange={(e) => setQuantity(e.target.value)}
          required
          className="w-full bg-base border border-border rounded-lg px-3 py-2 text-sm text-text-primary focus:outline-none focus:ring-2 focus:ring-accent/40"
        />
      </div>

      <div>
        <label className="block text-sm text-text-muted mb-1.5">Catatan (opsional)</label>
        <input
          type="text"
          value={note}
          onChange={(e) => setNote(e.target.value)}
          placeholder={type === 'production_in' ? 'Misal: Produksi pagi' : 'Misal: Tumpah, hilang'}
          className="w-full bg-base border border-border rounded-lg px-3 py-2 text-sm text-text-primary focus:outline-none focus:ring-2 focus:ring-accent/40"
        />
      </div>

      <Button type="submit" disabled={submitting} className="w-full">
        {submitting ? 'Menyimpan...' : 'Simpan'}
      </Button>
    </form>
  );
}