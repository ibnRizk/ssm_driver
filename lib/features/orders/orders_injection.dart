import '../../core/services/location/location_service.dart';
import '../../core/services/ringtone/ringtone_service.dart';
import '../../injection_container.dart';
import 'data/datasources/orders_remote_data_source.dart';
import 'data/repositories/orders_repository_impl.dart';
import 'domain/repositories/orders_repository.dart';
import 'presentation/cubit/current_work_cubit.dart';
import 'presentation/cubit/incoming_order_cubit.dart';
import 'presentation/cubit/offer_polling_cubit.dart';
import 'presentation/cubit/order_lifecycle_cubit.dart';
import 'presentation/cubit/report_problem_cubit.dart';

/// Per-feature registration. Cubits depend directly on the repository
/// interface (no use-case layer).
Future<void> initOrdersFeatureInjection() async {
  final sl = ServiceLocator.instance;

  /// Data
  sl.registerLazySingleton<OrdersRemoteDataSource>(
    () => OrdersRemoteDataSource(dioConsumer),
  );
  sl.registerLazySingleton<OrdersRepository>(
    () => OrdersRepositoryImpl(sl<OrdersRemoteDataSource>()),
  );

  /// Cubits
  sl.registerFactory<IncomingOrderCubit>(
    () => IncomingOrderCubit(sl<OrdersRepository>(), sl<RingtoneService>()),
  );
  sl.registerFactory<CurrentWorkCubit>(
    () => CurrentWorkCubit(sl<OrdersRepository>()),
  );
  sl.registerFactory<OfferPollingCubit>(
    () => OfferPollingCubit(sl<OrdersRepository>()),
  );
  sl.registerFactory<OrderLifecycleCubit>(
    () => OrderLifecycleCubit(sl<OrdersRepository>(), sl<LocationService>()),
  );
  sl.registerFactory<ReportProblemCubit>(
    () => ReportProblemCubit(sl<OrdersRepository>()),
  );
}
