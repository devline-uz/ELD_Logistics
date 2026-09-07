/**
 * `DutyGrid`/`HosRings` — barcha matnlar props orqali keladi (komponentlar
 * o'zi i18n import qilmaydi, `components/logs/types.ts`). Bu fayl `t()`dan
 * kerakli shakllarni quradi — bir joyda, ikkala ekran (Log view) ham shu
 * yerdan foydalanadi.
 */
import type { TFunction } from 'i18next';

import type { DutyGridLabels, HosRingsLabels } from '@/components/logs/types';

export function buildDutyGridLabels(t: TFunction): DutyGridLabels {
  return {
    statusRow: {
      OFF: t('logs.dutyGrid.status.off'),
      SB: t('logs.dutyGrid.status.sb'),
      DR: t('logs.dutyGrid.status.dr'),
      ON: t('logs.dutyGrid.status.on'),
    },
    special: {
      pc: t('logs.dutyGrid.special.pc'),
      ym: t('logs.dutyGrid.special.ym'),
    },
    eventType: {
      pti: t('logs.dutyGrid.event.pti'),
      fuel: t('logs.dutyGrid.event.fuel'),
      certify: t('logs.dutyGrid.event.certify'),
      malfunction: t('logs.dutyGrid.event.malfunction'),
    },
    total: t('logs.dutyGrid.total'),
    gridAriaLabel: t('logs.dutyGrid.gridAriaLabel'),
    segmentsTableCaption: t('logs.dutyGrid.segmentsTableCaption'),
    columnStatus: t('logs.dutyGrid.columns.status'),
    columnFrom: t('logs.dutyGrid.columns.from'),
    columnTo: t('logs.dutyGrid.columns.to'),
    columnDuration: t('logs.dutyGrid.columns.duration'),
    columnNote: t('logs.dutyGrid.columns.note'),
    eventsTableCaption: t('logs.dutyGrid.eventsTableCaption'),
    columnEvent: t('logs.dutyGrid.columns.event'),
    columnTime: t('logs.dutyGrid.columns.time'),
    emptyState: t('logs.dutyGrid.emptyState'),
  };
}

export function buildHosRingsLabels(t: TFunction): HosRingsLabels {
  return {
    unknown: t('logs.hos.unknown'),
    nearLimit: t('logs.hos.nearLimit'),
    exceeded: t('logs.hos.exceeded'),
    remainingSuffix: t('logs.hos.remainingSuffix'),
  };
}
