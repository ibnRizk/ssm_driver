import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';

class ParcelDetailsFooterBanner extends StatelessWidget {
  const ParcelDetailsFooterBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md.w,
        vertical: AppSpacing.sm.h,
      ),
      decoration: BoxDecoration(
        color: c.secondaryLight,
        borderRadius: BorderRadius.circular(AppRadius.md.r),
      ),
      alignment: Alignment.center,
      child: Text(
        'تحقق من هوية المستلم ثم أكمل إثبات التسليم.',
        style: AppTextStyles.caption(color: c.secondaryDark),
        textAlign: TextAlign.center,
      ),
    );
  }
}
