# SSM C2C Parcels — Mobile Integration Contract

> **Important:** Customer-to-customer parcels use the dedicated C2C API. Do not use the legacy warehouse-parcel endpoints under `/customer/parcels`, and do not treat `ARRIVED_AT_WAREHOUSE` as a C2C status.

Base URL examples below assume `{{base_url}}` already contains `/api/v1`.

## 1. Customer creates a parcel and supplies both locations

```http
POST {{base_url}}/customer/c2c-parcels
Authorization: Bearer {{customer_token}}
Idempotency-Key: {{idempotency_key}}
```

The creation request must include the sender pickup point and recipient drop-off point:

```json
{
  "sender_latitude": 31.0409,
  "sender_longitude": 31.3785,
  "recipient_latitude": 31.0450,
  "recipient_longitude": 31.3750
}
```

The request also carries parcel information, sender/recipient details, photos when applicable, and pickup/delivery instructions. The backend checks both points against delivery coverage before creating the parcel.

## 2. Sender pickup and driver lifecycle

The driver receives a dedicated C2C offer; this is not a store-order offer.

```http
GET  {{base_url}}/delivery-man/c2c-parcels/offers
POST {{base_url}}/delivery-man/c2c-parcels/{parcel_id}/accept
POST {{base_url}}/delivery-man/c2c-parcels/{parcel_id}/arrive-pickup
POST {{base_url}}/delivery-man/c2c-parcels/{parcel_id}/pickup
POST {{base_url}}/delivery-man/c2c-parcels/{parcel_id}/out-for-delivery
POST {{base_url}}/delivery-man/c2c-parcels/{parcel_id}/complete
```

All driver mutation requests require the driver Bearer token and an `Idempotency-Key` header. Reuse the same key only when retrying the exact same action after a timeout.

```text
driver_assigned
→ driver_accepted
→ driver_at_pickup
→ picked_up
→ out_for_delivery
→ delivered
```

The driver only receives approximate pickup/drop-off areas before acceptance. After acceptance, `current-work` and parcel details contain the full pickup and delivery information required to perform the job.

## 3. Driver history: store orders and C2C are separate arrays

```http
GET {{base_url}}/delivery-man/work-history?scope=current&limit=20&offset=1
GET {{base_url}}/delivery-man/work-history?scope=previous&limit=20&offset=1
```

```json
{
  "scope": "current",
  "total_size": 1,
  "limit": 20,
  "offset": 1,
  "orders": [],
  "c2c_parcels": [],
  "totals": {
    "orders": 0,
    "c2c_parcels": 1
  }
}
```

`orders` is for store orders. `c2c_parcels` is for customer-to-customer work. Do not try to parse C2C items as store orders.

Each `c2c_parcels` item contains the following mobile-facing fields:

```json
{
  "id": 1,
  "reference": "C2C-...",
  "status": "out_for_delivery",
  "status_version": 4,
  "is_terminal": false,
  "parcel": {
    "title": "Document",
    "description": "...",
    "category": "documents",
    "weight_kg": 1,
    "dimensions_cm": {},
    "is_fragile": false,
    "pickup_instructions": "...",
    "delivery_instructions": "..."
  },
  "pickup": {
    "name": "Sender name",
    "phone": "Sender phone",
    "latitude": 31.0409,
    "longitude": 31.3785
  },
  "dropoff": {
    "name": "Recipient name",
    "phone": "Recipient phone",
    "latitude": 31.045,
    "longitude": 31.375
  },
  "images": [],
  "timeline": [],
  "next_actions": ["complete"],
  "requires_otp_to_complete": true
}
```

## 4. Customer tracking and live driver location

```http
GET  {{base_url}}/customer/c2c-parcels/{parcel_id}/tracking
POST {{base_url}}/delivery-man/c2c-parcels/{parcel_id}/location
```

The tracking response returns the status timeline, driver data when it is safe to reveal it, current driver location, ETA when available, and a polling fallback interval.

The driver must post location pings during active work. Tracking does not invent GPS positions; it reflects the latest location received from the driver app.

### WebSocket channels

Subscribe through the normal authenticated broadcasting flow to:

```text
private-c2c-parcel.{parcelId}
private-c2c-parcel.{parcelId}.tracking
```

Important events include:

```text
parcel.driver_assigned
parcel.status_changed
parcel.driver_location_updated
parcel.cancelled
parcel.failed_delivery
parcel.return_started
parcel.delivered
```

If WebSocket is unavailable, poll the tracking endpoint using `polling_interval_seconds` (normally 15 seconds while the parcel is active).

## 5. Recipient OTP and completion

When the parcel is `out_for_delivery`, the recipient requests the hand-over code:

```http
POST {{base_url}}/customer/c2c-parcels/{parcel_id}/delivery-otp/request
Authorization: Bearer {{recipient_token}}
```

The recipient provides the code to the driver. The driver submits it during `complete`. Return-to-sender uses the same endpoint for the sender while the parcel is returning.

## 6. Push notifications

FCM is a supplement to the API, not the source of truth. On any parcel notification, refresh the appropriate offers, current-work, or tracking endpoint.

Common C2C notification types include:

```text
ssm.c2c_parcel.offer_created
ssm.c2c_parcel.incoming
ssm.c2c_parcel.driver_assigned
ssm.c2c_parcel.picked_up
ssm.c2c_parcel.out_for_delivery
ssm.c2c_parcel.delivered
ssm.c2c_parcel.cancelled
```

## 7. Privacy rules

- Before the driver accepts: only coarse pickup/drop-off areas are shown.
- After acceptance: the driver receives names, phones, and exact locations required for delivery.
- The recipient never receives the sender's exact pickup location.
- Driver location visibility differs by sender/recipient and parcel status; always render what the tracking response returns.

## Related Postman collection

Import `SSM_UNIFIED_API.postman_collection.json` and open the C2C customer and driver sections. It contains the executable requests for creation, offers, lifecycle, tracking, OTP, and error cases.
