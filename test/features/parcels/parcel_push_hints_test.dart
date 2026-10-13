import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_driver/core/error/failures.dart';
import 'package:ssm_driver/core/services/push/push_hint.dart';
import 'package:ssm_driver/features/parcels/domain/entities/parcel.dart';
import 'package:ssm_driver/features/parcels/presentation/cubit/parcel_details_cubit.dart';
import 'package:ssm_driver/features/parcels/presentation/cubit/parcel_details_state.dart';
import 'package:ssm_driver/features/parcels/presentation/cubit/parcels_cubit.dart';

import '../../helpers/fake_push_service.dart';
import 'parcels_test_fakes.dart';

void main() {
  late FakeParcelsRepository repository;
  late FakePushService push;

  setUp(() {
    repository = FakeParcelsRepository();
    push = FakePushService();
  });

  group('ParcelsCubit', () {
    late ParcelsCubit cubit;

    setUp(() => cubit = ParcelsCubit(repository, pushHints: push.hints));

    tearDown(() => cubit.close());

    test('a parcel push re-reads a loaded round', () async {
      await cubit.loadParcels();

      push.emit(const PushHint(PushTarget.parcel, id: 2));
      await pumpEventQueue();

      expect(repository.requestedPages, <int>[1, 1]);
    });

    test('a parcel push is ignored before the first load', () async {
      push.emit(const PushHint(PushTarget.parcel));
      await pumpEventQueue();

      expect(repository.requestedPages, isEmpty);
    });

    test('an order push does not re-read the round', () async {
      await cubit.loadParcels();

      push.emit(const PushHint(PushTarget.order));
      await pumpEventQueue();

      expect(repository.requestedPages, <int>[1]);
    });
  });

  group('ParcelDetailsCubit', () {
    late ParcelDetailsCubit cubit;

    setUp(() async {
      cubit = ParcelDetailsCubit(repository, pushHints: push.hints);
      await cubit.loadParcel(sampleParcel.id);
      repository.parcelResult = const Right<Failure, Parcel>(startedParcel);
    });

    tearDown(() => cubit.close());

    test('a push about the open parcel re-reads it', () async {
      push.emit(PushHint(PushTarget.parcel, id: sampleParcel.id));
      await pumpEventQueue();

      expect(cubit.state, const ParcelDetailsLoaded(startedParcel));
    });

    test('a parcel push naming no parcel re-reads it', () async {
      push.emit(const PushHint(PushTarget.parcel));
      await pumpEventQueue();

      expect(cubit.state, const ParcelDetailsLoaded(startedParcel));
    });

    test('a push about another parcel is ignored', () async {
      push.emit(PushHint(PushTarget.parcel, id: sampleParcel.id + 1));
      await pumpEventQueue();

      expect(cubit.state, const ParcelDetailsLoaded(sampleParcel));
    });
  });
}
