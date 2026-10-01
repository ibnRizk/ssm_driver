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

/// Reasons loaded; the Driver picks one and submits.
class ReportProblemReady extends ReportProblemState {
  final List<ProblemReason> reasons;
  final ProblemReason? selected;
  final bool isSubmitting;

  /// Why the last submit failed; the form stays so the Driver can retry.
  final String? submitError;

  const ReportProblemReady({
    required this.reasons,
    this.selected,
    this.isSubmitting = false,
    this.submitError,
  });

  @override
  List<Object?> get props => [reasons, selected, isSubmitting, submitError];
}

class ReportProblemSent extends ReportProblemState {
  final ProblemReport report;

  const ReportProblemSent(this.report);

  @override
  List<Object?> get props => [report];
}
