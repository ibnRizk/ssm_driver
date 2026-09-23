import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validator.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snack_bar.dart' show ToastType, showAppSnackBar;
import '../../../../injection_container.dart';
import '../cubit/register_cubit.dart';
import '../cubit/register_state.dart';
import '../widgets/auth_scaffold.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RegisterCubit>(
      create: (_) => ServiceLocator.instance<RegisterCubit>(),
      child: const _RegisterView(),
    );
  }
}

class _RegisterView extends StatefulWidget {
  const _RegisterView();

  @override
  State<_RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<_RegisterView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _identityNumberController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  IdentityType? _identityType;
  String? _zone;
  String? _vehicleType;
  bool _obscurePassword = true;

  // TODO: replace with real zones once the zones API exists.
  static const List<String> _zonePlaceholders = <String>[
    'الرياض',
    'جدة',
    'الدمام',
  ];

  // TODO: replace with real vehicle types once the vehicle-types API exists.
  static const List<String> _vehicleTypePlaceholders = <String>[
    'دراجة نارية',
    'سيارة',
    'فان',
  ];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _identityNumberController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    FocusScope.of(context).unfocus();
    final bool fieldsValid = _formKey.currentState?.validate() ?? false;
    if (!fieldsValid ||
        _identityType == null ||
        _zone == null ||
        _vehicleType == null) {
      if (_identityType == null || _zone == null || _vehicleType == null) {
        showAppSnackBar(
          context: context,
          message: Strings.fieldRequired,
          type: ToastType.error,
        );
      }
      return;
    }

    context.read<RegisterCubit>().register(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      identityType: _identityType!,
      identityNumber: _identityNumberController.text.trim(),
      password: _passwordController.text,
      zone: _zone!,
      vehicleType: _vehicleType!,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return BlocListener<RegisterCubit, RegisterState>(
      listener: (BuildContext context, RegisterState state) {
        if (state is RegisterError) {
          showAppSnackBar(
            context: context,
            message: state.message,
            type: ToastType.error,
          );
        } else if (state is RegisterSuccess) {
          context.goNamed(AppRoutes.homeName);
        }
      },
      child: AuthScaffold(
        appBar: AppBar(
          backgroundColor: c.surface,
          elevation: 0,
          iconTheme: IconThemeData(color: c.primary),
        ),
        title: Strings.authRegisterTitle,
        subtitle: Strings.authRegisterSubtitle,
        footerPrimary: Strings.authFooterSecure,
        footerSecondary: Strings.authFooterTagline,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: _LabeledTextField(
                      label: Strings.authFirstNameLabel,
                      hint: Strings.authFirstNameHint,
                      controller: _firstNameController,
                      validatorType: ValidatorType.standard,
                    ),
                  ),
                  SizedBox(width: AppSpacing.md.w),
                  Expanded(
                    child: _LabeledTextField(
                      label: Strings.authLastNameLabel,
                      hint: Strings.authLastNameHint,
                      controller: _lastNameController,
                      validatorType: ValidatorType.standard,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.lg.h),
              _LabeledTextField(
                label: Strings.authPhoneLabel,
                hint: Strings.authPhoneHint,
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                validatorType: ValidatorType.phone,
              ),
              SizedBox(height: AppSpacing.lg.h),
              _LabeledTextField(
                label: Strings.authEmailLabel,
                hint: Strings.authEmailHint,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validatorType: ValidatorType.email,
              ),
              SizedBox(height: AppSpacing.lg.h),
              _LabeledDropdown<IdentityType>(
                label: Strings.authIdentityTypeLabel,
                hint: Strings.authIdentityTypeHint,
                value: _identityType,
                items: IdentityType.values,
                itemLabel: (IdentityType type) => type.label,
                onChanged: (IdentityType? value) =>
                    setState(() => _identityType = value),
              ),
              SizedBox(height: AppSpacing.lg.h),
              _LabeledTextField(
                label: Strings.authIdentityNumberLabel,
                hint: Strings.authIdentityNumberHint,
                controller: _identityNumberController,
                keyboardType: TextInputType.text,
                validatorType: ValidatorType.standard,
              ),
              SizedBox(height: AppSpacing.lg.h),
              _LabeledTextField(
                label: Strings.authPasswordLabel,
                hint: Strings.authPasswordHint,
                controller: _passwordController,
                validatorType: ValidatorType.password,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: c.textHint,
                    size: 20.r,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              SizedBox(height: AppSpacing.lg.h),
              _LabeledDropdown<String>(
                label: Strings.authRegionLabel,
                hint: Strings.authRegionHint,
                value: _zone,
                items: _zonePlaceholders,
                itemLabel: (String zone) => zone,
                onChanged: (String? value) => setState(() => _zone = value),
              ),
              SizedBox(height: AppSpacing.lg.h),
              _LabeledDropdown<String>(
                label: Strings.authVehicleTypeLabel,
                hint: Strings.authVehicleTypeHint,
                value: _vehicleType,
                items: _vehicleTypePlaceholders,
                itemLabel: (String vehicleType) => vehicleType,
                onChanged: (String? value) =>
                    setState(() => _vehicleType = value),
              ),
              SizedBox(height: AppSpacing.xl.h),
              BlocBuilder<RegisterCubit, RegisterState>(
                builder: (BuildContext context, RegisterState state) {
                  return AppButton(
                    btnText: Strings.authRegisterButton,
                    isLoading: state is RegisterLoading,
                    onPressed: () => _submit(context),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bordered labeled text field, matching the visual weight of login's phone
/// field (`_PhoneField`) rather than the filled `MyTextFormField` style.
class _LabeledTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final ValidatorType validatorType;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;

  const _LabeledTextField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.validatorType,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
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
            style: AppTextStyles.bodyLarge(color: c.textPrimary),
            validator: (String? value) =>
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

/// Bordered labeled dropdown, styled to match [_LabeledTextField].
class _LabeledDropdown<T> extends StatelessWidget {
  final String label;
  final String hint;
  final T? value;
  final List<T> items;
  final String Function(T item) itemLabel;
  final ValueChanged<T?> onChanged;

  const _LabeledDropdown({
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
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
          child: DropdownButtonFormField<T>(
            initialValue: value,
            isExpanded: true,
            icon: Icon(Icons.keyboard_arrow_down_rounded, color: c.textHint),
            style: AppTextStyles.bodyLarge(color: c.textPrimary),
            dropdownColor: c.surface,
            validator: (T? selected) =>
                selected == null ? Strings.fieldRequired : null,
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
            ),
            items: items
                .map(
                  (T item) => DropdownMenuItem<T>(
                    value: item,
                    child: Text(itemLabel(item)),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
