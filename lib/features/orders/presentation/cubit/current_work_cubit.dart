import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/values/strings.dart';
import '../../domain/entities/current_work.dart';
import '../../domain/repositories/orders_repository.dart';
import 'current_work_state.dart';

/// Holds the Driver's active order. One instance is created by the Orders
/// tab and shared with the trip screen it pushes.
class CurrentWorkCubit extends Cubit<CurrentWorkState> {
  final OrdersRepository _repository;

  CurrentWorkCubit(this._repository) : super(const CurrentWorkInitial());

  /// Shows the loading state only on the first load, so a pull-to-refresh
  /// keeps the current content on screen until the new result arrives.
  Future<void> loadCurrentWork() async {
    if (state is! CurrentWorkLoaded && state is! CurrentWorkEmpty) {
      emit(const CurrentWorkLoading());
    }
    final result = await _repository.getCurrentWork();
    if (isClosed) return;
    result.fold(
      (Failure f) =>
          emit(CurrentWorkError(f.message ?? Strings.somethingWentWrong)),
      (CurrentWork? work) => emit(
        work == null ? const CurrentWorkEmpty() : CurrentWorkLoaded(work),
      ),
    );
  }
}
