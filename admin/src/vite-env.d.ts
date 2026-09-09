/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly VITE_API_BASE_URL: string;
  readonly VITE_API_DOCS_URL: string;
  readonly VITE_WS_URL: string;
  readonly VITE_MAP_STYLE_URL?: string;
  readonly VITE_SENTRY_DSN?: string;
  /** MSW dev/e2e bayrog'i (9.1) — faqat `import.meta.env.DEV` bilan birga tekshiriladi. */
  readonly VITE_ENABLE_MSW?: string;
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}
