import { describe, expect, it } from 'vitest';

import {
  ApiError,
  ERROR_I18N_KEYS,
  errorI18nKey,
  isApiError,
  normalizeError,
  normalizeNetworkError,
} from './errors';

function jsonResponse(body: unknown, init: ResponseInit): Response {
  return new Response(JSON.stringify(body), {
    ...init,
    headers: { 'Content-Type': 'application/json', ...init.headers },
  });
}

describe('normalizeError', () => {
  it('maps the backend envelope to code, message and field errors', async () => {
    const response = jsonResponse(
      {
        error: {
          code: 'VALIDATION_ERROR',
          message: 'validation failed',
          details: [{ field: 'unit_number', message: 'required' }],
        },
      },
      { status: 422 },
    );

    const normalized = await normalizeError(response);

    expect(normalized.code).toBe('VALIDATION_ERROR');
    expect(normalized.status).toBe(422);
    expect(normalized.message).toBe('validation failed');
    expect(normalized.fields).toEqual({ unit_number: 'required' });
  });

  it('falls back to the HTTP status when the envelope is missing', async () => {
    const normalized = await normalizeError(new Response('nope', { status: 403 }));

    expect(normalized.code).toBe('FORBIDDEN');
    expect(normalized.fields).toEqual({});
  });

  it('reads Retry-After for rate limited responses', async () => {
    const response = jsonResponse(
      { error: { code: 'RATE_LIMITED', message: 'slow down' } },
      { status: 429, headers: { 'Retry-After': '30' } },
    );

    const normalized = await normalizeError(response);

    expect(normalized.retryAfterSeconds).toBe(30);
  });

  it('leaves the response body readable for the caller', async () => {
    const response = jsonResponse(
      { error: { code: 'CONFLICT', message: 'changed' } },
      {
        status: 409,
      },
    );

    await normalizeError(response);

    await expect(response.json()).resolves.toMatchObject({ error: { code: 'CONFLICT' } });
  });
});

describe('errorI18nKey', () => {
  it('maps known codes', () => {
    expect(errorI18nKey('NOT_FOUND')).toBe(ERROR_I18N_KEYS.NOT_FOUND);
  });

  it('falls back for unknown codes', () => {
    expect(errorI18nKey('SOMETHING_NEW')).toBe(ERROR_I18N_KEYS.UNKNOWN);
  });
});

describe('ApiError', () => {
  it('is recognised by isApiError and carries the normalized shape', () => {
    const error = new ApiError(normalizeNetworkError(new Error('offline')));

    expect(isApiError(error)).toBe(true);
    expect(error.code).toBe('NETWORK_ERROR');
    expect(error.status).toBe(0);
    expect(error.message).toBe('offline');
  });
});
