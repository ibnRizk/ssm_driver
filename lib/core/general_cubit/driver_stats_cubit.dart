import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../error/failures.dart';
import '../services/driver_stats/cod_summary.dart';
import '../services/driver_stats/driver_stats_repository.dart';
import '../services/driver_stats/incentive_summary.dart';
import '../utils/values/strings.dart';
import 'driver_stats_state.dart';

/// The Driver's COD liability + incentive progress, read by the Home and
/// Earnings tabs.
///
/// Provided app-wide (owned by `app.dart`, which resets it on sign-out) so
/// the delivery flow can refresh it after a completion and every tab shows
/// the same numbers — those screens live outside the bottom-nav shell.
class DriverStatsCubit extends Cubit<DriverStatsState> {
  final DriverStatsRepository _repository;

  DriverStatsCubit(this._repository) : super(const DriverStatsInitial());

  /// First load for this session — always shows the loading state, so a
  /// previous Driver's numbers never flash after a re-login.
  Future<void> loadStats() async {
    emit(const DriverStatsLoading());
    await _fetch();
  }

  /// Keeps the current numbers on screen until fresh ones arrive.
  Future<void> refreshStats() async {
    if (state is! DriverStatsLoaded) emit(const DriverStatsLoading());
    await _fetch();
  }

  /// Drops the signed-out Driver's numbers from memory (logout / 401).
  void reset() => emit(const DriverStatsInitial());

  /// Both summaries are fetched concurrently; either failing fails the load.
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
            emit(DriverStatsLoaded(cod: cod, incentive: incentive)),
      ),
    );
  }

  void _emitError(Failure f) =>
      emit(DriverStatsError(message: f.message ?? Strings.somethingWentWrong));
}
