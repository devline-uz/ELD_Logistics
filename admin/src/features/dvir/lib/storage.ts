/**
 * Obyekt-saqlash **kaliti** → ko'rsatish uchun URL.
 *
 * ⚠️ Backendda kalitni o'qish uchun endpoint **yo'q**: `POST /files/presign`
 * faqat yuklash (`PUT`) URL'ini beradi, `GET /files/{key}` yoki presigned
 * `GET` yo'q (swagger `/files/*` bo'yicha yagona operatsiya — presign).
 * Shuning uchun DVIR fotolari va imzolari `VITE_FILES_BASE_URL` o'rnatilgan
 * muhitda ko'rsatiladi, aks holda UI kalitni matn sifatida va "preview
 * unavailable" izohini ko'rsatadi (rasm o'rniga bo'sh kvadrat emas).
 *
 * §16 reestriga nomzod: «DVIR foto/imzo kalitlari uchun o'qish endpointi yo'q».
 */
const FILES_BASE_URL: string | undefined =
  typeof import.meta.env.VITE_FILES_BASE_URL === 'string'
    ? import.meta.env.VITE_FILES_BASE_URL
    : undefined;

/**
 * Kalitdan ko'rsatish URL'i; baza URL bo'lmasa `undefined`.
 *
 * Kalit backenddan keladi, lekin `<img src>` ga to'g'ridan-to'g'ri berilmaydi
 * (fe-security §2 — URL injection):
 * - absolyut qiymat faqat `https:` bo'lsa qabul qilinadi (`javascript:`,
 *   `data:`, `blob:`, `http:` — rad etiladi);
 * - nisbiy kalitda `..` segmenti bo'lsa rad etiladi (baza URL'idan chiqib
 *   ketishning oldini olish).
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
