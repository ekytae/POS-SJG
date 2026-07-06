import { useCallback, useEffect, useState } from 'react';
import apiClient from '../api/client';

export function useCrud(endpoint) {
  const [items, setItems] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const fetchItems = useCallback(async () => {
    setLoading(true);
    try {
      const res = await apiClient.get(endpoint);
      // Handle response yang paginated (data.data) maupun flat array (data)
      const payload = res.data.data;
      setItems(Array.isArray(payload) ? payload : payload.data ?? []);
      setError(null);
    } catch (err) {
      setError(err.response?.data?.message ?? 'Gagal memuat data');
    } finally {
      setLoading(false);
    }
  }, [endpoint]);

  useEffect(() => {
    fetchItems();
  }, [fetchItems]);

  async function create(payload) {
    const res = await apiClient.post(endpoint, payload);
    await fetchItems();
    return res.data.data;
  }

  async function update(id, payload) {
    const res = await apiClient.put(`${endpoint}/${id}`, payload);
    await fetchItems();
    return res.data.data;
  }

  async function remove(id) {
    await apiClient.delete(`${endpoint}/${id}`);
    await fetchItems();
  }

  return { items, loading, error, create, update, remove, refetch: fetchItems };
}