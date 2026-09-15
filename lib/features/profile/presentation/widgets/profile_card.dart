import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';

/// Navy driver-identity card: avatar, name/phone/location/rating, an edit
/// pill, and the brand-orange wave bleeding off the bottom-left corner
/// (same motif as `ParcelsSummaryCard` / `EarningsHeroCard`).
class ProfileCard extends StatelessWidget {
  final String name;
  final String phone;
  final String location;
  final String rating;
  final VoidCallback? onEditTap;

  const ProfileCard({
    super.key,
    required this.name,
    required this.phone,
    required this.location,
    required this.rating,
    this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: c.primaryDark,
        borderRadius: BorderRadius.circular(AppRadius.lg.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: <Widget>[
          Positioned.directional(
            textDirection: Directionality.of(context),
            end: -40.w,
            bottom: -60.h,
            child: Container(
              width: 180.w,
              height: 160.h,
              decoration: BoxDecoration(
                color: c.secondary,
                borderRadius: BorderRadiusDirectional.only(
                  topStart: Radius.circular(80.r),
                  bottomStart: Radius.circular(80.r),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(AppSpacing.lg.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 72.r,
                  height: 72.r,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.md.r),
                    border: Border.all(color: c.secondary, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    name.characters.first,
                    style: AppTextStyles.h1(
                      color: c.primaryDark,
                    ).copyWith(fontSize: 28.sp),
                  ),
                ),
                SizedBox(width: AppSpacing.md.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        name,
                        style: AppTextStyles.title(color: Colors.white),
                      ),
                      SizedBox(height: AppSpacing.xxs.h),
                      Text(
                        phone,
                        style: AppTextStyles.caption(color: Colors.white70),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        location,
                        style: AppTextStyles.caption(color: Colors.white70),
                      ),
                      SizedBox(height: AppSpacing.sm.h),
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.star_rounded,
                            color: c.secondary,
                            size: 16.r,
                          ),
                          SizedBox(width: AppSpacing.xxs.w),
                          Text(
                            Strings.profileRatingLabel(rating),
                            style: AppTextStyles.caption(color: c.secondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    onTap: onEditTap,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm.w,
                        vertical: AppSpacing.xs.h,
                      ),
                      child: Text(
                        Strings.profileEdit,
                        style: AppTextStyles.label(color: c.primaryDark),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
