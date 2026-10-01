import 'package:equatable/equatable.dart';

/// A reason the Driver can report (`GET /delivery-man/problem-reasons`).
/// [label] is already translated by the server.
class ProblemReason extends Equatable {
  final String code;
  final String label;

  const ProblemReason({required this.code, required this.label});

  @override
  List<Object?> get props => [code, label];
}

/// The server's answer to a problem report. A report never changes the
/// order — it opens a support case, and [nextAction] is `continue_order`.
class ProblemReport extends Equatable {
  final int reportId;
  final String nextAction;

  /// True when the same Idempotency-Key was already accepted (a retry).
  final bool isReplay;

  const ProblemReport({
    required this.reportId,
    required this.nextAction,
    required this.isReplay,
  });

  @override
  List<Object?> get props => [reportId, nextAction, isReplay];
}
