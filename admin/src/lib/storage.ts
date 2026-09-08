/**
 * Obyekt-saqlash **kaliti** → ko'rsatish uchun URL (fe-api §8).
 *
 * ⚠️ Backendda kalitni o'qish uchun endpoint **yo'q**: `POST /files/presign`
 * faqat yuklash (`PUT`) URL'ini beradi, `GET /files/{key}` yoki presigned
 * `GET` yo'q. Shuning uchun fayllar `VITE_FILES_BASE_URL` o'rnatilgan muhitda
 * ko'rsatiladi, aks holda UI kalitni matn sifatida ko'rsatadi.
 *
 * Kanonik nusxa `src/lib/` da: ilgari `features/dvir/lib/storage.ts` va
 * `features/chat/lib/storage.ts` da ikki nusxa bor edi (modullar orasida
 * import taqiqlangani sabab).
 */
const FILES_BASE_URL: string | undefined =
  typeof import.meta.env.VITE_FILES_BASE_URL === 'string'
    ? import.meta.env.VITE_FILES_BASE_URL
    : undefined;

/**
 * Kalitdan ko'rsatish URL'i; baza URL bo'lmasa `undefined`.
 *
 * Kalit backenddan keladi, lekin `<img src>`/havolaga to'g'ridan-to'g'ri
 * berilmaydi (fe-security §2, §12):
 * - absolyut qiymat faqat `https:` bo'lsa qabul qilinadi (`javascript:`,
 *   `data:`, `blob:`, `http:` — rad etiladi);
 * - nisbiy kalitda `..` segmenti bo'lsa rad etiladi.
 */
export function resolveStorageUrl(key: string | undefined): string | undefined {
  if (!key) return undefined;

  if (/^[a-z][a-z0-9+.-]*:/i.test(key)) {
    try {
      const absolute = new URL(key);
      return absolute.protocol === 'https:' ? absolute.toString() : undefined;
    } catch {
      return undefined;
    }
  }

  if (!FILES_BASE_URL) return undefined;
  const normalized = key.replace(/^\/+/, '');
  if (normalized.split('/').includes('..')) return undefined;
  return `${FILES_BASE_URL.replace(/\/+$/, '')}/${normalized}`;
}

/** Kalitning oxirgi segmenti — server hech qanday fayl nomini saqlamaydi (§17 D36). */
export function storageFileNameFromKey(key: string | undefined): string {
  if (!key) return '';
  const segments = key.split('/');
  return segments[segments.length - 1] || key;
}

/** Inson o'qiy oladigan hajm — `FileUpload` va chat biriktirmalari uchun yagona yaxlitlash. */
export function formatFileSize(bytes: number | undefined): string | undefined {
  if (bytes === undefined || !Number.isFinite(bytes)) return undefined;
  if (bytes < 1024) return `${bytes} B`;
  const kb = bytes / 1024;
  if (kb < 1024) return `${kb.toFixed(0)} KB`;
  return `${(kb / 1024).toFixed(1)} MB`;
}
