# WebSocket API — `GET /api/v1/ws`

Real-time transport of ONEBOOK ELD (TZ B§5, D§3). Everything that is not
real-time stays REST; this endpoint never appears in the Swagger spec, so this
file is the contract.

Message frames are JSON text frames. Binary frames are rejected.

---

## 1. Authentication

Two forms are accepted, **never a token in the URL**:

1. **Handshake header** — `Authorization: Bearer <access_token>` on the upgrade
   request. The token is verified *before* the upgrade; a failure answers the
   normal REST error envelope (401/403) and no socket is opened.
2. **First frame** — connect without the header, then send an `auth` frame
   within **10 seconds**:

```json
{"type":"auth","token":"<access_token>"}
```

A connection that sends anything else first, or stays silent, is closed with
`UNAUTHORIZED`.

> **Forbidden:** `?token=`, `?access_token=`, `?jwt=`, `?bearer=`,
> `?authorization=`, `?api_key=`. Any of these query parameters aborts the
> handshake with `401 UNAUTHORIZED` — a credential in a URL leaks into access
> logs, referrers and proxy caches.

The principal must carry a company (`cid`) and must not be a limited capability
token (2FA enrolment). A super administrator selects its tenant with the
`X-Company-Id` header of the handshake, exactly like the REST API.

On success the server sends:

```json
{"type":"welcome","ts":"2026-09-06T18:05:00Z"}
```

---

## 2. Channels

| Channel | Permission | Contents |
|---|---|---|
| `tracking` | `tracking.view_live` | Live unit positions and ELD state |
| `notifications` | *(authenticated)* | The caller's in-app notifications |
| `chat` | `chat.read` | Office ↔ driver messages and read receipts |
| `dashboard` | `dashboard.read` | Dashboard KPI refresh |

Rules enforced on **every** `subscribe` frame (not only the first):

* the channel must exist, otherwise `NOT_FOUND`;
* the principal must hold the channel permission, otherwise `FORBIDDEN`;
* `filter.company_id`, if present, must equal the principal's own company,
  otherwise `FORBIDDEN` — a client can never listen to another tenant;
* `filter.unit_ids` must name units of the caller's company, otherwise
  `NOT_FOUND` (the existence of another company's unit is never confirmed);
* a filter may not carry more than **500** ids.

Delivery is deny-by-default: until a channel is subscribed, nothing is sent.
Company isolation is re-checked at fan-out time, so a stale subscription can
never outlive a tenant switch.

---

## 3. Client frames

### `subscribe`

```json
{
  "type": "subscribe",
  "channel": "tracking",
  "filter": {"unit_ids": ["2b7c8d9e-1122-3344-5566-778899aabbcc"]},
  "since": "2026-09-06T17:55:00Z"
}
```

* `filter` is optional. `unit_ids` / `driver_ids` narrow the stream; the hub
  matches them against the `unit_id` / `driver_id` fields of the event payload.
* `since` is optional — see [Reconnect](#5-reconnect-and-since).

Answer:

```json
{"type":"subscribed","channel":"tracking","ts":"2026-09-06T18:05:00Z"}
```

### `unsubscribe`

```json
{"type":"unsubscribe","channel":"tracking"}
```

Answer: `{"type":"unsubscribed","channel":"tracking","ts":"…"}`

### `ping`

An application level keepalive for clients that cannot observe protocol level
pongs. Answer: `{"type":"pong","ts":"…"}`.

---

## 4. Server frames

### Event

```json
{
  "type": "event",
  "channel": "tracking",
  "event": "unit_last_state",
  "data": { "...": "channel specific payload" },
  "ts": "2026-09-06T18:05:02Z"
}
```

A frame replayed by a `since` backfill carries `"replay": true`.

### Error

```json
{"type":"error","channel":"chat","code":"FORBIDDEN","message":"permission chat.read is required","ts":"…"}
```

Codes are the canonical `internal/apierr` codes. A frame level error (bad
subscribe) does **not** close the socket; an authentication failure does.

---

### 4.1 `tracking` — `unit_last_state`

```json
{
  "unit_id": "2b7c8d9e-1122-3344-5566-778899aabbcc",
  "company_id": "0f1e2d3c-4b5a-6978-8796-a5b4c3d2e1f0",
  "ts": "2026-09-06T18:05:00Z",
  "lat": 31.5204, "lng": 74.3587,
  "speed_kmh": 62.5, "heading": 187.0,
  "odometer_m": 128430000, "engine_hours": 4821.25,
  "duty_status": "DR",
  "driver_id": "1f9d7c2a-4c66-4c2f-9d2f-9a0b7d1e2f34",
  "online_status": "online",
  "updated_at": "2026-09-06T18:05:01Z"
}
```

Distances are metres (`_m`), speeds km/h; the backend performs no unit
conversion.

### 4.2 `notifications` — `notification_created`

```json
{
  "id": "6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f",
  "user_id": "3a2b1c0d-9e8f-4a5b-8c7d-6e5f4a3b2c1d",
  "alert_type": "hos_violation",
  "title": "11-hour driving limit exceeded",
  "body": "Driver John Doe exceeded the 11 hour driving limit at 18:05Z.",
  "entity_type": "violations",
  "entity_id": "1f9d7c2a-4c66-4c2f-9d2f-9a0b7d1e2f34",
  "channels": ["push", "email", "in_app"],
  "created_at": "2026-09-06T18:05:00Z"
}
```

The channel carries every notification of the company; a client filters on
`user_id` (the REST inbox `GET /notifications` is always personal).

### 4.3 `chat` — `chat_message`, `chat_message_read`

```json
{
  "id": "6f1a1a5e-1b4a-4d0d-9f2e-1c2b3a4d5e6f",
  "driver_id": "1f9d7c2a-4c66-4c2f-9d2f-9a0b7d1e2f34",
  "sender_id": "3a2b1c0d-9e8f-4a5b-8c7d-6e5f4a3b2c1d",
  "sender_side": "office",
  "kind": "text",
  "text": "Please head to dock 4 after your break.",
  "file_key": "",
  "lat": null, "lng": null,
  "status": "delivered",
  "sent_at": "2026-09-06T18:05:00Z",
  "delivered_at": "2026-09-06T18:05:04Z",
  "read_at": null
}
```

`chat_message_read` carries the same payload with `status: "read"` and a
`read_at`. A driver that is not connected receives a push instead
(`chat_message` alert).

### 4.4 `dashboard` — `dashboard_summary`

The payload of `GET /dashboard/summary` (`data` object), republished whenever
the summary is refreshed. Clients either subscribe here or poll the REST
endpoint every 60 seconds.

---

## 5. Reconnect and `since`

After a network drop the client reconnects, re-authenticates and re-subscribes
with `since` set to the `ts` of the last event it processed:

```json
{"type":"subscribe","channel":"chat","since":"2026-09-06T17:55:00Z"}
```

* Replayed frames carry `"replay": true` so a client can suppress duplicate
  notifications.
* At most **200** events are replayed per channel.
* `since` may not reach further back than **24 hours**; an older value is
  clamped silently.
* `since` in the future answers `TIME_IN_FUTURE` and no replay.
* When no backfill provider is wired for a channel, the subscription still
  succeeds and only live traffic follows — `since` is a best-effort optimisation,
  never a correctness guarantee. The REST endpoints remain the source of truth.

---

## 6. Keepalive and limits

| Setting | Value |
|---|---|
| Server ping interval | 30 s |
| Read deadline | 65 s (two missed pongs) |
| Write deadline | 10 s per frame |
| Auth deadline | 10 s after upgrade |
| Max inbound frame | 32 KiB |
| Outbound queue per client | 256 messages |

A client that does not answer two consecutive pings is disconnected. A client
whose outbound queue overflows has messages dropped rather than blocking the
publisher — after a drop, reconnect with `since`.

---

## 7. Horizontal scaling

One node holds roughly 20–50k connections. Nodes are joined by Redis pub/sub on
the `eld:ws` channel: a publisher writes to its local hub first and then to
Redis; every other node re-publishes to its own subscribers. The envelope
carries the originating `node_id`, so a node ignores its own echo. A Redis
outage degrades delivery to single node fan-out; it never drops the local
delivery.
