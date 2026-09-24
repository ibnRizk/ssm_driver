import '../../core/services/location/location_service.dart';
import '../../injection_container.dart';
import 'data/datasources/parcels_remote_data_source.dart';
import 'data/repositories/parcels_repository_impl.dart';
import 'domain/repositories/parcels_repository.dart';
import 'presentation/cubit/parcel_action_cubit.dart';
import 'presentation/cubit/parcel_details_cubit.dart';
import 'presentation/cubit/parcels_cubit.dart';

/// Per-feature registration. Cubits depend directly on the repository
/// interface (no use-case layer).
Future<void> initParcelsFeatureInjection() async {
  final sl = ServiceLocator.instance;

  /// Data
  sl.registerLazySingleton<ParcelsRemoteDataSource>(
    () => ParcelsRemoteDataSource(dioConsumer),
  );
  sl.registerLazySingleton<ParcelsRepository>(
    () => ParcelsRepositoryImpl(sl<ParcelsRemoteDataSource>()),
  );

  /// Cubits
  sl.registerFactory<ParcelsCubit>(() => ParcelsCubit(sl<ParcelsRepository>()));
  sl.registerFactory<ParcelDetailsCubit>(
    () => ParcelDetailsCubit(sl<ParcelsRepository>()),
  );
  sl.registerFactory<ParcelActionCubit>(
    () => ParcelActionCubit(sl<ParcelsRepository>(), sl<LocationService>()),
  );
}
