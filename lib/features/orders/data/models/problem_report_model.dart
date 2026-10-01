import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/json_readers.dart';
import '../../domain/entities/problem_report.dart';

/// `GET /delivery-man/problem-reasons` → a bare array of `{code, label}`.
class ProblemReasonModel extends ProblemReason {
  const ProblemReasonModel({required super.code, required super.label});

  /// Entries without a code or label can't be reported, so they're skipped.
  /// Throws [ServerException] when the body isn't a list.
  static List<ProblemReasonModel> listFromJson(dynamic json) {
    if (json is! List) throw const ServerException();
    return <ProblemReasonModel>[
      for (final dynamic entry in json)
        if (entry is Map)
          if ((_text(entry['code']), _text(entry['label']))
              case (final String code, final String label))
            ProblemReasonModel(code: code, label: label),
    ];
  }

  static String? _text(dynamic value) =>
      value is String && value.trim().isNotEmpty ? value.trim() : null;
}

/// `POST /delivery-man/orders/{id}/report-problem` →
/// `{ report_id, next_action, idempotent_replay }`.
class ProblemReportModel extends ProblemReport {
  const ProblemReportModel({
    required super.reportId,
    required super.nextAction,
    required super.isReplay,
  });

  factory ProblemReportModel.fromJson(Map<String, dynamic> json) =>
      ProblemReportModel(
        reportId: readInt(json['report_id']),
        // The documented (and only) action; the order carries on.
        nextAction: json['next_action'] as String? ?? 'continue_order',
        isReplay: json['idempotent_replay'] == true,
      );
}
