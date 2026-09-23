import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';

class OtpInputRow extends StatelessWidget {
  const OtpInputRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const <Widget>[
        OtpBox(value: '4'),
        OtpBox(value: '8'),
        OtpBox(),
        OtpBox(),
      ],
    );
  }
}

class OtpBox extends StatelessWidget {
  final String? value;

  const OtpBox({super.key, this.value});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final bool isFilled = value != null && value!.isNotEmpty;

    return Container(
      width: 72.w,
      height: 72.h,
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppRadius.md.r),
        border: Border.all(
          color: isFilled ? c.secondary : c.border,
          width: isFilled ? 2.w : 1.w,
        ),
      ),
      alignment: Alignment.center,
      child: isFilled
          ? Text(
              value!,
              style: AppTextStyles.h1(
                color: c.primaryDark,
              ).copyWith(fontSize: 32.sp),
            )
          : Container(
              width: 8.r,
              height: 8.r,
              decoration: BoxDecoration(
                color: c.border,
                shape: BoxShape.circle,
              ),
            ),
    );
  }
}
