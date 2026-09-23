import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';
import '../utils/values/strings.dart';
import 'app_button.dart';

class ErrorRetryView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorRetryView({
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
          Icon(
            Icons.wifi_off_rounded,
            size: 48.r,
            color: context.colors.textHint,
          ),
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
