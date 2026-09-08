/**
 * Imzo — **faqat ko'rish** (F107, CLAUDE.md buzilmas qoidasi).
 *
 * Admin panel hech qachon haydovchi yoki mexanik nomidan imzo qo'ymaydi:
 * bu komponentda hech qanday yuklash, chizish yoki "paste signature"
 * maydoni yo'q — dizayndagi `Paste driver signature here` formasi olib
 * tashlangan. Faqat mavjud kalitning tasviri (yoki "not signed") ko'rsatiladi.
 */
import { useTranslation } from 'react-i18next';

import { resolveStorageUrl } from '@/lib/storage';

export interface SignatureViewProps {
  label: string;
  signatureKey: string | undefined;
}

export function SignatureView({ label, signatureKey }: SignatureViewProps) {
  const { t } = useTranslation();
  const src = resolveStorageUrl(signatureKey);

  return (
    <figure className="flex flex-col gap-2">
      <figcaption className="text-body-sm text-neutral-500">{label}</figcaption>
      <div className="flex h-24 items-center justify-center rounded-md border border-stroke bg-surface px-3">
        {!signatureKey ? (
          <span className="text-body-sm text-neutral-400">
            {t('dvir.detail.signatures.missing')}
          </span>
        ) : src ? (
          <img src={src} alt={t('dvir.detail.signatures.alt', { label })} className="max-h-20" />
        ) : (
          <span className="break-all text-center text-body-sm text-neutral-500">
            {t('dvir.detail.preview.key', { key: signatureKey })}
          </span>
        )}
      </div>
    </figure>
  );
}
