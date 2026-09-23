import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes/app_routes.dart';
import '../domain/entities/approval_status.dart';

extension AuthNavigation on BuildContext {
  /// Approved drivers go to the dashboard; pending and rejected drivers are
  /// held at the onboarding status screen.
  void goAfterAuth(ApprovalStatus status) => goNamed(
    status == ApprovalStatus.approved
        ? AppRoutes.homeName
        : AppRoutes.onboardingStatusName,
  );
}
