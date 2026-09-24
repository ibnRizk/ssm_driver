import 'package:dartz/dartz.dart';
import 'package:ssm_driver/core/error/failures.dart';
import 'package:ssm_driver/core/services/location/device_location.dart';
import 'package:ssm_driver/features/home/data/datasources/home_remote_data_source.dart';
import 'package:ssm_driver/features/home/domain/repositories/home_repository.dart';

/// Throws [error] when set, otherwise returns the configured values.
class FakeHomeRemoteDataSource implements HomeRemoteDataSource {
  Object? error;
  bool isOnline = true;

  Future<T> _answer<T>(T value) async {
    if (error != null) throw error!;
    return value;
  }

  @override
  Future<bool> getOnlineStatus() => _answer(isOnline);

  @override
  Future<bool> goOnline() => _answer(true);

  @override
  Future<bool> goOffline() => _answer(false);

  @override
  Future<void> sendHeartbeat() => _answer(null);

  @override
  Future<void> publishLocation(DeviceLocation location) => _answer(null);
}

class FakeHomeRepository implements HomeRepository {
  Either<Failure, bool> onlineStatusResult = const Right<Failure, bool>(false);
  Either<Failure, bool> goOnlineResult = const Right<Failure, bool>(true);
  Either<Failure, bool> goOfflineResult = const Right<Failure, bool>(false);

  int toggleCalls = 0;
  int heartbeats = 0;
  final List<DeviceLocation> publishedLocations = <DeviceLocation>[];

  @override
  Future<Either<Failure, bool>> getOnlineStatus() async => onlineStatusResult;

  @override
  Future<Either<Failure, bool>> goOnline() async {
    toggleCalls++;
    return goOnlineResult;
  }

  @override
  Future<Either<Failure, bool>> goOffline() async {
    toggleCalls++;
    return goOfflineResult;
  }

  @override
  Future<Either<Failure, Unit>> sendHeartbeat() async {
    heartbeats++;
    return const Right<Failure, Unit>(unit);
  }

  @override
  Future<Either<Failure, Unit>> publishLocation(DeviceLocation location) async {
    publishedLocations.add(location);
    return const Right<Failure, Unit>(unit);
  }
}
