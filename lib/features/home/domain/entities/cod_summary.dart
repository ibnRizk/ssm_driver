import 'package:equatable/equatable.dart';

/// `GET /delivery-man/cod-summary` — cash the Driver collected and still owes
/// the platform. Money stays a decimal string (API docs §12): display it,
/// never do float arithmetic on it.
class CodSummary extends Equatable {
  final String currency;
  final String outstandingLiability;
  final int collectionsCount;

  const CodSummary({
    required this.currency,
    required this.outstandingLiability,
    required this.collectionsCount,
  });

  @override
  List<Object?> get props => [currency, outstandingLiability, collectionsCount];
}
