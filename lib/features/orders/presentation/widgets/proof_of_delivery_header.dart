import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:ssm_driver/core/utils/values/strings.dart';
import 'flow_back_button.dart';

class ProofOfDeliveryHeader extends StatelessWidget {
  final String orderId;

  const ProofOfDeliveryHeader({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Row(
      children: <Widget>[
        FlowBackButton(
          fillColor: c.surface,
          iconColor: c.primaryDark,
          padding: AppSpacing.sm,
        ),
        Expanded(
          child: Center(
            child: Text(
              Strings.orderProofOfDelivery,
              style: AppTextStyles.h1(color: c.primaryDark),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm.w,
            vertical: AppSpacing.xs.h,
          ),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: c.border),
          ),
          child: Text(
            Strings.orderIdTitle(orderId),
            style: AppTextStyles.label(color: c.textSecondary),
          ),
        ),
      ],
    );
  }
}
