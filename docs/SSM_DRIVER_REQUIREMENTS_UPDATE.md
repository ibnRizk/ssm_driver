# تحديث متطلبات تطبيق السائق — 30 سبتمبر 2026

هذا الملف يوثّق ما تم تنفيذه فعليًا لتطبيق السائق. استخدمه مع `docs/postman/README_DRIVER_API.md` لأنه يكمّل الـDriver API الحالي ولا يستبدله.

## الملفات

- Collection الجديدة: `docs/postman/SSM_DRIVER_REQUIREMENTS_UPDATE.postman_collection.json`
- الـCollection الأساسية: `docs/postman/SSM_DRIVER_API.postman_collection.json`
- بيئة Postman: `docs/postman/SSM_LOCAL.postman_environment.json`

اضبط `base_url` إلى `https://ssm.husseintech.com/api/v1`، وسجّل الدخول أولًا للحصول على `driver_token`. جميع المسارات أدناه تبدأ بـ`/api/v1`.

## A1 — أنواع المركبات عند التسجيل

`GET /vehicle/list` مسار Public بلا Token. أرسل `Accept-Language: ar` أو `en` ليعود `display_name` باللغة المطلوبة.

```json
[{ "id": 1, "name": "motorcycle", "display_name": "دراجة نارية" }]
```

التطبيق يجب أن يعرض هذه القائمة ثم يرسل `id` المعاد نفسه في `vehicle_id` عند التسجيل. لا يعتمد على IDs ثابتة.

## A2 — Profile السائق

`GET /delivery-man/profile` يتطلب `Authorization: Bearer <driver_token>`، ويعمل للحساب pending أو approved.

الحقول المضافة:

```json
{
  "zone": { "id": 7, "name": "المنصورة" },
  "rating": { "average": 4.9, "count": 132 },
  "vehicle": { "id": 1, "name": "دراجة نارية", "plate_number": null },
  "level": null,
  "title": null
}
```

- `rating: null` يعني لا توجد تقييمات بعد؛ لا تعرض رقمًا افتراضيًا.
- `vehicle: null` يعني لا توجد مركبة مخصصة؛ اعرض حالة “لم تُخصص مركبة”.
- لا يوجد نظام Levels/Titles في قاعدة البيانات حاليًا؛ `level` و`title` يرجعان `null` ولا يظهر لقب وهمي في UI.
- `plate_number` يرجع `null` إن لم يكن محفوظًا في بيانات السائق.

## A3 — الإبلاغ عن مشكلة في الطلب

المساران يتطلبان Driver approved وBearer token:

| المسار | الاستخدام |
|---|---|
| `GET /delivery-man/problem-reasons` | يجلب الأسباب المترجمة لاختيارها في الواجهة |
| `POST /delivery-man/orders/{order_id}/report-problem` | ينشئ بلاغ دعم للطلب النشط المملوك للسائق |

### Body

```json
{ "reason_code": "store_closed", "note": "المتجر مغلق" }
```

الأسباب: `store_closed`, `order_not_ready`, `damaged_item`, `wrong_items`, `customer_unreachable`, `other`.

- Header `Idempotency-Key` إجباري وغير فارغ. استخدم UUID مختلف لكل ضغط إرسال جديد، وأعد استخدام نفس المفتاح فقط عند Retry لنفس البلاغ.
- `note` اختياري حتى 1500 حرف.
- `photo` اختياري، multipart، JPG/PNG/WebP حتى 5 MB.
- السائق يستطيع الإبلاغ خلال `driver_accepted` أو `picked_up` أو `out_for_delivery` فقط.
- السائق لا يستطيع البلاغ عن طلب لا يملكه؛ الرد `404`.

### قرار التشغيل المنفذ

البلاغ **لا يغير حالة الطلب** ولا يلغيه ولا يعيد توزيعه تلقائيًا. يتم حفظه كـSupport Case مفتوح، والرد:

```json
{ "report_id": 12, "next_action": "continue_order", "idempotent_replay": false }
```

هذا يمنع إلغاء أو تعطيل طلب العميل تلقائيًا من زر بلاغ. الدعم/الإدارة تقرر الإجراء لاحقًا.

## A4 — الدعم والمساعدة

`GET /delivery-man/support-info` يتطلب Bearer token ويعيد:

```json
{
  "phone": "+966...",
  "whatsapp": "+966...",
  "email": "support@ssm.sa",
  "working_hours": "09:00 - 22:00",
  "faqs": []
}
```

المصدر هو SSM Settings: `phone` و`email_address`. إن لم توجد قيمة WhatsApp يستخدم رقم الدعم. `faqs` تكون مصفوفة فارغة حتى يتم إدخال `driver_support_faqs` في الإعدادات بصيغة JSON صحيحة.

## A5 — Parcel round

لم نغيره: الجولة حاليًا تعني كل الطرود النشطة المخصصة للسائق في `GET /delivery-man/parcels`. لا يوجد `round_id` أو grouping حسب متجر/دفعة في الـAPI الآن.

## حالات الأخطاء المهمة

| الحالة | المعنى في التطبيق |
|---|---|
| `401` | Token مفقود أو منتهي؛ أعد تسجيل الدخول |
| `403` | السائق pending/rejected ولا يملك صلاحيات تشغيل |
| `404` | الطلب ليس نشطًا أو لا يخص السائق الحالي |
| `422` | Body غير صحيح، أو Idempotency-Key مفقود، أو صورة غير صالحة |
| `409` | Idempotency-Key استُخدم سابقًا لبلاغ مختلف |

## اختبار Postman

1. Import للـCollection الأساسية وCollection التحديث.
2. نفّذ Login لتخزين `driver_token`، أو ضعه يدويًا في Environment.
3. اختبر `Vehicle types` بلا Token.
4. اختبر Profile وSupport بالـToken.
5. ضع `order_id` لطلب SSM نشط ومقبول لهذا السائق، ثم نفّذ `Get problem reasons` و`Report problem`.
6. أعد نفس request بنفس `Idempotency-Key` للتحقق من `idempotent_replay: true`.
