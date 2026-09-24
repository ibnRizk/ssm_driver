import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/tinted_note.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/current_work.dart';
import '../cubit/current_work_cubit.dart';
import '../cubit/order_lifecycle_cubit.dart';
import '../cubit/order_lifecycle_state.dart';
import '../lifecycle_feedback.dart';
import '../widgets/current_work_view.dart';
import '../widgets/flow_back_button.dart';
import '../widgets/package_details_card.dart';
import '../widgets/pickup_store_card.dart';
import '../widgets/verification_checklist.dart';
import '../work_status_label.dart';

/// Step 2 of the delivery flow: the Driver confirms the physical pickup
/// (`POST /delivery-man/orders/{id}/pickup`) before the delivery step
/// unlocks. No bottom nav; reads the app-wide [CurrentWorkCubit].
class PickupConfirmationScreen extends StatelessWidget {
  const PickupConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return BlocProvider<OrderLifecycleCubit>(
      create: (_) => ServiceLocator.instance<OrderLifecycleCubit>(),
      child: BlocListener<OrderLifecycleCubit, OrderLifecycleState>(
        listener: (BuildContext context, OrderLifecycleState state) {
          switch (state) {
            case LifecycleSuccess(:final transition):
              context.read<CurrentWorkCubit>().applyTransition(transition);
              context.pushReplacementNamed(AppRoutes.deliveryToCustomerName);
            case final LifecycleFailure failure:
              showLifecycleFailure(context, failure);
            default:
              break;
          }
        },
        child: Scaffold(
          backgroundColor: c.background,
          body: SafeArea(
            child: CurrentWorkView(
              header: const _Header(),
              builder: (_, CurrentWork work) => _Content(work: work),
            ),
          ),
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final CurrentWork work;

  const _Content({required this.work});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    final List<String> checklist = <String>[
      Strings.orderVerifyBagCount,
      Strings.orderVerifySealedCondition,
      Strings.orderVerifyNumberMatches,
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.screen.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const _Header(),
          SizedBox(height: AppSpacing.lg.h),
          PickupStoreCard(
            storeName: work.storeName,
            storeDistrict: work.storeAddress,
            orderId: work.orderLabel,
          ),
          SizedBox(height: AppSpacing.lg.h),
          PackageDetailsCard(
            title: work.isCashOnDelivery
                ? Strings.orderCodLabel
                : Strings.orderPaymentLabel,
            subtitle: work.paymentLabel,
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
          // Follows the server status: once pickup is confirmed (e.g. a
          // retried request already went through), move on instead.
          work.awaitingPickup
              ? BlocSelector<OrderLifecycleCubit, OrderLifecycleState, bool>(
                  selector: (OrderLifecycleState s) => s is LifecycleInProgress,
                  builder: (BuildContext context, bool inProgress) => AppButton(
                    btnText: Strings.orderPickupConfirmButton,
                    isLoading: inProgress,
                    onPressed: () =>
                        context.read<OrderLifecycleCubit>().confirmPickup(work),
                  ),
                )
              : AppButton(
                  btnText: Strings.orderContinueToCustomerButton,
                  onPressed: () => context.pushReplacementNamed(
                    AppRoutes.deliveryToCustomerName,
                  ),
                ),
          SizedBox(height: AppSpacing.xs.h),
          TextButton(
            onPressed: () {
              // TODO: Open the report-a-problem flow once the API has one.
            },
            child: Text(
              Strings.orderReportProblemButton,
              style: AppTextStyles.body(color: c.textHint),
            ),
          ),
        ],
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
        const FlowBackButton(),
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
