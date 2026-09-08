import type { ReactNode } from 'react';
import { Link } from 'react-router-dom';

import { KpiCard, type KpiCardProps } from '@/components/ui/KpiCard';

export interface KpiCardLinkProps extends KpiCardProps {
  to: string;
  /** Skrin-rider uchun havolaning to'liq maqsadi (§7.2 "Bosilganda"). */
  ariaLabel: string;
  icon?: ReactNode;
}

/**
 * `KpiCard` — bosilganda tegishli filtrlangan ro'yxatga o'tadi (§7.2, 9 KPI
 * kartasi jadvalidagi "Bosilganda" ustuni). `KpiCard`ning o'zi domenni
 * bilmaydi (fe-design-system §6) — havola xatti-harakati shu wrapper'da.
 */
export function KpiCardLink({ to, ariaLabel, ...cardProps }: KpiCardLinkProps) {
  return (
    <Link
      to={to}
      aria-label={ariaLabel}
      className="block rounded-xl focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary focus-visible:ring-offset-2"
    >
      <KpiCard {...cardProps} />
    </Link>
  );
}

export default KpiCardLink;
