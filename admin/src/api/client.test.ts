/**
 * `errorMiddleware` — birlik testi (D-f9).
 *
 * `POST /units/import` va `POST /drivers/import` `422`da standart
 * `{error:...}` konverti o'rniga `ImportResultEnvelope`
 * (`{data:{imported,total,errors[]}}`) qaytaradi. `errorMiddleware`
 * `STRUCTURED_ERROR_RESPONSE_PATHS`ga mos so'rovlar uchun butun JSON tanani
 * `ApiError.payload`ga saqlaydi — shu fayl aynan shu xatti-harakatni va boshqa
 * (struktura ro'yxatida bo'lmagan) endpointlar uchun regressiya yo'qligini
 * tekshiradi.
 */
import { describe, expect, it } from 'vitest';

import { isApiError } from '@/lib/errors';

import { errorMiddleware } from './client';

function jsonResponse(body: unknown, status: number): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'Content-Type': 'application/json' },
  });
}

/** `MiddlewareCallbackParams & {response}` ning testda kerakli qismi. */
function callParams(response: Response, schemaPath: string) {
  return {
    request: new Request('https://api.example.test/v1' + schemaPath, { method: 'POST' }),
    schemaPath,
    params: {},
    id: 'test-request',
    options: {} as never,
    response,
  };
}

describe('errorMiddleware — structured 422 (import)', () => {
  it("`/units/import` 422 javobida `ImportResultEnvelope`ni ApiError.payload'ga saqlaydi", async () => {
    const envelope = {
      data: {
        imported: 0,
        total: 2,
        errors: [{ row: 1, field: 'unit_number', message: 'required' }],
      },
    };

    await expect(
      errorMiddleware.onResponse?.(callParams(jsonResponse(envelope, 422), '/units/import')),
    ).rejects.toSatisfy((err: unknown) => {
      if (!isApiError(err)) return false;
      expect(err.status).toBe(422);
      expect(err.payload).toEqual(envelope);
      return true;
    });
  });

  it('`/drivers/import` 422 javobida ham xuddi shunday ishlaydi', async () => {
    const envelope = {
      data: {
        imported: 0,
        total: 1,
        errors: [{ row: 1, field: 'license_no', message: 'required' }],
      },
    };

    await expect(
      errorMiddleware.onResponse?.(callParams(jsonResponse(envelope, 422), '/drivers/import')),
    ).rejects.toSatisfy((err: unknown) => {
      if (!isApiError(err)) return false;
      expect(err.payload).toEqual(envelope);
      return true;
    });
  });
});

describe('errorMiddleware — regressiya (standart {error:...} konverti)', () => {
  it("struktura ro'yxatida bo'lmagan endpoint uchun `payload` `undefined` qoladi, `fields` normal to'ldiriladi", async () => {
    const body = {
      error: {
        code: 'VALIDATION_ERROR',
        message: 'validation failed',
        details: [{ field: 'unit_number', message: 'required' }],
      },
    };

    await expect(
      errorMiddleware.onResponse?.(callParams(jsonResponse(body, 422), '/units')),
    ).rejects.toSatisfy((err: unknown) => {
      if (!isApiError(err)) return false;
      expect(err.payload).toBeUndefined();
      expect(err.code).toBe('VALIDATION_ERROR');
      expect(err.fields).toEqual({ unit_number: 'required' });
      return true;
    });
  });

  it("`response.ok` bo'lsa hech narsa otilmaydi", async () => {
    const result = await errorMiddleware.onResponse?.(
      callParams(new Response(null, { status: 200 }), '/units'),
    );
    expect(result).toBeUndefined();
  });
});
