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
import '../cubit/login_cubit.dart';
import '../cubit/login_state.dart';
import '../widgets/auth_scaffold.dart';

/// Driver entry point: phone number + country code, matching the design's
/// standard auth layout (see [AuthScaffold]).
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoginCubit>(
      create: (_) => ServiceLocator.instance<LoginCubit>(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      context.read<LoginCubit>().submitPhone(_phoneController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      listener: (BuildContext context, LoginState state) {
        if (state is LoginError) {
          showAppSnackBar(
            context: context,
            message: state.message,
            type: ToastType.error,
          );
        } else if (state is LoginSuccess) {
          context.goNamed(AppRoutes.homeName);
        }
      },
      child: AuthScaffold(
        greeting: Strings.authDriverGreeting,
        title: Strings.authWelcomeTitle,
        subtitle: Strings.authWelcomeSubtitle,
        footerPrimary: Strings.authFooterSecure,
        footerSecondary: Strings.authFooterTagline,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                Strings.authPhoneLabel,
                style: AppTextStyles.titleSmall(
                  color: context.colors.textPrimary,
                ),
              ),
              SizedBox(height: AppSpacing.xs.h),
              _PhoneField(controller: _phoneController),
              SizedBox(height: AppSpacing.xl.h),
              BlocBuilder<LoginCubit, LoginState>(
                builder: (BuildContext context, LoginState state) {
                  return AppButton(
                    btnText: Strings.authContinue,
                    isLoading: state is LoginLoading,
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

/// Phone input with a fixed "+966" country code segment — the design has no
/// country picker, just the SSM home market code.
class _PhoneField extends StatelessWidget {
  final TextEditingController controller;

  const _PhoneField({required this.controller});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg.r),
        border: Border.all(color: c.border),
      ),
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md.w),
      child: Row(
        children: <Widget>[
          Text(
            '+966',
            style: AppTextStyles.title(color: c.primary),
          ),
          SizedBox(width: AppSpacing.sm.w),
          SizedBox(
            height: 24.h,
            child: VerticalDivider(color: c.border, thickness: 1),
          ),
          SizedBox(width: AppSpacing.sm.w),
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: TextInputType.phone,
              textAlign: TextAlign.end,
              style: AppTextStyles.bodyLarge(color: c.textPrimary),
              validator: (String? value) =>
                  Validator.call(value: value, type: ValidatorType.phone),
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  vertical: AppSpacing.md.h,
                ),
                hintText: Strings.authPhoneHint,
                hintStyle: AppTextStyles.bodyLarge(color: c.textHint),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
