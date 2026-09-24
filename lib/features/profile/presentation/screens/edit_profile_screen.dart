import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/validator.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snack_bar.dart' show ToastType, showAppSnackBar;
import '../../../../core/widgets/error_retry_view.dart';
import '../../../../core/widgets/labeled_text_field.dart';
import '../../../../core/widgets/password_text_field.dart';
import '../../../../core/widgets/simple_app_bar.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/driver_profile.dart';
import '../../domain/entities/profile_update.dart';
import '../cubit/edit_profile_cubit.dart';
import '../cubit/edit_profile_state.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';

/// Edit Profile (تعديل البيانات) — name, phone, email and an optional new
/// password (`PATCH /delivery-man/profile`).
///
/// Pre-fills from the Profile tab's [ProfileCubit] when one is passed in, and
/// refreshes that same cubit after a successful save so the tab shows the new
/// data. Opened any other way (e.g. a deep link) it loads its own.
class EditProfileScreen extends StatelessWidget {
  final ProfileCubit? cubit;

  const EditProfileScreen({super.key, this.cubit});

  @override
  Widget build(BuildContext context) {
    final ProfileCubit? shared = cubit;
    return MultiBlocProvider(
      providers: [
        if (shared != null)
          BlocProvider<ProfileCubit>.value(value: shared)
        else
          BlocProvider<ProfileCubit>(
            create: (_) =>
                ServiceLocator.instance<ProfileCubit>()..loadProfile(),
          ),
        BlocProvider<EditProfileCubit>(
          create: (_) => ServiceLocator.instance<EditProfileCubit>(),
        ),
      ],
      child: const _EditProfileView(),
    );
  }
}

class _EditProfileView extends StatelessWidget {
  const _EditProfileView();

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Scaffold(
      backgroundColor: c.background,
      appBar: SimpleAppBar(
        title: Strings.profileEditTitle,
        onBack: () => context.pop(),
      ),
      body: SafeArea(
        child: BlocBuilder<ProfileCubit, ProfileState>(
          // Once the form is up, keep it: the post-save refresh must not
          // swap it for a spinner (and drop the typed values) mid-pop.
          buildWhen: (ProfileState previous, _) => previous is! ProfileLoaded,
          builder: (BuildContext context, ProfileState state) =>
              switch (state) {
                ProfileInitial() || ProfileLoading() => Center(
                  child: CircularProgressIndicator(color: c.secondary),
                ),
                ProfileError(:final String message) => ErrorRetryView(
                  message: message,
                  onRetry: context.read<ProfileCubit>().loadProfile,
                ),
                ProfileLoaded(:final DriverProfile profile) =>
                  _EditProfileForm(profile: profile),
              },
        ),
      ),
    );
  }
}

class _EditProfileForm extends StatefulWidget {
  final DriverProfile profile;

  const _EditProfileForm({required this.profile});

  @override
  State<_EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<_EditProfileForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _firstNameController =
      TextEditingController(text: widget.profile.firstName);
  late final TextEditingController _lastNameController = TextEditingController(
    text: widget.profile.lastName,
  );
  late final TextEditingController _phoneController = TextEditingController(
    text: widget.profile.phone,
  );
  late final TextEditingController _emailController = TextEditingController(
    text: widget.profile.email,
  );
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Blank keeps the current password; otherwise the usual password rules.
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return null;
    return Validator.call(value: value, type: ValidatorType.password);
  }

  String? _validateConfirmPassword(String? value) {
    if (_passwordController.text.isEmpty) return null;
    return value == _passwordController.text
        ? null
        : Strings.passwordsDoNotMatch;
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final String password = _passwordController.text;
    context.read<EditProfileCubit>().submit(
      ProfileUpdate(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: password.isEmpty ? null : password,
      ),
    );
  }

  void _onStateChanged(BuildContext context, EditProfileState state) {
    switch (state) {
      case EditProfileSuccess():
        showAppSnackBar(
          context: context,
          message: Strings.profileUpdateSuccess,
          type: ToastType.success,
        );
        context.read<ProfileCubit>().loadProfile();
        context.pop();
      case EditProfileError(:final String message):
        showAppSnackBar(
          context: context,
          message: message,
          type: ToastType.error,
        );
      case EditProfileInitial() || EditProfileLoading():
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EditProfileCubit, EditProfileState>(
      listener: _onStateChanged,
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppSpacing.screen.w),
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
                    PasswordTextField(
                      controller: _passwordController,
                      label: Strings.profileNewPasswordLabel,
                      hint: Strings.profileNewPasswordHint,
                      validator: _validatePassword,
                      autofillHints: const <String>[AutofillHints.newPassword],
                    ),
                    SizedBox(height: AppSpacing.lg.h),
                    PasswordTextField(
                      controller: _confirmPasswordController,
                      label: Strings.profileConfirmPasswordLabel,
                      hint: Strings.profileConfirmPasswordHint,
                      validator: _validateConfirmPassword,
                      autofillHints: const <String>[AutofillHints.newPassword],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(AppSpacing.screen.w),
              child: BlocBuilder<EditProfileCubit, EditProfileState>(
                builder: (BuildContext context, EditProfileState state) =>
                    AppButton(
                      btnText: Strings.save,
                      isLoading: state is EditProfileLoading,
                      onPressed: _submit,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
