/**
 * Feedback — MSW handler'lari (Bosqich 8.1, fe-testing §MSW).
 */
import { http, HttpResponse } from 'msw';

import type { Feedback, ListResponse } from '@/api/types';

import { jsonError, listMeta, url } from './shared';

export function feedbackFixture(overrides: Partial<Feedback> = {}): Feedback {
  return {
    id: '1a2b3c4d-5e6f-4708-8192-a3b4c5d6e7f8',
    driver_id: '2b7c4d1a-9b5e-4c8d-8e2f-1a2b3c4d5e6f',
    driver_name: 'John Miller',
    app_rating: 4,
    text: 'The log screen is much faster now.',
    submitted_at: '2026-09-06T18:40:00Z',
    ...overrides,
  };
}

/** `GET /feedback` — muvaffaqiyatli. */
export const feedbackListHandler = http.get(url('/feedback'), () =>
  HttpResponse.json({
    data: [feedbackFixture()],
    meta: listMeta(),
  } satisfies ListResponse<Feedback>),
);

/** `GET /feedback` — bo'sh natija. */
export const feedbackListEmptyHandler = http.get(url('/feedback'), () =>
  HttpResponse.json({ data: [], meta: listMeta({ total: 0 }) } satisfies ListResponse<Feedback>),
);

/** `GET /feedback` — `422` (masalan `min_rating` 5dan katta). */
export const feedbackListErrorHandler = http.get(url('/feedback'), () =>
  jsonError('VALIDATION_ERROR', 'min_rating must be between 1 and 5', 422, [
    { field: 'min_rating', message: 'out of range' },
  ]),
);
