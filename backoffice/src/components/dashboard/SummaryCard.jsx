export default function SummaryCard({ label, value, accentClass = 'text-text-primary' }) {
  return (
    <div className="bg-surface border border-border rounded-2xl p-5">
      <p className="text-sm text-text-muted mb-2">{label}</p>
      <p className={`text-2xl font-semibold font-mono font-tabular ${accentClass}`}>
        {value}
      </p>
    </div>
  );
}