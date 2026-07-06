import { useState } from 'react';
import Tabs from '../components/ui/Tabs';
import CategoryTab from '../components/products/CategoryTab';
import UnitTab from '../components/products/UnitTab';
import ProductTab from '../components/products/ProductTab';
import StockHistoryTab from '../components/products/StockHistoryTab';
import { useCrud } from '../hooks/useCrud';

const tabs = [
  { key: 'products', label: 'Produk' },
  { key: 'categories', label: 'Kategori' },
  { key: 'units', label: 'Satuan' },
  { key: 'stock', label: 'Stok Masuk / Penyesuaian' },
];

export default function Products() {
  const [activeTab, setActiveTab] = useState('products');

  // Load categories & units di level parent supaya bisa dipakai bareng
  // di ProductTab (dropdown) & StockHistoryTab (dropdown produk)
  const { items: categories } = useCrud('/categories');
  const { items: units } = useCrud('/units');
  const { items: products } = useCrud('/products');

  return (
    <div>
      <div className="mb-6">
        <h1 className="text-xl font-semibold text-text-primary">Manajemen Stok</h1>
        <p className="text-sm text-text-muted mt-1">
          Kelola produk, kategori, satuan, dan pergerakan stok
        </p>
      </div>

      <Tabs tabs={tabs} active={activeTab} onChange={setActiveTab} />

      {activeTab === 'products' && <ProductTab categories={categories} units={units} />}
      {activeTab === 'categories' && <CategoryTab />}
      {activeTab === 'units' && <UnitTab />}
      {activeTab === 'stock' && <StockHistoryTab products={products} />}
    </div>
  );
}