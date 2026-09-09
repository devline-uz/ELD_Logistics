/**
 * Fayl yuklash — presign oqimi (fe-api §8).
 *
 *   1. `onPresign({ kind, content_type, size_bytes, filename })`
 *      → `{ upload_url, method, key, headers, max_bytes, expires_at }`
 *   2. `PUT <upload_url>` — XHR orqali (progress uchun; `fetch` bermaydi)
 *   3. Muvaffaqiyatda `onUploaded({ key, filename, size, contentType })`
 *      chaqiriladi — domen endpointiga `key` yuborish chaqiruvchining ishi.
 *
 * Komponent domenni bilmaydi: qaysi endpoint `key`ni qabul qilishini,
 * qanday saqlashini bilmaydi — faqat `kind` bo'yicha oq ro'yxatga (fe-api §8
 * jadvali) va presign javobidagi `max_bytes`ga tayanadi.
 */
import { useCallback, useId, useRef, useState, type DragEvent } from 'react';
import { useTranslation } from 'react-i18next';
import { UploadCloud, X } from 'lucide-react';

import type { PresignResponse } from '@/api/types';
import { Icon } from '@/components/ui/Icon';
import { Button } from '@/components/ui/Button';
import { Spinner } from '@/components/feedback/Spinner';
import { formatFileSize } from '@/lib/storage';
import { checkUploadTarget, sanitizeUploadHeaders } from '@/lib/upload-url';

/** Backend `kind` enum'i (fe-api §8 oq ro'yxati). */
export type FileUploadKind = 'dvir_photo' | 'invoice' | 'signature' | 'logo' | 'chat' | 'import';

/**
 * `kind` bo'yicha MIME + kengaytma + hajm cheklovi (fe-security §12 — MIME
 * **va** kengaytma ikkalasi tekshiriladi; `file.type` brauzer taxmini bo'lib,
 * uni o'zgartirish oson). Haqiqiy hajm chegarasi presign javobidagi
 * `max_bytes` bilan qayta tasdiqlanadi.
 */
const KIND_RULES: Record<
  FileUploadKind,
  { accept: string[]; extensions: string[]; maxBytes: number }
> = {
  dvir_photo: {
    accept: ['image/jpeg', 'image/png'],
    extensions: ['.jpg', '.jpeg', '.png'],
    maxBytes: 5 * 1024 * 1024,
  },
  invoice: {
    accept: ['application/pdf', 'image/jpeg', 'image/png'],
    extensions: ['.pdf', '.jpg', '.jpeg', '.png'],
    maxBytes: 10 * 1024 * 1024,
  },
  signature: { accept: ['image/png'], extensions: ['.png'], maxBytes: 1 * 1024 * 1024 },
  logo: {
    accept: ['image/png', 'image/jpeg', 'image/svg+xml'],
    extensions: ['.png', '.jpg', '.jpeg', '.svg'],
    maxBytes: 2 * 1024 * 1024,
  },
  chat: {
    accept: ['image/*', 'application/pdf'],
    extensions: ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.pdf'],
    maxBytes: 10 * 1024 * 1024,
  },
  import: {
    accept: ['text/csv', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'],
    extensions: ['.csv', '.xlsx'],
    maxBytes: 10 * 1024 * 1024,
  },
};

export interface FileUploadResult {
  key: string;
  filename: string;
  size: number;
  contentType: string;
}

export interface FileUploadProps {
  kind: FileUploadKind;
  label: string;
  description?: string;
  disabled?: boolean;
  onPresign: (input: {
    kind: FileUploadKind;
    content_type: string;
    size_bytes: number;
    filename?: string;
  }) => Promise<PresignResponse>;
  onUploaded: (result: FileUploadResult) => void;
  onError?: (message: string) => void;
  className?: string;
}

type UploadState =
  | { status: 'idle' }
  | { status: 'uploading'; filename: string; size: number; progress: number }
  | { status: 'done'; filename: string; size: number }
  | { status: 'error'; filename?: string; message: string };

function matchesAccept(file: File, patterns: string[]): boolean {
  return patterns.some((pattern) => {
    if (pattern.endsWith('/*')) return file.type.startsWith(pattern.slice(0, -1));
    return file.type === pattern;
  });
}

/** Kengaytma oq ro'yxati — `file.type` bilan bir vaqtda tekshiriladi. */
function matchesExtension(file: File, extensions: string[]): boolean {
  const lower = file.name.toLowerCase();
  return extensions.some((extension) => lower.endsWith(extension));
}

/** `lib/storage.ts` dagi yagona yaxlitlash — bu yerda `undefined` bo'lmaydi. */
function formatBytes(bytes: number): string {
  return formatFileSize(bytes) ?? '';
}

/**
 * `PUT` to'g'ridan-to'g'ri storage'ga — XHR bilan progress uchun (F13 istisnosi).
 *
 * Manzil va header'lar bu yerga **tekshirilgan holda** keladi
 * (`checkUploadTarget` / `sanitizeUploadHeaders`) — presign javobi ishonchli
 * manba emas (fe-security §2, §12).
 */
function uploadViaXhr(
  target: { url: string; method: 'PUT' | 'POST' },
  headers: Record<string, string>,
  file: File,
  onProgress: (percent: number) => void,
): { promise: Promise<void>; abort: () => void } {
  const xhr = new XMLHttpRequest();
  const promise = new Promise<void>((resolve, reject) => {
    xhr.open(target.method, target.url, true);

    for (const [name, value] of Object.entries(headers)) {
      xhr.setRequestHeader(name, value);
    }

    xhr.upload.addEventListener('progress', (event) => {
      if (event.lengthComputable) onProgress(Math.round((event.loaded / event.total) * 100));
    });

    xhr.addEventListener('load', () => {
      if (xhr.status >= 200 && xhr.status < 300) resolve();
      else reject(new Error(`Upload failed (${xhr.status})`));
    });
    xhr.addEventListener('error', () => reject(new Error('Network error during upload')));
    xhr.addEventListener('abort', () => reject(new Error('aborted')));

    xhr.send(file);
  });

  return { promise, abort: () => xhr.abort() };
}

export function FileUpload({
  kind,
  label,
  description,
  disabled,
  onPresign,
  onUploaded,
  onError,
  className,
}: FileUploadProps) {
  const { t } = useTranslation();
  const inputId = useId();
  const [state, setState] = useState<UploadState>({ status: 'idle' });
  const [isDragOver, setIsDragOver] = useState(false);
  const abortRef = useRef<(() => void) | null>(null);
  const rules = KIND_RULES[kind];

  const validate = useCallback(
    (file: File): string | undefined => {
      if (!matchesAccept(file, rules.accept) || !matchesExtension(file, rules.extensions)) {
        return t('ui.data.fileUpload.errors.invalidType', { types: rules.accept.join(', ') });
      }
      if (file.size > rules.maxBytes) {
        return t('ui.data.fileUpload.errors.tooLarge', { max: formatBytes(rules.maxBytes) });
      }
      return undefined;
    },
    [rules, t],
  );

  const startUpload = useCallback(
    async (file: File) => {
      const validationError = validate(file);
      if (validationError) {
        setState({ status: 'error', filename: file.name, message: validationError });
        onError?.(validationError);
        return;
      }

      setState({ status: 'uploading', filename: file.name, size: file.size, progress: 0 });

      try {
        const presign = await onPresign({
          kind,
          content_type: file.type,
          size_bytes: file.size,
          filename: file.name,
        });

        if (presign.max_bytes && file.size > presign.max_bytes) {
          const message = t('ui.data.fileUpload.errors.tooLarge', {
            max: formatBytes(presign.max_bytes),
          });
          setState({ status: 'error', filename: file.name, message });
          onError?.(message);
          return;
        }

        // Presign javobi ishonchli manba emas: sxema/metod/host tekshiriladi,
        // header'lar oq ro'yxat bo'yicha filtrlanadi (fe-security §2, §12).
        const target = checkUploadTarget(presign.upload_url, presign.method);
        if (!target.ok) {
          const message = t('ui.data.fileUpload.errors.uploadFailed');
          setState({ status: 'error', filename: file.name, message });
          onError?.(message);
          return;
        }
        const headers = sanitizeUploadHeaders(presign.headers, file.type);

        const { promise, abort } = uploadViaXhr(target, headers, file, (progress) => {
          setState((prev) => (prev.status === 'uploading' ? { ...prev, progress } : prev));
        });
        abortRef.current = abort;

        await promise;
        abortRef.current = null;

        setState({ status: 'done', filename: file.name, size: file.size });
        onUploaded({
          key: presign.key ?? '',
          filename: file.name,
          size: file.size,
          contentType: file.type,
        });
      } catch (cause) {
        abortRef.current = null;
        const wasAborted = cause instanceof Error && cause.message === 'aborted';
        const message = wasAborted
          ? t('ui.data.fileUpload.cancelled')
          : t('ui.data.fileUpload.errors.uploadFailed');
        setState({ status: 'error', filename: file.name, message });
        if (!wasAborted) onError?.(message);
      }
    },
    [kind, onError, onPresign, onUploaded, t, validate],
  );

  const handleFiles = useCallback(
    (files: FileList | null) => {
      const file = files?.[0];
      if (file) void startUpload(file);
    },
    [startUpload],
  );

  const handleCancel = useCallback(() => {
    abortRef.current?.();
    abortRef.current = null;
  }, []);

  const handleRetry = useCallback(() => setState({ status: 'idle' }), []);

  const handleDrop = useCallback(
    (event: DragEvent<HTMLDivElement>) => {
      event.preventDefault();
      setIsDragOver(false);
      if (disabled) return;
      handleFiles(event.dataTransfer.files);
    },
    [disabled, handleFiles],
  );

  const isBusy = state.status === 'uploading';

  return (
    <div className={className}>
      <label htmlFor={inputId} className="mb-1 block text-body font-medium text-neutral-700">
        {label}
      </label>
      {description ? <p className="mb-1 text-body-sm text-neutral-600">{description}</p> : null}

      <div
        role="presentation"
        onDragOver={(event) => {
          event.preventDefault();
          if (!disabled) setIsDragOver(true);
        }}
        onDragLeave={() => setIsDragOver(false)}
        onDrop={handleDrop}
        className={`flex flex-col items-center justify-center gap-2 rounded-lg border border-dashed p-6 text-center transition-colors ${
          isDragOver ? 'border-primary bg-light' : 'border-stroke bg-surface'
        } ${disabled ? 'opacity-60' : ''}`}
        aria-busy={isBusy}
      >
        <Icon icon={UploadCloud} size={24} className="text-neutral-400" />

        <input
          id={inputId}
          type="file"
          className="sr-only"
          accept={rules.accept.join(',')}
          disabled={disabled || isBusy}
          onChange={(event) => handleFiles(event.target.files)}
        />

        <p className="text-body-sm text-neutral-600">{t('ui.data.fileUpload.dragHint')}</p>
        <Button
          type="button"
          variant="secondary"
          size="sm"
          disabled={disabled || isBusy}
          onClick={() => document.getElementById(inputId)?.click()}
        >
          {t('ui.data.fileUpload.browse')}
        </Button>

        {state.status === 'uploading' ? (
          <div className="mt-2 flex w-full flex-col items-center gap-1">
            <div className="flex items-center gap-2">
              <Spinner size="sm" />
              <span className="text-body-sm text-neutral-700">
                {state.filename} ({formatBytes(state.size)})
              </span>
            </div>
            <div
              role="progressbar"
              aria-valuenow={state.progress}
              aria-valuemin={0}
              aria-valuemax={100}
              className="h-2 w-full max-w-xs overflow-hidden rounded-full bg-neutral-200"
            >
              <div
                className="h-full rounded-full bg-primary transition-all"
                style={{ width: `${state.progress}%` }}
              />
            </div>
            <Button type="button" variant="ghost" size="sm" onClick={handleCancel}>
              <Icon icon={X} size={14} />
              {t('common.actions.cancel')}
            </Button>
          </div>
        ) : null}

        {state.status === 'done' ? (
          <p role="status" className="text-body-sm text-success-dark">
            {t('ui.data.fileUpload.done', { filename: state.filename })}
          </p>
        ) : null}

        {state.status === 'error' ? (
          <div className="mt-2 flex flex-col items-center gap-2">
            <p role="alert" className="text-body-sm text-error-dark">
              {state.message}
            </p>
            <Button type="button" variant="secondary" size="sm" onClick={handleRetry}>
              {t('common.actions.tryAgain')}
            </Button>
          </div>
        ) : null}
      </div>
    </div>
  );
}
