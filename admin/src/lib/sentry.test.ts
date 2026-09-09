import { describe, expect, it } from 'vitest';

import { MASKED_VALUE } from '@/lib/sensitive';
import { captureException, initSentry, isSentryEnabled } from '@/lib/sentry';
import { scrubEvent, scrubUrl } from '@/lib/sentry.scrub';

describe("sentry — DSN yo'q holat", () => {
  it("VITE_SENTRY_DSN bo'sh bo'lganda o'chirilgan bo'ladi", () => {
    expect(import.meta.env.VITE_SENTRY_DSN ?? '').toBe('');
    expect(isSentryEnabled()).toBe(false);
  });

  it("initSentry SDK chunk'ini yuklamaydi va xato bermaydi", async () => {
    await expect(initSentry()).resolves.toBeUndefined();
    // Ikkinchi chaqiruv ham jim o'tadi (idempotent).
    await expect(initSentry()).resolves.toBeUndefined();
  });

  it('captureException no-op — hech qanday xato otmaydi', () => {
    expect(() => {
      captureException(new Error('boom'), { source: 'test' });
    }).not.toThrow();
  });
});

describe('scrubUrl', () => {
  it('token query parametrlarini maskalaydi', () => {
    expect(scrubUrl('https://api.test/v1/units?access_token=abc&page=2')).toBe(
      `https://api.test/v1/units?access_token=${MASKED_VALUE}&page=2`,
    );
  });

  it("query bo'lmasa URL o'zgarmaydi", () => {
    expect(scrubUrl('https://api.test/v1/units')).toBe('https://api.test/v1/units');
  });
});

describe('scrubEvent', () => {
  it('header, cookie, token va PII maydonlarini maskalaydi', () => {
    const event = scrubEvent({
      request: {
        url: 'https://admin.test/login?refresh_token=zzz',
        headers: { Authorization: 'Bearer secret', 'X-Trace-Id': 'tr-1' },
        cookies: { session: 'abc' },
        data: {
          password: 'hunter2',
          license_no: 'AZ-99',
          driver_name: 'John Doe',
          email: 'a@b.uz',
          unit_number: '104',
          nested: { access_token: 'aaa', ok: 1 },
        },
      },
      user: { id: 'u-1', email: 'a@b.uz', username: 'john' },
      extra: { refresh_token: 'rrr', count: 3 },
      breadcrumbs: [{ data: { authorization: 'Bearer x' }, message: 'GET /x?token=1' }],
    });

    expect(event.request?.cookies).toBeUndefined();
    expect(event.request?.headers?.Authorization).toBe(MASKED_VALUE);
    expect(event.request?.headers?.['X-Trace-Id']).toBe('tr-1');
    expect(event.request?.url).toContain(MASKED_VALUE);

    const data = event.request?.data as Record<string, unknown>;
    expect(data.password).toBe(MASKED_VALUE);
    expect(data.license_no).toBe(MASKED_VALUE);
    expect(data.driver_name).toBe(MASKED_VALUE);
    expect(data.email).toBe(MASKED_VALUE);
    expect(data.unit_number).toBe('104');
    expect((data.nested as Record<string, unknown>).access_token).toBe(MASKED_VALUE);
    expect((data.nested as Record<string, unknown>).ok).toBe(1);

    expect(event.user).toEqual({ id: 'u-1' });
    expect(event.extra.refresh_token).toBe(MASKED_VALUE);
    expect(event.extra.count).toBe(3);
    const crumb = event.breadcrumbs[0];
    expect((crumb?.data as Record<string, unknown> | undefined)?.authorization).toBe(MASKED_VALUE);
    expect(crumb?.message).toContain(MASKED_VALUE);
  });

  it('siklik havolada osilib qolmaydi', () => {
    const cyclic: Record<string, unknown> = { token: 'x' };
    cyclic.self = cyclic;
    const event = scrubEvent({ extra: { cyclic } });
    expect(event.extra.cyclic.token).toBe(MASKED_VALUE);
  });
});
