import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import 'package:flutter_base/core/utils/values/strings.dart';

class AlternativeConfirmationCard extends StatelessWidget {
  const AlternativeConfirmationCard({super.key});

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
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      Strings.orderAltConfirmTitle,
                      style: AppTextStyles.title(color: c.primaryDark),
                    ),
                    SizedBox(height: AppSpacing.xxs.h),
                    Text(
                      Strings.orderAltConfirmSubtitle,
                      style: AppTextStyles.caption(color: c.textHint),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: c.secondaryLight,
                  borderRadius: BorderRadius.circular(AppRadius.sm.r),
                ),
                child: Icon(
                  Icons.my_location_rounded,
                  color: c.secondary,
                  size: 20.r,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md.h),
          AppButton(
            btnText: Strings.orderAltConfirmButton,
            color: c.primaryDark,
            onPressed: () {
              context.goNamed(AppRoutes.homeName);
            },
          ),
        ],
      ),
    );
  }
}
