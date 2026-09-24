import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:ssm_driver/core/utils/values/strings.dart';

class ParcelsHeader extends StatelessWidget {
  /// `null` while the list is loading (no count pill yet).
  final int? count;

  const ParcelsHeader({super.key, this.count});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final int? total = count;

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
            child: total == null
                ? const SizedBox.shrink()
                : Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md.w,
                      vertical: AppSpacing.xs.h,
                    ),
                    decoration: BoxDecoration(
                      color: c.secondary,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      Strings.parcelsCount(total),
                      style: AppTextStyles.label(color: Theme.of(context).colorScheme.onPrimary),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
