import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:ssm_driver/core/utils/values/strings.dart';

class ParcelsListHeader extends StatelessWidget {
  const ParcelsListHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          Strings.parcelsDeliveryList,
          style: AppTextStyles.h2(color: c.primaryDark),
        ),
        Text(
          Strings.parcelsNearestFirst,
          style: AppTextStyles.title(color: c.secondary),
        ),
      ],
    );
  }
}
