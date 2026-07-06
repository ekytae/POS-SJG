import { useEffect, useState } from 'react';
import apiClient from '../api/client';

export function useReport(endpoint, params, enabled = true) {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  useEffect(() => {
    if (!enabled) return;

    let isMounted = true;
    setLoading(true);
    setError(null);

    apiClient
      .get(endpoint, { params })
      .then((res) => {
        if (isMounted) setData(res.data.data);
      })
      .catch((err) => {
        if (isMounted) setError(err.response?.data?.message ?? 'Gagal memuat laporan');
      })
      .finally(() => {
        if (isMounted) setLoading(false);
      });

    return () => {
      isMounted = false;
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [endpoint, JSON.stringify(params), enabled]);

  return { data, loading, error };
}