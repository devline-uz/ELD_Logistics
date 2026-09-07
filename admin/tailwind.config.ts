import type { Config } from 'tailwindcss';

/**
 * Dizayn tokenlari — fe-design-system SKILL.md asosida (Bosqich 1.1).
 *
 * Qoida: ranglar CSS o'zgaruvchilari orqali beriladi (`--color-*` in
 * `src/styles/index.css`), shunda mavzu almashtirish JS'siz ishlaydi.
 * Kodda hardcode hex/px yozilmaydi — faqat token sinflari.
 */
const config: Config = {
  content: ['./index.html', './src/**/*.{ts,tsx}'],
  theme: {
    extend: {
      colors: {
        primary: {
          DEFAULT: 'var(--color-primary)',
          hover: 'var(--color-primary-hover)',
        },
        bg: 'var(--color-bg)',
        surface: {
          DEFAULT: 'var(--color-surface)',
          muted: 'var(--color-surface-muted)',
        },
        stroke: 'var(--color-stroke)',
        light: 'var(--color-light)',
        neutral: {
          50: 'var(--color-neutral-50)',
          100: 'var(--color-neutral-100)',
          200: 'var(--color-neutral-200)',
          300: 'var(--color-neutral-300)',
          400: 'var(--color-neutral-400)',
          500: 'var(--color-neutral-500)',
          600: 'var(--color-neutral-600)',
          700: 'var(--color-neutral-700)',
          800: 'var(--color-neutral-800)',
          900: 'var(--color-neutral-900)',
          950: 'var(--color-neutral-950)',
        },
        success: {
          bg: 'var(--color-success-bg)',
          DEFAULT: 'var(--color-success-base)',
          base: 'var(--color-success-base)',
          dark: 'var(--color-success-dark)',
        },
        warning: {
          bg: 'var(--color-warning-bg)',
          DEFAULT: 'var(--color-warning-base)',
          base: 'var(--color-warning-base)',
          dark: 'var(--color-warning-dark)',
        },
        error: {
          bg: 'var(--color-error-bg)',
          DEFAULT: 'var(--color-error-base)',
          base: 'var(--color-error-base)',
          dark: 'var(--color-error-dark)',
        },
        decorative: {
          pink: 'var(--color-decorative-pink)',
          teal: 'var(--color-decorative-teal)',
          green: 'var(--color-decorative-green)',
          purple: 'var(--color-decorative-purple)',
          orange: 'var(--color-decorative-orange)',
          yellow: 'var(--color-decorative-yellow)',
          blue: 'var(--color-decorative-blue)',
        },
      },
      fontFamily: {
        sans: [
          'IBM Plex Sans',
          '-apple-system',
          'BlinkMacSystemFont',
          'Segoe UI',
          'Roboto',
          'Helvetica Neue',
          'Arial',
          'sans-serif',
        ],
        display: [
          'Product Sans',
          'IBM Plex Sans',
          '-apple-system',
          'BlinkMacSystemFont',
          'Segoe UI',
          'Roboto',
          'Helvetica Neue',
          'Arial',
          'sans-serif',
        ],
      },
      fontSize: {
        'display-1': ['48px', { lineHeight: '56px', fontWeight: '700' }],
        'display-2': ['40px', { lineHeight: '48px', fontWeight: '700' }],
        h1: ['48px', { lineHeight: '56px', fontWeight: '700' }],
        h2: ['40px', { lineHeight: '48px', fontWeight: '700' }],
        h3: ['32px', { lineHeight: '40px', fontWeight: '700' }],
        h4: ['24px', { lineHeight: '32px', fontWeight: '700' }],
        'body-lg': ['16px', { lineHeight: '24px', fontWeight: '400' }],
        body: ['14px', { lineHeight: '20px', fontWeight: '400' }],
        'body-sm': ['12px', { lineHeight: '16px', fontWeight: '400' }],
        'body-xs': ['10px', { lineHeight: '14px', fontWeight: '400' }],
      },
      spacing: {
        0: '0px',
        1: '4px',
        2: '8px',
        3: '12px',
        4: '16px',
        5: '20px',
        6: '24px',
        8: '32px',
        10: '40px',
        12: '48px',
        16: '64px',
      },
      borderRadius: {
        sm: '4px',
        md: '8px',
        lg: '12px',
        xl: '16px',
        full: '9999px',
      },
      boxShadow: {
        card: '0 4px 27.25px rgba(28,30,36,0.08)',
        dropdown: '0 8px 27.25px rgba(28,30,36,0.12)',
        modal: '0 20px 48px rgba(28,30,36,0.20)',
      },
      maxWidth: {
        content: '1440px',
      },
      screens: {
        // Minimal qo'llab-quvvatlanadigan kenglik — 1280px (NFR §15)
        xs: '1280px',
      },
    },
  },
  plugins: [],
};

export default config;
