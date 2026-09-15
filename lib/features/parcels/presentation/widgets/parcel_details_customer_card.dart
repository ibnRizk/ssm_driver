import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';

class ParcelDetailsCustomerCard extends StatelessWidget {
  const ParcelDetailsCustomerCard({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md.w),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg.r),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Palette.shadowHairline,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 48.r,
            height: 48.r,
            decoration: BoxDecoration(
              color: c.secondaryLight,
              borderRadius: BorderRadius.circular(AppRadius.md.r),
            ),
            alignment: Alignment.center,
            child: Text(
              'س',
              style: AppTextStyles.h1(color: c.primaryDark).copyWith(fontSize: 24.sp),
            ),
          ),
          SizedBox(width: AppSpacing.md.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'سارة أحمد',
                  style: AppTextStyles.title(color: c.primaryDark),
                ),
                SizedBox(height: AppSpacing.xxs.h),
                Text(
                  'حي المروج، شارع الأمير سلطان، تربة\n05X XXX XXXX',
                  style: AppTextStyles.caption(color: c.textHint),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
