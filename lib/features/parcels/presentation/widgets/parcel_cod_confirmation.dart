import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';

/// "I collected 75.50 SAR in cash" — the Driver's explicit confirmation a
/// cash parcel needs before either proof completes it.
class ParcelCodConfirmation extends StatelessWidget {
  /// Display text as the server sent it, e.g. "75.50 SAR".
  final String amount;
  final bool value;

  /// `null` disables the box (a completion is in flight).
  final ValueChanged<bool>? onChanged;

  const ParcelCodConfirmation({
    super.key,
    required this.amount,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final ValueChanged<bool>? changed = onChanged;

    return Material(
      color: c.secondaryLight,
      borderRadius: BorderRadius.circular(AppRadius.md.r),
      clipBehavior: Clip.antiAlias,
      child: CheckboxListTile(
        value: value,
        onChanged: changed == null
            ? null
            : (bool? checked) => changed(checked ?? false),
        controlAffinity: ListTileControlAffinity.leading,
        activeColor: c.secondary,
        contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.sm.w),
        title: Text(
          Strings.parcelCodConfirmLabel(amount),
          style: AppTextStyles.title(color: c.secondaryDark),
        ),
      ),
    );
  }
}
