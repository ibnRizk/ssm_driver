import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/app_button.dart';

/// The accept/reject pair under [OrderSummaryCard] — accept leads (right,
/// solid orange), reject trails (left, light gray).
class OrderActionButtons extends StatelessWidget {
  final String acceptLabel;
  final String rejectLabel;
  final bool isAccepting;
  final bool isRejecting;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const OrderActionButtons({
    super.key,
    required this.acceptLabel,
    required this.rejectLabel,
    required this.onAccept,
    required this.onReject,
    this.isAccepting = false,
    this.isRejecting = false,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final bool busy = isAccepting || isRejecting;

    return Row(
      children: <Widget>[
        Expanded(
          child: AppButton(
            btnText: acceptLabel,
            isLoading: isAccepting,
            onPressed: busy ? null : onAccept,
          ),
        ),
        SizedBox(width: AppSpacing.sm.w),
        Expanded(
          child: AppButton(
            btnText: rejectLabel,
            isLoading: isRejecting,
            color: c.border,
            textColor: c.textPrimary,
            onPressed: busy ? null : onReject,
          ),
        ),
      ],
    );
  }
}
