import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_driver/core/services/location/device_location.dart';
import 'package:ssm_driver/core/services/location/location_failure.dart';
import 'package:ssm_driver/features/home/presentation/cubit/location_tracking_cubit.dart';
import 'package:ssm_driver/features/home/presentation/cubit/location_tracking_state.dart';

import '../../helpers/fake_location_service.dart';
import 'home_test_fakes.dart';

void main() {
  late FakeHomeRepository repository;
  late FakeLocationService location;
  late LocationTrackingCubit cubit;

  setUp(() {
    repository = FakeHomeRepository();
    location = FakeLocationService();
    // Only the immediate report on start() runs; later ticks are driven by
    // calling reportNow() so the tests never depend on real time.
    cubit = LocationTrackingCubit(
      repository,
      location,
      interval: const Duration(hours: 1),
    );
  });

  tearDown(() => cubit.close());

  void blockLocation(LocationIssue issue) => location.result =
      Left<LocationFailure, DeviceLocation>(LocationFailure(issue));

  test('starting publishes the location and sends a heartbeat', () async {
    cubit.start();
    await pumpEventQueue();

    expect(repository.publishedLocations, <DeviceLocation>[sampleLocation]);
    expect(repository.heartbeats, 1);
    expect(cubit.state, const TrackingActive());
  });

  test('only the first report may show the permission prompt', () async {
    cubit.start();
    await pumpEventQueue();

    await cubit.reportNow();

    expect(location.permissionRequests, <bool>[true, false]);
  });

  test('without a fix the heartbeat is still sent', () async {
    blockLocation(LocationIssue.unavailable);

    cubit.start();
    await pumpEventQueue();

    expect(repository.publishedLocations, isEmpty);
    expect(repository.heartbeats, 1);
    expect(cubit.state, const TrackingBlocked(LocationIssue.unavailable));
  });

  test('a fix arriving again clears the blocked state', () async {
    blockLocation(LocationIssue.permissionDenied);
    cubit.start();
    await pumpEventQueue();
    location.result = Right<LocationFailure, DeviceLocation>(sampleLocation);

    await cubit.reportNow();

    expect(cubit.state, const TrackingActive());
  });

  test('nothing is sent while stopped', () async {
    await cubit.reportNow();

    expect(location.calls, 0);
    expect(repository.heartbeats, 0);
  });

  test('stopping mid-report skips the heartbeat', () async {
    cubit.start();
    cubit.stop();
    await pumpEventQueue();

    expect(repository.heartbeats, 0);
    expect(cubit.state, const TrackingStopped());
  });

  group('resolving a location issue', () {
    test('blocked permission opens the app settings', () async {
      blockLocation(LocationIssue.permissionDeniedForever);
      cubit.start();
      await pumpEventQueue();

      await cubit.resolveIssue();

      expect(location.appSettingsOpened, 1);
    });

    test('location services off opens the location settings', () async {
      blockLocation(LocationIssue.serviceDisabled);
      cubit.start();
      await pumpEventQueue();

      await cubit.resolveIssue();

      expect(location.locationSettingsOpened, 1);
    });

    test('an undecided permission is asked for again', () async {
      blockLocation(LocationIssue.permissionDenied);
      cubit.start();
      await pumpEventQueue();

      await cubit.resolveIssue();

      expect(location.permissionRequests, <bool>[true, true]);
    });
  });
}
