import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';
import 'app_button.dart';
import 'app_outlined_button.dart';

/// Icon, title, body and a confirm/dismiss pair — for in-app announcements
/// such as a newly assigned parcel. Use as `showAppDialog`'s child: pops
/// `true` for [confirmText], `false` for [dismissText].
class NoticeDialog extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final String confirmText;
  final String dismissText;

  const NoticeDialog({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    required this.confirmText,
    required this.dismissText,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Padding(
      padding: EdgeInsets.all(AppSpacing.lg.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Icon(icon, size: 40.r, color: c.secondary),
          SizedBox(height: AppSpacing.md.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.h2(color: c.primaryDark),
          ),
          SizedBox(height: AppSpacing.sm.h),
          Text(
            body,
            textAlign: TextAlign.center,
            style: AppTextStyles.body(color: c.textSecondary),
          ),
          SizedBox(height: AppSpacing.xl.h),
          AppButton(
            btnText: confirmText,
            onPressed: () => Navigator.of(context).pop(true),
          ),
          SizedBox(height: AppSpacing.sm.h),
          AppOutlinedButton(
            text: dismissText,
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    );
  }
}
