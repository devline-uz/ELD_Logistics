import { fileURLToPath, URL } from 'node:url';

import react from '@vitejs/plugin-react';
import { defineConfig } from 'vitest/config';

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url)),
    },
  },
  server: {
    port: 5173,
  },
  build: {
    outDir: 'dist',
    sourcemap: true,
  },
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: ['./vitest.setup.ts'],
    css: false,
    include: ['src/**/*.{test,spec}.{ts,tsx}'],
    // MSW so'rovlarni ushlab olishi uchun mutlaq (absolyut) baza kerak —
    // `.env.local` haqiqiy prod URL'ini beradi, lekin testlar backendga
    // ulanmasligi shart (fe-api §1, W12: haqiqiy backendga urinilmaydi).
    env: {
      VITE_API_BASE_URL: 'http://eldapi.test/api/v1',
    },
    coverage: {
      provider: 'v8',
      reporter: ['text', 'html', 'lcov'],
      include: ['src/**/*.{ts,tsx}'],
      exclude: ['src/**/*.d.ts', 'src/main.tsx', 'src/api/schema.d.ts'],
    },
  },
});
