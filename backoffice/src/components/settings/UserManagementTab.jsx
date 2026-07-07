import { useState } from 'react';
import { useCrud } from '../../hooks/useCrud';
import apiClient from '../../api/client';
import Button from '../ui/Button';
import Modal from '../ui/Modal';
import Input from '../ui/Input';
import { useAuthStore } from '../../store/authStore';

export default function UserManagementTab() {
  const { items, loading, error, refetch } = useCrud('/users');
  const currentUser = useAuthStore((state) => state.user);

  const [modalOpen, setModalOpen] = useState(false);
  const [form, setForm] = useState({ name: '', username: '', password: '', role_id: 2 });
  const [formError, setFormError] = useState(null);
  const [submitting, setSubmitting] = useState(false);

  function openCreate() {
    setForm({ name: '', username: '', password: '', role_id: 2 });
    setFormError(null);
    setModalOpen(true);
  }

  async function handleSubmit(e) {
    e.preventDefault();
    setFormError(null);
    setSubmitting(true);

    try {
      await apiClient.post('/users', form);
      setModalOpen(false);
      refetch();
    } catch (err) {
      setFormError(
        Object.values(err.response?.data?.errors ?? {})[0]?.[0] ??
          err.response?.data?.message ??
          'Gagal menambah user'
      );
    } finally {
      setSubmitting(false);
    }
  }

  async function handleToggleActive(user) {
    if (user.id === currentUser?.id) {
      alert('Anda tidak bisa menonaktifkan akun sendiri');
      return;
    }

    try {
      await apiClient.patch(`/users/${user.id}/toggle-active`);
      refetch();
    } catch (err) {
      alert(err.response?.data?.message ?? 'Gagal mengubah status user');
    }
  }

  return (
    <div>
      <div className="flex justify-end mb-4">
        <Button onClick={openCreate}>+ Tambah Kasir</Button>
      </div>

      {loading && <p className="text-sm text-text-muted">Memuat...</p>}
      {error && <p className="text-sm text-danger">{error}</p>}

      <div className="bg-surface border border-border rounded-2xl overflow-hidden">
        <table className="w-full text-sm">
          <thead>
            <tr className="border-b border-border text-text-muted text-left">
              <th className="px-5 py-3 font-medium">Nama</th>
              <th className="px-5 py-3 font-medium">Username</th>
              <th className="px-5 py-3 font-medium">Role</th>
              <th className="px-5 py-3 font-medium">Status</th>
              <th className="px-5 py-3 font-medium w-32">Aksi</th>
            </tr>
          </thead>
          <tbody>
            {items.map((user) => (
              <tr key={user.id} className="border-b border-border last:border-0">
                <td className="px-5 py-3 text-text-primary">
                  {user.name}
                  {user.id === currentUser?.id && (
                    <span className="text-xs text-text-muted ml-1.5">(Anda)</span>
                  )}
                </td>
                <td className="px-5 py-3 text-text-muted">{user.username}</td>
                <td className="px-5 py-3">
                  <span className="text-xs px-2 py-0.5 rounded-full bg-accent-soft text-accent capitalize">
                    {user.role?.name}
                  </span>
                </td>
                <td className="px-5 py-3">
                  <span
                    className={`text-xs px-2 py-0.5 rounded-full ${
                      user.is_active ? 'bg-positive/10 text-positive' : 'bg-white/5 text-text-muted'
                    }`}
                  >
                    {user.is_active ? 'Aktif' : 'Nonaktif'}
                  </span>
                </td>
                <td className="px-5 py-3">
                  {user.id !== currentUser?.id && (
                    <button
                      onClick={() => handleToggleActive(user)}
                      className="text-accent text-xs hover:underline"
                    >
                      {user.is_active ? 'Nonaktifkan' : 'Aktifkan'}
                    </button>
                  )}
                </td>
              </tr>
            ))}
            {items.length === 0 && !loading && (
              <tr>
                <td colSpan={5} className="px-5 py-8 text-center text-text-muted text-sm">
                  Belum ada user
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>

      <Modal isOpen={modalOpen} onClose={() => setModalOpen(false)} title="Tambah Kasir Baru">
        <form onSubmit={handleSubmit} className="space-y-4">
          {formError && <p className="text-sm text-danger">{formError}</p>}

          <Input
            label="Nama"
            value={form.name}
            onChange={(e) => setForm({ ...form, name: e.target.value })}
            required
            autoFocus
          />
          <Input
            label="Username"
            value={form.username}
            onChange={(e) => setForm({ ...form, username: e.target.value })}
            required
          />
          <Input
            label="Password"
            type="password"
            value={form.password}
            onChange={(e) => setForm({ ...form, password: e.target.value })}
            required
            minLength={6}
          />

          <Button type="submit" disabled={submitting} className="w-full">
            {submitting ? 'Menyimpan...' : 'Simpan'}
          </Button>
        </form>
      </Modal>
    </div>
  );
}