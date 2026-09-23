import 'package:equatable/equatable.dart';

import 'approval_status.dart';

class OnboardingStatus extends Equatable {
  final String name;
  final ApprovalStatus approvalStatus;
  final bool canOperate;
  final String? rejectionReason;

  const OnboardingStatus({
    required this.name,
    required this.approvalStatus,
    required this.canOperate,
    this.rejectionReason,
  });

  @override
  List<Object?> get props => [name, approvalStatus, canOperate, rejectionReason];
}
