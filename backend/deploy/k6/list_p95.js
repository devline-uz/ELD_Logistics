// list_p95.js — NFR load test (TZ B§8): list endpoints must stay at
// p95 <= 300 ms and report endpoints at p95 <= 800 ms under the target load.
//
//   k6 run -e BASE_URL=https://api.example.com -e USERNAME=admin -e PASSWORD=... \
//          -e VUS=50 -e DURATION=3m deploy/k6/list_p95.js
//
// The run fails (exit 99) as soon as a threshold is crossed.
import http from 'k6/http';
import { check, sleep } from 'k6';
import { Trend } from 'k6/metrics';
import { login, loginAs, authHeaders, LIST_ENDPOINTS } from './smoke.js';

const BASE_URL = __ENV.BASE_URL || 'http://localhost:8080';
const VUS = parseInt(__ENV.VUS || '50', 10);
const DURATION = __ENV.DURATION || '3m';
const PASSWORD = __ENV.PASSWORD || '';

// USER_POOL_PREFIX/USER_POOL_SIZE log in as USER_POOL_PREFIX1..N instead of
// the single USERNAME account, and each VU picks one of the resulting tokens
// (see loginAs's doc comment for why: one shared account rate-limits itself
// under any real VU count). deploy/k6/seed.sql seeds exactly this pool
// (office1..office300, same password as k6admin) for a local run:
//
//   k6 run -e USER_POOL_PREFIX=office -e USER_POOL_SIZE=8 -e VUS=20 \
//          --setup-timeout 3m deploy/k6/list_p95.js
//
// Left unset, behavior is unchanged: one account, one token, like before.
//
// Q-note / found bug: internal/middleware/ratelimit.go's LoginRateLimit
// hard-codes 5 logins/minute/IP (LoginPerIPPerMinute) — RATE_LIMIT_LOGIN only
// reaches the separate internal/auth.Guard lockout used *inside* the login
// service, not this HTTP-level gate in front of it, so raising the env var
// does not raise the wall setup() runs into building a pool from one IP. The
// LOGIN_PACING_MS sleep below keeps setup() under that fixed 5/min regardless
// of USER_POOL_SIZE; see the task report for the fix recommendation
// (thread cfg.RateLimit.Login into mw.LoginRateLimit).
const LOGIN_PACING_MS = parseInt(__ENV.LOGIN_PACING_MS || '12500', 10);
const USER_POOL_PREFIX = __ENV.USER_POOL_PREFIX || '';
const USER_POOL_SIZE = parseInt(__ENV.USER_POOL_SIZE || '0', 10);

// Report endpoints get a looser budget: they aggregate. Kept in sync with the
// routes actually registered in internal/domain/reports/http.go and
// internal/domain/logs/http.go — each needs its own required query
// parameters (see REPORT_QUERY below), so REPORT_ENDPOINTS is not
// user-overridable the way LIST_ENDPOINTS is.
const REPORT_ENDPOINTS = [
  '/api/v1/reports/activity',
  '/api/v1/reports/distance-by-region',
  '/api/v1/reports/uncertified-logs',
];

// Per-endpoint query builder: distance-by-region takes quarter/year (not a
// date window), the other two take from/to (YYYY-MM-DD, last 7 days).
const REPORT_QUERY = {
  '/api/v1/reports/activity': () => {
    const to = new Date();
    const from = new Date(to.getTime() - 7 * 24 * 3600 * 1000);
    return `from=${from.toISOString().slice(0, 10)}&to=${to.toISOString().slice(0, 10)}`;
  },
  '/api/v1/reports/distance-by-region': () => {
    const now = new Date();
    const quarter = Math.floor(now.getUTCMonth() / 3) + 1;
    return `quarter=${quarter}&year=${now.getUTCFullYear()}`;
  },
  '/api/v1/reports/uncertified-logs': () => 'page=1&per_page=25',
};

const listLatency = new Trend('list_latency', true);
const reportLatency = new Trend('report_latency', true);

export const options = {
  // USER_POOL_SIZE paces its logins at LOGIN_PACING_MS apart (see the Q-note
  // above); k6's own default setup() budget (10s) would abort long before a
  // pool of any real size finishes, so it is raised here rather than forcing
  // every invocation to remember --setup-timeout.
  setupTimeout: '5m',
  scenarios: {
    lists: {
      executor: 'ramping-vus',
      startVUs: 0,
      stages: [
        { duration: '30s', target: VUS },
        { duration: DURATION, target: VUS },
        { duration: '15s', target: 0 },
      ],
      exec: 'listScenario',
    },
    reports: {
      executor: 'constant-vus',
      vus: Math.max(1, Math.floor(VUS / 10)),
      duration: DURATION,
      exec: 'reportScenario',
      startTime: '30s',
    },
  },
  thresholds: {
    // NFR: list endpoints p95 <= 300 ms, reports p95 <= 800 ms.
    'list_latency': ['p(95)<300'],
    'report_latency': ['p(95)<800'],
    'http_req_failed': ['rate<0.01'],
    'checks': ['rate>0.99'],
  },
};

export function setup() {
  if (USER_POOL_SIZE > 0) {
    const tokens = [];
    for (let i = 1; i <= USER_POOL_SIZE; i++) {
      if (i > 1) {
        sleep(LOGIN_PACING_MS / 1000);
      }
      tokens.push(loginAs(`${USER_POOL_PREFIX}${i}`, PASSWORD));
    }
    return { tokens };
  }
  return { tokens: [login()] };
}

// tokenFor spreads VUs evenly across the pool so the per-user rate limit
// bucket sees at most ceil(VUS/poolSize) concurrent virtual users.
function tokenFor(data) {
  return data.tokens[__VU % data.tokens.length];
}

export function listScenario(data) {
  const path = LIST_ENDPOINTS[Math.floor(Math.random() * LIST_ENDPOINTS.length)];
  const page = 1 + Math.floor(Math.random() * 3);

  const res = http.get(
    `${BASE_URL}${path}?page=${page}&per_page=25`,
    Object.assign({ tags: { name: `GET ${path}` } }, authHeaders(tokenFor(data))),
  );

  listLatency.add(res.timings.duration);
  check(res, { 'list 200': (r) => r.status === 200 });
  sleep(0.2 + Math.random() * 0.3);
}

export function reportScenario(data) {
  const path = REPORT_ENDPOINTS[Math.floor(Math.random() * REPORT_ENDPOINTS.length)];
  const query = REPORT_QUERY[path]();

  const res = http.get(
    `${BASE_URL}${path}?${query}`,
    Object.assign({ tags: { name: `GET ${path}` } }, authHeaders(tokenFor(data))),
  );

  reportLatency.add(res.timings.duration);
  check(res, { 'report 200': (r) => r.status === 200 });
  sleep(1);
}

// Unused, but k6 requires a default export when no scenario names it.
export default function () {}
