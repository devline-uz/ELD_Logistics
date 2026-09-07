/**
 * Users — MSW handler'lari (2.1, fe-testing §MSW). `GET /users/{id}`
 * swaggerda yo'q — `users.ts` hooki keshdan o'qiydi, shuning uchun bu yerda
 * faqat ro'yxat + amal endpointlari bor.
 */
import { http, HttpResponse } from 'msw';

import type { InvitationSent, ListResponse, User } from '@/api/types';

import { jsonError, listMeta, url } from './shared';

export function userFixture(overrides: Partial<User> = {}): User {
  return {
    id: 'user-1',
    first_name: 'Jane',
    last_name: 'Admin',
    full_name: 'Jane Admin',
    email: 'jane.admin@example.com',
    username: 'jadmin',
    status: 'active',
    created_at: '2026-09-01T10:00:00Z',
    ...overrides,
  };
}

/** `GET /users` — muvaffaqiyatli. */
export const usersListHandler = http.get(url('/users'), () =>
  HttpResponse.json({ data: [userFixture()], meta: listMeta() } satisfies ListResponse<User>),
);

/** `GET /users` — bo'sh natija. */
export const usersListEmptyHandler = http.get(url('/users'), () =>
  HttpResponse.json({ data: [], meta: listMeta({ total: 0 }) } satisfies ListResponse<User>),
);

/** `GET /users` — `422`. */
export const usersListErrorHandler = http.get(url('/users'), () =>
  jsonError('VALIDATION_ERROR', 'per_page must be 10, 25 or 50', 422),
);

/** `POST /users` — muvaffaqiyatli (invitation, parol yo'q). */
export const userCreateHandler = http.post(url('/users'), () =>
  HttpResponse.json({ data: userFixture({ id: 'user-new', status: 'invited' }) }, { status: 201 }),
);

/** `POST /users` — `409` (`username`/`email` band). */
export const userCreateConflictHandler = http.post(url('/users'), () =>
  jsonError('CONFLICT', 'email already in use', 409),
);

/** `POST /users` — `404` (noma'lum rol/branch). */
export const userCreateRoleNotFoundHandler = http.post(url('/users'), () =>
  jsonError('NOT_FOUND', 'Unknown role', 404),
);

/** `PATCH /users/{id}` — muvaffaqiyatli. */
export const userUpdateHandler = http.patch(url('/users/:id'), ({ params }) =>
  HttpResponse.json({ data: userFixture({ id: params.id as string }) }),
);

/** `PATCH /users/{id}` — `404`. */
export const userUpdateNotFoundHandler = http.patch(url('/users/:id'), () =>
  jsonError('NOT_FOUND', 'User not found', 404),
);

/** `DELETE /users/{id}` — muvaffaqiyatli (`204`). */
export const userDeleteHandler = http.delete(
  url('/users/:id'),
  () => new HttpResponse(null, { status: 204 }),
);

/** `DELETE /users/{id}` — `409 SELF_TARGET_FORBIDDEN` / `LAST_ADMINISTRATOR`. */
export const userDeleteConflictHandler = http.delete(url('/users/:id'), () =>
  jsonError('CONFLICT', 'Cannot delete the last active Administrator', 409),
);

/** `POST /users/{id}/activate` — muvaffaqiyatli (alohida kalit yo'q, `users.update`). */
export const userActivateHandler = http.post(url('/users/:id/activate'), ({ params }) =>
  HttpResponse.json({ data: userFixture({ id: params.id as string, status: 'active' }) }),
);

/** `POST /users/{id}/activate` — `409` (invitation qabul qilinmagan). */
export const userActivateConflictHandler = http.post(url('/users/:id/activate'), () =>
  jsonError('CONFLICT', 'Invitation was not accepted yet', 409),
);

/** `POST /users/{id}/deactivate` — muvaffaqiyatli. */
export const userDeactivateHandler = http.post(url('/users/:id/deactivate'), ({ params }) =>
  HttpResponse.json({ data: userFixture({ id: params.id as string, status: 'inactive' }) }),
);

/** `POST /users/{id}/deactivate` — `409 SELF_TARGET_FORBIDDEN` / `LAST_ADMINISTRATOR`. */
export const userDeactivateConflictHandler = http.post(url('/users/:id/deactivate'), () =>
  jsonError('CONFLICT', 'Cannot deactivate the last active Administrator', 409),
);

/** `POST /users/{id}/resend-invitation` — muvaffaqiyatli (`202`). */
export const userResendInvitationHandler = http.post(url('/users/:id/resend-invitation'), () =>
  HttpResponse.json(
    {
      data: {
        user_id: 'user-1',
        channel: 'email',
        purpose: 'invitation',
        expires_at: '2026-09-04T10:00:00Z',
      } satisfies InvitationSent,
    },
    { status: 202 },
  ),
);

/** `POST /users/{id}/resend-invitation` — `409` (allaqachon qabul qilingan). */
export const userResendInvitationConflictHandler = http.post(
  url('/users/:id/resend-invitation'),
  () => jsonError('CONFLICT', 'Invitation was already accepted', 409),
);

/** `POST /users/{id}/reset-password` — muvaffaqiyatli (`202`). */
export const userResetPasswordHandler = http.post(url('/users/:id/reset-password'), () =>
  HttpResponse.json(
    {
      data: {
        user_id: 'user-1',
        channel: 'email',
        purpose: 'password_reset',
        expires_at: '2026-09-04T10:00:00Z',
      } satisfies InvitationSent,
    },
    { status: 202 },
  ),
);

/** `POST /users/{id}/reset-password` — `409 ACCOUNT_INACTIVE`. */
export const userResetPasswordInactiveHandler = http.post(url('/users/:id/reset-password'), () =>
  jsonError('CONFLICT', 'Account is inactive', 409),
);

/** Bazaviy to'plam — ro'yxat + CRUD muvaffaqiyat holatlari. */
export const usersBaseHandlers = [
  usersListHandler,
  userCreateHandler,
  userUpdateHandler,
  userDeleteHandler,
];
