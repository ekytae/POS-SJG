import { useState } from 'react';
import Tabs from '../components/ui/Tabs';
import StoreProfileTab from '../components/settings/StoreProfileTab';
import UserManagementTab from '../components/settings/UserManagementTab';

const tabs = [
  { key: 'profile', label: 'Profil Toko' },
  { key: 'users', label: 'Kelola User' },
];

export default function Settings() {
  const [activeTab, setActiveTab] = useState('profile');

  return (
    <div>
      <div className="mb-6">
        <h1 className="text-xl font-semibold text-text-primary">Pengaturan</h1>
        <p className="text-sm text-text-muted mt-1">Kelola profil toko dan akun user</p>
      </div>

      <Tabs tabs={tabs} active={activeTab} onChange={setActiveTab} />

      {activeTab === 'profile' && <StoreProfileTab />}
      {activeTab === 'users' && <UserManagementTab />}
    </div>
  );
}