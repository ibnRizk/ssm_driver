import '../../injection_container.dart';
import 'data/datasources/support_remote_data_source.dart';
import 'data/repositories/support_repository_impl.dart';
import 'domain/repositories/support_repository.dart';
import 'presentation/cubit/support_cubit.dart';

/// Per-feature registration. Cubits depend directly on the repository
/// interface (no use-case layer).
Future<void> initSupportFeatureInjection() async {
  final sl = ServiceLocator.instance;

  /// Data
  sl.registerLazySingleton<SupportRemoteDataSource>(
    () => SupportRemoteDataSource(dioConsumer),
  );
  sl.registerLazySingleton<SupportRepository>(
    () => SupportRepositoryImpl(sl<SupportRemoteDataSource>()),
  );

  /// Cubits
  sl.registerFactory<SupportCubit>(() => SupportCubit(sl<SupportRepository>()));
}
