import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/uuid.dart';
import '../../../../core/utils/values/strings.dart';
import '../../domain/entities/current_work.dart';
import '../../domain/entities/problem_report.dart';
import '../../domain/repositories/orders_repository.dart';
import 'report_problem_state.dart';

/// Loads the problem reasons, then sends one report for an order — or gives
/// the order up when the Driver can't finish it.
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

  /// Opens a support case for [orderId]; the order carries on.
  Future<void> submit({required int orderId, String? note}) => _send(
    ProblemAction.report,
    fingerprint: 'report:$orderId',
    note: note,
    send: (ProblemReason reason, String key, String? note) async =>
        (await _repository.reportProblem(
          orderId: orderId,
          reasonCode: reason.code,
          idempotencyKey: key,
          note: note,
        )).map<ReportProblemState>(ReportProblemSent.new),
  );

  /// Gives [work] up for the picked reason: released back to dispatch
  /// before pickup, a failed delivery after it.
  Future<void> giveUp({required CurrentWork work, String? note}) {
    final bool pickedUp = !work.awaitingPickup;
    return _send(
      ProblemAction.giveUp,
      fingerprint: 'giveUp:${work.orderId}:$pickedUp',
      note: note,
      send: (ProblemReason reason, String key, String? note) async =>
          (await _repository.giveUpOrder(
            orderId: work.orderId,
            pickedUp: pickedUp,
            reasonCode: reason.code,
            idempotencyKey: key,
            note: note,
            expectedVersion: work.statusVersion > 0 ? work.statusVersion : null,
          )).map<ReportProblemState>(
            (_) => ReportProblemGaveUp(pickedUp: pickedUp),
          ),
    );
  }

  Future<void> _send(
    ProblemAction action, {
    required String fingerprint,
    required String? note,
    required Future<Either<Failure, ReportProblemState>> Function(
      ProblemReason reason,
      String key,
      String? note,
    )
    send,
  }) async {
    final ReportProblemState current = state;
    if (current is! ReportProblemReady || current.isSubmitting) return;
    final ProblemReason? reason = current.selected;
    if (reason == null) return;
    final String? trimmed = note?.trim();
    final String? cleanNote = trimmed == null || trimmed.isEmpty
        ? null
        : trimmed;

    final String sent = '$fingerprint:${reason.code}:${cleanNote ?? ''}';
    final String key = _pending?.fingerprint == sent
        ? _pending!.key
        : _newIdempotencyKey();
    _pending = (key: key, fingerprint: sent);

    emit(
      ReportProblemReady(
        reasons: current.reasons,
        selected: reason,
        inFlight: action,
      ),
    );
    final Either<Failure, ReportProblemState> result = await send(
      reason,
      key,
      cleanNote,
    );
    if (isClosed) return;

    result.fold(
      (Failure f) {
        // Only a network failure leaves the outcome unknown; anything else
        // is definitive, so the next attempt is a new command.
        if (f is! NetworkFailure) _pending = null;
        emit(
          ReportProblemReady(
            reasons: current.reasons,
            selected: reason,
            submitError: f.message ?? Strings.somethingWentWrong,
          ),
        );
      },
      (ReportProblemState done) {
        _pending = null;
        emit(done);
      },
    );
  }
}
