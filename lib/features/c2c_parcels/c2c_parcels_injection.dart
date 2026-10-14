import '../../core/services/location/location_service.dart';
import '../../injection_container.dart';
import 'data/datasources/c2c_parcels_remote_data_source.dart';
import 'data/repositories/c2c_parcels_repository_impl.dart';
import 'domain/repositories/c2c_parcels_repository.dart';
import 'presentation/cubit/c2c_action_cubit.dart';
import 'presentation/cubit/c2c_board_cubit.dart';
import 'presentation/cubit/c2c_job_cubit.dart';
import 'presentation/cubit/c2c_location_cubit.dart';
import 'presentation/cubit/c2c_offer_watch_cubit.dart';

/// Per-feature registration. Cubits depend directly on the repository
/// interface (no use-case layer).
Future<void> initC2cParcelsFeatureInjection() async {
  final sl = ServiceLocator.instance;

  /// Data
  sl.registerLazySingleton<C2cParcelsRemoteDataSource>(
    () => C2cParcelsRemoteDataSource(dioConsumer),
  );
  sl.registerLazySingleton<C2cParcelsRepository>(
    () => C2cParcelsRepositoryImpl(sl<C2cParcelsRemoteDataSource>()),
  );

  /// Cubits
  sl.registerFactory<C2cBoardCubit>(
    () => C2cBoardCubit(sl<C2cParcelsRepository>(), pushHints: pushService.hints),
  );
  sl.registerFactory<C2cJobCubit>(
    () => C2cJobCubit(sl<C2cParcelsRepository>(), pushHints: pushService.hints),
  );
  sl.registerFactory<C2cActionCubit>(
    () => C2cActionCubit(sl<C2cParcelsRepository>()),
  );
  sl.registerFactory<C2cOfferWatchCubit>(
    () => C2cOfferWatchCubit(
      sl<C2cParcelsRepository>(),
      arrivals: pushService.received,
    ),
  );
  sl.registerFactory<C2cLocationCubit>(
    () => C2cLocationCubit(
      sl<C2cParcelsRepository>(),
      sl<LocationService>(),
      pushHints: pushService.hints,
    ),
  );
}
