import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import 'package:ssm_driver/core/utils/values/strings.dart';

/// Red filled button for logout.
class LogoutButton extends StatelessWidget {
  final VoidCallback? onTap;

  const LogoutButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppButton(
      color: context.colors.error,
      onPressed: onTap,
      btnText: Strings.profileLogout,
    );
  }
}
