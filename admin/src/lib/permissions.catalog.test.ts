import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';

import { describe, expect, it } from 'vitest';

import { ALL_PERMISSIONS, type Permission } from '@/lib/permissions';

/**
 * 0.17 — Permission katalogi drift testi.
 *
 * Haqiqat manbai: `admin/openapi/swagger.json` dagi har operatsiyaning
 * `x-permission` maydoni (hujjat ko'rinishi — `docs/api/permissions.md`).
 * Test ikki tomonlama solishtiradi: swagger'da bor-katalogda yo'q = 0 va
 * katalogda bor-swagger'da yo'q = 0.
 *
 * Swagger yangilangach (`npm run api`) bu test qizil bo'lsa — `PERM` ni
 * yangilash kerak, teskarisi emas: backend ustun.
 */

/** `x-permission` ning permission BO'LMAGAN qiymatlari (docs/api/permissions.md). */
const SPECIAL_VALUES = {
  /** Auth talab qilmaydi: login, parol tiklash, invitation, app config. */
  public: 6,
  /** Har qanday tizimga kirgan foydalanuvchi — permission tekshirilmaydi. */
  authenticated: 7,
  /** Alohida bayroq, rol emas (F33) — faqat `/companies*`. */
  super_admin: 4,
} as const;

const SPECIAL_NAMES: readonly string[] = Object.keys(SPECIAL_VALUES);

/**
 * OR mantiq bilan qo'riqlangan endpointlar.
 *
 * swaggo OR sintaksisiga ega emas, shuning uchun swagger faqat bitta kalit
 * ko'rsatadi, backend esa ikkitasini ham qabul qiladi. Ikkala kalit ham
 * katalogda bor, shuning uchun bu istisnolar solishtiruvni buzmaydi — lekin
 * UI ruxsat tekshiruvi bu ekranlarda `can.any([...])` ishlatishi SHART
 * (`can(...)` bitta kalit bilan foydalanuvchini nohaq to'sib qo'yadi).
 */
const OR_GUARDED_ENDPOINTS = [
  {
    method: 'get',
    path: '/unidentified-events',
    inSwagger: 'logs.assign_unidentified',
    alsoAccepted: 'logs.read',
  },
  {
    method: 'get',
    path: '/permissions',
    inSwagger: 'permissions.read',
    alsoAccepted: 'roles.read',
  },
] as const;

interface SwaggerDocument {
  /** `paths[path][method]` — operatsiya obyekti, ba'zilarida `x-permission`. */
  paths: Record<string, Record<string, unknown>>;
}

// Vitest `root` — `admin/` (vite.config.ts yonidagi papka).
const swaggerPath = resolve(process.cwd(), 'openapi/swagger.json');
const swagger = JSON.parse(readFileSync(swaggerPath, 'utf8')) as SwaggerDocument;

interface Operation {
  method: string;
  path: string;
  permission: string;
}

const operations: Operation[] = Object.entries(swagger.paths).flatMap(([path, methods]) =>
  Object.entries(methods).flatMap(([method, operation]) => {
    const permission =
      typeof operation === 'object' && operation !== null
        ? (operation as { 'x-permission'?: unknown })['x-permission']
        : undefined;
    return typeof permission === 'string' ? [{ method, path, permission }] : [];
  }),
);

const swaggerKeys = new Set(
  operations.map((op) => op.permission).filter((value) => !SPECIAL_NAMES.includes(value)),
);
const catalogKeys = new Set<string>(ALL_PERMISSIONS);

const format = (keys: Iterable<string>) => [...keys].sort().join('\n  - ');

describe('permission catalog vs swagger x-permission', () => {
  it('has a permission on every guarded operation', () => {
    expect(operations.length).toBeGreaterThan(0);
  });

  it('lists exactly 104 permission keys', () => {
    expect(swaggerKeys.size).toBe(104);
    expect(catalogKeys.size).toBe(104);
    expect(ALL_PERMISSIONS).toHaveLength(104);
  });

  it('has no key that swagger does not know (catalog → swagger)', () => {
    const stale = [...catalogKeys].filter((key) => !swaggerKeys.has(key));
    expect(
      stale,
      stale.length === 0
        ? ''
        : `PERM da bor, lekin swagger'da yo'q (o'lik kalit — PERM dan olib tashlang):\n  - ${format(stale)}`,
    ).toEqual([]);
  });

  it('covers every key swagger uses (swagger → catalog)', () => {
    const missing = [...swaggerKeys].filter((key) => !catalogKeys.has(key));
    expect(
      missing,
      missing.length === 0
        ? ''
        : `swagger'da bor, lekin PERM da yo'q (src/lib/permissions.ts ga qo'shing):\n  - ${format(missing)}`,
    ).toEqual([]);
  });

  it('keeps the three special values out of the catalog', () => {
    for (const name of SPECIAL_NAMES) {
      expect(catalogKeys.has(name), `\`${name}\` permission emas — PERM da bo'lmasligi kerak`).toBe(
        false,
      );
    }
  });

  it('matches the documented count of special-value operations', () => {
    for (const [name, count] of Object.entries(SPECIAL_VALUES)) {
      const actual = operations.filter((op) => op.permission === name).length;
      expect(actual, `\`x-permission: ${name}\` operatsiyalari soni`).toBe(count);
    }
  });
});

describe('OR-guarded endpoints (swaggo cannot express OR)', () => {
  it.each(OR_GUARDED_ENDPOINTS)(
    '$method $path: swagger says $inSwagger, backend also accepts $alsoAccepted',
    ({ method, path, inSwagger, alsoAccepted }) => {
      const operation = operations.find((op) => op.path === path && op.method === method);
      expect(operation?.permission, `${method.toUpperCase()} ${path} — swagger x-permission`).toBe(
        inSwagger,
      );

      // Ikkala kalit ham katalogda — shuning uchun istisno solishtiruvni buzmaydi.
      expect(catalogKeys.has(inSwagger)).toBe(true);
      expect(catalogKeys.has(alsoAccepted)).toBe(true);

      // UI shu ekranlarda `can.any([a, b])` ishlatadi (bitta kalit bilan emas).
      const pair: Permission[] = [inSwagger, alsoAccepted];
      expect(new Set(pair).size).toBe(2);
    },
  );
});
