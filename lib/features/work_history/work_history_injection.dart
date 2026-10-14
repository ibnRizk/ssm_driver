import '../../injection_container.dart';
import 'data/datasources/work_history_remote_data_source.dart';
import 'data/repositories/work_history_repository_impl.dart';
import 'domain/repositories/work_history_repository.dart';
import 'presentation/cubit/work_history_cubit.dart';

/// Per-feature registration. Cubits depend directly on the repository
/// interface (no use-case layer).
Future<void> initWorkHistoryFeatureInjection() async {
  final sl = ServiceLocator.instance;

  /// Data
  sl.registerLazySingleton<WorkHistoryRemoteDataSource>(
    () => WorkHistoryRemoteDataSource(dioConsumer),
  );
  sl.registerLazySingleton<WorkHistoryRepository>(
    () => WorkHistoryRepositoryImpl(sl<WorkHistoryRemoteDataSource>()),
  );

  /// Cubits
  sl.registerFactory<WorkHistoryCubit>(
    () => WorkHistoryCubit(sl<WorkHistoryRepository>()),
  );
}
