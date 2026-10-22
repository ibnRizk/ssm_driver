import 'package:dartz/dartz.dart';
import 'package:ssm_driver/core/error/failures.dart';
import 'package:ssm_driver/core/services/location/device_location.dart';
import 'package:ssm_driver/features/c2c_parcels/data/models/c2c_parcel_model.dart';
import 'package:ssm_driver/features/c2c_parcels/domain/entities/c2c_parcel.dart';
import 'package:ssm_driver/features/c2c_parcels/domain/repositories/c2c_parcels_repository.dart';

import '../../helpers/c2c_fixtures.dart';

/// A parsed contract §3 item.
C2cParcel c2cJob({
  int id = 1,
  String status = 'out_for_delivery',
  List<String> nextActions = const <String>['complete'],
  Object? requiresOtp = true,
  bool isTerminal = false,
}) => C2cParcelModel.fromJson(
  c2cItemJson(
    id: id,
    status: status,
    nextActions: nextActions,
    requiresOtp: requiresOtp,
    isTerminal: isTerminal,
  ),
);

C2cParcel c2cOffer(int id) => C2cParcelModel.fromJson(
  c2cItemJson(id: id, status: 'driver_assigned', nextActions: <String>['accept']),
  coarse: true,
);

/// Records every command; answers with the configured results.
class FakeC2cRepository implements C2cParcelsRepository {
  Either<Failure, List<C2cParcel>> offersResult =
      const Right<Failure, List<C2cParcel>>(<C2cParcel>[]);
  Either<Failure, List<C2cParcel>> jobsResult =
      const Right<Failure, List<C2cParcel>>(<C2cParcel>[]);
  Either<Failure, C2cParcel?> actionResult =
      const Right<Failure, C2cParcel?>(null);
  Either<Failure, Unit> rejectResult = const Right<Failure, Unit>(unit);

  int offerReads = 0;
  int jobReads = 0;
  final List<({int id, C2cAction action, String key, String? otp})> actions =
      <({int id, C2cAction action, String key, String? otp})>[];
  final List<({int offerId, String key, String reason})> rejections =
      <({int offerId, String key, String reason})>[];
  final List<({int id, DeviceLocation location})> pings =
      <({int id, DeviceLocation location})>[];

  @override
  Future<Either<Failure, List<C2cParcel>>> getOffers() async {
    offerReads++;
    return offersResult;
  }

  @override
  Future<Either<Failure, List<C2cParcel>>> getActiveJobs() async {
    jobReads++;
    return jobsResult;
  }

  @override
  Future<Either<Failure, C2cParcel?>> runAction(
    int parcelId,
    C2cAction action, {
    required String idempotencyKey,
    String? otp,
  }) async {
    actions.add((id: parcelId, action: action, key: idempotencyKey, otp: otp));
    return actionResult;
  }

  @override
  Future<Either<Failure, Unit>> rejectOffer(
    int offerId, {
    required String idempotencyKey,
    String reason = 'busy',
  }) async {
    rejections.add((offerId: offerId, key: idempotencyKey, reason: reason));
    return rejectResult;
  }

  @override
  Future<Either<Failure, Unit>> sendLocation(
    int parcelId,
    DeviceLocation location,
  ) async {
    pings.add((id: parcelId, location: location));
    return const Right<Failure, Unit>(unit);
  }
}
