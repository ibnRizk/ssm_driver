import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Full-width navy banner explaining the delivery-fee / cash-collection
/// policy, with the fee amount highlighted in brand orange.
class EarningsInfoBanner extends StatelessWidget {
  const EarningsInfoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final TextStyle bodyStyle = AppTextStyles.body(color: Colors.white);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.md.w),
      decoration: BoxDecoration(
        color: c.primaryDark,
        borderRadius: BorderRadius.circular(AppRadius.lg.r),
      ),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: bodyStyle,
          children: <InlineSpan>[
            const TextSpan(text: 'رسوم التوصيل '),
            TextSpan(
              text: '10',
              style: bodyStyle.copyWith(
                color: c.secondary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const TextSpan(
              text:
                  ' ر.س تذهب كاملة لصاحب المشروع، والمبالغ النقدية المحصلة تُسلَّم للإدارة.',
            ),
          ],
        ),
      ),
    );
  }
}
