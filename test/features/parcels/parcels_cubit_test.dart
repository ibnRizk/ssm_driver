import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_driver/core/error/failures.dart';
import 'package:ssm_driver/features/parcels/domain/entities/parcel.dart';
import 'package:ssm_driver/features/parcels/presentation/cubit/parcels_cubit.dart';
import 'package:ssm_driver/features/parcels/presentation/cubit/parcels_state.dart';

import 'parcels_test_fakes.dart';

void main() {
  late FakeParcelsRepository repository;
  late ParcelsCubit cubit;

  setUp(() {
    repository = FakeParcelsRepository();
    cubit = ParcelsCubit(repository);
  });

  tearDown(() => cubit.close());

  /// One page of a [total]-parcel list, holding the given parcel ids.
  Either<Failure, ParcelsPage> pageOf(List<int> ids, {required int total}) =>
      Right<Failure, ParcelsPage>(
        ParcelsPage(
          parcels: <Parcel>[for (final int id in ids) parcelWithId(id)],
          totalSize: total,
        ),
      );

  List<int> loadedIds() => (cubit.state as ParcelsLoaded).page.parcels
      .map((Parcel p) => p.id)
      .toList();

  group('first page', () {
    test('emits loading then the page', () async {
      final expectation = expectLater(
        cubit.stream,
        emitsInOrder(<ParcelsState>[
          const ParcelsLoading(),
          const ParcelsLoaded(samplePage, hasMore: false),
        ]),
      );

      await cubit.loadParcels();
      await expectation;
    });

    test('asks for page 1 with the page size', () async {
      await cubit.loadParcels();

      expect(repository.requestedPages, <int>[1]);
      expect(repository.lastLimit, ParcelsCubit.pageSize);
    });

    test('has more when the total exceeds the loaded parcels', () async {
      repository.pageResults[1] = pageOf(<int>[1, 2], total: 3);

      await cubit.loadParcels();

      expect((cubit.state as ParcelsLoaded).hasMore, isTrue);
    });

    test('a refresh keeps the loaded list instead of a spinner', () async {
      await cubit.loadParcels();
      final List<ParcelsState> emitted = <ParcelsState>[];
      final sub = cubit.stream.listen(emitted.add);

      await cubit.loadParcels();
      await sub.cancel();

      expect(emitted.whereType<ParcelsLoading>(), isEmpty);
    });

    test('emits the failure message on error', () async {
      repository.pageResult = const Left<Failure, ParcelsPage>(
        NetworkFailure(message: 'No internet'),
      );

      await cubit.loadParcels();

      expect(cubit.state, const ParcelsError('No internet'));
    });
  });

  group('load more', () {
    setUp(() {
      repository.pageResults[1] = pageOf(<int>[1, 2], total: 3);
      repository.pageResults[2] = pageOf(<int>[3], total: 3);
    });

    test('appends the next page', () async {
      await cubit.loadParcels();

      await cubit.loadMore();

      expect(loadedIds(), <int>[1, 2, 3]);
      expect(repository.requestedPages, <int>[1, 2]);
    });

    test('shows progress while fetching', () async {
      await cubit.loadParcels();
      final expectation = expectLater(
        cubit.stream,
        emits(
          isA<ParcelsLoaded>().having(
            (ParcelsLoaded s) => s.isLoadingMore,
            'isLoadingMore',
            isTrue,
          ),
        ),
      );

      await cubit.loadMore();
      await expectation;
    });

    test('stops once every parcel is loaded', () async {
      await cubit.loadParcels();
      await cubit.loadMore();

      await cubit.loadMore();

      expect((cubit.state as ParcelsLoaded).hasMore, isFalse);
      expect(repository.requestedPages, <int>[1, 2]);
    });

    test('an empty page ends the list despite a larger total', () async {
      repository.pageResults[2] = pageOf(<int>[], total: 3);
      await cubit.loadParcels();

      await cubit.loadMore();

      expect((cubit.state as ParcelsLoaded).hasMore, isFalse);
    });

    test('a failure keeps the loaded parcels and reports the error', () async {
      repository.pageResults[2] = const Left<Failure, ParcelsPage>(
        NetworkFailure(message: 'offline'),
      );
      await cubit.loadParcels();

      await cubit.loadMore();

      final ParcelsLoaded state = cubit.state as ParcelsLoaded;
      expect(loadedIds(), <int>[1, 2]);
      expect(state.loadMoreError, 'offline');
    });

    test('after a failure scrolling does not retry by itself', () async {
      repository.pageResults[2] = const Left<Failure, ParcelsPage>(
        NetworkFailure(message: 'offline'),
      );
      await cubit.loadParcels();
      await cubit.loadMore();

      await cubit.loadMore();

      expect(repository.requestedPages, <int>[1, 2]);
    });

    test('retry fetches the same page again', () async {
      repository.pageResults[2] = const Left<Failure, ParcelsPage>(
        NetworkFailure(message: 'offline'),
      );
      await cubit.loadParcels();
      await cubit.loadMore();
      repository.pageResults[2] = pageOf(<int>[3], total: 3);

      await cubit.retryLoadMore();

      expect(repository.requestedPages, <int>[1, 2, 2]);
      expect(loadedIds(), <int>[1, 2, 3]);
    });

    test('a page arriving after a refresh is dropped', () async {
      await cubit.loadParcels();
      final Completer<void> gate = Completer<void>();
      repository.pageGates[2] = gate;
      final Future<void> more = cubit.loadMore();

      await cubit.loadParcels();
      gate.complete();
      await more;

      expect(loadedIds(), <int>[1, 2]);
    });

    test('a refresh starts again from page 1', () async {
      await cubit.loadParcels();
      await cubit.loadMore();

      await cubit.loadParcels();
      await cubit.loadMore();

      expect(repository.requestedPages, <int>[1, 2, 1, 2]);
    });
  });

  test('applyParcel swaps in the updated parcel', () async {
    await cubit.loadParcels();

    cubit.applyParcel(startedParcel);

    expect(
      cubit.state,
      const ParcelsLoaded(
        ParcelsPage(parcels: <Parcel>[startedParcel], totalSize: 1),
        hasMore: false,
      ),
    );
  });
}
