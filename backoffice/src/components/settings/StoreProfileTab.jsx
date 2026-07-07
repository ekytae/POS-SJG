import { useEffect, useState } from 'react';
import apiClient from '../../api/client';
import Button from '../ui/Button';
import Input from '../ui/Input';

export default function StoreProfileTab() {
  const [form, setForm] = useState({
    store_name: '',
    store_address: '',
    store_phone: '',
  });
  const [logoFile, setLogoFile] = useState(null);
  const [logoPreview, setLogoPreview] = useState(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState(null);
  const [success, setSuccess] = useState(null);

  useEffect(() => {
    apiClient
      .get('/settings')
      .then((res) => {
        const data = res.data.data;
        setForm({
          store_name: data.store_name ?? '',
          store_address: data.store_address ?? '',
          store_phone: data.store_phone ?? '',
        });
        if (data.logo_path) {
          setLogoPreview(`${import.meta.env.VITE_API_BASE_URL.replace('/api/v1', '')}/storage/${data.logo_path}`);
        }
      })
      .catch(() => setError('Gagal memuat pengaturan toko'))
      .finally(() => setLoading(false));
  }, []);

  function handleLogoChange(e) {
    const file = e.target.files?.[0];
    if (!file) return;
    setLogoFile(file);
    setLogoPreview(URL.createObjectURL(file));
  }

  async function handleSubmit(e) {
    e.preventDefault();
    setError(null);
    setSuccess(null);
    setSaving(true);

    try {
      const formData = new FormData();
      formData.append('store_name', form.store_name);
      formData.append('store_address', form.store_address ?? '');
      formData.append('store_phone', form.store_phone ?? '');
      formData.append('_method', 'PUT'); // Laravel butuh ini untuk PUT dengan file upload
      if (logoFile) {
        formData.append('logo', logoFile);
      }

      await apiClient.post('/settings', formData, {
        headers: { 'Content-Type': 'multipart/form-data' },
      });

      setSuccess('Pengaturan toko berhasil disimpan');
    } catch (err) {
      setError(err.response?.data?.message ?? 'Gagal menyimpan pengaturan');
    } finally {
      setSaving(false);
    }
  }

  if (loading) return <p className="text-sm text-text-muted">Memuat...</p>;

  return (
    <form
      onSubmit={handleSubmit}
      className="bg-surface border border-border rounded-2xl p-6 space-y-4 max-w-lg"
    >
      {error && <p className="text-sm text-danger">{error}</p>}
      {success && <p className="text-sm text-positive">{success}</p>}

      <div>
        <label className="block text-sm text-text-muted mb-2">Logo Toko</label>
        <div className="flex items-center gap-4">
          <div className="h-16 w-16 rounded-xl bg-base border border-border flex items-center justify-center overflow-hidden">
            {logoPreview ? (
              <img src={logoPreview} alt="Logo" className="h-full w-full object-cover" />
            ) : (
              <span className="text-2xl">🫚</span>
            )}
          </div>
          <label className="cursor-pointer">
            <span className="text-sm text-accent hover:underline">Ganti logo</span>
            <input type="file" accept="image/*" onChange={handleLogoChange} className="hidden" />
          </label>
        </div>
      </div>

      <Input
        label="Nama Toko"
        value={form.store_name}
        onChange={(e) => setForm({ ...form, store_name: e.target.value })}
        required
      />

      <Input
        label="Alamat"
        value={form.store_address}
        onChange={(e) => setForm({ ...form, store_address: e.target.value })}
      />

      <Input
        label="Nomor Telepon"
        value={form.store_phone}
        onChange={(e) => setForm({ ...form, store_phone: e.target.value })}
      />

      <Button type="submit" disabled={saving}>
        {saving ? 'Menyimpan...' : 'Simpan Perubahan'}
      </Button>
    </form>
  );
}