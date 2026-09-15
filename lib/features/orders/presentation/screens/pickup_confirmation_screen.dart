import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/tinted_note.dart';
import '../widgets/package_details_card.dart';
import '../widgets/pickup_store_card.dart';
import '../widgets/verification_checklist.dart';

/// Standalone screen: the driver confirms the order was physically picked
/// up from the store before the delivery step unlocks. No bottom nav.
///
/// TODO: Replace the mock order/checklist fields below with the real order
/// payload (route `extra`) once the orders API exists.
class PickupConfirmationScreen extends StatelessWidget {
  const PickupConfirmationScreen({super.key});

  static const String _orderId = 'SSM-1048#';
  static const String _storeName = 'مطاعم مذاق';
  static const String _storeDistrict = 'حي الملك فهد، نزلة';
  static const String _packageSubtitle = 'وجبة برجر × 2 SSM + بطاطس';

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    final List<String> checklist = <String>[
      Strings.orderVerifyBagCount,
      Strings.orderVerifySealedCondition,
      Strings.orderVerifyNumberMatches,
    ];

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.screen.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const _Header(),
              SizedBox(height: AppSpacing.lg.h),
              const PickupStoreCard(
                storeName: _storeName,
                storeDistrict: _storeDistrict,
                orderId: _orderId,
              ),
              SizedBox(height: AppSpacing.lg.h),
              PackageDetailsCard(
                title: Strings.orderPackageReadyTitle,
                subtitle: _packageSubtitle,
              ),
              SizedBox(height: AppSpacing.lg.h),
              Text(
                Strings.orderVerificationTitle,
                style: AppTextStyles.title(color: c.textPrimary),
              ),
              SizedBox(height: AppSpacing.sm.h),
              VerificationChecklist(items: checklist),
              SizedBox(height: AppSpacing.lg.h),
              TintedNote(
                text: Strings.orderConfirmInfoBanner,
                backgroundColor: c.secondaryLight,
                textColor: c.secondaryDark,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.lg.h),
              AppButton(
                btnText: Strings.orderPickupConfirmButton,
                onPressed: () {
                  // TODO: Confirm pickup with the orders API once it exists.
                  context.pushReplacementNamed(
                    AppRoutes.deliveryToCustomerName,
                  );
                },
              ),
              SizedBox(height: AppSpacing.xs.h),
              TextButton(
                onPressed: () {
                  // TODO: Open the report-a-problem flow once it exists.
                },
                child: Text(
                  Strings.orderReportProblemButton,
                  style: AppTextStyles.body(color: c.textHint),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Row(
      children: <Widget>[
        Material(
          color: Colors.transparent,
          shape: CircleBorder(side: BorderSide(color: c.border)),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => Navigator.of(context).maybePop(),
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xs.r),
              child: Icon(
                Icons.chevron_right_rounded,
                color: c.textPrimary,
                size: 24.r,
              ),
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: Text(
              Strings.orderPickupConfirmTitle,
              style: AppTextStyles.h1(color: c.textPrimary),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm.w,
            vertical: AppSpacing.xxs.h,
          ),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: c.border),
          ),
          child: Text(
            Strings.orderStepOfLabel(2, 4),
            style: AppTextStyles.label(color: c.textSecondary),
          ),
        ),
      ],
    );
  }
}
