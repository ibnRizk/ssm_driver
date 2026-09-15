import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:flutter_base/core/utils/values/strings.dart';

/// White card with centered, bold red logout copy.
class LogoutButton extends StatelessWidget {
  final VoidCallback? onTap;

  const LogoutButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.lg.r),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: AppSpacing.md.h),
        decoration: AppDecorations.card(c),
        alignment: Alignment.center,
        child: Text(
          Strings.profileLogout,
          style: AppTextStyles.title(color: c.error),
        ),
      ),
    );
  }
}
