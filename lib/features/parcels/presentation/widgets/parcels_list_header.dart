import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ParcelsListHeader extends StatelessWidget {
  const ParcelsListHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          'قائمة التوصيل',
          style: AppTextStyles.h2(color: c.primaryDark),
        ),
        Text(
          'الأقرب أولاً',
          style: AppTextStyles.title(color: c.secondary),
        ),
      ],
    );
  }
}
