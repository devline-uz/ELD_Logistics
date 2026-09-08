/**
 * Presign javobining **maqsad manzilini** tekshirish (fe-security §2 — URL
 * injection, §12 — fayl yuklash).
 *
 * `POST /files/presign` javobi ishonchli manba emas: buzilgan yoki buzib
 * kiritilgan javob foydalanuvchi faylini (invoice, imzo, DVIR fotosi)
 * ixtiyoriy hostga jo'natishi mumkin. Shuning uchun XHR ochilishidan **oldin**
 * quyidagilar majburlanadi:
 *
 * - sxema faqat `https:` (dev uchun `http://localhost` / `127.0.0.1` istisno);
 * - metod faqat `PUT` yoki `POST`;
 * - `upload_url` yo'q/noto'g'ri bo'lsa — **xato**, hech qanday fallback yo'q
 *   (`?? ''` bo'sh satr faylni o'z origin'imizga PUT qilardi);
 * - host oq ro'yxati — `VITE_FILES_UPLOAD_HOST` (vergul bilan ajratilgan).
 *   O'zgaruvchi **bo'sh/e'lon qilinmagan bo'lsa host tekshirilmaydi** va
 *   faqat sxema/metod tekshiruvi ishlaydi (muhitlar bo'yicha storage hosti
 *   turlicha; qattiq qiymat kodga yozilmaydi).
 *
 * Header'lar ham oq ro'yxat bo'yicha filtrlanadi: server `Content-Type`siz
 * to'plam qaytarsa validatsiyadan o'tgan `file.type` yo'qolib, saqlashga tur
 * backend ixtiyorida yozilib qolardi.
 */

/** Tekshiruv natijasi — sabab kaliti bilan (i18n chaqiruvchi tomonda). */
export type UploadTargetCheck =
  | { ok: true; url: string; method: 'PUT' | 'POST' }
  | {
      ok: false;
      reason:
        'missing_url' | 'invalid_url' | 'insecure_scheme' | 'host_not_allowed' | 'invalid_method';
    };

const ALLOWED_METHODS = ['PUT', 'POST'] as const;

/** Lokal ishlab chiqish hostlari — faqat ular uchun `http:` qabul qilinadi. */
const LOCAL_HOSTS = new Set(['localhost', '127.0.0.1', '[::1]', '::1']);

/** `VITE_FILES_UPLOAD_HOST` → hostlar to'plami; bo'sh bo'lsa `undefined`. */
export function parseAllowedHosts(raw: string | undefined): Set<string> | undefined {
  const hosts = (raw ?? '')
    .split(',')
    .map((item) => item.trim().toLowerCase())
    .filter((item) => item.length > 0);
  return hosts.length > 0 ? new Set(hosts) : undefined;
}

const ENV_ALLOWED_HOSTS = parseAllowedHosts(
  typeof import.meta.env.VITE_FILES_UPLOAD_HOST === 'string'
    ? import.meta.env.VITE_FILES_UPLOAD_HOST
    : undefined,
);

/**
 * Presign `upload_url` + `method` ni tekshiradi.
 *
 * @param allowedHosts testlar uchun ochiq; berilmasa `VITE_FILES_UPLOAD_HOST`.
 */
export function checkUploadTarget(
  uploadUrl: string | undefined,
  method: string | undefined,
  allowedHosts: Set<string> | undefined = ENV_ALLOWED_HOSTS,
): UploadTargetCheck {
  if (!uploadUrl || uploadUrl.trim().length === 0) return { ok: false, reason: 'missing_url' };

  let parsed: URL;
  try {
    parsed = new URL(uploadUrl);
  } catch {
    return { ok: false, reason: 'invalid_url' };
  }

  const host = parsed.hostname.toLowerCase();
  const isLocal = LOCAL_HOSTS.has(host);
  if (parsed.protocol !== 'https:' && !(parsed.protocol === 'http:' && isLocal)) {
    return { ok: false, reason: 'insecure_scheme' };
  }

  if (allowedHosts && !allowedHosts.has(host) && !isLocal) {
    return { ok: false, reason: 'host_not_allowed' };
  }

  const normalizedMethod = (method ?? 'PUT').toUpperCase();
  if (!ALLOWED_METHODS.includes(normalizedMethod as (typeof ALLOWED_METHODS)[number])) {
    return { ok: false, reason: 'invalid_method' };
  }

  return { ok: true, url: parsed.toString(), method: normalizedMethod as 'PUT' | 'POST' };
}

/** Storage'ga uzatishga ruxsat etilgan header nomlari. */
function isAllowedHeader(name: string): boolean {
  const lower = name.toLowerCase();
  return lower === 'content-type' || lower.startsWith('x-amz-') || lower.startsWith('x-ms-blob-');
}

/**
 * Presign header'larini oq ro'yxat bo'yicha filtrlaydi va `Content-Type` ni
 * **har doim** presign so'roviga yuborilgan `contentType` bilan majburlaydi.
 */
export function sanitizeUploadHeaders(
  headers: Record<string, string> | undefined,
  contentType: string,
): Record<string, string> {
  const result: Record<string, string> = {};
  for (const [name, value] of Object.entries(headers ?? {})) {
    if (
      typeof value === 'string' &&
      isAllowedHeader(name) &&
      name.toLowerCase() !== 'content-type'
    ) {
      result[name] = value;
    }
  }
  result['Content-Type'] = contentType;
  return result;
}
