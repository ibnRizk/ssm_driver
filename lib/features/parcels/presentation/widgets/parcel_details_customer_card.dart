import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';

class ParcelDetailsCustomerCard extends StatelessWidget {
  final String name;
  final String address;
  final String phone;

  const ParcelDetailsCustomerCard({
    super.key,
    required this.name,
    required this.address,
    required this.phone,
  });

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
              name.characters.first,
              style: AppTextStyles.h1(color: c.primaryDark).copyWith(fontSize: 24.sp),
            ),
          ),
          SizedBox(width: AppSpacing.md.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  name,
                  style: AppTextStyles.title(color: c.primaryDark),
                ),
                if (address.isNotEmpty) ...<Widget>[
                  SizedBox(height: AppSpacing.xxs.h),
                  Text(
                    address,
                    style: AppTextStyles.caption(color: c.textHint),
                  ),
                ],
                if (phone.isNotEmpty) ...<Widget>[
                  SizedBox(height: AppSpacing.xxs.h),
                  Text(
                    phone,
                    textDirection: TextDirection.ltr,
                    style: AppTextStyles.caption(color: c.textHint),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
