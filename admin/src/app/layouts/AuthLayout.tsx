import type { ReactNode } from 'react';
import { useTranslation } from 'react-i18next';

export interface AuthLayoutProps {
  children: ReactNode;
}

/**
 * Auth ekranlari uchun umumiy qobiq (TZ §7.1: «nav tashqarisida»).
 *
 * 🎨 Dizaynda auth ekranlari chizilmagan (§7.1.1) — brend rangi + logotip +
 * markazlashgan karta (maks. 440px), mavjud CSS token'lardan (`--color-*`).
 */
export function AuthLayout({ children }: AuthLayoutProps) {
  const { t } = useTranslation();

  return (
    <div
      className="flex min-h-screen items-center justify-center px-4 py-10"
      style={{ backgroundColor: 'var(--color-surface-muted)' }}
    >
      <div className="w-full max-w-[440px]">
        <div className="mb-6 flex items-center justify-center gap-2">
          <span className="text-lg font-semibold" style={{ color: 'var(--color-primary)' }}>
            {t('app.name')}
          </span>
        </div>

        <main
          className="rounded-lg p-8 shadow-sm"
          style={{
            backgroundColor: 'var(--color-surface)',
            border: '1px solid var(--color-stroke)',
          }}
        >
          {children}
        </main>
      </div>
    </div>
  );
}

export default AuthLayout;
