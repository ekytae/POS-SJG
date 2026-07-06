import { useState } from 'react';
import Tabs from '../components/ui/Tabs';
import DateRangeFilter from '../components/reports/DateRangeFilter';
import SalesReportTab from '../components/reports/SalesReportTab';
import BestSellingTab from '../components/reports/BestSellingTab';
import ExpenseReportTab from '../components/reports/ExpenseReportTab';
import StockCardTab from '../components/reports/StockCardTab';

const tabs = [
  { key: 'sales', label: 'Penjualan' },
  { key: 'best-selling', label: 'Produk Terlaris' },
  { key: 'expenses', label: 'Pengeluaran' },
  { key: 'stock-card', label: 'Kartu Stok' },
];

function toLocalDateString(date) {
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const day = String(date.getDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
}

function defaultFrom() {
  const d = new Date();
  d.setDate(d.getDate() - 6);
  return toLocalDateString(d);
}

function defaultTo() {
  return toLocalDateString(new Date());
}

export default function Reports() {
  const [activeTab, setActiveTab] = useState('sales');
  const [from, setFrom] = useState(defaultFrom());
  const [to, setTo] = useState(defaultTo());

  return (
    <div>
      <div className="mb-6">
        <h1 className="text-xl font-semibold text-text-primary">Laporan</h1>
        <p className="text-sm text-text-muted mt-1">Analisis performa toko berdasarkan periode</p>
      </div>

      <Tabs tabs={tabs} active={activeTab} onChange={setActiveTab} />
      <DateRangeFilter from={from} to={to} onChangeFrom={setFrom} onChangeTo={setTo} />

      {activeTab === 'sales' && <SalesReportTab from={from} to={to} />}
      {activeTab === 'best-selling' && <BestSellingTab from={from} to={to} />}
      {activeTab === 'expenses' && <ExpenseReportTab from={from} to={to} />}
      {activeTab === 'stock-card' && <StockCardTab from={from} to={to} />}
    </div>
  );
}