/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,jsx}'],
  theme: {
    extend: {
      colors: {
        base: '#080b12',
        surface: '#10141d',
        border: 'rgba(255,255,255,0.08)',
        'text-primary': '#e4e2d8',
        'text-muted': '#8b8d98',
        accent: {
          DEFAULT: '#d9822b',
          soft: 'rgba(217,130,43,0.12)',
        },
        positive: '#34d399',
        danger: '#f87171',
      },
      fontFamily: {
        sans: ['Inter', 'sans-serif'],
        mono: ['JetBrains Mono', 'monospace'],
      },
    },
  },
  plugins: [],
};