import '../../injection_container.dart';
import 'presentation/cubit/incoming_order_cubit.dart';

/// Per-feature registration. See `home_injection.dart` for the full-shape
/// convention (usecases/repos/datasources go here too, once the orders API
/// exists).
Future<void> initOrdersFeatureInjection() async {
  /// Cubits
  ServiceLocator.instance.registerFactory<IncomingOrderCubit>(
    () => IncomingOrderCubit(),
  );
}
