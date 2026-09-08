/**
 * Distance by Region / IFTA — "Generate" modali (7.8.2), `ExportJobModal` ustiga qurilgan.
 *
 * Maydonlar: `GET BY` (`regions_and_units|regions_only`) · `Units *` (faqat
 * `regions_and_units` rejimida — shartli maydon) · `Quarter *` · `Year *`.
 *
 * **D31.4 (backend bo'shlig'i):** spetsifikatsiyadagi `Regions *` ko'p-tanlov maydoni
 * `ExportParams`da yo'q (`distance_by_region` uchun faqat `mode/quarter/year/unit_ids`
 * qabul qilinadi) — maydon olib tashlangan, o'rniga eksport butun davr uchun ishlashini
 * tushuntiruvchi eslatma ko'rsatiladi (`docs/tz/16-17-…` D31).
 */
import { useEffect, useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';

import type { ExportJob } from '@/api/types';
import { Alert } from '@/components/feedback/Alert';
import { MultiSelect, type MultiSelectOption } from '@/components/ui/MultiSelect';
import { Select, type SelectOption } from '@/components/ui/Select';

import { ExportJobModal } from './ExportJobModal';
import type { DistanceReportMode } from './DistanceByRegionTable';
import { buildYearOptions, QUARTER_OPTIONS } from '../lib/reportFilters';

const MODE_OPTIONS: DistanceReportMode[] = ['regions_and_units', 'regions_only'];

export interface DistanceReportGenerateModalProps {
  open: boolean;
  onClose: () => void;
  defaultQuarter: number;
  defaultYear: number;
  defaultMode: DistanceReportMode;
  unitOptions: readonly MultiSelectOption[];
  onJobDone?: (job: ExportJob) => void;
}

export function DistanceReportGenerateModal({
  open,
  onClose,
  defaultQuarter,
  defaultYear,
  defaultMode,
  unitOptions,
  onJobDone,
}: DistanceReportGenerateModalProps) {
  const { t } = useTranslation();
  const [mode, setMode] = useState<DistanceReportMode>(defaultMode);
  const [unitIds, setUnitIds] = useState<string[]>([]);
  const [quarter, setQuarter] = useState<string>(String(defaultQuarter));
  const [year, setYear] = useState<string>(String(defaultYear));

  useEffect(() => {
    if (open) {
      setMode(defaultMode);
      setUnitIds([]);
      setQuarter(String(defaultQuarter));
      setYear(String(defaultYear));
    }
  }, [open, defaultMode, defaultQuarter, defaultYear]);

  const modeOptions: SelectOption<DistanceReportMode>[] = MODE_OPTIONS.map((value) => ({
    value,
    label: t(`reports.distanceByRegion.generateModal.modeOptions.${value}`),
  }));

  const yearOptions = useMemo(() => buildYearOptions(), []);

  const generateDisabled = mode === 'regions_and_units' && unitIds.length === 0;

  return (
    <ExportJobModal
      open={open}
      onClose={onClose}
      type="distance_by_region"
      titleKey="reports.distanceByRegion.generateModal.title"
      formats={['csv', 'xlsx', 'pdf']}
      generateDisabled={generateDisabled}
      generateDisabledReason={t('reports.distanceByRegion.generateModal.unitsRequired')}
      params={{
        mode,
        quarter: Number(quarter),
        year: Number(year),
        unit_ids: mode === 'regions_and_units' ? unitIds : undefined,
      }}
      onJobDone={onJobDone}
    >
      <div className="flex flex-col gap-4">
        <Alert variant="info" message={t('reports.distanceByRegion.generateModal.regionsNote')} />

        <Select
          label={t('reports.distanceByRegion.generateModal.getBy')}
          required
          value={mode}
          onChange={(value) => value && setMode(value)}
          options={modeOptions}
        />

        {mode === 'regions_and_units' ? (
          <MultiSelect
            label={t('reports.distanceByRegion.generateModal.units')}
            placeholder={t('reports.distanceByRegion.generateModal.unitsPlaceholder')}
            required
            searchable
            selectAll
            values={unitIds}
            onChange={setUnitIds}
            options={unitOptions}
          />
        ) : null}

        <div className="grid grid-cols-2 gap-4">
          <Select
            label={t('reports.distanceByRegion.generateModal.quarter')}
            required
            value={quarter}
            onChange={(value) => value && setQuarter(value)}
            options={QUARTER_OPTIONS}
          />
          <Select
            label={t('reports.distanceByRegion.generateModal.year')}
            required
            value={year}
            onChange={(value) => value && setYear(value)}
            options={yearOptions}
          />
        </div>
      </div>
    </ExportJobModal>
  );
}

export default DistanceReportGenerateModal;
