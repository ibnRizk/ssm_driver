import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';

class ParcelDetailsHeader extends StatelessWidget {
  final String parcelId;

  const ParcelDetailsHeader({super.key, required this.parcelId});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

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
                Icons.chevron_right_rounded,
                color: c.primaryDark,
                size: 24.r,
              ),
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: Text(
              'تفاصيل طرد',
              style: AppTextStyles.h1(color: c.primaryDark).copyWith(fontSize: 24.sp),
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
            parcelId,
            style: AppTextStyles.label(color: c.textSecondary),
          ),
        ),
      ],
    );
  }
}
