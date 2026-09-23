import '../../domain/entities/approval_status.dart';
import '../../domain/entities/onboarding_status.dart';

class OnboardingStatusModel extends OnboardingStatus {
  const OnboardingStatusModel({
    required super.name,
    required super.approvalStatus,
    required super.canOperate,
    super.rejectionReason,
  });

  factory OnboardingStatusModel.fromJson(Map<String, dynamic> json) {
    return OnboardingStatusModel(
      name: json['name'] as String? ?? '',
      approvalStatus: ApprovalStatus.fromApi(json['approval_status'] as String?),
      canOperate: json['can_operate'] == true,
      rejectionReason: json['rejection_reason'] as String?,
    );
  }
}
