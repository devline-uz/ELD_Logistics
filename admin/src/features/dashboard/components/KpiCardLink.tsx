import type { ReactNode } from 'react';
import { Link } from 'react-router-dom';

import { KpiCard, type KpiCardProps } from '@/components/ui/KpiCard';

export interface KpiCardLinkProps extends KpiCardProps {
  to: string;
  icon?: ReactNode;
}

/**
 * `KpiCard` — bosilganda tegishli filtrlangan ro'yxatga o'tadi (§7.2, 9 KPI
 * kartasi jadvalidagi "Bosilganda" ustuni). `KpiCard`ning o'zi domenni
 * bilmaydi (fe-design-system §6) — havola xatti-harakati shu wrapper'da.
 *
 * Havolaning accessible name'i **ko'rinadigan matndan** (label + qiymat +
 * delta) hosil bo'ladi — `aria-label` bilan almashtirilmaydi, aks holda
 * axe `label-content-name-mismatch` (WCAG 2.5.3) buziladi: ko'rinadigan
 * qiymat/delta matni aria-label ichida yo'q bo'lib qoladi.
 */
export function KpiCardLink({ to, ...cardProps }: KpiCardLinkProps) {
  return (
    <Link
      to={to}
      className="block rounded-xl focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary focus-visible:ring-offset-2"
    >
      <KpiCard {...cardProps} />
    </Link>
  );
}

export default KpiCardLink;
