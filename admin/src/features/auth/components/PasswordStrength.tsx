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
    <ul aria-live="polite" className="flex flex-col gap-1 text-xs" role="status">
      {RULES.map((rule) => {
        const ok = rule.test(password);
        return (
          <li
            key={rule.key}
            className="flex items-center gap-1.5"
            style={{ color: ok ? 'var(--color-success-dark)' : 'var(--color-neutral-500)' }}
          >
            <span aria-hidden="true">{ok ? '✓' : '○'}</span>
            {t(`auth.passwordStrength.${rule.key}`)}
          </li>
        );
      })}
      <li className="sr-only">
        {t('auth.passwordStrength.summary', { passed, total: RULES.length })}
      </li>
    </ul>
  );
}

export default PasswordStrength;
