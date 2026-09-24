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
import '../../domain/entities/identity_type.dart';
import '../../domain/entities/registration_data.dart';
import '../auth_navigation.dart';
import '../identity_type_label.dart';
import '../cubit/register_cubit.dart';
import '../cubit/register_state.dart';
import '../../../../core/widgets/password_text_field.dart';
import '../widgets/auth_scaffold.dart';
import '../../../../core/widgets/labeled_text_field.dart';

typedef _Option = ({int id, String label});

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
  _Option? _zone;
  _Option? _vehicleType;

  // TODO: The Driver API has no zones/vehicles list endpoint yet — confirm
  // these IDs with the backend (the Postman collection uses 1 for both).
  static const List<_Option> _zonePlaceholders = <_Option>[
    (id: 1, label: 'الرياض'),
    (id: 2, label: 'جدة'),
    (id: 3, label: 'الدمام'),
  ];

  static const List<_Option> _vehicleTypePlaceholders = <_Option>[
    (id: 1, label: 'دراجة نارية'),
    (id: 2, label: 'سيارة'),
    (id: 3, label: 'فان'),
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
    if (!(_formKey.currentState?.validate() ?? false)) return;

    context.read<RegisterCubit>().register(
      RegistrationData(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        identityType: _identityType!,
        identityNumber: _identityNumberController.text.trim(),
        password: _passwordController.text,
        zoneId: _zone!.id,
        vehicleId: _vehicleType!.id,
      ),
    );
  }

  void _onStateChanged(BuildContext context, RegisterState state) {
    switch (state) {
      case RegisterError(:final String message):
        showAppSnackBar(
          context: context,
          message: message,
          type: ToastType.error,
        );
      case RegisterSuccess(approvalStatus: final status?):
        context.goAfterAuth(status);
      case RegisterSuccess():
        showAppSnackBar(
          context: context,
          message: Strings.authRegisterSuccessLogin,
          type: ToastType.success,
        );
        context.goNamed(AppRoutes.loginName);
      case RegisterInitial() || RegisterLoading():
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return BlocListener<RegisterCubit, RegisterState>(
      listener: _onStateChanged,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: LabeledTextField(
                      label: Strings.authFirstNameLabel,
                      hint: Strings.authFirstNameHint,
                      controller: _firstNameController,
                      validatorType: ValidatorType.standard,
                    ),
                  ),
                  SizedBox(width: AppSpacing.md.w),
                  Expanded(
                    child: LabeledTextField(
                      label: Strings.authLastNameLabel,
                      hint: Strings.authLastNameHint,
                      controller: _lastNameController,
                      validatorType: ValidatorType.standard,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.lg.h),
              LabeledTextField(
                label: Strings.authPhoneLabel,
                hint: Strings.authPhoneHint,
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                validatorType: ValidatorType.phone,
              ),
              SizedBox(height: AppSpacing.lg.h),
              LabeledTextField(
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
              LabeledTextField(
                label: Strings.authIdentityNumberLabel,
                hint: Strings.authIdentityNumberHint,
                controller: _identityNumberController,
                validatorType: ValidatorType.standard,
              ),
              SizedBox(height: AppSpacing.lg.h),
              PasswordTextField(
                controller: _passwordController,
                validatorType: ValidatorType.password,
                autofillHints: const <String>[AutofillHints.newPassword],
              ),
              SizedBox(height: AppSpacing.lg.h),
              _LabeledDropdown<_Option>(
                label: Strings.authRegionLabel,
                hint: Strings.authRegionHint,
                value: _zone,
                items: _zonePlaceholders,
                itemLabel: (_Option zone) => zone.label,
                onChanged: (_Option? value) => setState(() => _zone = value),
              ),
              SizedBox(height: AppSpacing.lg.h),
              _LabeledDropdown<_Option>(
                label: Strings.authVehicleTypeLabel,
                hint: Strings.authVehicleTypeHint,
                value: _vehicleType,
                items: _vehicleTypePlaceholders,
                itemLabel: (_Option vehicle) => vehicle.label,
                onChanged: (_Option? value) =>
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

/// Bordered labeled dropdown, styled to match [LabeledTextField].
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
