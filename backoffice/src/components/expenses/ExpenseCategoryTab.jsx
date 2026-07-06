import { useState } from 'react';
import { useCrud } from '../../hooks/useCrud';
import Button from '../ui/Button';
import Modal from '../ui/Modal';
import Input from '../ui/Input';

export default function ExpenseCategoryTab() {
  const { items, loading, error, create, update, remove } = useCrud('/expense-categories');
  const [modalOpen, setModalOpen] = useState(false);
  const [editing, setEditing] = useState(null);
  const [name, setName] = useState('');
  const [formError, setFormError] = useState(null);

  function openCreate() {
    setEditing(null);
    setName('');
    setFormError(null);
    setModalOpen(true);
  }

  function openEdit(category) {
    setEditing(category);
    setName(category.name);
    setFormError(null);
    setModalOpen(true);
  }

  async function handleSubmit(e) {
    e.preventDefault();
    try {
      if (editing) {
        await update(editing.id, { name });
      } else {
        await create({ name });
      }
      setModalOpen(false);
    } catch (err) {
      setFormError(err.response?.data?.message ?? 'Gagal menyimpan kategori');
    }
  }

  async function handleDelete(id) {
    if (!confirm('Hapus kategori pengeluaran ini?')) return;
    try {
      await remove(id);
    } catch (err) {
      alert(err.response?.data?.message ?? 'Gagal menghapus kategori');
    }
  }

  return (
    <div>
      <div className="flex justify-end mb-4">
        <Button onClick={openCreate}>+ Tambah Kategori</Button>
      </div>

      {loading && <p className="text-sm text-text-muted">Memuat...</p>}
      {error && <p className="text-sm text-danger">{error}</p>}

      <div className="bg-surface border border-border rounded-2xl overflow-hidden">
        <table className="w-full text-sm">
          <thead>
            <tr className="border-b border-border text-text-muted text-left">
              <th className="px-5 py-3 font-medium">Nama Kategori</th>
              <th className="px-5 py-3 font-medium w-32">Aksi</th>
            </tr>
          </thead>
          <tbody>
            {items.map((category) => (
              <tr key={category.id} className="border-b border-border last:border-0">
                <td className="px-5 py-3 text-text-primary">{category.name}</td>
                <td className="px-5 py-3 space-x-2">
                  <button
                    onClick={() => openEdit(category)}
                    className="text-accent text-xs hover:underline"
                  >
                    Edit
                  </button>
                  <button
                    onClick={() => handleDelete(category.id)}
                    className="text-danger text-xs hover:underline"
                  >
                    Hapus
                  </button>
                </td>
              </tr>
            ))}
            {items.length === 0 && !loading && (
              <tr>
                <td colSpan={2} className="px-5 py-8 text-center text-text-muted text-sm">
                  Belum ada kategori pengeluaran
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>

      <Modal
        isOpen={modalOpen}
        onClose={() => setModalOpen(false)}
        title={editing ? 'Edit Kategori' : 'Tambah Kategori'}
      >
        <form onSubmit={handleSubmit} className="space-y-4">
          {formError && <p className="text-sm text-danger">{formError}</p>}
          <Input
            label="Nama Kategori"
            value={name}
            onChange={(e) => setName(e.target.value)}
            required
            autoFocus
          />
          <Button type="submit" className="w-full">
            Simpan
          </Button>
        </form>
      </Modal>
    </div>
  );
}