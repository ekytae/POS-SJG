import { useState } from 'react';
import Tabs from '../components/ui/Tabs';
import ExpenseListTab from '../components/expenses/ExpenseListTab';
import ExpenseCategoryTab from '../components/expenses/ExpenseCategoryTab';
import { useCrud } from '../hooks/useCrud';

const tabs = [
  { key: 'list', label: 'Daftar Pengeluaran' },
  { key: 'categories', label: 'Kategori' },
];

export default function Expenses() {
  const [activeTab, setActiveTab] = useState('list');
  const { items: expenseCategories } = useCrud('/expense-categories');

  return (
    <div>
      <div className="mb-6">
        <h1 className="text-xl font-semibold text-text-primary">Pengeluaran</h1>
        <p className="text-sm text-text-muted mt-1">Catat dan kelola biaya operasional toko</p>
      </div>

      <Tabs tabs={tabs} active={activeTab} onChange={setActiveTab} />

      {activeTab === 'list' && <ExpenseListTab expenseCategories={expenseCategories} />}
      {activeTab === 'categories' && <ExpenseCategoryTab />}
    </div>
  );
}