import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../widgets/alternative_confirmation_card.dart';
import '../widgets/otp_input_row.dart';
import '../widgets/proof_of_delivery_header.dart';
import '../widgets/proof_of_delivery_status_card.dart';
import 'package:flutter_base/core/utils/values/strings.dart';

class ProofOfDeliveryScreen extends StatelessWidget {
  const ProofOfDeliveryScreen({super.key});

  static const String _orderId = 'SSM-1048#';

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.screen.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const ProofOfDeliveryHeader(orderId: _orderId),
              SizedBox(height: AppSpacing.lg.h),
              const ProofOfDeliveryStatusCard(),
              SizedBox(height: AppSpacing.xl.h),
              Text(
                Strings.orderPODEnterCode,
                style: AppTextStyles.h2(color: c.primaryDark),
              ),
              SizedBox(height: AppSpacing.xxs.h),
              Text(
                Strings.orderPODCodeHint,
                style: AppTextStyles.body(color: c.textHint),
              ),
              SizedBox(height: AppSpacing.lg.h),
              const OtpInputRow(),
              SizedBox(height: AppSpacing.xl.h),
              AppButton(
                btnText: Strings.orderPODConfirm,
                onPressed: () {
                  context.goNamed(AppRoutes.homeName);
                },
              ),
              SizedBox(height: AppSpacing.xl.h),
              const AlternativeConfirmationCard(),
              SizedBox(height: AppSpacing.xxl.h),
              Text(
                Strings.orderPODWarning,
                textAlign: TextAlign.center,
                style: AppTextStyles.caption(color: c.textHint),
              ),
              SizedBox(height: AppSpacing.lg.h),
            ],
          ),
        ),
      ),
    );
  }
}
