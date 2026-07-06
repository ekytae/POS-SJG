export default function Input({ label, ...props }) {
  return (
    <div>
      {label && <label className="block text-sm text-text-muted mb-1.5">{label}</label>}
      <input
        className="w-full bg-base border border-border rounded-lg px-3 py-2 text-sm text-text-primary focus:outline-none focus:ring-2 focus:ring-accent/40 focus:border-accent"
        {...props}
      />
    </div>
  );
}