import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:ssm_driver/core/utils/values/strings.dart';

class ParcelDetailsHeader extends StatelessWidget {
  /// `null` while the parcel is still loading (no id pill yet).
  final String? parcelId;

  /// Defaults to the "Parcel Details" title.
  final String? title;

  const ParcelDetailsHeader({super.key, required this.parcelId, this.title});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final String? id = parcelId;

    return Row(
      children: <Widget>[
        Material(
          color: c.surface,
          shape: CircleBorder(side: BorderSide(color: c.border)),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => Navigator.of(context).maybePop(),
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.sm.r),
              child: Icon(
                Icons.chevron_left_rounded, color: c.primaryDark,
                size: 24.r,
                ),
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: Text(
              title ?? Strings.parcelDetailsTitle,
              style: AppTextStyles.h1(color: c.primaryDark).copyWith(fontSize: 24.sp),
            ),
          ),
        ),
        if (id != null)
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
              id,
              textDirection: TextDirection.ltr,
              style: AppTextStyles.label(color: c.textSecondary),
            ),
          ),
      ],
    );
  }
}
