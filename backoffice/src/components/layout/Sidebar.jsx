import { NavLink } from 'react-router-dom';
import { useAuthStore } from '../../store/authStore';

const menuItems = [
  { to: '/dashboard', label: 'Dashboard', icon: '📊' },
  { to: '/products', label: 'Stok', icon: '📦' },
  { to: '/expenses', label: 'Pengeluaran', icon: '💸' },
  { to: '/reports', label: 'Laporan', icon: '📈' },
  { to: '/settings', label: 'Pengaturan', icon: '⚙️' },
];

export default function Sidebar() {
  const logout = useAuthStore((state) => state.logout);
  const user = useAuthStore((state) => state.user);

  return (
    <aside className="w-60 shrink-0 bg-surface border-r border-border flex flex-col h-screen sticky top-0">
      <div className="px-5 py-5 border-b border-border">
        <p className="text-sm font-semibold text-text-primary">Susu Jahe Geprek</p>
        <p className="text-xs text-text-muted mt-0.5">Backoffice</p>
      </div>

      <nav className="flex-1 px-3 py-4 space-y-1">
        {menuItems.map((item) => (
          <NavLink
            key={item.to}
            to={item.to}
            className={({ isActive }) =>
              `flex items-center gap-2.5 px-3 py-2 rounded-lg text-sm transition-colors ${
                isActive
                  ? 'bg-accent-soft text-accent'
                  : 'text-text-muted hover:bg-white/5 hover:text-text-primary'
              }`
            }
          >
            <span>{item.icon}</span>
            {item.label}
          </NavLink>
        ))}
      </nav>

      <div className="px-3 py-4 border-t border-border">
        <p className="px-3 text-xs text-text-muted mb-2">{user?.name}</p>
        <button
          onClick={logout}
          className="w-full text-left px-3 py-2 rounded-lg text-sm text-danger hover:bg-danger/10 transition-colors"
        >
          Keluar
        </button>
      </div>
    </aside>
  );
}