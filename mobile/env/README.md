# Muhit fayllari

`flutter run --dart-define-from-file=env/dev.json` (yoki `stage`/`prod`).

| Kalit | Izoh |
|---|---|
| `API_BASE_URL` | REST bazasi, `/api/v1` bilan tugaydi |
| `WS_URL` | `wss://` majburiy (M154), token URL'da emas |
| `SENTRY_DSN` | **Repoda bo'sh.** CI sirlaridan `--dart-define=SENTRY_DSN=...` bilan uzatiladi |
| `ENABLE_DEV_MENU` | Prod'da doim `false` (M163) |
| `ENABLE_CERT_PINNING` | Prod'da doim `true`; bypass yo'q (M153) |

`Env.validate()` prod'da `ENABLE_DEV_MENU=true` yoki pinning o'chirilgan bo'lsa ishga
tushishda `StateError` tashlaydi.
