import '../../injection_container.dart';
import 'data/datasources/auth_remote_data_source.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'presentation/cubit/login_cubit.dart';
import 'presentation/cubit/register_cubit.dart';
import 'presentation/cubit/session_cubit.dart';

/// Per-feature registration. Cubits depend directly on the repository
/// interface (no use-case layer).
Future<void> initAuthFeatureInjection() async {
  final sl = ServiceLocator.instance;

  /// Data
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(dioConsumer),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remote: sl<AuthRemoteDataSource>(),
      storage: secureStorage,
    ),
  );

  /// Cubits
  sl.registerFactory<LoginCubit>(() => LoginCubit(sl<AuthRepository>()));
  sl.registerFactory<RegisterCubit>(() => RegisterCubit(sl<AuthRepository>()));
  // App-wide: provided once in App, shared by splash, onboarding and logout.
  sl.registerLazySingleton<SessionCubit>(
    () => SessionCubit(sl<AuthRepository>()),
  );
}
