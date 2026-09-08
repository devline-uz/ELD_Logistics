/**
 * Server (`VALIDATION_ERROR.details[]`) xatolarini `react-hook-form` maydon
 * xatolariga bog'laydi (fe-screens §2, fe-api §6).
 *
 * `normalizeError`/`ApiError` — `@/lib/errors` da (o'zgartirilmaydi, faqat
 * o'qiladi). Bu yerda faqat `fields` → `setError` ko'chirilishi va noma'lum
 * maydon nomlari uchun forma tepasidagi umumiy xabar hisoblanadi.
 */
import type { FieldValues, Path, UseFormReturn } from 'react-hook-form';

import { isApiError } from '@/lib/errors';

export interface ApplyServerErrorsResult {
  /**
   * Formada mos maydon topilmagan xatolar (yoki `fields` umuman bo'lmagan
   * holatda xom `message`) — sahifa tepasidagi umumiy alert uchun.
   */
  formMessage?: string;
}

/**
 * `error` — mutation'ning `onError` argumenti (odatda `ApiError`).
 * Har bir `fields[key]` formadagi haqiqiy maydon nomi bilan solishtiriladi;
 * mos kelmasa xabar `formMessage`ga yig'iladi (yo'qolib ketmasligi uchun).
 * Birinchi bog'langan maydonga fokus qilinadi va u ko'rinadigan joyga scroll
 * qilinadi.
 */
export function applyServerErrors<TFieldValues extends FieldValues>(
  form: UseFormReturn<TFieldValues>,
  error: unknown,
): ApplyServerErrorsResult {
  if (!isApiError(error)) {
    return { formMessage: error instanceof Error ? error.message : undefined };
  }

  const knownFieldNames = new Set(Object.keys(form.getValues()));
  const fieldEntries = Object.entries(error.fields);

  const unmatched: string[] = [];
  let firstMatchedField: Path<TFieldValues> | undefined;

  for (const [field, message] of fieldEntries) {
    if (knownFieldNames.has(field)) {
      const path = field as Path<TFieldValues>;
      form.setError(path, { type: 'server', message });
      firstMatchedField ??= path;
    } else {
      unmatched.push(message);
    }
  }

  if (firstMatchedField) {
    form.setFocus(firstMatchedField);
    const el = document.querySelector<HTMLElement>(`[name="${String(firstMatchedField)}"]`);
    el?.scrollIntoView({ block: 'center', behavior: 'smooth' });
  }

  if (unmatched.length > 0) {
    return { formMessage: unmatched.join(' ') };
  }

  if (fieldEntries.length === 0) {
    return { formMessage: error.message };
  }

  return {};
}
