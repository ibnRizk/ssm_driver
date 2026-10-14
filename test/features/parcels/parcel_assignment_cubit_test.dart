import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_driver/core/error/failures.dart';
import 'package:ssm_driver/core/services/push/push_hint.dart';
import 'package:ssm_driver/features/parcels/data/models/parcel_model.dart';
import 'package:ssm_driver/features/parcels/domain/entities/parcel.dart';
import 'package:ssm_driver/features/parcels/presentation/cubit/parcel_assignment_cubit.dart';
import 'package:ssm_driver/features/parcels/presentation/cubit/parcel_assignment_state.dart';

import '../../helpers/fake_push_service.dart';
import 'parcels_test_fakes.dart';

void main() {
  late FakeParcelsRepository repository;
  late FakePushService push;
  late ParcelAssignmentCubit cubit;

  Either<Failure, ParcelsPage> pageOf(List<Parcel> parcels) =>
      Right<Failure, ParcelsPage>(
        ParcelsPage(parcels: parcels, totalSize: parcels.length),
      );

  setUp(() {
    repository = FakeParcelsRepository();
    push = FakePushService();
    cubit = ParcelAssignmentCubit(repository, arrivals: push.received);
  });

  tearDown(() => cubit.close());

  test('parcels assigned before the start are never announced', () async {
    repository.pageResult = pageOf(<Parcel>[parcelWithId(1)]);
    await cubit.start();

    push.receive(const PushHint(PushTarget.parcel));
    await pumpEventQueue();

    expect(cubit.state, const ParcelAssignmentIdle());
  });

  test('a parcel push that lists a new parcel announces it', () async {
    repository.pageResult = pageOf(<Parcel>[parcelWithId(1)]);
    await cubit.start();
    final Parcel added = parcelWithId(2);
    repository.pageResult = pageOf(<Parcel>[parcelWithId(1), added]);

    push.receive(const PushHint(PushTarget.parcel, id: 2));
    await pumpEventQueue();

    expect(cubit.state, ParcelAssignmentFound(<Parcel>[added]));
  });

  test('a parcel is announced only once', () async {
    repository.pageResult = pageOf(<Parcel>[]);
    await cubit.start();
    repository.pageResult = pageOf(<Parcel>[parcelWithId(2)]);
    push.receive(const PushHint(PushTarget.parcel));
    await pumpEventQueue();
    final List<ParcelAssignmentState> later = <ParcelAssignmentState>[];
    final sub = cubit.stream.listen(later.add);

    push.receive(const PushHint(PushTarget.parcel));
    await pumpEventQueue();

    expect(later, isEmpty);
    await sub.cancel();
  });

  test('an opened notification is not announced', () async {
    repository.pageResult = pageOf(<Parcel>[]);
    await cubit.start();
    repository.pageResult = pageOf(<Parcel>[parcelWithId(2)]);

    // A tap reaches hints but not received: the tap router opens it.
    push.emit(const PushHint(PushTarget.parcel, id: 2));
    await pumpEventQueue();

    expect(cubit.state, const ParcelAssignmentIdle());
  });

  test('an order push does not re-read the parcels', () async {
    await cubit.start();

    push.receive(const PushHint(PushTarget.order));
    await pumpEventQueue();

    expect(repository.requestedPages, <int>[1]);
  });

  test('without a baseline the first push only records one', () async {
    repository.pageResult = const Left<Failure, ParcelsPage>(
      NetworkFailure(message: 'offline'),
    );
    await cubit.start();
    repository.pageResult = pageOf(<Parcel>[parcelWithId(2)]);

    push.receive(const PushHint(PushTarget.parcel));
    await pumpEventQueue();

    expect(cubit.state, const ParcelAssignmentIdle());
  });

  test('a delivered parcel is not announced', () async {
    repository.pageResult = pageOf(<Parcel>[]);
    await cubit.start();
    repository.pageResult = pageOf(<Parcel>[
      ParcelModel.fromJson(parcelJson(id: 5, status: 'DELIVERED')),
    ]);

    push.receive(const PushHint(PushTarget.parcel));
    await pumpEventQueue();

    expect(cubit.state, const ParcelAssignmentIdle());
  });

  test('reads a wide first page', () async {
    await cubit.start();

    expect(repository.lastLimit, ParcelAssignmentCubit.watchLimit);
  });
}
