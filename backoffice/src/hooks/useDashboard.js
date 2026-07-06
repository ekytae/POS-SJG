import { useEffect, useState } from 'react';
import apiClient from '../api/client';

export function useDashboard() {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    let isMounted = true;

    apiClient
      .get('/dashboard/summary')
      .then((res) => {
        if (isMounted) setData(res.data.data);
      })
      .catch((err) => {
        if (isMounted) setError(err.response?.data?.message ?? 'Gagal memuat data dashboard');
      })
      .finally(() => {
        if (isMounted) setLoading(false);
      });

    return () => {
      isMounted = false;
    };
  }, []);

  return { data, loading, error };
}