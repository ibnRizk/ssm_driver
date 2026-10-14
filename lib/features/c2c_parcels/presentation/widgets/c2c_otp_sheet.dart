import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/otp_input_row.dart';

/// Asks for the recipient's six-digit hand-over code (contract §5). Pops
/// with the typed code, or `null` when dismissed. The code is never kept.
Future<String?> showC2cOtpSheet(BuildContext context) =>
    showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl.r)),
      ),
      builder: (_) => const _OtpSheet(),
    );

class _OtpSheet extends StatefulWidget {
  const _OtpSheet();

  @override
  State<_OtpSheet> createState() => _OtpSheetState();
}

class _OtpSheetState extends State<_OtpSheet> {
  String _otp = '';

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screen.w,
        AppSpacing.xl.h,
        AppSpacing.screen.w,
        AppSpacing.xl.h + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(Strings.c2cOtpTitle, style: AppTextStyles.h2(color: c.primaryDark)),
          SizedBox(height: AppSpacing.xxs.h),
          Text(Strings.c2cOtpHint, style: AppTextStyles.body(color: c.textHint)),
          SizedBox(height: AppSpacing.lg.h),
          // No rebuild needed: the value is only read on confirm.
          OtpInputRow(onChanged: (String value) => _otp = value),
          SizedBox(height: AppSpacing.xl.h),
          AppButton(
            btnText: Strings.c2cActionComplete,
            onPressed: () => Navigator.of(context).pop(_otp),
          ),
        ],
      ),
    );
  }
}
