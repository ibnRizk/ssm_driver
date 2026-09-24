import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:ssm_driver/core/utils/values/strings.dart';

/// The list keeps the server's order — no "nearest first" claim until the
/// app actually sorts by distance.
class ParcelsListHeader extends StatelessWidget {
  const ParcelsListHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Text(
      Strings.parcelsDeliveryList,
      style: AppTextStyles.h2(color: c.primaryDark),
    );
  }
}
