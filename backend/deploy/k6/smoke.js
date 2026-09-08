// smoke.js — minimal end to end check of a deployed ONEBOOK ELD API:
// infrastructure endpoints, login, and one page of every list endpoint.
//
//   k6 run -e BASE_URL=http://localhost:8080 -e USERNAME=admin -e PASSWORD=... deploy/k6/smoke.js
//
// Exit code is non zero when any check fails, so it doubles as a deploy gate.
import http from 'k6/http';
import { check, group, fail } from 'k6';

const BASE_URL = __ENV.BASE_URL || 'http://localhost:8080';
const USERNAME = __ENV.USERNAME || 'admin';
const PASSWORD = __ENV.PASSWORD || '';
const COMPANY = __ENV.COMPANY || '';

export const options = {
  vus: 1,
  iterations: 1,
  thresholds: {
    checks: ['rate==1.00'],
    http_req_failed: ['rate==0.00'],
  },
};

// Every list endpoint exposed by the API. Keep in sync with the router.
export const LIST_ENDPOINTS = [
  '/api/v1/units',
  '/api/v1/drivers',
  '/api/v1/trailers',
  '/api/v1/shipping-documents',
  '/api/v1/eld-devices',
  '/api/v1/users',
  '/api/v1/roles',
  '/api/v1/company/branches',
  '/api/v1/dvir-reports',
  '/api/v1/violations',
  '/api/v1/notifications',
  '/api/v1/maintenance-schedules',
  '/api/v1/routes',
  '/api/v1/support-tickets',
];

// loginAs signs in an explicit account, so a caller can build a pool of
// distinct sessions (see list_p95.js's USER_POOL_*): every request under load
// otherwise shares the one account's per-user rate limit bucket
// (DefaultPerUserPerMinute = 600/min), which a handful of VUs exhausts in
// seconds and turns an NFR run into a 429 flood rather than a latency
// measurement.
export function loginAs(username, password) {
  const payload = { username, password, device_type: 'web' };
  if (COMPANY) {
    payload.company_id = COMPANY;
  }

  const res = http.post(`${BASE_URL}/api/v1/auth/login`, JSON.stringify(payload), {
    headers: { 'Content-Type': 'application/json' },
    tags: { name: 'POST /auth/login' },
  });

  const ok = check(res, {
    'login 200': (r) => r.status === 200,
    'login returns an access token': (r) => !!extractToken(r),
  });
  if (!ok) {
    fail(`login failed for ${username}: ${res.status} ${res.body}`);
  }
  return extractToken(res);
}

export function login() {
  return loginAs(USERNAME, PASSWORD);
}

function extractToken(res) {
  let body;
  try {
    body = res.json();
  } catch (e) {
    return null;
  }
  const data = body && body.data ? body.data : body;
  return (data && (data.access_token || data.token)) || null;
}

export function authHeaders(token) {
  return {
    headers: {
      Authorization: `Bearer ${token}`,
      Accept: 'application/json',
    },
  };
}

export default function () {
  group('infrastructure', () => {
    const health = http.get(`${BASE_URL}/health`, { tags: { name: 'GET /health' } });
    check(health, {
      'health 200': (r) => r.status === 200,
      'health status ok': (r) => r.json('status') === 'ok',
    });

    const ready = http.get(`${BASE_URL}/ready`, { tags: { name: 'GET /ready' } });
    check(ready, { 'ready 200': (r) => r.status === 200 });
  });

  group('auth', () => {
    // 401 here is the correct, intended response — mark it "expected" so it
    // does not also trip the http_req_failed==0 threshold below, which only
    // means to catch transport errors and unintended 4xx/5xx.
    const anon = http.get(`${BASE_URL}/api/v1/units`, {
      tags: { name: 'GET /units (anon)' },
      responseCallback: http.expectedStatuses(401),
    });
    check(anon, {
      'unauthenticated list is 401': (r) => r.status === 401,
      'error envelope carries a code': (r) => !!r.json('error.code'),
    });
  });

  const token = login();

  group('lists', () => {
    for (const path of LIST_ENDPOINTS) {
      const res = http.get(
        `${BASE_URL}${path}?page=1&per_page=25`,
        Object.assign({ tags: { name: `GET ${path}` } }, authHeaders(token)),
      );
      check(res, {
        [`${path} 200`]: (r) => r.status === 200,
        [`${path} returns data+meta`]: (r) => {
          const b = r.json();
          return b && Array.isArray(b.data) && b.meta !== undefined;
        },
        [`${path} leaks no secrets`]: (r) => !/"(password|.*_hash|license_no|.*_enc)"\s*:/.test(r.body),
      });
    }
  });
}
