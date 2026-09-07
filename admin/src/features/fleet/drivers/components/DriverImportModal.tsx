/**
 * Driver import modal (`docs/tz/07-3-fleet.md` §7.3.3, F83). Umumiy
 * `ImportModal` (`components/data/`) ustidan yupqa moslama — bosqich 2
 * ko'rigi B2: `useDriversImport`/`useDriversImportTemplate` hooklari
 * yozilgan edi, lekin `DriverListPage`da tugma/modal yo'q edi (o'lik kod).
 */
import { useDriversImport, useDriversImportTemplate } from '@/api/queries/drivers';
import { ImportModal } from '@/components/data/ImportModal';

export interface DriverImportModalProps {
  open: boolean;
  onClose: () => void;
}

export function DriverImportModal({ open, onClose }: DriverImportModalProps) {
  const template = useDriversImportTemplate();
  const importMutation = useDriversImport();

  return (
    <ImportModal
      open={open}
      onClose={onClose}
      i18nNamespace="fleetDrivers.import"
      filenamePrefix="driver"
      onDownloadTemplate={(format) => template.mutateAsync({ format })}
      isTemplatePending={template.isPending}
      onImport={(file) => importMutation.mutateAsync(file)}
      isImportPending={importMutation.isPending}
    />
  );
}

export default DriverImportModal;
