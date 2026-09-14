import '../../injection_container.dart';
import 'presentation/cubit/login_cubit.dart';

/// Per-feature registration. See `home_injection.dart` for the full-shape
/// convention (usecases/repos/datasources go here too, once the auth API
/// exists).
Future<void> initAuthFeatureInjection() async {
  /// Cubits
  ServiceLocator.instance.registerFactory<LoginCubit>(() => LoginCubit());
}
