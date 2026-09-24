import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/values/strings.dart';
import '../../domain/entities/cod_summary.dart';
import '../../domain/entities/incentive_summary.dart';
import '../../domain/repositories/home_repository.dart';
import 'home_state.dart';

/// Dashboard stats: COD liability + incentive progress.
///
/// Provided app-wide (owned by `app.dart`, which resets it on sign-out) so the delivery flow can refresh it
/// after a completion — those screens live outside the bottom-nav shell.
class HomeCubit extends Cubit<HomeState> {
  final HomeRepository _repository;

  HomeCubit(this._repository) : super(const HomeInitial());

  /// First load for this session — always shows the loading state, so a
  /// previous Driver's numbers never flash after a re-login.
  Future<void> loadDashboard() async {
    emit(const HomeLoading());
    await _fetch();
  }

  /// Keeps the current numbers on screen until fresh ones arrive.
  Future<void> refreshDashboard() async {
    if (state is! HomeLoaded) emit(const HomeLoading());
    await _fetch();
  }

  /// Drops the signed-out Driver's numbers from memory (logout / 401).
  void reset() => emit(const HomeInitial());

  Future<void> _fetch() async {
    final (
      Either<Failure, CodSummary> codResult,
      Either<Failure, IncentiveSummary> incentiveResult,
    ) = await (
      _repository.getCodSummary(),
      _repository.getIncentiveSummary(),
    ).wait;
    if (isClosed) return;

    codResult.fold(
      _emitError,
      (CodSummary cod) => incentiveResult.fold(
        _emitError,
        (IncentiveSummary incentive) =>
            emit(HomeLoaded(cod: cod, incentive: incentive)),
      ),
    );
  }

  void _emitError(Failure f) =>
      emit(HomeError(message: f.message ?? Strings.somethingWentWrong));
}
