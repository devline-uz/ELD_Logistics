## 7.9 Chat — `/chat`

- **Ruxsat:** `chat.read` (o'qish), `chat.send` (yozish) · **Endpointlar:** `GET /chat/threads?with_messages=` · `GET /chat/threads/{driver_id}/messages?before=&limit=` · `POST /chat/threads/{driver_id}/messages` · `POST /chat/messages/{id}/read` · WS `chat` kanali
- **Tarkib:** chapda suhbatlar ro'yxati (`Search driver`, oxirgi xabar parchasi, vaqt, o'qilmagan badge), o'ngda yozishma
- **Xabar:** matn ≤ 2000 (`tz.md` §15.4) · rasm/PDF ≤ 10 MB (`kind=chat`, §10) · joylashuv ulashish (ko'rish)
- **Holatlar:** `sent · delivered · read` — belgichalar; sana ajratgichlari (`Today`, `Yesterday`, `<hafta kuni>`)
- **F130** Yuklash: `before` kursori bilan yuqoriga scroll («Load older messages»). Yangi xabar WS `chat_message` orqali; ko'rinib turgan xabarlar `POST /chat/messages/{id}/read` bilan belgilanadi (IntersectionObserver + 1 s debounce).
- **F131 [MUST]** Dizayndagi demo yozishmalar («Did you finish the Hi-FI wireframes for flora app design?») **boshqa loyihadan** — butunlay olib tashlanadi. Bo'sh holat: `No conversations yet` / «Select a driver to start a conversation». §16
- **F132** Fayl biriktirish, o'qilgan belgisi, onlayn holati dizaynda **yo'q** → 🎨 qo'shiladi (TZ §15.4 talab qiladi).
- **F133** Haydovchi haydash rejimida bo'lsa (`duty_status=DR`) — admin tomonida ogohlantirish: «Driver is driving; the message will be delivered but not shown until they stop.» (`tz.md` §15.4).

---

## 7.10 Support & History

### 7.10.1 Contact Support — `/support`
- **Ruxsat:** `support.read` · **Endpointlar:** `GET /support-tickets`, `GET /support-tickets/{id}`, `GET/POST /support-tickets/{id}/messages` (`support.create`), `PATCH /support-tickets/{id}/status` (`support.update_status`), `POST /support-tickets` (`support.create`)
- **Filtrlar:** `status` (`new|in_progress|resolved|closed`) · `driver_id` · `search` · `from`/`to`; saralash `created_at|status|subject`
- **Ustunlar:** `**Ticket #** · Driver Name · **Subject** · Issue Date · Status · Action`
- **F134** Dizaynda bo'sh holatda `Ticket ID`/`Message`, to'la holatda `Ticket #`/`Subject` edi. ✅ `tz.md` §1.3: **`Ticket #`, `Subject`** — ikkala holatda ham. §16
- **F135** Status yozuvi: ✅ **`In Progress`** (dizaynda `In-Progress` varianti ham bor edi). Backend qiymati `in_progress`, ko'rsatiladigan matn `In Progress`. §16
- **Detal (`/support/:id`) — `TICKET DETAILS`:** `Ticket # · Status · Driver · Contact On · Email/Phone · Issue Date · Subject · Description` + **thread** (xabarlar ro'yxati + javob yozish maydoni + fayl ≤ 3)
- **F136** Dizaynda thread yo'q edi (faqat statik tavsif). ✅ `tz.md` §15 qo'shimchasi: admin javobi tiket ichida. 🎨
- **Status o'zgartirish modali:** `Status` select + `Cancel/Save`; `new → in_progress → resolved` (backendda `closed` ham bor)

### 7.10.2 Feedback — `/feedback`
- **Ruxsat:** `feedback.read` · **Endpoint:** `GET /feedback?driver_id&min_rating&from&to`; saralash `submitted_at|app_rating`
- **Ustunlar:** `# · Driver Name · App Rating (1–5 yulduz) · Feedback · App version · Submitted On`
- **F137** Feedback javob talab qilmaydi (`tz.md` Q79) — amal tugmasi yo'q. Uzun matn `truncate` + **satr bosilganda modal** bilan to'liq ko'rinadi (dizaynda ochilgan ko'rinish yo'q edi). 🎨

### 7.10.3 Histories — `/audit`
- **Ruxsat:** `audit.view` · **Endpointlar:** `GET /audit-log?table&record_id&user&action&from&to&order` · `GET /audit-log/tables`
- **F138 [MUST]** `tz.md` §17: UI'dagi **4 jurnal** (Unit Activities, Driver Activities, Histories, Company history) — bitta `audit_log` ustidagi **filtrlangan ko'rinishlar**. Alohida ma'lumot manbai yo'q.

| UI jurnali | Marshrut | Filtr |
|---|---|---|
| Histories (barcha) | `/audit` | filtrsiz + `table` tanlovi (`GET /audit-log/tables`) |
| Unit Activities | `/units/:id/activities` | `GET /units/{id}/history` |
| Driver Activities | `/drivers/:id/activities` | `GET /drivers/{id}/activities` |
| Company history | `/settings/company-history` | `GET /company/history` |

- **Ustunlar:** `Date · User (Edited By) · Action · Table · Record · Changes`
- **`Changes` formati:** `<FIELD> changed from <eski> to <yangi>`; bo'sh qiymat — ✅ **`N/A`** (dizaynda `na` va `N/A` aralash edi, `tz.md` §1.3). §16
- **F139** Dizayndagi `Histories` sahifasining `Add User` tugmasi **olib tashlanadi** (mos emas, `tz.md` §1.3). Filtr panelidagi `Export Drivers`/`Import Drivers` ham olib tashlanadi. §16
- **F140** Sana formati: hafta kuni **3 harf** (`Mon, Tue, Wed, Thu, Fri, Sat, Sun`) — dizayndagi `Tues`/`Thurs` (4 harf) to'g'rilanadi (`tz.md` §1.3). `Intl.DateTimeFormat` `weekday:'short'` buni avtomatik beradi. §16
- **F141** `audit_log` **append-only** — hech qanday tahrir/o'chirish amali yo'q.

---

## 7.11 Notifications (header dropdown + sahifa) — `/notifications`

- **Ruxsat:** `notifications.read` · **Endpointlar:** `GET /notifications?read&alert_type` · `PATCH /notifications/{id}/read` · `POST /notifications/read-all` · WS `notifications` kanali
- **Header dropdown:** oxirgi 10 ta, o'qilmaganlar soni badge'da, «Mark all as read», «See all»
- **Sahifa:** sana bo'yicha guruhlangan (`Today`, `Yesterday`, `<sana>`), filtr `alert_type` (16 qiymat) va `read`
- **F142** Har bildirishnoma `entity_type`/`entity_id` bo'yicha tegishli ekranga o'tadi: `violations → /violations/:id`, `dvir → /dvir/:id`, `log_edit_request → /logs/edit-requests`, `maintenance_* → /maintenance/due`, `chat_message → /chat`, `unidentified_driving → /logs/unassigned`.
- **F143** WS `notification_created` kelganda: (a) ro'yxat keshi yangilanadi, (b) `alert_type` `*_violation|dvir_critical|eld_malfunction` bo'lsa — toast ham chiqadi. Klient `user_id` bo'yicha filtrlaydi (`websocket.md` §4.2 — kanal butun kompaniyani tashiydi).
- **F144** Vaqt formati: ✅ **nisbiy 24 soatgacha** (`2 hours ago`), keyin absolyut (`28 May, 10:04`). Dizaynda mobil nisbiy / planshet absolyut edi. §16

---

## 7.12 Inspection logs — `/inspection` **[MAY]**
- **Ruxsat:** `inspection.view` · `GET /inspection/logs?driver_id&date`; `POST /inspection/email` (`inspection.email`), `POST /inspection/transfer` (`inspection.transfer`)
- Asosan haydovchi/planshet oqimi. Web'da faqat **tarix**: kim, qachon, qaysi haydovchi uchun yo'l tekshiruvini ochgan; hisobotni qayta yuborish. 🎨 dizayn yo'q.

---

