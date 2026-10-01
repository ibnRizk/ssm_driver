import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/values/strings.dart';
import '../../domain/entities/zone.dart';
import '../../domain/repositories/auth_repository.dart';
import 'zones_state.dart';

/// The zone choices on the registration form.
class ZonesCubit extends Cubit<ZonesState> {
  final AuthRepository _authRepository;

  ZonesCubit(this._authRepository) : super(const ZonesLoading());

  Future<void> load() async {
    emit(const ZonesLoading());
    final result = await _authRepository.getZones();
    if (isClosed) return;
    emit(
      result.fold(
        (Failure f) =>
            ZonesError(message: f.message ?? Strings.somethingWentWrong),
        (List<Zone> zones) =>
            zones.isEmpty ? const ZonesEmpty() : ZonesLoaded(zones),
      ),
    );
  }
}
