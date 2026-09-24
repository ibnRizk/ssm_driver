import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_driver/core/error/failures.dart';
import 'package:ssm_driver/features/parcels/domain/entities/parcel.dart';
import 'package:ssm_driver/features/parcels/presentation/cubit/parcel_details_cubit.dart';
import 'package:ssm_driver/features/parcels/presentation/cubit/parcel_details_state.dart';

import 'parcels_test_fakes.dart';

void main() {
  late FakeParcelsRepository repository;
  late ParcelDetailsCubit cubit;

  setUp(() {
    repository = FakeParcelsRepository();
    cubit = ParcelDetailsCubit(repository);
  });

  tearDown(() => cubit.close());

  void failNext() => repository.parcelResult = const Left<Failure, Parcel>(
    ServerFailure(message: 'Parcel not found.'),
  );

  test('without an initial copy it loads, then shows the server copy', () async {
    final expectation = expectLater(
      cubit.stream,
      emitsInOrder(<ParcelDetailsState>[
        const ParcelDetailsLoading(),
        const ParcelDetailsLoaded(sampleParcel),
      ]),
    );

    await cubit.loadParcel(2);
    await expectation;
  });

  test('shows the initial copy first, then the server copy', () async {
    repository.parcelResult = const Right<Failure, Parcel>(startedParcel);
    final expectation = expectLater(
      cubit.stream,
      emitsInOrder(<ParcelDetailsState>[
        const ParcelDetailsLoaded(sampleParcel),
        const ParcelDetailsLoaded(startedParcel),
      ]),
    );

    await cubit.loadParcel(2, initial: sampleParcel);
    await expectation;
  });

  test('a failure without any copy shows the error', () async {
    failNext();

    await cubit.loadParcel(2);

    expect(cubit.state, const ParcelDetailsError('Parcel not found.'));
  });

  test('a failed refresh keeps the initial copy on screen', () async {
    failNext();

    await cubit.loadParcel(2, initial: sampleParcel);

    expect(cubit.state, const ParcelDetailsLoaded(sampleParcel));
  });
}
