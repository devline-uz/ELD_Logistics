/**
 * Nuqson fotolari uchun lightbox (5.3) — `Modal` ustida qurilgan, shuning
 * uchun fokus tuzoq, `Esc` va `aria-modal` tayyor (fe-a11y §1).
 *
 * `←`/`→` bilan fotolar orasida yurish mumkin. Foto manbai — obyekt-saqlash
 * kaliti; ko'rish URL'i `resolveStorageUrl` orqali olinadi va mavjud
 * bo'lmasa kalitning o'zi matn sifatida ko'rsatiladi (`storage.ts` izohi).
 */
import { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { ChevronLeft, ChevronRight } from 'lucide-react';

import { IconButton } from '@/components/ui/IconButton';
import { Modal } from '@/components/ui/Modal';

import { resolveStorageUrl } from '@/lib/storage';

export interface PhotoLightboxProps {
  open: boolean;
  onClose: () => void;
  /** Obyekt-saqlash kalitlari (≤ 5 — fe-api §8). */
  photoKeys: string[];
  /** Ochilishda ko'rsatiladigan foto indeksi. */
  initialIndex: number;
  /** Skrin-rider uchun kontekst (nuqson nomi). */
  defectName: string;
}

export function PhotoLightbox({
  open,
  onClose,
  photoKeys,
  initialIndex,
  defectName,
}: PhotoLightboxProps) {
  const { t } = useTranslation();
  const [index, setIndex] = useState(initialIndex);

  useEffect(() => {
    if (open) setIndex(initialIndex);
  }, [open, initialIndex]);

  const total = photoKeys.length;
  const key = photoKeys[index];
  const src = resolveStorageUrl(key);

  const go = (delta: number) => {
    if (total === 0) return;
    setIndex((prev) => (prev + delta + total) % total);
  };

  useEffect(() => {
    if (!open) return undefined;
    const onKeyDown = (event: KeyboardEvent) => {
      if (event.key === 'ArrowLeft') go(-1);
      if (event.key === 'ArrowRight') go(1);
    };
    window.addEventListener('keydown', onKeyDown);
    return () => window.removeEventListener('keydown', onKeyDown);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [open, total]);

  return (
    <Modal open={open} onClose={onClose} title={t('dvir.lightbox.title')} size="xl">
      <div className="flex flex-col gap-3">
        <div className="flex items-center gap-3">
          <IconButton
            icon={ChevronLeft}
            aria-label={t('dvir.lightbox.previous')}
            onClick={() => go(-1)}
            disabled={total < 2}
          />
          <div className="flex min-h-[16rem] flex-1 items-center justify-center rounded-lg bg-neutral-100 p-2">
            {src ? (
              <img
                src={src}
                alt={t('dvir.detail.defects.photoAlt', { index: index + 1, name: defectName })}
                className="max-h-[60vh] w-auto"
              />
            ) : (
              <div className="p-6 text-center">
                <p className="text-body text-neutral-600">{t('dvir.detail.preview.unavailable')}</p>
                <p className="mt-1 break-all text-body-sm text-neutral-600">
                  {t('dvir.detail.preview.key', { key })}
                </p>
              </div>
            )}
          </div>
          <IconButton
            icon={ChevronRight}
            aria-label={t('dvir.lightbox.next')}
            onClick={() => go(1)}
            disabled={total < 2}
          />
        </div>
        <p className="text-center text-body-sm text-neutral-600" aria-live="polite">
          {t('dvir.lightbox.position', { current: index + 1, total })}
        </p>
      </div>
    </Modal>
  );
}
