export default function Button({ variant = 'primary', children, className = '', ...props }) {
  const variants = {
    primary: 'bg-accent hover:bg-accent/90 text-white',
    secondary: 'bg-white/5 hover:bg-white/10 text-text-primary border border-border',
    danger: 'bg-danger/10 hover:bg-danger/20 text-danger',
  };

  return (
    <button
      className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors disabled:opacity-50 ${variants[variant]} ${className}`}
      {...props}
    >
      {children}
    </button>
  );
}