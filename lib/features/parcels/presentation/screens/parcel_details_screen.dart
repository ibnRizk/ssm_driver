import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/launch_url_method.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snack_bar.dart'
    show ToastType, showAppSnackBar;
import '../../../../core/widgets/cod_cash_banner.dart';
import '../../../../core/widgets/error_retry_view.dart';
import '../../../../core/widgets/maps_call_buttons.dart';
import '../../../../core/widgets/no_data_found.dart';
import '../../../../core/widgets/tinted_note.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/parcel.dart';
import '../cubit/parcel_action_cubit.dart';
import '../cubit/parcel_action_state.dart';
import '../cubit/parcel_details_cubit.dart';
import '../cubit/parcel_details_state.dart';
import '../parcel_display.dart';
import '../widgets/parcel_details_customer_card.dart';
import '../widgets/parcel_details_footer_banner.dart';
import '../widgets/parcel_details_header.dart';
import '../widgets/parcel_details_source_card.dart';
import '../widgets/parcel_details_status_card.dart';

/// One parcel (`GET /delivery-man/parcels/{id}`): warehouse source,
/// recipient, and the next step — start delivery, then complete it on the
/// proof screen.
class ParcelDetailsScreen extends StatelessWidget {
  /// `null` when the route's id isn't a number.
  final int? parcelId;

  /// The list's copy, shown while the server copy loads.
  final Parcel? initial;

  const ParcelDetailsScreen({super.key, required this.parcelId, this.initial});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final int? id = parcelId;

    if (id == null) {
      return Scaffold(
        backgroundColor: c.background,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.screen.w),
            child: const Column(
              children: <Widget>[
                ParcelDetailsHeader(parcelId: null),
                Expanded(child: NoDataFound()),
              ],
            ),
          ),
        ),
      );
    }

    return MultiBlocProvider(
      providers: <BlocProvider<StateStreamableSource<Object?>>>[
        BlocProvider<ParcelDetailsCubit>(
          create: (_) => ServiceLocator.instance<ParcelDetailsCubit>()
            ..loadParcel(id, initial: initial),
        ),
        BlocProvider<ParcelActionCubit>(
          create: (_) => ServiceLocator.instance<ParcelActionCubit>(),
        ),
      ],
      child: BlocListener<ParcelActionCubit, ParcelActionState>(
        listener: (BuildContext context, ParcelActionState state) {
          switch (state) {
            case ParcelActionSuccess(:final Parcel parcel):
              showAppSnackBar(
                context: context,
                message: Strings.parcelDeliveryStarted,
                type: ToastType.success,
              );
              context.read<ParcelDetailsCubit>().applyParcel(parcel);
            case ParcelActionFailure(
              :final String message,
              :final bool shouldRefresh,
            ):
              showAppSnackBar(
                context: context,
                message: message,
                type: ToastType.error,
              );
              if (shouldRefresh) {
                context.read<ParcelDetailsCubit>().loadParcel(id);
              }
            default:
              break;
          }
        },
        child: Scaffold(
          backgroundColor: c.background,
          body: SafeArea(
            child: BlocBuilder<ParcelDetailsCubit, ParcelDetailsState>(
              builder: (BuildContext context, ParcelDetailsState state) =>
                  switch (state) {
                    ParcelDetailsLoading() => _Placeholder(
                      child: Center(
                        child: CircularProgressIndicator(color: c.secondary),
                      ),
                    ),
                    ParcelDetailsError(:final String message) => _Placeholder(
                      child: ErrorRetryView(
                        message: message,
                        onRetry: () =>
                            context.read<ParcelDetailsCubit>().loadParcel(id),
                      ),
                    ),
                    ParcelDetailsLoaded(:final Parcel parcel) => _Content(
                      parcel: parcel,
                    ),
                  },
            ),
          ),
        ),
      ),
    );
  }
}

/// The header over a loading/error view.
class _Placeholder extends StatelessWidget {
  final Widget child;

  const _Placeholder({required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.screen.w),
      child: Column(
        children: <Widget>[
          const ParcelDetailsHeader(parcelId: null),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final Parcel parcel;

  const _Content({required this.parcel});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final double? lat = parcel.latitude;
    final double? lng = parcel.longitude;
    final String phone = parcel.recipientPhone;
    final String? notes = parcel.customerNotes;

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.screen.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ParcelDetailsHeader(parcelId: parcel.label),
          SizedBox(height: AppSpacing.lg.h),
          ParcelDetailsStatusCard(statusLabel: parcel.statusLabel),
          SizedBox(height: AppSpacing.xl.h),
          Text(
            Strings.parcelSourceTitle,
            style: AppTextStyles.h2(color: c.primaryDark),
          ),
          SizedBox(height: AppSpacing.sm.h),
          ParcelDetailsSourceCard(companyName: parcel.shippingCompanyName),
          SizedBox(height: AppSpacing.xl.h),
          Text(
            Strings.parcelCustomerData,
            style: AppTextStyles.h2(color: c.primaryDark),
          ),
          SizedBox(height: AppSpacing.sm.h),
          ParcelDetailsCustomerCard(
            name: parcel.recipientLabel,
            address: parcel.deliveryAddress,
            phone: phone,
          ),
          if (notes != null) ...<Widget>[
            SizedBox(height: AppSpacing.sm.h),
            TintedNote(
              text: Strings.parcelCustomerNotes(notes),
              backgroundColor: c.secondaryLight,
              textColor: c.secondaryDark,
            ),
          ],
          SizedBox(height: AppSpacing.xl.h),
          MapsCallButtons(
            mapsLabel: Strings.parcelActionMaps,
            callLabel: Strings.parcelActionCall,
            onMapsTap: lat == null || lng == null
                ? null
                : () => openMapsDirections(
                    latitude: lat,
                    longitude: lng,
                    context: context,
                  ),
            onCallTap: phone.isEmpty
                ? null
                : () => makePhoneCall(phoneNumber: phone, context: context),
          ),
          if (parcel.isCashOnDelivery) ...<Widget>[
            SizedBox(height: AppSpacing.lg.h),
            CodCashBanner(amount: parcel.paymentLabel),
          ],
          SizedBox(height: AppSpacing.lg.h),
          const ParcelDetailsFooterBanner(),
          SizedBox(height: AppSpacing.xl.h),
          _NextStepButton(parcel: parcel),
          SizedBox(height: AppSpacing.lg.h),
        ],
      ),
    );
  }
}

/// The CTA follows the server status: start delivery → complete → done.
class _NextStepButton extends StatelessWidget {
  final Parcel parcel;

  const _NextStepButton({required this.parcel});

  @override
  Widget build(BuildContext context) {
    return switch (parcel.status) {
      ParcelStatus.arrivedAtWarehouse =>
        BlocSelector<ParcelActionCubit, ParcelActionState, bool>(
          selector: (ParcelActionState s) => s is ParcelActionInProgress,
          builder: (BuildContext context, bool inProgress) => AppButton(
            btnText: Strings.parcelActionStartDelivery,
            isLoading: inProgress,
            onPressed: () =>
                context.read<ParcelActionCubit>().startDelivery(parcel),
          ),
        ),
      ParcelStatus.outForDelivery => AppButton(
        btnText: Strings.parcelActionComplete,
        onPressed: () => _openProof(context),
      ),
      // Delivered, or a status this app doesn't know: nothing to do here.
      _ => AppButton(btnText: parcel.statusLabel, onPressed: null),
    };
  }

  Future<void> _openProof(BuildContext context) async {
    final ParcelDetailsCubit cubit = context.read<ParcelDetailsCubit>();
    final Parcel? delivered = await context.pushNamed<Parcel>(
      AppRoutes.parcelProofName,
      extra: parcel,
    );
    if (delivered != null && !cubit.isClosed) cubit.applyParcel(delivered);
  }
}
