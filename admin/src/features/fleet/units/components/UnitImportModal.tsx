/**
 * Unit import modal (2.3, `docs/tz/07-3-fleet.md` §7.3.3, F83). Umumiy
 * `ImportModal` (`components/data/`) ustidan yupqa moslama — bosqich 2
 * ko'rigi B2 (Units/Drivers import oqimi umumiylashtirildi).
 */
import { useUnitsImport, useUnitsImportTemplate } from '@/api/queries/units';
import { ImportModal } from '@/components/data/ImportModal';

export interface UnitImportModalProps {
  open: boolean;
  onClose: () => void;
}

export function UnitImportModal({ open, onClose }: UnitImportModalProps) {
  const template = useUnitsImportTemplate();
  const importMutation = useUnitsImport();

  return (
    <ImportModal
      open={open}
      onClose={onClose}
      i18nNamespace="fleet.units.import"
      filenamePrefix="unit"
      onDownloadTemplate={(format) => template.mutateAsync({ format })}
      isTemplatePending={template.isPending}
      onImport={(file) => importMutation.mutateAsync(file)}
      isImportPending={importMutation.isPending}
    />
  );
}

export default UnitImportModal;
