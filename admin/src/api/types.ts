/**
 * Domen tiplari uchun qulay alias'lar.
 *
 * `schema.d.ts` dagi Go paket prefiksli uzun nomlar
 * (`github_com_devline_onebook-eld_internal_domain_fleet_dto.Unit`)
 * komponentlarda **hech qachon** ko'rinmasligi kerak — faqat shu fayl orqali.
 *
 * ⚠️ BLOKER: `schema.d.ts` hozircha placeholder (swagger spec 401 qaytaradi,
 * `DOCS_TOKEN` kerak). Shu sababli quyidagi alias'lar `unknown` ga yechiladi.
 * `npm run api` haqiqiy sxemani generatsiya qilgach, `DTO_PREFIX` ostidagi
 * nomlar spec bilan solishtiriladi va qolgan domen tiplari shu yerga qo'shiladi.
 */
import type { components, paths } from './schema';

export type { paths };

type Schemas = components['schemas'];

/**
 * Sxemadan tipni nomi bo'yicha oladi. Nom hali sxemada bo'lmasa (placeholder
 * holati) `unknown` qaytaradi — bu kompilyatsiyani buzmaydi, ammo `any` ham emas.
 */
export type Schema<K extends string> = K extends keyof Schemas ? Schemas[K] : unknown;

/** Barcha DTO tiplarining Go paket prefiksi. */
type Dto<
  D extends string,
  T extends string,
> = Schema<`github_com_devline_onebook-eld_internal_domain_${D}_dto.${T}`>;

/* ------------------------------------------------------------------ *
 * Umumiy konvertlar
 * ------------------------------------------------------------------ */

/** Ro'yxat javobidagi `meta` bloki: `{ page, per_page, total }`. */
export type ListMeta = Dto<'auth', 'Meta'>;

/** Ro'yxat javobi konverti. */
export interface ListResponse<T> {
  data: T[];
  meta: ListMeta;
}

/** Ruxsat etilgan sahifa hajmlari (boshqa qiymat yuborilmaydi). */
export type PerPage = 10 | 25 | 50;

/** Saralash yo'nalishi. */
export type SortOrder = 'asc' | 'desc';

/** Barcha ro'yxat ekranlari uchun umumiy query parametrlari. */
export interface ListParams {
  page?: number;
  per_page?: PerPage;
  sort?: string;
  order?: SortOrder;
  search?: string;
}

/* ------------------------------------------------------------------ *
 * Auth
 * ------------------------------------------------------------------ */

export type LoginResponse = Dto<'auth', 'LoginResponse'>;
export type TokensEnvelope = Dto<'auth', 'TokensEnvelope'>;
export type SessionInfo = Dto<'auth', 'Session'>;
export type Me = Dto<'auth', 'Me'>;
export type User = Dto<'auth', 'User'>;
export type Company = Dto<'auth', 'Company'>;

/* ------------------------------------------------------------------ *
 * Fleet
 * ------------------------------------------------------------------ */

export type Unit = Dto<'fleet', 'Unit'>;
export type Trailer = Dto<'fleet', 'Trailer'>;
export type EldDevice = Dto<'fleet', 'EldDevice'>;

/* ------------------------------------------------------------------ *
 * Drivers
 * ------------------------------------------------------------------ */

export type Driver = Dto<'drivers', 'Driver'>;

/* ------------------------------------------------------------------ *
 * Qolgan domenlar (logs, dvir, maintenance, tracking, routes, reports,
 * chat, support, settings, audit) — `npm run api` dan keyin qo'shiladi.
 * Nomlash qoidasi: `export type X = Dto<'<domen>', '<DtoNomi>'>;`
 * ------------------------------------------------------------------ */
