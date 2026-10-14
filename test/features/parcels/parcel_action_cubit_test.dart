import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_driver/core/error/failures.dart';
import 'package:ssm_driver/core/services/location/location_failure.dart';
import 'package:ssm_driver/core/services/location/device_location.dart';
import 'package:ssm_driver/features/parcels/data/models/parcel_model.dart';
import 'package:ssm_driver/features/parcels/domain/entities/parcel.dart';
import 'package:ssm_driver/features/parcels/domain/entities/parcel_proof.dart';
import 'package:ssm_driver/features/parcels/presentation/cubit/parcel_action_cubit.dart';
import 'package:ssm_driver/features/parcels/presentation/cubit/parcel_action_state.dart';

import '../../helpers/fake_location_service.dart';
import '../../helpers/key_localizations.dart';
import 'parcels_test_fakes.dart';

void main() {
  useKeyLocalizations();

  late FakeParcelsRepository repository;
  late FakeLocationService location;
  late ParcelActionCubit cubit;

  setUp(() {
    repository = FakeParcelsRepository();
    location = FakeLocationService();
    cubit = ParcelActionCubit(repository, location);
  });

  tearDown(() => cubit.close());

  test('start delivery shows progress, then the updated parcel', () async {
    repository.parcelResult = const Right<Failure, Parcel>(startedParcel);
    final expectation = expectLater(
      cubit.stream,
      emitsInOrder(<ParcelActionState>[
        const ParcelActionInProgress(ParcelAction.startDelivery),
        const ParcelActionSuccess(ParcelAction.startDelivery, startedParcel),
      ]),
    );

    await cubit.startDelivery(sampleParcel);
    await expectation;
  });

  test('a server rejection asks for a refresh', () async {
    repository.parcelResult = const Left<Failure, Parcel>(
      ServerFailure(message: 'Parcel already delivered.'),
    );

    await cubit.startDelivery(sampleParcel);

    expect(
      cubit.state,
      const ParcelActionFailure(
        ParcelAction.startDelivery,
        'Parcel already delivered.',
        shouldRefresh: true,
      ),
    );
  });

  test('a network failure does not ask for a refresh', () async {
    repository.parcelResult = const Left<Failure, Parcel>(
      NetworkFailure(message: 'offline'),
    );

    await cubit.startDelivery(sampleParcel);

    expect((cubit.state as ParcelActionFailure).shouldRefresh, isFalse);
  });

  test('an incomplete OTP is rejected without calling the server', () async {
    await cubit.completeWithOtp(sampleParcel, '123', cashCollected: true);

    expect(repository.completeCalls, 0);
    expect(cubit.state, isA<ParcelActionFailure>());
  });

  test('a six-digit OTP is sent as an OTP proof', () async {
    await cubit.completeWithOtp(sampleParcel, '123456', cashCollected: true);

    expect((repository.lastProof as ParcelOtpProof?)?.otp, '123456');
  });

  test('a COD parcel is completed with the cash collected', () async {
    await cubit.completeWithOtp(sampleParcel, '123456', cashCollected: true);

    expect(repository.lastCodCollected, isTrue);
  });

  test('an unconfirmed COD parcel is refused without calling the server', () async {
    await cubit.completeWithOtp(sampleParcel, '123456');

    expect(repository.completeCalls, 0);
    expect(
      cubit.state,
      const ParcelActionFailure(
        ParcelAction.complete,
        'parcel_cod_confirm_required',
        shouldRefresh: false,
      ),
    );
  });

  test('an unconfirmed COD parcel never asks for a location fix', () async {
    await cubit.completeWithLocation(sampleParcel);

    expect(location.permissionRequests, isEmpty);
    expect(repository.completeCalls, 0);
  });

  test('a prepaid parcel completes without a cash confirmation', () async {
    final Parcel prepaid = ParcelModel.fromJson(
      parcelJson(paymentType: 'PREPAID'),
    );

    await cubit.completeWithOtp(prepaid, '123456');

    expect(repository.completeCalls, 1);
    expect(repository.lastCodCollected, isFalse);
  });

  test('a prepaid parcel never reports cash, even if ticked', () async {
    final Parcel prepaid = ParcelModel.fromJson(
      parcelJson(paymentType: 'PREPAID'),
    );

    await cubit.completeWithLocation(prepaid, cashCollected: true);

    expect(repository.lastCodCollected, isFalse);
  });

  test('a wrong OTP shows the server message and allows retry', () async {
    repository.parcelResult = const Left<Failure, Parcel>(
      ServerFailure(message: 'The delivery code is incorrect.'),
    );
    await cubit.completeWithOtp(sampleParcel, '000000', cashCollected: true);
    repository.parcelResult = const Right<Failure, Parcel>(startedParcel);

    await cubit.completeWithOtp(sampleParcel, '123456', cashCollected: true);

    expect(repository.completeCalls, 2);
    expect((repository.lastProof as ParcelOtpProof?)?.otp, '123456');
  });

  test('after a wrong OTP the location proof is still accepted', () async {
    repository.parcelResult = const Left<Failure, Parcel>(
      ServerFailure(message: 'The delivery code is incorrect.'),
    );
    await cubit.completeWithOtp(sampleParcel, '000000', cashCollected: true);
    repository.parcelResult = const Right<Failure, Parcel>(startedParcel);

    await cubit.completeWithLocation(sampleParcel, cashCollected: true);

    expect(repository.lastProof, isA<ParcelLocationProof>());
  });

  test('location proof sends the current fix', () async {
    await cubit.completeWithLocation(sampleParcel, cashCollected: true);

    expect(
      (repository.lastProof as ParcelLocationProof?)?.location,
      sampleLocation,
    );
    expect(location.permissionRequests, <bool>[true]);
  });

  test('location proof emits one progress state then success', () async {
    final expectation = expectLater(
      cubit.stream,
      emitsInOrder(<ParcelActionState>[
        const ParcelActionInProgress(ParcelAction.complete),
        const ParcelActionSuccess(ParcelAction.complete, sampleParcel),
      ]),
    );

    await cubit.completeWithLocation(sampleParcel, cashCollected: true);
    await expectation;
  });

  test('without a location fix nothing is sent', () async {
    location.result = const Left<LocationFailure, DeviceLocation>(
      LocationFailure(LocationIssue.serviceDisabled),
    );

    await cubit.completeWithLocation(sampleParcel, cashCollected: true);

    expect(repository.completeCalls, 0);
    expect(cubit.state, isA<ParcelActionFailure>());
  });
}
