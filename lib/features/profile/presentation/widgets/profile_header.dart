import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:ssm_driver/core/utils/values/strings.dart';

/// Profile screen header — a centered title. This is a root tab body
/// (`MainScaffold` owns the bottom nav), so unlike `ParcelDetailsHeader`
/// there is no back button here.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Center(
      child: Text(
        Strings.profileDriverAccount,
        style: AppTextStyles.h1(color: c.primary),
      ),
    );
  }
}
