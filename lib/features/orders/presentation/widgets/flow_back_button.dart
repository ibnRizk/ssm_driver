import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';

/// Circular back button shared by the order-flow screen headers.
///
/// Pops to the previous screen; when there is none (opened directly, e.g.
/// via a deep link) it falls back to the Orders tab instead of doing nothing.
/// `chevron_left` auto-mirrors, so it points right in RTL and left in LTR.
class FlowBackButton extends StatelessWidget {
  /// `null` keeps the button transparent.
  final Color? fillColor;
  final bool showBorder;
  final Color? iconColor;
  final double padding;

  const FlowBackButton({
    super.key,
    this.fillColor,
    this.showBorder = true,
    this.iconColor,
    this.padding = AppSpacing.xs,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Material(
      color: fillColor ?? Colors.transparent,
      shape: CircleBorder(
        side: showBorder ? BorderSide(color: c.border) : BorderSide.none,
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => context.canPop()
            ? context.pop()
            : context.goNamed(AppRoutes.ordersName),
        child: Padding(
          padding: EdgeInsets.all(padding.r),
          child: Icon(
            Icons.chevron_left_rounded,
            color: iconColor ?? c.textPrimary,
            size: 24.r,
          ),
        ),
      ),
    );
  }
}
