import 'package:equatable/equatable.dart';

import '../../domain/entities/problem_report.dart';

sealed class ReportProblemState extends Equatable {
  const ReportProblemState();

  @override
  List<Object?> get props => [];
}

class ReportProblemLoading extends ReportProblemState {
  const ReportProblemLoading();
}

/// The server answered with no reasons to pick from.
class ReportProblemNoReasons extends ReportProblemState {
  const ReportProblemNoReasons();
}

/// The reasons couldn't be loaded.
class ReportProblemLoadFailed extends ReportProblemState {
  final String message;

  const ReportProblemLoadFailed(this.message);

  @override
  List<Object?> get props => [message];
}

/// What the Driver sends with the picked reason.
enum ProblemAction {
  /// A support case; the order carries on.
  report,

  /// The order is given up: released before pickup, failed after.
  giveUp,
}

/// Reasons loaded; the Driver picks one and submits.
class ReportProblemReady extends ReportProblemState {
  final List<ProblemReason> reasons;
  final ProblemReason? selected;

  /// The action on its way, if any.
  final ProblemAction? inFlight;

  /// Why the last submit failed; the form stays so the Driver can retry.
  final String? submitError;

  /// A give-up was refused unsent: the note is under
  /// [giveUpNoteMinLength] characters.
  final bool noteTooShort;

  /// A give-up got a definitive refusal (e.g. 409 stale `expected_version`):
  /// the order may have moved on, so `current-work` must be re-read before
  /// the Driver tries again.
  final bool workStale;

  const ReportProblemReady({
    required this.reasons,
    this.selected,
    this.inFlight,
    this.submitError,
    this.noteTooShort = false,
    this.workStale = false,
  });

  bool get isSubmitting => inFlight != null;

  @override
  List<Object?> get props => [
    reasons,
    selected,
    inFlight,
    submitError,
    noteTooShort,
    workStale,
  ];
}

class ReportProblemSent extends ReportProblemState {
  final ProblemReport report;

  const ReportProblemSent(this.report);

  @override
  List<Object?> get props => [report];
}

/// The order was given up and has left the Driver's `current-work`.
/// [pickedUp] tells whether it was released or its delivery failed.
class ReportProblemGaveUp extends ReportProblemState {
  final bool pickedUp;

  const ReportProblemGaveUp({required this.pickedUp});

  @override
  List<Object?> get props => [pickedUp];
}
