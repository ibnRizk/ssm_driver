import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_driver/core/error/failures.dart';
import 'package:ssm_driver/core/services/location/location_failure.dart';
import 'package:ssm_driver/core/services/location/device_location.dart';
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
    await cubit.completeWithOtp(sampleParcel, '123');

    expect(repository.completeCalls, 0);
    expect(cubit.state, isA<ParcelActionFailure>());
  });

  test('a six-digit OTP is sent as an OTP proof', () async {
    await cubit.completeWithOtp(sampleParcel, '123456');

    expect((repository.lastProof as ParcelOtpProof?)?.otp, '123456');
  });

  test('a COD parcel is completed with the cash collected', () async {
    await cubit.completeWithOtp(sampleParcel, '123456');

    expect(repository.lastCodCollected, isTrue);
  });

  test('location proof sends the current fix', () async {
    await cubit.completeWithLocation(sampleParcel);

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

    await cubit.completeWithLocation(sampleParcel);
    await expectation;
  });

  test('without a location fix nothing is sent', () async {
    location.result = const Left<LocationFailure, DeviceLocation>(
      LocationFailure(LocationIssue.serviceDisabled),
    );

    await cubit.completeWithLocation(sampleParcel);

    expect(repository.completeCalls, 0);
    expect(cubit.state, isA<ParcelActionFailure>());
  });
}
