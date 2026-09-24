import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';
import '../utils/validator.dart';

/// Labeled, bordered input shared by the auth and edit-profile forms — same
/// visual weight as login's phone field rather than the filled
/// `MyTextFormField` style.
class LabeledTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final ValidatorType validatorType;

  /// Replaces the [validatorType] rule when set — for rules [Validator] can't
  /// express, such as an optional field or a match against another field.
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final Iterable<String>? autofillHints;

  const LabeledTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.validatorType,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.autofillHints,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(label, style: AppTextStyles.titleSmall(color: c.textPrimary)),
        SizedBox(height: AppSpacing.xs.h),
        Container(
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg.r),
            border: Border.all(color: c.border),
          ),
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md.w),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            autofillHints: autofillHints,
            style: AppTextStyles.bodyLarge(color: c.textPrimary),
            validator:
                validator ??
                (String? value) =>
                    Validator.call(value: value, type: validatorType),
            decoration: InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: AppSpacing.md.h),
              hintText: hint,
              hintStyle: AppTextStyles.bodyLarge(color: c.textHint),
              suffixIcon: suffixIcon,
            ),
          ),
        ),
      ],
    );
  }
}
