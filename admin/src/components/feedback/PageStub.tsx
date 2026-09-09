import { useTranslation } from 'react-i18next';

export interface PageStubProps {
  /** Ekran sarlavhasining i18n kaliti (`pages.*.title`). */
  titleKey: string;
  /** Ekran qaysi bosqichda quriladi (`tasks.md`). */
  stage: number;
}

/** Bosqich 0 joy egallovchi ekran — keyingi bosqichda haqiqiy sahifa bilan almashtiriladi. */
export function PageStub({ titleKey, stage }: PageStubProps) {
  const { t } = useTranslation();

  return (
    <section className="flex flex-col gap-2">
      <h1 className="text-xl font-semibold text-neutral-900">{t(titleKey)}</h1>
      <p className="text-sm text-neutral-600">{t('stub.notice', { stage })}</p>
    </section>
  );
}

export default PageStub;
