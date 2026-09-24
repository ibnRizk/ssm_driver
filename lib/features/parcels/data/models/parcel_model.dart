import '../../../../core/utils/json_readers.dart';
import '../../domain/entities/parcel.dart';

class ParcelModel extends Parcel {
  const ParcelModel({
    required super.id,
    required super.trackingNumber,
    required super.status,
    required super.recipientName,
    required super.recipientPhone,
    required super.deliveryAddress,
    required super.latitude,
    required super.longitude,
    required super.shippingCompanyName,
    required super.customerNotes,
    required super.isCashOnDelivery,
    required super.codAmount,
  });

  factory ParcelModel.fromJson(Map<String, dynamic> json) {
    final dynamic company = json['shipping_company'];
    final dynamic metadata = json['metadata'];
    final dynamic notes = metadata is Map ? metadata['customer_notes'] : null;

    return ParcelModel(
      id: readInt(json['id']),
      trackingNumber: json['parcel_tracking_number']?.toString() ?? '',
      status: ParcelStatus.fromApi(json['parcel_status'] as String?),
      recipientName: json['recipient_name']?.toString() ?? '',
      recipientPhone: json['recipient_phone']?.toString() ?? '',
      deliveryAddress: json['delivery_address']?.toString() ?? '',
      latitude: readDouble(json['latitude']),
      longitude: readDouble(json['longitude']),
      shippingCompanyName: company is Map
          ? company['name']?.toString() ?? ''
          : '',
      customerNotes: notes is String && notes.trim().isNotEmpty ? notes : null,
      isCashOnDelivery: json['payment_type'] == 'COD',
      codAmount: readDecimal(json['cod_amount']),
    );
  }
}
