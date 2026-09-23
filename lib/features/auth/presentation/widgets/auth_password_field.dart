import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validator.dart';
import '../../../../core/utils/values/strings.dart';
import 'auth_text_field.dart';

class AuthPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final ValidatorType validatorType;
  final Iterable<String>? autofillHints;

  const AuthPasswordField({
    super.key,
    required this.controller,
    this.validatorType = ValidatorType.standard,
    this.autofillHints,
  });

  @override
  State<AuthPasswordField> createState() => _AuthPasswordFieldState();
}

class _AuthPasswordFieldState extends State<AuthPasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return AuthTextField(
      label: Strings.authPasswordLabel,
      hint: Strings.authPasswordHint,
      controller: widget.controller,
      validatorType: widget.validatorType,
      obscureText: _obscure,
      autofillHints: widget.autofillHints,
      suffixIcon: IconButton(
        icon: Icon(
          _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: context.colors.textHint,
          size: 20.r,
        ),
        onPressed: () => setState(() => _obscure = !_obscure),
      ),
    );
  }
}
