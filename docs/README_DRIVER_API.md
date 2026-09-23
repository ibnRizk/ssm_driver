# SSM Driver API — Complete Integration README

This document is the integration manual for the Driver mobile application and the Postman collection:

`SSM_DRIVER_API.postman_collection.json`

It is intentionally self-contained. A mobile developer should be able to import the collection, understand the authentication and lifecycle rules, implement the Driver app, and troubleshoot common failures using this file alone.

---

## 1. Production connection details

| Setting | Value |
|---|---|
| Website | `https://ssm.husseintech.com/` |
| API base URL | `https://ssm.husseintech.com/api/v1` |
| Request format | JSON, except document upload which is multipart |
| Response format | JSON, except private document streaming |
| Authentication | Opaque Bearer token returned by Driver login |
| Currency | `SAR` |
| Date/time format | ISO-8601 |

Every path in this document is relative to the API base URL. For example:

```text
GET /delivery-man/profile
```

means:

```text
GET https://ssm.husseintech.com/api/v1/delivery-man/profile
```

Do not use the website root as the API base URL. The correct API base always ends with `/api/v1`.

---

## 2. Files to give the Driver developer

Required:

- `SSM_DRIVER_API.postman_collection.json` — all Driver requests, examples, scripts, and assertions.
- `README_DRIVER_API.md` — this integration document.

Optional for local backend testing:

- `SSM_LOCAL.postman_environment.json` — local variables and test fixtures. It points to localhost by default and must not be used unchanged for production.
- `fixtures/sample-image.png` — sample onboarding document.

The collection contains both normal application requests and deliberate negative/security tests. Do not run the whole collection against production: some folders create accounts, update locations, accept/reject offers, and complete deliveries.

---

## 3. Importing and configuring Postman

1. Open Postman.
2. Import `SSM_DRIVER_API.postman_collection.json`.
3. Import `SSM_LOCAL.postman_environment.json` only if you need the prepared test variables.
4. Duplicate the environment and name it `SSM Production`.
5. Set:

```text
base_url = https://ssm.husseintech.com/api/v1
```

6. Replace local fixture credentials with a real, approved production Driver account.
7. Never commit real phone numbers, passwords, FCM tokens, or Bearer tokens.

For a quick manual integration, only these variables are essential:

| Variable | Meaning |
|---|---|
| `base_url` | API base URL |
| `driver_phone` | Approved Driver phone number |
| `driver_password` | Driver password |
| `driver_token` | Token saved automatically after successful login |
| `fcm_token` | Firebase device token |
| `assignment_id` | Active offer/assignment ID |
| `order_id` | Accepted order ID |
| `idempotency_key` | UUID used for retry-safe delivery commands |

Variables such as `driver_a_*`, `driver_b_*`, `driver_c_*`, `assignment_a_id`, and `assignment_b_id` exist for the automated multi-driver dispatch scenario. A normal mobile application does not need them.

---

## 4. Required HTTP headers

### Public requests

```http
Accept: application/json
Content-Type: application/json
```

### Authenticated requests

```http
Accept: application/json
Content-Type: application/json
Authorization: Bearer <driver_token>
```

### Retry-safe delivery commands

Pickup, out-for-delivery, and order completion also require:

```http
Idempotency-Key: <uuid>
```

Generate a UUID once for a user action and keep the same UUID while retrying that same action. Generate a new UUID for the next different action.

Correct:

```text
Tap Pickup -> key A -> network timeout -> retry Pickup with key A
Tap Out for delivery -> key B
Tap Complete -> key C
```

Incorrect:

```text
Retry the same Pickup command with a different UUID every time
Reuse the Pickup UUID for Complete
```

Offer accept/reject supports an idempotency key but the delivery lifecycle commands require it.

---

## 5. Authentication model

The Driver API uses an opaque token stored by the backend. It is not a JWT and the application must not parse it or assume it contains claims.

Login:

```http
POST /auth/delivery-man/login
```

```json
{
  "phone": "+966500000000",
  "password": "your-password"
}
```

Successful response:

```json
{
  "token": "opaque-server-token",
  "approval_status": "approved",
  "topic": "delivery_man_123",
  "zone_topic": "zone_1_delivery_man"
}
```

Store `token` in encrypted device storage. Use it in the `Authorization` header for every Driver endpoint.

Important authentication rules:

- One active token is supported per Driver.
- Logging in again replaces the previous token.
- The old token then returns `401`.
- Missing or invalid token returns `401` with code `auth-001`.
- Wrong phone/password returns `401`.
- Missing required login fields returns `403` because this endpoint retains the legacy validation status contract.
- There is no Driver logout endpoint. Logout is a client action: delete the local token and stop background location/push subscriptions.
- Never send the token in query parameters or request bodies.

Always validate a restored session when the app starts:

```http
GET /delivery-man/session/validate
```

If it returns `401`, clear the local session and open the login screen.

---

## 6. Account states and approval gate

A Driver can authenticate while the account is still pending. Authentication and operational approval are different concepts.

| `approval_status` | Meaning | Operational API access |
|---|---|---|
| `pending` | Waiting for admin review | Blocked |
| `approved` | Accepted and eligible, subject to account/availability rules | Allowed |
| `rejected` | Rejected by admin | Blocked; show rejection reason |

Pending Drivers can use the onboarding endpoints, but cannot go online, publish operational locations, see offers, process orders, access COD/incentives, or process parcels.

Blocked operational requests return:

```json
{
  "errors": [
    {
      "code": "driver-not-approved",
      "approval_status": "pending"
    }
  ]
}
```

The mobile application should route users as follows:

```text
Login
  -> pending  -> Onboarding status/documents screen
  -> rejected -> Rejection screen with rejection_reason
  -> approved -> Driver home screen
```

---

## 7. Registration and onboarding

### 7.1 Register Driver

```http
POST /auth/delivery-man/store
```

Example JSON:

```json
{
  "f_name": "Ahmed",
  "l_name": "Ali",
  "identity_type": "driving_license",
  "identity_number": "DL-12345678",
  "email": "driver@example.com",
  "phone": "+966500000000",
  "password": "Strong#Pass2026",
  "zone_id": 1,
  "vehicle_id": 1,
  "earning": 1
}
```

Field rules:

| Field | Required | Notes |
|---|---:|---|
| `f_name` | Yes | First name |
| `l_name` | Yes | Last name |
| `identity_type` | Yes | `passport`, `driving_license`, or `nid` |
| `identity_number` | Yes | Government identity/license number |
| `email` | Yes | Must be unique |
| `phone` | Yes | Must be unique; send international format |
| `password` | Yes | Minimum 8 chars, uppercase, lowercase, digit, and symbol |
| `zone_id` | Yes | Existing active zone |
| `vehicle_id` | Yes | Existing vehicle type |
| `earning` | Yes | Send `1`; required by the registration contract |

Success is `200`. Duplicate identity/contact data or a weak password returns `403` with an `errors` array.

### 7.2 Login after registration

The newly registered Driver can log in and receive a token even while pending. Save that token and use it for onboarding.

### 7.3 Read onboarding status

```http
GET /delivery-man/onboarding-status
```

Important response fields:

```json
{
  "driver_id": 123,
  "name": "Ahmed Ali",
  "phone": "+966500000000",
  "approval_status": "pending",
  "can_operate": false,
  "account_status": "inactive",
  "is_online": false,
  "rejection_reason": null,
  "documents": []
}
```

`can_operate` is the simplest UI decision field. Do not infer approval only from whether login succeeded.

### 7.4 Upload onboarding document

```http
POST /delivery-man/documents
Content-Type: multipart/form-data
```

Multipart fields:

| Field | Type | Rules |
|---|---|---|
| `document_type` | text | Backend-supported document category |
| `file` | file | jpg, jpeg, png, webp, or PDF; maximum 10 MB |

Success is `201`. The document is queued for review and appears in `onboarding-status.documents`.

Document records include safe metadata such as ID, original name, MIME type, size, verification status, rejection reason, and creation time. Internal storage paths are never returned.

### 7.5 Stream own private document

```http
GET /delivery-man/documents/{document_id}/file
```

This endpoint returns the file stream, not JSON. Another Driver's document returns `403`; an unknown document returns `404`.

---

## 8. Profile, session, and push token

### Validate session

```http
GET /delivery-man/session/validate
```

Use it during app startup/resume. It returns authentication state, safe Driver identity, online state, capacity, and zone information.

### Get profile

```http
GET /delivery-man/profile
```

This is a safe mobile profile response. It does not expose the auth token, other Drivers, internal wallet details, or private administrative fields.

### Register/update FCM token

```http
PUT /delivery-man/update-fcm-token
```

```json
{
  "fcm_token": "firebase-device-registration-token"
}
```

An empty token returns `422`. Call this after login and whenever Firebase refreshes the device token.

The login response may include FCM topic names. Treat push messages as hints, not as authoritative state. After receiving an offer notification, call `GET /delivery-man/active-offer`.

---

## 9. Availability, heartbeat, and location

### Go online

```http
POST /delivery-man/online
```

### Go offline

```http
POST /delivery-man/offline
```

### Heartbeat

```http
POST /delivery-man/heartbeat
```

Online/offline responses include:

```json
{
  "message": "...",
  "is_online": true,
  "last_seen_at": "2026-09-23T12:00:00+03:00",
  "availability_version": 4
}
```

Going offline can be refused while the Driver owns active work. The app must show the backend error and remain online instead of silently changing its local state.

### Record location

Preferred endpoint:

```http
POST /delivery-man/location
```

Legacy-compatible alias:

```http
POST /delivery-man/record-location-data
```

Example:

```json
{
  "latitude": 24.7136,
  "longitude": 46.6753,
  "accuracy": 8.5,
  "heading": 120,
  "speed": 9.4,
  "recorded_at": "2026-09-23T12:00:00+03:00",
  "location": "King Fahd Road"
}
```

Validation:

| Field | Required | Validation |
|---|---:|---|
| `latitude` | Yes | Numeric, `-90` to `90` |
| `longitude` | Yes | Numeric, `-180` to `180` |
| `accuracy` | No | Numeric accuracy in meters |
| `heading` | No | `0` to `360` |
| `speed` | No | `0` to `200` |
| `recorded_at` | No | ISO-8601, not future, not older than one day |
| `location` | No | Human-readable text |

Never send `driver_id` or `delivery_man_id`. Identity always comes from the Bearer token. Spoofing these fields is rejected with `422`.

Recommended mobile cadence:

- Idle and online: every 20–30 seconds.
- Travelling to pickup: every 5–10 seconds.
- Out for delivery: every 3–5 seconds.
- Send heartbeat independently so a temporary GPS failure does not immediately look like an app logout.
- Pause background updates after a confirmed offline response.

A Driver is dispatch-eligible only when all of these are true:

- Approved.
- Administratively active.
- Online.
- In the same zone as the order.
- Heartbeat is not older than 120 seconds.
- Latest location is not older than 120 seconds.
- Within the dispatch radius (15 km).
- Below active-order capacity (default capacity is 1).

---

## 10. Automatic offer flow

When a Merchant marks an order ready for pickup, the server selects the nearest eligible Driver and exposes one offer at a time.

```text
Merchant marks ready
  -> nearest eligible Driver receives offer
  -> accept  -> assignment won
  -> reject  -> next nearest eligible Driver
  -> timeout -> next nearest eligible Driver
  -> no eligible Driver / attempts exhausted -> assignment_failed
```

Production offer duration is approximately 30 seconds. Always use the server-provided timing fields instead of starting a blind local 30-second timer.

### Read active offer

```http
GET /delivery-man/active-offer
```

No offer:

```json
{
  "offer": null
}
```

Offer fields include:

```json
{
  "offer": {
    "assignment_id": 501,
    "order_id": 9001,
    "attempt_number": 1,
    "offered_at": "2026-09-23T12:00:00+03:00",
    "expires_at": "2026-09-23T12:00:30+03:00",
    "server_now": "2026-09-23T12:00:05+03:00",
    "remaining_seconds": 25,
    "distance_meters_snapshot": 840,
    "pickup": {
      "name": "Store name",
      "address": "Store address",
      "latitude": 24.71,
      "longitude": 46.67
    },
    "delivery_address": "Delivery address",
    "payment_method": "cash_on_delivery",
    "cod_amount": "125.00",
    "order_type": "delivery"
  }
}
```

Before acceptance, customer name, phone, and email are intentionally hidden.

### Accept offer

```http
POST /delivery-man/offers/{assignment_id}/accept
```

Optional body:

```json
{
  "expected_version": 3
}
```

Success:

```json
{
  "message": "Offer accepted.",
  "assignment": {
    "assignment_id": 501,
    "order_id": 9001,
    "assignment_status": "accepted",
    "order_status": "driver_accepted",
    "order_version": 4
  }
}
```

### Reject offer

```http
POST /delivery-man/offers/{assignment_id}/reject
```

```json
{
  "reason": "Too far from pickup"
}
```

`reason` is optional and limited to 255 characters.

Offer error handling:

| HTTP | Code/meaning | App behavior |
|---:|---|---|
| `404` | `assignment-not-found` | Close the offer; it does not exist or belongs to another Driver |
| `409` | `assignment-conflict` | Refresh `active-offer`; it expired, was already handled, or another Driver won |
| `422` | Validation error | Correct request data |
| `429` | Rate limit | Back off and retry later |

Exactly one Driver can win an assignment. The client must accept a `409` as a normal race outcome.

---

## 11. Current work and order lifecycle

### Read current work

```http
GET /delivery-man/current-work
```

When there is no accepted active assignment:

```json
{
  "work": null
}
```

Current work is returned while the status is `driver_accepted`, `picked_up`, or `out_for_delivery`. It includes pickup details, destination, delivery coordinates, customer name and phone, order note, payment method, COD amount, timestamps, and status version.

Customer phone is released only after acceptance. Customer email is never returned.

Required lifecycle order:

```text
driver_accepted
  -> picked_up
  -> out_for_delivery
  -> delivered
```

Skipping a step is rejected.

### Confirm pickup

```http
POST /delivery-man/orders/{order_id}/pickup
Idempotency-Key: <uuid>
```

Optional optimistic-lock body:

```json
{
  "expected_version": 4
}
```

### Start delivery

```http
POST /delivery-man/orders/{order_id}/out-for-delivery
Idempotency-Key: <uuid>
```

### Complete delivery with OTP

```http
POST /delivery-man/orders/{order_id}/complete
Idempotency-Key: <uuid>
```

```json
{
  "proof_method": "otp",
  "otp": "123456",
  "cod_collected": true,
  "expected_version": 6
}
```

The OTP is a six-digit code shown by the customer. Do not log or store it after completion.

### Complete delivery with location/time proof

```json
{
  "proof_method": "location_time",
  "latitude": 24.7136,
  "longitude": 46.6753,
  "accuracy": 9.2,
  "device_timestamp": "2026-09-23T12:15:00+03:00",
  "cod_collected": false,
  "expected_version": 6
}
```

For a COD order, `cod_collected: true` is required when the Driver actually receives the cash. The backend determines the authoritative amount; never calculate or send an authoritative COD amount from the phone.

Lifecycle response fields:

```json
{
  "message": "...",
  "order_id": 9001,
  "ssm_status": "picked_up",
  "ssm_status_version": 5,
  "idempotent_replay": false
}
```

If a network timeout occurs, retry the command with the same idempotency key. A safe replay can return the already-committed response with `idempotent_replay: true`.

Common lifecycle errors:

| HTTP | Error | Meaning |
|---:|---|---|
| `404` | `driver-order-not-found` | Order is unknown or not assigned to this Driver |
| `409` | `assignment-conflict` | Invalid sequence, stale version, or conflicting state |
| `422` | `otp-incorrect` | Customer OTP is wrong |
| `422` | Validation | Proof or required idempotency header is missing/invalid |
| `403` | Approval/account gate | Driver cannot operate |

---

## 12. COD summary and incentives

### COD summary

```http
GET /delivery-man/cod-summary
```

```json
{
  "currency": "SAR",
  "outstanding_cod_liability": "250.00",
  "cod_collections_count": 2
}
```

`outstanding_cod_liability` is cash collected by the Driver and still owed to the platform. Admin settlements reduce this balance. The Driver API intentionally does not expose an endpoint for editing collections or creating settlements.

### Incentive summary

```http
GET /delivery-man/incentive-summary
```

```json
{
  "currency": "SAR",
  "completed_deliveries_count": 18,
  "completed_toward_next_reward": 8,
  "deliveries_required_for_next_reward": 2,
  "earned_incentive_amount": "5.00",
  "awards_count": 1
}
```

Current rule: `5 SAR` for every `10` qualifying completed deliveries. This represents earned incentives only; it is not salary, payroll, withdrawal, or COD settlement data.

Always treat money as a decimal string. Do not convert authoritative financial values to binary floating-point numbers.

---

## 13. Parcel workflow

Parcels are warehouse/shipping jobs assigned to a Driver by an admin. They are separate from normal store orders.

Parcel lifecycle:

```text
ARRIVED_AT_WAREHOUSE
  -> OUT_FOR_DELIVERY (optional explicit step)
  -> DELIVERED
```

### List parcels

```http
GET /delivery-man/parcels
GET /delivery-man/parcels?status=active
GET /delivery-man/parcels?status=delivered
```

The response is paginated and includes `data`, `total_size`, `limit`, and `offset`.

### Parcel details

```http
GET /delivery-man/parcels/{parcel_id}
```

Only assigned parcels are visible. Foreign/unknown parcels return `404`.

### Start parcel delivery

```http
POST /delivery-man/parcels/{parcel_id}/start-delivery
```

This step is optional because completion can occur directly from the warehouse state. Starting a parcel that is already delivered returns `422`.

### Complete prepaid parcel with location proof

```http
POST /delivery-man/parcels/{parcel_id}/complete
```

```json
{
  "proof_type": "LOCATION_TIME",
  "latitude": 24.7136,
  "longitude": 46.6753,
  "notes": "Delivered to recipient"
}
```

### Complete with OTP proof

```json
{
  "proof_type": "OTP",
  "otp": "123456",
  "notes": "Recipient confirmed"
}
```

### Complete COD parcel

```json
{
  "proof_type": "LOCATION_TIME",
  "latitude": 24.7136,
  "longitude": 46.6753,
  "cod_collected": true,
  "cod_notes": "Cash received",
  "notes": "Delivered"
}
```

Rules:

- `proof_type` is uppercase: `LOCATION_TIME` or `OTP`.
- A COD parcel needs `cod_collected: true` to record the cash.
- A prepaid parcel never creates a COD collection.
- Repeating completion after delivery is idempotent and returns the same delivered state.
- A parcel not assigned to the Driver returns `404` for details and a protected validation/domain error for completion.
- The response exposes only safe customer identity data, not tokens or account internals.

---

## 14. Notifications

### List notifications

```http
GET /delivery-man/notifications?per_page=20&status=all
GET /delivery-man/notifications?per_page=20&status=read
GET /delivery-man/notifications?per_page=20&status=unread
```

The response contains `data`, pagination `links`, and `meta`. Titles and bodies are translated by the backend.

### Unread count

```http
GET /delivery-man/notifications/unread-count
```

### Mark one as read

```http
PATCH /delivery-man/notifications/{notification_id}/read
```

### Mark all as read

```http
POST /delivery-man/notifications/read-all
```

Another Driver's notification and unknown UUIDs return `404`. Notification payloads must not be used as the source of truth for order state, OTP, or financial state; refresh the appropriate API resource.

Realtime private channel:

```text
private-driver.{driver_id}
```

Relevant events:

- `ssm.driver.offer_created`
- `ssm.driver.offer_rejected`
- `ssm.driver.offer_expired`
- `ssm.driver.assigned`
- `ssm.notification.created`

---

## 15. HTTP status and error contract

| HTTP status | Meaning in this API |
|---:|---|
| `200` | Successful read/action or idempotent replay |
| `201` | Document uploaded |
| `401` | Missing, invalid, replaced, or revoked Bearer token; wrong credentials |
| `403` | Validation on legacy auth/register endpoints, pending/rejected Driver, or forbidden document access |
| `404` | Resource is absent or intentionally hidden because it belongs to another Driver |
| `409` | State/version/race conflict, expired/stale offer, invalid lifecycle order |
| `422` | Modern request validation or domain rule failure |
| `429` | Rate limit exceeded |
| `500` | Unexpected backend failure; capture request ID/time and report it |

Typical error envelope:

```json
{
  "errors": [
    {
      "code": "auth-001",
      "message": "Unauthorized."
    }
  ]
}
```

Implementation advice:

- Use `code` for program decisions.
- Use `message` for display/fallback diagnostics.
- Do not compare only English message text.
- Treat `404` on another Driver's data as expected security behavior.
- On `409`, refresh the corresponding offer/work resource before showing the next action.
- On `429`, honor backoff and do not immediately loop.

---

## 16. Rate limits

Current intended limits:

| Area | Limit |
|---|---:|
| Authentication | 10 requests/minute per IP |
| Location updates | 60 requests/minute |
| Offer accept/reject | 30 requests/minute |
| Notification inbox | 120 requests/minute |

Do not retry `401`, `403`, `404`, `409`, or `422` in a tight loop. Only network failures and selected server errors should use bounded exponential backoff.

---

## 17. Recommended Driver app state machine

```text
SIGNED_OUT
  -> login

AUTHENTICATED_PENDING
  -> onboarding status
  -> upload documents
  -> wait for admin

AUTHENTICATED_APPROVED_OFFLINE
  -> register FCM token
  -> go online

ONLINE_IDLE
  -> heartbeat + location
  -> poll active offer / listen for push

OFFER_VISIBLE
  -> accept -> DRIVER_ACCEPTED
  -> reject -> ONLINE_IDLE
  -> expire -> ONLINE_IDLE

DRIVER_ACCEPTED
  -> pickup -> PICKED_UP

PICKED_UP
  -> out for delivery -> OUT_FOR_DELIVERY

OUT_FOR_DELIVERY
  -> complete with proof -> ONLINE_IDLE
```

Server responses are authoritative. Do not advance local state before receiving a successful response.

---

## 18. Suggested Flutter/Dart networking pattern

Use a single API client that adds the base URL, JSON headers, Bearer token, and consistent error parsing.

```dart
class DriverApiClient {
  DriverApiClient(this.dio, this.tokenStore);

  final Dio dio;
  final TokenStore tokenStore;

  static const baseUrl = 'https://ssm.husseintech.com/api/v1';

  Future<Response<T>> request<T>(
    String path, {
    String method = 'GET',
    Object? data,
    Map<String, dynamic>? headers,
  }) async {
    final token = await tokenStore.read();

    return dio.request<T>(
      '$baseUrl$path',
      data: data,
      options: Options(
        method: method,
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
          ...?headers,
        },
      ),
    );
  }
}
```

Example retry-safe pickup:

```dart
final key = const Uuid().v4();

await client.request(
  '/delivery-man/orders/$orderId/pickup',
  method: 'POST',
  headers: {'Idempotency-Key': key},
  data: {'expected_version': orderVersion},
);
```

Persist the key until the command succeeds or is definitively rejected. A timeout does not prove the server failed to commit the action.

---

## 19. Postman folder guide

| Folder | Purpose | Safe on production? |
|---|---|---|
| `01 Registration & Onboarding` | Creates pending Driver, logs in, uploads document, checks approval gating | No, creates data |
| `02 Post-approval check` | Verifies an admin-approved registered Driver | Only with a prepared account |
| `03 Login & Profile` | Login, session, profile, onboarding, FCM | Mostly; FCM update mutates data |
| `04 Availability, Heartbeat & Location` | Online/offline and GPS validation | No, changes operational state |
| `05 Dispatch setup (A, B, C)` | Logs in and positions three test Drivers | Test environment only |
| `06 Dispatch scenarios` | Reject, expiry, next-driver selection, acceptance races | Test environment only |
| `07 Offers` | Single-driver offer checks and unknown IDs | Use carefully |
| `08 Current work & Delivery` | Pickup, delivery, proof, OTP completion | Never on real orders for testing |
| `09 COD & Incentives` | Read-only summaries | Safe with authorized account |
| `10 Parcel work` | Reads and completes test parcels | Test environment only |
| `11 Notifications` | Lists and marks notifications read | Reads are safe; mark-read mutates state |
| `90 Security Tests` | Cross-driver access, spoofing, stale offers, invalid tokens | Test environment only |

The complete automated run requires Customer and Merchant setup, admin approval actions, seeded Drivers, test orders/parcels, and a queue worker. It is an integration suite, not a production smoke test.

---

## 20. Minimal manual test sequence

Use this sequence when connecting a real Driver app for the first time:

1. `POST /auth/delivery-man/login`.
2. Save the returned token securely.
3. `GET /delivery-man/session/validate`.
4. `GET /delivery-man/onboarding-status`.
5. Confirm `approval_status = approved` and `can_operate = true`.
6. `PUT /delivery-man/update-fcm-token`.
7. `POST /delivery-man/online`.
8. `POST /delivery-man/heartbeat`.
9. `POST /delivery-man/location`.
10. `GET /delivery-man/active-offer`.
11. If an offer exists, accept/reject using its `assignment_id`.
12. After acceptance, `GET /delivery-man/current-work`.
13. Perform pickup, out-for-delivery, and completion in order with separate idempotency keys.
14. Check `GET /delivery-man/cod-summary` and `GET /delivery-man/incentive-summary`.
15. Check notifications and unread count.

---

## 21. Security requirements for the mobile developer

- Store Bearer tokens only in secure/encrypted storage.
- Never print passwords, tokens, OTPs, full customer phone numbers, or proof data in production logs.
- Never accept `driver_id` from UI state as authority; the server derives Driver identity from the token.
- Do not show pre-acceptance customer contact information; it is intentionally absent.
- Do not attempt to read another Driver's assignment, parcel, document, or notification.
- Stop background location after logout/offline according to platform policy.
- Use TLS only; never downgrade the production base URL to HTTP.
- Treat FCM/realtime data as a notification to refresh REST state.
- Use decimal-safe types/strings for money.
- Preserve idempotency keys across network retries.

---

## 22. Troubleshooting checklist

### Every protected request returns 401

- Confirm the header is exactly `Authorization: Bearer <token>`.
- Confirm there are no quotes around the token.
- Confirm a newer login did not replace this token.
- Run `GET /delivery-man/session/validate`.

### Login succeeds but operational routes return 403

- Read `/delivery-man/onboarding-status`.
- Confirm `approval_status` is `approved`.
- Confirm `can_operate` is `true`.
- Show `rejection_reason` when present.

### Driver is online but receives no offer

- Send a recent heartbeat.
- Send a recent valid GPS location.
- Confirm the Driver and order are in the same zone.
- Confirm distance is within 15 km.
- Confirm active-order capacity is available.
- Confirm the Merchant marked the order ready for pickup.
- Refresh `/delivery-man/active-offer` after push events.

### Accept returns 409

The offer expired, was already rejected, or another Driver won. Refresh `active-offer`; do not keep retrying the stale assignment.

### Pickup/out-for-delivery/complete returns 422

- Confirm `Idempotency-Key` is present.
- Confirm body fields and proof method.
- Confirm coordinates and timestamps are valid.
- Confirm COD completion sends `cod_collected: true` when required.

### Delivery command returns 409

- Refresh `current-work`.
- Follow the lifecycle order.
- Update `expected_version` from the latest server response.
- If retrying after a timeout, reuse the original idempotency key.

### Location returns 422

- Check numeric latitude/longitude ranges.
- Remove `driver_id` and `delivery_man_id`.
- Ensure `recorded_at` is not in the future or older than one day.

### Server returns 500

Record:

- UTC/local timestamp.
- HTTP method and path.
- Response status/body.
- Non-sensitive request fields.
- Any server/request correlation ID from headers.

Do not include passwords, tokens, OTPs, or customer personal data in the report.

---

## 23. Endpoint quick reference

| Method | Endpoint | Authentication | Purpose |
|---|---|---|---|
| `POST` | `/auth/delivery-man/store` | Public | Register Driver |
| `POST` | `/auth/delivery-man/login` | Public | Login and obtain token |
| `GET` | `/delivery-man/session/validate` | Bearer | Validate session/capacity |
| `GET` | `/delivery-man/profile` | Bearer | Driver profile |
| `GET` | `/delivery-man/onboarding-status` | Bearer | Approval and documents |
| `POST` | `/delivery-man/documents` | Bearer | Upload onboarding document |
| `GET` | `/delivery-man/documents/{id}/file` | Bearer | Stream own private document |
| `PUT` | `/delivery-man/update-fcm-token` | Bearer | Register device push token |
| `POST` | `/delivery-man/online` | Bearer + approved | Go online |
| `POST` | `/delivery-man/offline` | Bearer + approved | Go offline |
| `POST` | `/delivery-man/heartbeat` | Bearer + approved | Refresh availability |
| `POST` | `/delivery-man/location` | Bearer + approved | Publish location |
| `POST` | `/delivery-man/record-location-data` | Bearer + approved | Legacy location alias |
| `GET` | `/delivery-man/active-offer` | Bearer + approved | Read current offer |
| `POST` | `/delivery-man/offers/{id}/accept` | Bearer + approved | Accept offer |
| `POST` | `/delivery-man/offers/{id}/reject` | Bearer + approved | Reject offer |
| `GET` | `/delivery-man/current-work` | Bearer + approved | Accepted active assignment |
| `POST` | `/delivery-man/orders/{id}/pickup` | Bearer + approved + idempotency | Confirm pickup |
| `POST` | `/delivery-man/orders/{id}/out-for-delivery` | Bearer + approved + idempotency | Start final delivery |
| `POST` | `/delivery-man/orders/{id}/complete` | Bearer + approved + idempotency | Complete with proof |
| `GET` | `/delivery-man/cod-summary` | Bearer + approved | COD liability summary |
| `GET` | `/delivery-man/incentive-summary` | Bearer + approved | Incentive progress/earnings |
| `GET` | `/delivery-man/parcels` | Bearer + approved | List assigned parcels |
| `GET` | `/delivery-man/parcels/{id}` | Bearer + approved | Parcel details |
| `POST` | `/delivery-man/parcels/{id}/start-delivery` | Bearer + approved | Start parcel delivery |
| `POST` | `/delivery-man/parcels/{id}/complete` | Bearer + approved | Complete parcel with proof |
| `GET` | `/delivery-man/notifications` | Bearer | Notification inbox |
| `GET` | `/delivery-man/notifications/unread-count` | Bearer | Unread count |
| `PATCH` | `/delivery-man/notifications/{id}/read` | Bearer | Mark one read |
| `POST` | `/delivery-man/notifications/read-all` | Bearer | Mark all read |

---

## 24. Final implementation notes

- The REST API response is always the source of truth.
- The Driver app does not select or claim arbitrary orders. It only handles the offer assigned by automatic dispatch.
- The app cannot assign itself, spoof another Driver, or override COD amounts.
- Offers, deliveries, COD facts, and incentives are separate concepts; do not combine their state locally.
- Use `active-offer` for offer state and `current-work` after acceptance.
- Refresh state after app resume, token restoration, push events, conflicts, and network uncertainty.
- Keep UI actions disabled while the corresponding command is in flight, but preserve retry capability with the same idempotency key.

