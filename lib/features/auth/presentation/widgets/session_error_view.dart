import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_button.dart';

class SessionErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const SessionErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Icon(Icons.wifi_off_rounded, size: 48.r, color: context.colors.textHint),
          SizedBox(height: AppSpacing.md.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.body(color: context.colors.textSecondary),
          ),
          SizedBox(height: AppSpacing.xl.h),
          AppButton(btnText: Strings.retry, onPressed: onRetry),
        ],
      ),
    );
  }
}
