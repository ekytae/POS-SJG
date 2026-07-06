export default function DateRangeFilter({ from, to, onChangeFrom, onChangeTo }) {
  return (
    <div className="flex items-end gap-3 mb-6">
      <div>
        <label className="block text-xs text-text-muted mb-1.5">Dari Tanggal</label>
        <input
          type="date"
          value={from}
          onChange={(e) => onChangeFrom(e.target.value)}
          className="bg-base border border-border rounded-lg px-3 py-2 text-sm text-text-primary focus:outline-none focus:ring-2 focus:ring-accent/40"
        />
      </div>
      <div>
        <label className="block text-xs text-text-muted mb-1.5">Sampai Tanggal</label>
        <input
          type="date"
          value={to}
          onChange={(e) => onChangeTo(e.target.value)}
          className="bg-base border border-border rounded-lg px-3 py-2 text-sm text-text-primary focus:outline-none focus:ring-2 focus:ring-accent/40"
        />
      </div>
    </div>
  );
}