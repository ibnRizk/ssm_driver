import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Profile screen header — a centered title with a settings gear at the
/// end. This is a root tab body (`MainScaffold` owns the bottom nav), so
/// unlike `ParcelDetailsHeader` there is no back button here.
class ProfileHeader extends StatelessWidget {
  final VoidCallback? onSettingsTap;

  const ProfileHeader({super.key, this.onSettingsTap});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Row(
      children: <Widget>[
        Expanded(
          child: Center(
            child: Text(
              'حساب المندوب',
              style: AppTextStyles.h1(color: c.primary),
            ),
          ),
        ),
        Material(
          color: c.surface,
          shape: CircleBorder(side: BorderSide(color: c.border)),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onSettingsTap,
            child: Padding(
              padding: EdgeInsets.all(10.r),
              child: Icon(
                Icons.settings_outlined,
                color: c.primaryDark,
                size: 20.r,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
