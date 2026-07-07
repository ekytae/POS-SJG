import { useState } from 'react';
import apiClient from '../../api/client';
import { useCrud } from '../../hooks/useCrud';
import Button from '../ui/Button';
import Modal from '../ui/Modal';
import Input from '../ui/Input';
import { formatRupiah, toLocalDateString } from '../../utils/format';

export default function ExpenseListTab({ expenseCategories }) {
  const { items, loading, error, remove, refetch } = useCrud('/expenses');
  const [modalOpen, setModalOpen] = useState(false);
  const [form, setForm] = useState({
    expense_category_id: '',
    amount: '',
    description: '',
    date: toLocalDateString(new Date()),
  });
  const [formError, setFormError] = useState(null);
  const [submitting, setSubmitting] = useState(false);

  function openCreate() {
    setForm({
      expense_category_id: '',
      amount: '',
      description: '',
      date: toLocalDateString(new Date()),
    });
    setFormError(null);
    setModalOpen(true);
  }

  async function handleSubmit(e) {
    e.preventDefault();
    setFormError(null);
    setSubmitting(true);

    try {
      await apiClient.post('/expenses', form);
      setModalOpen(false);
      refetch();
    } catch (err) {
      setFormError(err.response?.data?.message ?? 'Gagal menyimpan pengeluaran');
    } finally {
      setSubmitting(false);
    }
  }

  async function handleDelete(id) {
    if (!confirm('Hapus catatan pengeluaran ini?')) return;
    try {
      await remove(id);
    } catch (err) {
      alert(err.response?.data?.message ?? 'Gagal menghapus');
    }
  }

  const totalAmount = items.reduce((sum, item) => sum + Number(item.amount), 0);

  return (
    <div>
      <div className="flex items-center justify-between mb-4">
        <div className="bg-surface border border-border rounded-xl px-4 py-2.5">
          <p className="text-xs text-text-muted">Total Pengeluaran</p>
          <p className="text-lg font-mono font-tabular text-danger">{formatRupiah(totalAmount)}</p>
        </div>
        <Button onClick={openCreate}>+ Catat Pengeluaran</Button>
      </div>

      {loading && <p className="text-sm text-text-muted">Memuat...</p>}
      {error && <p className="text-sm text-danger">{error}</p>}

      <div className="bg-surface border border-border rounded-2xl overflow-hidden">
        <table className="w-full text-sm">
          <thead>
            <tr className="border-b border-border text-text-muted text-left">
              <th className="px-5 py-3 font-medium">Tanggal</th>
              <th className="px-5 py-3 font-medium">Kategori</th>
              <th className="px-5 py-3 font-medium">Keterangan</th>
              <th className="px-5 py-3 font-medium">Jumlah</th>
              <th className="px-5 py-3 font-medium w-24">Aksi</th>
            </tr>
          </thead>
          <tbody>
            {items.map((expense) => (
              <tr key={expense.id} className="border-b border-border last:border-0">
                <td className="px-5 py-3 text-text-muted">
                  {new Date(expense.date).toLocaleDateString('id-ID', {
                    day: 'numeric',
                    month: 'short',
                    year: 'numeric',
                  })}
                </td>
                <td className="px-5 py-3 text-text-primary">{expense.category?.name ?? '-'}</td>
                <td className="px-5 py-3 text-text-muted">{expense.description ?? '-'}</td>
                <td className="px-5 py-3 font-mono font-tabular text-danger">
                  {formatRupiah(expense.amount)}
                </td>
                <td className="px-5 py-3">
                  <button
                    onClick={() => handleDelete(expense.id)}
                    className="text-danger text-xs hover:underline"
                  >
                    Hapus
                  </button>
                </td>
              </tr>
            ))}
            {items.length === 0 && !loading && (
              <tr>
                <td colSpan={5} className="px-5 py-8 text-center text-text-muted text-sm">
                  Belum ada pengeluaran tercatat
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>

      <Modal isOpen={modalOpen} onClose={() => setModalOpen(false)} title="Catat Pengeluaran">
        <form onSubmit={handleSubmit} className="space-y-4">
          {formError && <p className="text-sm text-danger">{formError}</p>}

          <div>
            <label className="block text-sm text-text-muted mb-1.5">Kategori</label>
            <select
              value={form.expense_category_id}
              onChange={(e) => setForm({ ...form, expense_category_id: e.target.value })}
              required
              className="w-full bg-base border border-border rounded-lg px-3 py-2 text-sm text-text-primary focus:outline-none focus:ring-2 focus:ring-accent/40"
            >
              <option value="">Pilih kategori</option>
              {expenseCategories.map((c) => (
                <option key={c.id} value={c.id}>
                  {c.name}
                </option>
              ))}
            </select>
          </div>

          <Input
            label="Jumlah (Rp)"
            type="number"
            min="0"
            value={form.amount}
            onChange={(e) => setForm({ ...form, amount: e.target.value })}
            required
          />

          <Input
            label="Tanggal"
            type="date"
            value={form.date}
            onChange={(e) => setForm({ ...form, date: e.target.value })}
            required
          />

          <Input
            label="Keterangan (opsional)"
            type="text"
            value={form.description}
            onChange={(e) => setForm({ ...form, description: e.target.value })}
            placeholder="Misal: Beli gula & teh"
          />

          <Button type="submit" disabled={submitting} className="w-full">
            {submitting ? 'Menyimpan...' : 'Simpan'}
          </Button>
        </form>
      </Modal>
    </div>
  );
}