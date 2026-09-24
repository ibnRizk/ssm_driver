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
import '../../../../core/widgets/app_snack_bar.dart'
    show ToastType, showAppSnackBar;
import '../../../../injection_container.dart';
import '../../../home/presentation/cubit/home_cubit.dart';
import '../../domain/entities/current_work.dart';
import '../cubit/current_work_cubit.dart';
import '../cubit/current_work_state.dart';
import '../cubit/order_lifecycle_cubit.dart';
import '../cubit/order_lifecycle_state.dart';
import '../lifecycle_feedback.dart';
import '../widgets/alternative_confirmation_card.dart';
import '../widgets/current_work_view.dart';
import '../widgets/otp_input_row.dart';
import '../widgets/proof_of_delivery_header.dart';
import '../widgets/proof_of_delivery_status_card.dart';
import '../work_status_label.dart';

/// Step 4 of the delivery flow: completes the order
/// (`POST /delivery-man/orders/{id}/complete`) with the customer's six-digit
/// OTP, or with the device's location and time as the alternative proof.
/// No bottom nav; reads the app-wide [CurrentWorkCubit].
class ProofOfDeliveryScreen extends StatelessWidget {
  const ProofOfDeliveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return BlocProvider<OrderLifecycleCubit>(
      create: (_) => ServiceLocator.instance<OrderLifecycleCubit>(),
      child: BlocListener<OrderLifecycleCubit, OrderLifecycleState>(
        listener: (BuildContext context, OrderLifecycleState state) {
          switch (state) {
            case LifecycleSuccess(:final transition):
              showAppSnackBar(
                context: context,
                message: Strings.orderDeliveryCompleted,
                type: ToastType.success,
              );
              context.read<CurrentWorkCubit>().applyTransition(transition);
              // COD liability and incentive progress just changed.
              context.read<HomeCubit>().refreshDashboard();
              context.goNamed(AppRoutes.homeName);
            case final LifecycleFailure failure:
              showLifecycleFailure(context, failure);
            default:
              break;
          }
        },
        child: Scaffold(
          backgroundColor: c.background,
          body: SafeArea(
            child: Builder(
              builder: (BuildContext context) => CurrentWorkView(
                header: const ProofOfDeliveryHeader(orderId: null),
                // Once delivered, the order leaves `current-work`; keep the
                // form on screen while navigating home instead of flashing
                // the empty state.
                buildWhen: (_, CurrentWorkState current) =>
                    current is! CurrentWorkEmpty ||
                    context.read<OrderLifecycleCubit>().state
                        is! LifecycleSuccess,
                builder: (_, CurrentWork work) => _Content(work: work),
              ),
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

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.screen.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ProofOfDeliveryHeader(orderId: work.orderLabel),
          SizedBox(height: AppSpacing.lg.h),
          ProofOfDeliveryStatusCard(
            subtitle: work.isCashOnDelivery
                ? Strings.orderCodToCollect(work.paymentLabel)
                : Strings.orderPaymentPrepaid,
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
          _OtpForm(work: work),
          SizedBox(height: AppSpacing.xl.h),
          BlocSelector<OrderLifecycleCubit, OrderLifecycleState, bool>(
            selector: (OrderLifecycleState s) => s is LifecycleInProgress,
            builder: (BuildContext context, bool inProgress) =>
                AlternativeConfirmationCard(
                  isLoading: inProgress,
                  onConfirm: () => context
                      .read<OrderLifecycleCubit>()
                      .completeWithLocation(work),
                ),
          ),
          SizedBox(height: AppSpacing.xxl.h),
          Text(
            Strings.orderPODWarning,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption(color: c.textHint),
          ),
          SizedBox(height: AppSpacing.lg.h),
        ],
      ),
    );
  }
}

/// The code boxes and the confirm button. The typed code lives only in this
/// widget — it's sent once and never stored (API docs §11).
class _OtpForm extends StatefulWidget {
  final CurrentWork work;

  const _OtpForm({required this.work});

  @override
  State<_OtpForm> createState() => _OtpFormState();
}

class _OtpFormState extends State<_OtpForm> {
  String _otp = '';

  @override
  Widget build(BuildContext context) {
    return BlocSelector<OrderLifecycleCubit, OrderLifecycleState, bool>(
      selector: (OrderLifecycleState s) => s is LifecycleInProgress,
      builder: (BuildContext context, bool inProgress) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          OtpInputRow(
            enabled: !inProgress,
            // No rebuild needed: the value is only read on confirm.
            onChanged: (String value) => _otp = value,
          ),
          SizedBox(height: AppSpacing.xl.h),
          AppButton(
            btnText: Strings.orderPODConfirm,
            isLoading: inProgress,
            onPressed: () => context
                .read<OrderLifecycleCubit>()
                .completeWithOtp(widget.work, _otp),
          ),
        ],
      ),
    );
  }
}
