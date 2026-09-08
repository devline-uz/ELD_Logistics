/**
 * IANA vaqt mintaqalari — Company/Branch formalari uchun (§7.13.1/§7.13.2:
 * `Timezone * (IANA ro'yxati)`).
 *
 * Backendda katalog endpointi yo'q (`GET /company` faqat joriy qiymatni
 * qaytaradi, tanlov ro'yxati emas) — `Intl.supportedValuesOf('timeZone')`
 * ham loyihaning `tsconfig` `lib` maqsadida (`ES2022`) tip xavfsiz emas va
 * eski brauzerlarda yo'q bo'lishi mumkin. Shu sabab qo'lda tuzilgan, eng ko'p
 * ishlatiladigan mintaqalar ro'yxati beriladi — foydalanuvchi kerakli
 * zonani qidiruv (`searchable`) bilan topadi. `value` har doim haqiqiy IANA
 * identifikatori, backend uni o'zgartirmasdan qabul qiladi.
 */
export interface TimezoneOption {
  value: string;
  label: string;
}

export const TIMEZONE_OPTIONS: readonly TimezoneOption[] = [
  { value: 'UTC', label: 'UTC' },
  { value: 'America/New_York', label: 'America/New_York (Eastern)' },
  { value: 'America/Chicago', label: 'America/Chicago (Central)' },
  { value: 'America/Denver', label: 'America/Denver (Mountain)' },
  { value: 'America/Phoenix', label: 'America/Phoenix (Mountain, no DST)' },
  { value: 'America/Los_Angeles', label: 'America/Los_Angeles (Pacific)' },
  { value: 'America/Anchorage', label: 'America/Anchorage (Alaska)' },
  { value: 'Pacific/Honolulu', label: 'Pacific/Honolulu (Hawaii)' },
  { value: 'America/Toronto', label: 'America/Toronto' },
  { value: 'America/Vancouver', label: 'America/Vancouver' },
  { value: 'America/Winnipeg', label: 'America/Winnipeg' },
  { value: 'America/Halifax', label: 'America/Halifax' },
  { value: 'America/Mexico_City', label: 'America/Mexico_City' },
  { value: 'America/Bogota', label: 'America/Bogota' },
  { value: 'America/Sao_Paulo', label: 'America/Sao_Paulo' },
  { value: 'Europe/London', label: 'Europe/London' },
  { value: 'Europe/Dublin', label: 'Europe/Dublin' },
  { value: 'Europe/Lisbon', label: 'Europe/Lisbon' },
  { value: 'Europe/Madrid', label: 'Europe/Madrid' },
  { value: 'Europe/Paris', label: 'Europe/Paris' },
  { value: 'Europe/Berlin', label: 'Europe/Berlin' },
  { value: 'Europe/Rome', label: 'Europe/Rome' },
  { value: 'Europe/Warsaw', label: 'Europe/Warsaw' },
  { value: 'Europe/Athens', label: 'Europe/Athens' },
  { value: 'Europe/Istanbul', label: 'Europe/Istanbul' },
  { value: 'Europe/Moscow', label: 'Europe/Moscow' },
  { value: 'Africa/Cairo', label: 'Africa/Cairo' },
  { value: 'Africa/Johannesburg', label: 'Africa/Johannesburg' },
  { value: 'Africa/Lagos', label: 'Africa/Lagos' },
  { value: 'Africa/Nairobi', label: 'Africa/Nairobi' },
  { value: 'Asia/Dubai', label: 'Asia/Dubai' },
  { value: 'Asia/Tashkent', label: 'Asia/Tashkent' },
  { value: 'Asia/Almaty', label: 'Asia/Almaty' },
  { value: 'Asia/Karachi', label: 'Asia/Karachi' },
  { value: 'Asia/Kolkata', label: 'Asia/Kolkata' },
  { value: 'Asia/Dhaka', label: 'Asia/Dhaka' },
  { value: 'Asia/Bangkok', label: 'Asia/Bangkok' },
  { value: 'Asia/Jakarta', label: 'Asia/Jakarta' },
  { value: 'Asia/Singapore', label: 'Asia/Singapore' },
  { value: 'Asia/Hong_Kong', label: 'Asia/Hong_Kong' },
  { value: 'Asia/Shanghai', label: 'Asia/Shanghai' },
  { value: 'Asia/Tokyo', label: 'Asia/Tokyo' },
  { value: 'Asia/Seoul', label: 'Asia/Seoul' },
  { value: 'Australia/Perth', label: 'Australia/Perth' },
  { value: 'Australia/Adelaide', label: 'Australia/Adelaide' },
  { value: 'Australia/Sydney', label: 'Australia/Sydney' },
  { value: 'Pacific/Auckland', label: 'Pacific/Auckland' },
];
