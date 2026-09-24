import '../../core/services/location/location_service.dart';
import '../../injection_container.dart';
import 'data/datasources/home_remote_data_source.dart';
import 'data/repositories/home_repository_impl.dart';
import 'domain/repositories/home_repository.dart';
import 'presentation/cubit/availability_cubit.dart';
import 'presentation/cubit/home_cubit.dart';
import 'presentation/cubit/location_tracking_cubit.dart';

/// Per-feature registration. Cubits depend directly on the repository
/// interface (no use-case layer).
///
/// Convention: cubits are `registerFactory` (fresh instance per provider),
/// while repositories and data sources are `registerLazySingleton`.
Future<void> initHomeFeatureInjection() async {
  final sl = ServiceLocator.instance;

  /// Data
  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSource(dioConsumer),
  );
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(sl<HomeRemoteDataSource>()),
  );

  /// Cubits
  sl.registerFactory<HomeCubit>(() => HomeCubit(sl<HomeRepository>()));
  sl.registerFactory<AvailabilityCubit>(
    () => AvailabilityCubit(sl<HomeRepository>()),
  );
  sl.registerFactory<LocationTrackingCubit>(
    () => LocationTrackingCubit(sl<HomeRepository>(), sl<LocationService>()),
  );
}
