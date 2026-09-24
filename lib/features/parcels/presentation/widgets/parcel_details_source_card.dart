import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:ssm_driver/core/utils/values/strings.dart';

class ParcelDetailsSourceCard extends StatelessWidget {
  /// The shipping company that sent the parcel; empty when unknown.
  final String companyName;

  const ParcelDetailsSourceCard({super.key, required this.companyName});

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
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: c.secondaryLight,
              borderRadius: BorderRadius.circular(AppRadius.md.r),
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              color: c.secondary,
              size: 24.r,
            ),
          ),
          SizedBox(width: AppSpacing.md.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  Strings.parcelSourceWarehouse,
                  style: AppTextStyles.title(color: c.primaryDark),
                ),
                SizedBox(height: AppSpacing.xxs.h),
                Text(
                  companyName.isEmpty
                      ? Strings.parcelSourceDescription
                      : Strings.parcelSourceFrom(companyName),
                  style: AppTextStyles.caption(color: c.textHint),
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.sm.w),
          Text(
            Strings.parcelReceived,
            style: AppTextStyles.label(color: c.secondaryDark),
          ),
        ],
      ),
    );
  }
}
