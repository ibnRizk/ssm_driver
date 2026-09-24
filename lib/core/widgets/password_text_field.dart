import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../utils/validator.dart';
import '../utils/values/strings.dart';
import 'labeled_text_field.dart';

/// [LabeledTextField] with a show/hide toggle. [label] and [hint] default to
/// the generic password copy.
class PasswordTextField extends StatefulWidget {
  final TextEditingController controller;
  final ValidatorType validatorType;
  final FormFieldValidator<String>? validator;
  final Iterable<String>? autofillHints;
  final String? label;
  final String? hint;

  const PasswordTextField({
    super.key,
    required this.controller,
    this.validatorType = ValidatorType.standard,
    this.validator,
    this.autofillHints,
    this.label,
    this.hint,
  });

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return LabeledTextField(
      label: widget.label ?? Strings.authPasswordLabel,
      hint: widget.hint ?? Strings.authPasswordHint,
      controller: widget.controller,
      validatorType: widget.validatorType,
      validator: widget.validator,
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
