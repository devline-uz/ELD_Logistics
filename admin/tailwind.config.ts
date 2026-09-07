import type { Config } from 'tailwindcss';

/**
 * Dizayn tokenlari skeleti.
 *
 * Bosqich 0 — faqat karkas. Haqiqiy qiymatlar (ranglar, tipografika, spacing,
 * radius, soyalar) TZ §5 bo'yicha **Bosqich 1.1** da to'ldiriladi.
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
        // Bosqich 1.1 da to'ldiriladi: brand, neutral, success, warning, danger, info…
      },
      fontFamily: {
        // Bosqich 1.2: sans → IBM Plex Sans (lokal woff2) + fallback stack
      },
      fontSize: {
        // Bosqich 1.1: tipografika shkalasi
      },
      spacing: {
        // Bosqich 1.1: spacing shkalasi (4px bazasi)
      },
      borderRadius: {
        // Bosqich 1.1
      },
      boxShadow: {
        // Bosqich 1.1
      },
      screens: {
        // Minimal qo'llab-quvvatlanadigan kenglik — 1280px (NFR §15)
      },
    },
  },
  plugins: [],
};

export default config;
