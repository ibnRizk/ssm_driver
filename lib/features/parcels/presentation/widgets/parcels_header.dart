import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:ssm_driver/core/utils/values/strings.dart';

class ParcelsHeader extends StatelessWidget {
  const ParcelsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Row(
      children: <Widget>[
        const Expanded(child: SizedBox()),
        Text(
          Strings.parcelsTodayTitle,
          style: AppTextStyles.h1(color: c.primaryDark).copyWith(fontSize: 24.sp),
        ),
        Expanded(
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md.w,
                vertical: AppSpacing.xs.h,
              ),
              decoration: BoxDecoration(
                color: c.secondary,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text(
                Strings.parcelsMockCount,
                style: AppTextStyles.label(color: Theme.of(context).colorScheme.onPrimary),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
