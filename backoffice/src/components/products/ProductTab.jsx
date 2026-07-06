import { useState } from 'react';
import { useCrud } from '../../hooks/useCrud';
import Button from '../ui/Button';
import Modal from '../ui/Modal';
import Input from '../ui/Input';
import { formatRupiah } from '../../utils/format';

export default function ProductTab({ categories, units }) {
  const { items, loading, error, create, update, remove } = useCrud('/products');
  const [modalOpen, setModalOpen] = useState(false);
  const [editing, setEditing] = useState(null);
  const [form, setForm] = useState({
    category_id: '',
    unit_id: '',
    name: '',
    price: '',
    stock: '',
  });
  const [formError, setFormError] = useState(null);

  function openCreate() {
    setEditing(null);
    setForm({ category_id: '', unit_id: '', name: '', price: '', stock: '' });
    setFormError(null);
    setModalOpen(true);
  }

  function openEdit(product) {
    setEditing(product);
    setForm({
      category_id: product.category?.id ?? '',
      unit_id: product.unit?.id ?? '',
      name: product.name,
      price: product.price,
      stock: product.stock,
    });
    setFormError(null);
    setModalOpen(true);
  }

  async function handleSubmit(e) {
    e.preventDefault();
    try {
      if (editing) {
        await update(editing.id, form);
      } else {
        await create(form);
      }
      setModalOpen(false);
    } catch (err) {
      setFormError(err.response?.data?.message ?? 'Gagal menyimpan produk');
    }
  }

  async function handleDelete(id) {
    if (!confirm('Nonaktifkan produk ini? Produk tidak akan muncul lagi di transaksi baru.')) return;
    try {
      await remove(id);
    } catch (err) {
      alert(err.response?.data?.message ?? 'Gagal menonaktifkan produk');
    }
  }

  return (
    <div>
      <div className="flex justify-end mb-4">
        <Button onClick={openCreate}>+ Tambah Produk</Button>
      </div>

      {loading && <p className="text-sm text-text-muted">Memuat...</p>}
      {error && <p className="text-sm text-danger">{error}</p>}

      <div className="bg-surface border border-border rounded-2xl overflow-hidden">
        <table className="w-full text-sm">
          <thead>
            <tr className="border-b border-border text-text-muted text-left">
              <th className="px-5 py-3 font-medium">Produk</th>
              <th className="px-5 py-3 font-medium">Kategori</th>
              <th className="px-5 py-3 font-medium">Harga</th>
              <th className="px-5 py-3 font-medium">Stok</th>
              <th className="px-5 py-3 font-medium">Status</th>
              <th className="px-5 py-3 font-medium w-32">Aksi</th>
            </tr>
          </thead>
          <tbody>
            {items.map((product) => (
              <tr key={product.id} className="border-b border-border last:border-0">
                <td className="px-5 py-3 text-text-primary">{product.name}</td>
                <td className="px-5 py-3 text-text-muted">{product.category?.name ?? '-'}</td>
                <td className="px-5 py-3 font-mono font-tabular text-text-primary">
                  {formatRupiah(product.price)}
                </td>
                <td className="px-5 py-3 font-mono font-tabular text-text-primary">
                  {product.stock} {product.unit?.name}
                </td>
                <td className="px-5 py-3">
                  <span
                    className={`text-xs px-2 py-0.5 rounded-full ${
                      product.is_active
                        ? 'bg-positive/10 text-positive'
                        : 'bg-white/5 text-text-muted'
                    }`}
                  >
                    {product.is_active ? 'Aktif' : 'Nonaktif'}
                  </span>
                </td>
                <td className="px-5 py-3 space-x-2">
                  <button
                    onClick={() => openEdit(product)}
                    className="text-accent text-xs hover:underline"
                  >
                    Edit
                  </button>
                  {product.is_active && (
                    <button
                      onClick={() => handleDelete(product.id)}
                      className="text-danger text-xs hover:underline"
                    >
                      Nonaktifkan
                    </button>
                  )}
                </td>
              </tr>
            ))}
            {items.length === 0 && !loading && (
              <tr>
                <td colSpan={6} className="px-5 py-8 text-center text-text-muted text-sm">
                  Belum ada produk
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>

      <Modal
        isOpen={modalOpen}
        onClose={() => setModalOpen(false)}
        title={editing ? 'Edit Produk' : 'Tambah Produk'}
      >
        <form onSubmit={handleSubmit} className="space-y-4">
          {formError && <p className="text-sm text-danger">{formError}</p>}

          <Input
            label="Nama Produk"
            value={form.name}
            onChange={(e) => setForm({ ...form, name: e.target.value })}
            required
            autoFocus
          />

          <div>
            <label className="block text-sm text-text-muted mb-1.5">Kategori</label>
            <select
              value={form.category_id}
              onChange={(e) => setForm({ ...form, category_id: e.target.value })}
              required
              className="w-full bg-base border border-border rounded-lg px-3 py-2 text-sm text-text-primary focus:outline-none focus:ring-2 focus:ring-accent/40"
            >
              <option value="">Pilih kategori</option>
              {categories.map((c) => (
                <option key={c.id} value={c.id}>
                  {c.name}
                </option>
              ))}
            </select>
          </div>

          <div>
            <label className="block text-sm text-text-muted mb-1.5">Satuan</label>
            <select
              value={form.unit_id}
              onChange={(e) => setForm({ ...form, unit_id: e.target.value })}
              required
              className="w-full bg-base border border-border rounded-lg px-3 py-2 text-sm text-text-primary focus:outline-none focus:ring-2 focus:ring-accent/40"
            >
              <option value="">Pilih satuan</option>
              {units.map((u) => (
                <option key={u.id} value={u.id}>
                  {u.name}
                </option>
              ))}
            </select>
          </div>

          <Input
            label="Harga Jual"
            type="number"
            value={form.price}
            onChange={(e) => setForm({ ...form, price: e.target.value })}
            required
            min="0"
          />

          {!editing && (
            <Input
              label="Stok Awal"
              type="number"
              value={form.stock}
              onChange={(e) => setForm({ ...form, stock: e.target.value })}
              required
              min="0"
            />
          )}

          <Button type="submit" className="w-full">
            Simpan
          </Button>
        </form>
      </Modal>
    </div>
  );
}