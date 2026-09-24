import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';
import '../utils/values/strings.dart';
import 'alternative_confirmation_card.dart';
import 'app_button.dart';
import 'otp_input_row.dart';
import 'proof_of_delivery_status_card.dart';

/// The proof-of-delivery body shared by orders and parcels: what to collect,
/// the recipient's six-digit OTP, and the location/time alternative.
///
/// State-agnostic — the screen supplies [isLoading] from its own cubit and
/// sends the proof through the callbacks.
class ProofOfDeliveryForm extends StatelessWidget {
  /// Defaults to "Order Ready for Delivery".
  final String? statusTitle;

  /// What to collect — "Cash to collect: 31 SAR", or "Prepaid".
  final String statusSubtitle;

  /// A completion (either proof) is in flight.
  final bool isLoading;

  final ValueChanged<String> onConfirmOtp;
  final VoidCallback onConfirmLocation;

  const ProofOfDeliveryForm({
    super.key,
    this.statusTitle,
    required this.statusSubtitle,
    required this.isLoading,
    required this.onConfirmOtp,
    required this.onConfirmLocation,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        ProofOfDeliveryStatusCard(
          title: statusTitle,
          subtitle: statusSubtitle,
        ),
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
        _OtpForm(isLoading: isLoading, onConfirm: onConfirmOtp),
        SizedBox(height: AppSpacing.xl.h),
        AlternativeConfirmationCard(
          isLoading: isLoading,
          onConfirm: onConfirmLocation,
        ),
        SizedBox(height: AppSpacing.xxl.h),
        Text(
          Strings.orderPODWarning,
          textAlign: TextAlign.center,
          style: AppTextStyles.caption(color: c.textHint),
        ),
      ],
    );
  }
}

/// The code boxes and the confirm button. The typed code lives only in this
/// widget — it's sent once and never stored (API docs §11).
class _OtpForm extends StatefulWidget {
  final bool isLoading;
  final ValueChanged<String> onConfirm;

  const _OtpForm({required this.isLoading, required this.onConfirm});

  @override
  State<_OtpForm> createState() => _OtpFormState();
}

class _OtpFormState extends State<_OtpForm> {
  String _otp = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        OtpInputRow(
          enabled: !widget.isLoading,
          // No rebuild needed: the value is only read on confirm.
          onChanged: (String value) => _otp = value,
        ),
        SizedBox(height: AppSpacing.xl.h),
        AppButton(
          btnText: Strings.orderPODConfirm,
          isLoading: widget.isLoading,
          onPressed: () => widget.onConfirm(_otp),
        ),
      ],
    );
  }
}
