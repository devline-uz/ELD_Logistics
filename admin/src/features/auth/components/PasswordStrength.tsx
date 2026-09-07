import { useTranslation } from 'react-i18next';

export interface PasswordStrengthProps {
  password: string;
}

interface Rule {
  key: string;
  test: (value: string) => boolean;
}

const RULES: Rule[] = [
  { key: 'length', test: (value) => value.length >= 10 },
  { key: 'letter', test: (value) => /[A-Za-z]/.test(value) },
  { key: 'number', test: (value) => /\d/.test(value) },
];

/** Parol kuchi indikatori (TZ §18.3: ≥10 belgi, harf + raqam). */
export function PasswordStrength({ password }: PasswordStrengthProps) {
  const { t } = useTranslation();
  const passed = RULES.filter((rule) => rule.test(password)).length;

  return (
    // `role="status"` `<ul>` elementiga to'g'ridan-to'g'ri qo'yilsa uning
    // ro'yxat semantikasini buzadi (axe: aria-allowed-role/listitem) — shu
    // sabab live-region alohida o'rovchi elementga ko'chirildi (fe-a11y §2).
    <div aria-live="polite" role="status" className="text-xs">
      <ul className="flex flex-col gap-1">
        {RULES.map((rule) => {
          const ok = rule.test(password);
          return (
            <li
              key={rule.key}
              className={`flex items-center gap-1.5 ${ok ? 'text-success-dark' : 'text-neutral-500'}`}
            >
              <span aria-hidden="true">{ok ? '✓' : '○'}</span>
              {t(`auth.passwordStrength.${rule.key}`)}
            </li>
          );
        })}
      </ul>
      <span className="sr-only">
        {t('auth.passwordStrength.summary', { passed, total: RULES.length })}
      </span>
    </div>
  );
}

export default PasswordStrength;
