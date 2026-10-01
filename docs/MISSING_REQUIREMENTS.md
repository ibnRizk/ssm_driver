# Driver App — Missing Requirements Checklist

_Last updated: 2026-09-30_

The Driver App has four features we can't finish on the frontend alone. Each item below lists exactly what we need, and from whom. Where it helps, the current placeholder in the app is shown so you can see what's being replaced.

**Backend:** section A. **Design:** section B.

| # | Feature | Backend | Design | Blocks |
|---|---|---|---|---|
| 1 | Vehicle types at registration | A1 | — | Risk of registrations with a wrong or invalid `vehicle_id` |
| 2 | Profile: zone, rating, vehicle | A2 | B3 | Profile shows placeholder data |
| 3 | Report a problem during an order | A3 | B2 | Button does nothing |
| 4 | Help & Support | A4 | B1 | Menu item does nothing |
| 5 | Home "Parcel round" card | A5 (confirm only) | B4 (review) | Already live; needs confirmation |

---

## A. Backend API Requirements

### A1. Vehicle types list — **high priority**

Registration sends a `vehicle_id` that must be an existing vehicle type. The app currently offers hard-coded IDs 1–3 (motorcycle, car, van), which may not match the database.

**Endpoint**

```http
GET /api/v1/vehicle/list
```

- **Public (no auth).** The driver has no token yet at registration.
- Same shape as the existing `GET /zone/list`: a plain JSON array.
- `display_name` should follow the request language (`Accept-Language: ar|en`).

```json
[
  { "id": 1, "name": "motorcycle", "display_name": "دراجة نارية" },
  { "id": 2, "name": "car", "display_name": "سيارة" }
]
```

**In the meantime:** please send us the real vehicle IDs and names currently in the database, so the temporary list is correct.

### A2. Extra fields on `GET /delivery-man/profile`

The profile screen shows placeholders for these values today:

| Shown today (placeholder) | Field needed | Notes |
|---|---|---|
| "Turabah Governorate" | `zone: { id, name }` | The driver's registered zone; `name` translated |
| "Certified Courier" | `level` or `title` | **Only if driver levels exist.** If not, tell us and we'll remove it |
| Rating "4.9" | `rating: { average, count }` | `null` when the driver has no ratings yet |
| "SSM Bicycle" / "Active vehicle for local delivery zone" | `vehicle: { id, name, plate_number? }` | `plate_number` only if it's stored |

**Example addition to the existing response:**

```json
{
  "zone": { "id": 1, "name": "الرياض" },
  "rating": { "average": 4.9, "count": 132 },
  "vehicle": { "id": 1, "name": "دراجة نارية", "plate_number": "ABC 1234" }
}
```

### A3. Report a problem during an order — **needs a product decision**

The "Report a problem" button on the pickup confirmation screen has nothing to call yet.

**Endpoints**

```http
GET  /api/v1/delivery-man/problem-reasons
POST /api/v1/delivery-man/orders/{order_id}/report-problem
```

`GET /problem-reasons` returns a translated list:

```json
[
  { "code": "store_closed", "label": "المتجر مغلق" },
  { "code": "order_not_ready", "label": "الطلب غير جاهز" },
  { "code": "damaged_item", "label": "منتج تالف" },
  { "code": "wrong_items", "label": "منتجات خاطئة" }
]
```

`POST /report-problem` request (multipart if a photo is sent). It should require an `Idempotency-Key` header, like the other order commands:

```json
{ "reason_code": "store_closed", "note": "optional free text" }
```

**Decisions we need before building:**

1. Does a report **change the order's status** (cancel, reassign, put on hold), or does it only notify support?
2. What does the response tell the app to do next: stay on the order, leave the order flow, or wait?
3. Can problems be reported **only at pickup**, or also **during delivery**?
4. Is a photo required, optional, or not supported?

### A4. Help & Support content

```http
GET /api/v1/delivery-man/support-info
```

```json
{
  "phone": "+9665XXXXXXXX",
  "whatsapp": "+9665XXXXXXXX",
  "email": "support@example.com",
  "working_hours": "9:00 – 22:00",
  "faqs": [{ "question": "…", "answer": "…" }]
}
```

- Serving this from the backend lets support details change **without an app store release**.
- **Alternative:** if the content is fixed, send it to us and we'll put it in the app instead.

### A5. Parcel round — confirmation only

The home screen's "Parcel round" card is **already live**. It uses the existing `GET /delivery-man/parcels`, treating the round as **every parcel currently assigned to the driver**. It shows the count and, when all parcels come from one shipping company, that company's name.

**Please confirm** that's the intended meaning of a "round". If a round is really a *group* of parcels (per store or per batch), we'd need a `round_id` or `store` field on each parcel, or a small summary endpoint returning `{ count, store_name }`.

---

## B. Design / UI Requirements (Figma)

### B1. Help & Support screen

- Contact options: call, WhatsApp, email (tap to open).
- FAQ section (expandable questions), if FAQs are provided (A4).
- States: loading, error with retry, no FAQs.

### B2. Report-a-problem flow

Starts from the "Report a problem" button on pickup confirmation.

- Reason picker, from the list in A3.
- Optional note field.
- Optional photo, if A3 decision 4 allows it.
- Confirmation step before sending.
- States: submitting, success, error with retry.
- **What the driver sees after reporting.** This depends on the backend's answer to A3 decisions 1–2.

### B3. Profile edge states

- **No rating yet** (new driver): what replaces "4.9"?
- **No vehicle assigned**: what does the vehicle card show?
- **Courier title**: keep "Certified Courier" only if driver levels exist (A2).

### B4. Home "Parcel round" card — review

The card is live with interim styling. Please review:

- **Empty state:** currently plain text ("No parcels are assigned to you right now"). Should the card hide instead?
- **Mixed companies:** currently "N parcels ready for delivery" without a company name. Is that the right wording?
- **Loading and error:** currently short text lines in the card's place.

### Not needed from design

- **Vehicle type picker at registration:** it will reuse the region picker's existing loading, error and retry design.

---

## Priority

1. **A1 vehicle IDs:** the only item with a data-integrity risk today.
2. **A3 decisions:** B2 is blocked until they're answered.
3. **A2 + B3, A4 + B1:** each pair can proceed in parallel.
4. **A5 / B4:** confirmation and review only; the feature already works.
