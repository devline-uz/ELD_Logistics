/**
 * Unit import modal (2.3, `docs/tz/07-3-fleet.md` §7.3.3, F83).
 *
 * Oqim: (1) shablon yuklab olish → (2) fayl tanlash (drag&drop) → (3)
 * yuborish → (4) natija: import bo'lsa muvaffaqiyat, bo'lmasa qator xatolari
 * jadvali (all-or-nothing).
 *
 * ⚠️ `POST /units/import` 422'da standart bo'lmagan konvert qaytaradi
 * (`{data:{imported,total,errors[]}}`), `client.ts`ning `errorMiddleware`si
 * buni `ApiError.payload`ga saqlaydi (`fe-architect` tuzatishi, §16-17 qayd
 * 282-qator). Shu yerda `readImportResultFromError` orqali o'qiladi — agar
 * kelajakda bu tuzatish orqaga qaytsa, faqat umumiy xato xabari ko'rsatiladi
 * (qator jadvali kodi shu bilan bir xil componentda qoladi, ishlab ketadi).
 */
import { useRef, useState, type DragEvent } from 'react';
import { useTranslation } from 'react-i18next';
import { UploadCloud } from 'lucide-react';

import { useUnitsImport, useUnitsImportTemplate } from '@/api/queries/units';
import type { ImportResult, ImportRowError } from '@/api/types';
import { Alert } from '@/components/feedback/Alert';
import { useToast } from '@/components/feedback/toast-context';
import { Button } from '@/components/ui/Button';
import { Icon } from '@/components/ui/Icon';
import { Modal } from '@/components/ui/Modal';
import { isApiError } from '@/lib/errors';

export interface UnitImportModalProps {
  open: boolean;
  onClose: () => void;
}

const MAX_FILE_BYTES = 10 * 1024 * 1024;
const ACCEPTED_TYPES = [
  'text/csv',
  'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
];
const ACCEPTED_EXTENSIONS = ['.csv', '.xlsx'];

function isImportResult(value: unknown): value is ImportResult {
  return typeof value === 'object' && value !== null && 'errors' in value;
}

/** `ApiError.payload` — `{data: ImportResult}` (§16-17: import 422 konvert istisnosi). */
function readImportResultFromError(error: unknown): ImportResult | undefined {
  if (!isApiError(error)) return undefined;
  const payload = error.payload;
  if (typeof payload !== 'object' || payload === null) return undefined;
  const data = (payload as { data?: unknown }).data;
  return isImportResult(data) ? data : undefined;
}

function downloadBlob(blob: Blob, filename: string): void {
  const objectUrl = URL.createObjectURL(blob);
  const anchor = document.createElement('a');
  anchor.href = objectUrl;
  anchor.download = filename;
  document.body.appendChild(anchor);
  anchor.click();
  anchor.remove();
  URL.revokeObjectURL(objectUrl);
}

function errorsToCsv(errors: ImportRowError[]): string {
  const header = 'row,field,message';
  const rows = errors.map(
    (item) =>
      `${item.row ?? ''},"${(item.field ?? '').replace(/"/g, '""')}","${(item.message ?? '').replace(/"/g, '""')}"`,
  );
  return [header, ...rows].join('\n');
}

export function UnitImportModal({ open, onClose }: UnitImportModalProps) {
  const { t } = useTranslation();
  const toast = useToast();
  const template = useUnitsImportTemplate();
  const importMutation = useUnitsImport();
  const inputRef = useRef<HTMLInputElement>(null);

  const [isDragOver, setIsDragOver] = useState(false);
  const [fileError, setFileError] = useState<string | undefined>(undefined);
  const [selectedFile, setSelectedFile] = useState<File | undefined>(undefined);
  const [result, setResult] = useState<ImportResult | undefined>(undefined);
  const [genericError, setGenericError] = useState<string | undefined>(undefined);

  const reset = () => {
    setSelectedFile(undefined);
    setResult(undefined);
    setFileError(undefined);
    setGenericError(undefined);
  };

  const handleClose = () => {
    reset();
    onClose();
  };

  const validateFile = (file: File): string | undefined => {
    const hasValidExtension = ACCEPTED_EXTENSIONS.some((extension) =>
      file.name.toLowerCase().endsWith(extension),
    );
    if (!ACCEPTED_TYPES.includes(file.type) && !hasValidExtension) {
      return t('fleet.units.import.errors.invalidType');
    }
    if (file.size > MAX_FILE_BYTES) {
      return t('fleet.units.import.errors.tooLarge');
    }
    return undefined;
  };

  const handleFiles = (files: FileList | null) => {
    const file = files?.[0];
    if (!file) return;
    const validationError = validateFile(file);
    if (validationError) {
      setFileError(validationError);
      setSelectedFile(undefined);
      return;
    }
    setFileError(undefined);
    setSelectedFile(file);
    setResult(undefined);
    setGenericError(undefined);
  };

  const handleDownloadTemplate = async (format: 'csv' | 'xlsx') => {
    try {
      const blob = await template.mutateAsync({ format });
      downloadBlob(blob, `units-import-template.${format}`);
    } catch {
      toast.show({ variant: 'error', message: t('fleet.units.import.errors.templateFailed') });
    }
  };

  const handleSubmit = async () => {
    if (!selectedFile) return;
    setGenericError(undefined);
    setResult(undefined);
    try {
      const importResult = await importMutation.mutateAsync(selectedFile);
      setResult(importResult);
      if ((importResult.imported ?? 0) > 0 && (importResult.errors?.length ?? 0) === 0) {
        toast.show({
          variant: 'success',
          message: t('fleet.units.import.toast.success', { count: importResult.imported ?? 0 }),
        });
      }
    } catch (error) {
      const rowResult = readImportResultFromError(error);
      if (rowResult) {
        setResult(rowResult);
      } else {
        setGenericError(t('fleet.units.import.errors.genericFailure'));
      }
    }
  };

  const handleDownloadErrors = () => {
    if (!result?.errors || result.errors.length === 0) return;
    const blob = new Blob([errorsToCsv(result.errors)], { type: 'text/csv' });
    downloadBlob(blob, 'units-import-errors.csv');
  };

  const hasErrors = (result?.errors?.length ?? 0) > 0;
  const nothingImported = result !== undefined && (result.imported ?? 0) === 0;

  return (
    <Modal
      open={open}
      onClose={handleClose}
      size="lg"
      title={t('fleet.units.import.title')}
      closeOnBackdrop={!importMutation.isPending}
      footer={
        <>
          <Button variant="secondary" onClick={handleClose}>
            {t('common.actions.close')}
          </Button>
          {!result ? (
            <Button
              onClick={() => void handleSubmit()}
              disabled={!selectedFile}
              loading={importMutation.isPending}
            >
              {t('fleet.units.import.actions.upload')}
            </Button>
          ) : hasErrors ? (
            <Button onClick={() => reset()}>{t('common.actions.tryAgain')}</Button>
          ) : null}
        </>
      }
    >
      <div className="flex flex-col gap-4">
        <div className="flex flex-wrap items-center gap-2">
          <span className="text-body text-neutral-700">
            {t('fleet.units.import.downloadTemplateLabel')}
          </span>
          <Button
            variant="secondary"
            size="sm"
            onClick={() => void handleDownloadTemplate('csv')}
            loading={template.isPending}
          >
            {t('fleet.units.import.actions.downloadCsv')}
          </Button>
          <Button
            variant="secondary"
            size="sm"
            onClick={() => void handleDownloadTemplate('xlsx')}
            loading={template.isPending}
          >
            {t('fleet.units.import.actions.downloadXlsx')}
          </Button>
        </div>

        {!result ? (
          <div
            role="presentation"
            onDragOver={(event: DragEvent<HTMLDivElement>) => {
              event.preventDefault();
              setIsDragOver(true);
            }}
            onDragLeave={() => setIsDragOver(false)}
            onDrop={(event: DragEvent<HTMLDivElement>) => {
              event.preventDefault();
              setIsDragOver(false);
              handleFiles(event.dataTransfer.files);
            }}
            className={`flex flex-col items-center justify-center gap-2 rounded-lg border border-dashed p-6 text-center ${
              isDragOver ? 'border-primary bg-light' : 'border-stroke bg-surface'
            }`}
          >
            <Icon icon={UploadCloud} size={24} className="text-neutral-400" />
            <input
              ref={inputRef}
              type="file"
              className="sr-only"
              id="unit-import-file"
              accept=".csv,.xlsx"
              onChange={(event) => handleFiles(event.target.files)}
            />
            <label htmlFor="unit-import-file" className="sr-only">
              {t('fleet.units.import.fileInputLabel')}
            </label>
            <p className="text-body-sm text-neutral-500">{t('fleet.units.import.dragHint')}</p>
            <Button variant="secondary" size="sm" onClick={() => inputRef.current?.click()}>
              {t('fleet.units.import.actions.browse')}
            </Button>
            {selectedFile ? (
              <p className="text-body-sm text-neutral-700">{selectedFile.name}</p>
            ) : null}
            {fileError ? (
              <p role="alert" className="text-body-sm text-error-dark">
                {fileError}
              </p>
            ) : null}
          </div>
        ) : null}

        {genericError ? <Alert message={genericError} /> : null}

        {result ? (
          <div className="flex flex-col gap-3">
            {nothingImported ? (
              <Alert
                variant="error"
                message={t('fleet.units.import.nothingImported', {
                  count: result.errors?.length ?? 0,
                })}
              />
            ) : (
              <Alert
                variant="success"
                message={t('fleet.units.import.summary', {
                  imported: result.imported ?? 0,
                  total: result.total ?? 0,
                })}
              />
            )}

            {hasErrors ? (
              <div className="flex flex-col gap-2">
                <div className="flex items-center justify-between">
                  <h3 className="text-body font-semibold text-neutral-900">
                    {t('fleet.units.import.errorsTitle')}
                  </h3>
                  <button
                    type="button"
                    onClick={handleDownloadErrors}
                    className="text-body-sm font-medium text-primary hover:underline"
                  >
                    {t('fleet.units.import.actions.downloadErrors')}
                  </button>
                </div>
                <div className="overflow-x-auto rounded-lg border border-stroke">
                  <table className="w-full border-collapse text-body-sm">
                    <thead className="bg-surface-muted">
                      <tr>
                        <th scope="col" className="px-3 py-2 text-start font-medium">
                          {t('fleet.units.import.columns.row')}
                        </th>
                        <th scope="col" className="px-3 py-2 text-start font-medium">
                          {t('fleet.units.import.columns.field')}
                        </th>
                        <th scope="col" className="px-3 py-2 text-start font-medium">
                          {t('fleet.units.import.columns.message')}
                        </th>
                      </tr>
                    </thead>
                    <tbody>
                      {(result.errors ?? []).map((rowError, index) => (
                        <tr
                          key={`${rowError.row}-${rowError.field}-${index}`}
                          className="border-t border-stroke"
                        >
                          <td className="px-3 py-2">{rowError.row}</td>
                          <td className="px-3 py-2">{rowError.field}</td>
                          <td className="px-3 py-2">{rowError.message}</td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </div>
            ) : null}
          </div>
        ) : null}
      </div>
    </Modal>
  );
}

export default UnitImportModal;
