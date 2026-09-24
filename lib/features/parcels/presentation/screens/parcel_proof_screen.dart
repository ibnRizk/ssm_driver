import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/general_cubit/driver_stats_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_snack_bar.dart'
    show ToastType, showAppSnackBar;
import '../../../../core/widgets/no_data_found.dart';
import '../../../../core/widgets/proof_of_delivery_form.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/parcel.dart';
import '../cubit/parcel_action_cubit.dart';
import '../cubit/parcel_action_state.dart';
import '../parcel_display.dart';
import '../widgets/parcel_details_header.dart';

/// Completes a parcel (`POST /delivery-man/parcels/{id}/complete`) with the
/// recipient's six-digit OTP, or with the device's location as the
/// alternative proof — the same two proofs as the order flow.
///
/// Pops with the delivered [Parcel] on success.
class ParcelProofScreen extends StatelessWidget {
  /// `null` when opened without a parcel (e.g. a stale deep link).
  final Parcel? parcel;

  const ParcelProofScreen({super.key, required this.parcel});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final Parcel? target = parcel;

    return BlocProvider<ParcelActionCubit>(
      create: (_) => ServiceLocator.instance<ParcelActionCubit>(),
      child: BlocListener<ParcelActionCubit, ParcelActionState>(
        listener: (BuildContext context, ParcelActionState state) {
          switch (state) {
            case ParcelActionSuccess(:final Parcel parcel):
              showAppSnackBar(
                context: context,
                message: Strings.parcelDeliveryCompleted,
                type: ToastType.success,
              );
              // COD liability and incentive progress just changed.
              context.read<DriverStatsCubit>().refreshStats();
              context.pop(parcel);
            case ParcelActionFailure(:final String message):
              showAppSnackBar(
                context: context,
                message: message,
                type: ToastType.error,
              );
            default:
              break;
          }
        },
        child: Scaffold(
          backgroundColor: c.background,
          body: SafeArea(
            child: target == null
                ? Padding(
                    padding: EdgeInsets.all(AppSpacing.screen.w),
                    child: Column(
                      children: <Widget>[
                        ParcelDetailsHeader(
                          parcelId: null,
                          title: Strings.orderProofOfDelivery,
                        ),
                        const Expanded(child: NoDataFound()),
                      ],
                    ),
                  )
                : _Content(parcel: target),
          ),
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final Parcel parcel;

  const _Content({required this.parcel});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.screen.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ParcelDetailsHeader(
            parcelId: parcel.label,
            title: Strings.orderProofOfDelivery,
          ),
          SizedBox(height: AppSpacing.lg.h),
          BlocSelector<ParcelActionCubit, ParcelActionState, bool>(
            selector: (ParcelActionState s) => s is ParcelActionInProgress,
            builder: (BuildContext context, bool inProgress) =>
                ProofOfDeliveryForm(
                  statusTitle: Strings.parcelReadyForHandover,
                  statusSubtitle: parcel.isCashOnDelivery
                      ? Strings.orderCodToCollect(parcel.paymentLabel)
                      : Strings.orderPaymentPrepaid,
                  isLoading: inProgress,
                  onConfirmOtp: (String otp) => context
                      .read<ParcelActionCubit>()
                      .completeWithOtp(parcel, otp),
                  onConfirmLocation: () => context
                      .read<ParcelActionCubit>()
                      .completeWithLocation(parcel),
                ),
          ),
          SizedBox(height: AppSpacing.lg.h),
        ],
      ),
    );
  }
}
