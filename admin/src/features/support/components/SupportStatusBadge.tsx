import { useTranslation } from 'react-i18next';

import { Badge } from '@/components/ui/Badge';

import { supportTicketStatusBadgeTone } from '../lib/status';

export interface SupportStatusBadgeProps {
  status: string | undefined;
}

/** `In Progress` display for `in_progress` (F135) — never the raw `snake_case`. */
export function SupportStatusBadge({ status }: SupportStatusBadgeProps) {
  const { t } = useTranslation();

  return (
    <Badge tone={supportTicketStatusBadgeTone(status)}>
      {status ? t(`enums.support_ticket_status.${status}`) : t('common.na')}
    </Badge>
  );
}

export default SupportStatusBadge;
