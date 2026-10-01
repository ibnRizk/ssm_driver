import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/uuid.dart';
import '../../../../core/utils/values/strings.dart';
import '../../domain/entities/problem_report.dart';
import '../../domain/repositories/orders_repository.dart';
import 'report_problem_state.dart';

/// Loads the problem reasons and sends one report for an order.
///
/// The `Idempotency-Key` is a fresh UUID per report, reused only to retry
/// the identical report after a network failure (outcome unknown) — the
/// server answers 409 if a key is reused for a different report.
class ReportProblemCubit extends Cubit<ReportProblemState> {
  final OrdersRepository _repository;
  final String Function() _newIdempotencyKey;

  /// The key and report it was used for, kept while a retry is a replay.
  ({String key, String fingerprint})? _pending;

  ReportProblemCubit(
    this._repository, {
    String Function() newIdempotencyKey = generateUuidV4,
  }) : _newIdempotencyKey = newIdempotencyKey,
       super(const ReportProblemLoading());

  Future<void> loadReasons() async {
    emit(const ReportProblemLoading());
    final result = await _repository.getProblemReasons();
    if (isClosed) return;
    emit(
      result.fold(
        (Failure f) =>
            ReportProblemLoadFailed(f.message ?? Strings.somethingWentWrong),
        (List<ProblemReason> reasons) => reasons.isEmpty
            ? const ReportProblemNoReasons()
            : ReportProblemReady(reasons: reasons),
      ),
    );
  }

  void select(ProblemReason reason) {
    final ReportProblemState current = state;
    if (current is! ReportProblemReady || current.isSubmitting) return;
    emit(ReportProblemReady(reasons: current.reasons, selected: reason));
  }

  Future<void> submit({required int orderId, String? note}) async {
    final ReportProblemState current = state;
    if (current is! ReportProblemReady || current.isSubmitting) return;
    final ProblemReason? reason = current.selected;
    if (reason == null) return;

    final String fingerprint = '$orderId:${reason.code}:${note ?? ''}';
    final String key = _pending?.fingerprint == fingerprint
        ? _pending!.key
        : _newIdempotencyKey();
    _pending = (key: key, fingerprint: fingerprint);

    emit(
      ReportProblemReady(
        reasons: current.reasons,
        selected: reason,
        isSubmitting: true,
      ),
    );
    final Either<Failure, ProblemReport> result = await _repository
        .reportProblem(
          orderId: orderId,
          reasonCode: reason.code,
          idempotencyKey: key,
          note: note,
        );
    if (isClosed) return;

    result.fold(
      (Failure f) {
        // Only a network failure leaves the outcome unknown; anything else
        // is definitive, so the next attempt is a new report.
        if (f is! NetworkFailure) _pending = null;
        emit(
          ReportProblemReady(
            reasons: current.reasons,
            selected: reason,
            submitError: f.message ?? Strings.somethingWentWrong,
          ),
        );
      },
      (ProblemReport report) {
        _pending = null;
        emit(ReportProblemSent(report));
      },
    );
  }
}
