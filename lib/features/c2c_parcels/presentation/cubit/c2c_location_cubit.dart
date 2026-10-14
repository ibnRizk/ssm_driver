import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/services/location/device_location.dart';
import '../../../../core/services/location/location_failure.dart';
import '../../../../core/services/location/location_service.dart';
import '../../../../core/services/push/push_hint.dart';
import '../../domain/entities/c2c_parcel.dart';
import '../../domain/repositories/c2c_parcels_repository.dart';

/// Posts the Driver's position to `POST /c2c-parcels/{id}/location` every
/// [interval] for each active C2C job — customer tracking shows only what
/// the app reports (contract §4).
///
/// The state is the number of jobs being reported for. The job list is
/// re-read every [refreshEvery] ticks and on every C2C push, so a job
/// accepted or finished anywhere starts or stops its pings.
class C2cLocationCubit extends Cubit<int> {
  final C2cParcelsRepository _repository;
  final LocationService _location;
  final Duration interval;
  final int refreshEvery;
  StreamSubscription<PushHint>? _pushSubscription;

  Timer? _timer;
  int _ticks = 0;
  bool _inFlight = false;

  /// `null` until the first successful read.
  List<int>? _activeIds;

  C2cLocationCubit(
    this._repository,
    this._location, {
    Stream<PushHint>? pushHints,
    this.interval = const Duration(seconds: 20),
    this.refreshEvery = 3,
  }) : super(0) {
    _pushSubscription = pushHints
        ?.where((PushHint hint) => hint.concerns(PushTarget.c2cParcel))
        .listen((_) => reportNow(refreshJobs: true));
  }

  /// Reads the jobs and reports right away, then every [interval].
  void start() {
    if (_timer != null) return;
    _timer = Timer.periodic(interval, (_) => reportNow());
    reportNow(refreshJobs: true);
  }

  /// One round. Never asks for the location permission — that's for the
  /// Driver's own actions; without a fix the round is skipped.
  Future<void> reportNow({bool refreshJobs = false}) async {
    if (_inFlight) return;
    _inFlight = true;
    try {
      _ticks++;
      if (refreshJobs || _activeIds == null || _ticks % refreshEvery == 0) {
        await _refreshJobs();
      }
      final List<int> ids = _activeIds ?? const <int>[];
      if (isClosed || ids.isEmpty) return;

      final Either<LocationFailure, DeviceLocation> fix = await _location
          .currentLocation();
      if (isClosed) return;
      final DeviceLocation? location = fix.fold((_) => null, (l) => l);
      if (location == null) return;
      // Failures are dropped on purpose: the next tick sends a fresher fix.
      await Future.wait(<Future<Either<Failure, Unit>>>[
        for (final int id in ids) _repository.sendLocation(id, location),
      ]);
    } finally {
      _inFlight = false;
    }
  }

  Future<void> _refreshJobs() async {
    final Either<Failure, List<C2cParcel>> result = await _repository
        .getActiveJobs();
    if (isClosed) return;
    // A failed read keeps the last known jobs pinging.
    result.fold((_) {}, (List<C2cParcel> jobs) {
      _activeIds = <int>[
        for (final C2cParcel job in jobs)
          if (job.isActiveWork) job.id,
      ];
      emit(_activeIds!.length);
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _timer = null;
    _pushSubscription?.cancel();
    return super.close();
  }
}
