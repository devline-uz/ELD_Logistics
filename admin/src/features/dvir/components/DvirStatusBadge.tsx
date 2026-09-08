/** DVIR holati badge'i — **6 holat** (F106); rang yagona ma'no manbai emas. */
import { useTranslation } from 'react-i18next';

import { Badge } from '@/components/ui/Badge';

import { dvirStatusKey, dvirStatusTone, type DvirStatus } from '../lib/status';

export interface DvirStatusBadgeProps {
  status: DvirStatus | undefined;
}

export function DvirStatusBadge({ status }: DvirStatusBadgeProps) {
  const { t } = useTranslation();
  return <Badge tone={dvirStatusTone(status)}>{t(dvirStatusKey(status))}</Badge>;
}
