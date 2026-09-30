import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/values/strings.dart';
import '../../domain/repositories/home_repository.dart';
import 'availability_state.dart';

/// The Driver's online/offline switch. Local state only ever changes to what
/// the server confirmed (API docs §9, §17).
class AvailabilityCubit extends Cubit<AvailabilityState> {
  final HomeRepository _repository;

  AvailabilityCubit(this._repository) : super(const AvailabilityLoading());

  Future<void> load() async {
    emit(const AvailabilityLoading());
    _apply(await _repository.getOnlineStatus(), previous: null);
  }

  Future<void> toggle() async {
    final AvailabilityState current = state;
    final bool? isOnline = current.isOnline;
    if (isOnline == null) return load();
    if (current is AvailabilityLoaded && current.isUpdating) return;

    emit(AvailabilityLoaded(isOnline: isOnline, isUpdating: true));
    _apply(
      isOnline ? await _repository.goOffline() : await _repository.goOnline(),
      previous: isOnline,
    );
  }

  void _apply(Either<Failure, bool> result, {required bool? previous}) {
    if (isClosed) return;
    result.fold(
      (Failure f) => emit(
        AvailabilityError(
          message: f.message ?? Strings.somethingWentWrong,
          isOnline: previous,
        ),
      ),
      (bool isOnline) => emit(AvailabilityLoaded(isOnline: isOnline)),
    );
  }

  void reset() {
    emit(const AvailabilityLoading());
  }
}
