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
import '../../../../core/widgets/tinted_note.dart';
import '../../domain/entities/current_work.dart';
import '../cubit/current_work_cubit.dart';
import '../cubit/current_work_state.dart';
import '../widgets/current_work_view.dart';
import '../widgets/flow_back_button.dart';
import '../widgets/trip_cod_summary.dart';
import '../widgets/trip_step_card.dart';
import '../work_status_label.dart';
import '../widgets/report_problem_button.dart';

/// The accepted-order trip screen (`GET /delivery-man/current-work`):
/// pickup step, delivery step, order note, COD summary, and the next-step
/// CTA.
///
/// Reads the app-wide [CurrentWorkCubit] — already loaded by the Orders tab,
/// or by the incoming-order screen right after accepting. Pushed outside the
/// bottom-nav shell (see `AppRoutes.orderTrip`).
class OrderTripScreen extends StatefulWidget {
  const OrderTripScreen({super.key});

  @override
  State<OrderTripScreen> createState() => _OrderTripScreenState();
}

class _OrderTripScreenState extends State<OrderTripScreen> {
  @override
  void initState() {
    super.initState();
    // Reached some other way (e.g. a deep link) before anything loaded.
    final CurrentWorkCubit cubit = context.read<CurrentWorkCubit>();
    if (cubit.state is CurrentWorkInitial) cubit.loadCurrentWork();
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: CurrentWorkView(
          header: const _TripHeader(orderLabel: null),
          builder: (_, CurrentWork work) => _TripContent(work: work),
        ),
      ),
    );
  }
}

class _TripContent extends StatelessWidget {
  final CurrentWork work;

  const _TripContent({required this.work});

  /// Keeps an international number's leading `+` in place inside RTL text.
  static final String _ltrMark = String.fromCharCode(0x200E);

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final double? storeLat = work.storeLatitude;
    final double? storeLng = work.storeLongitude;
    final String? note = work.orderNote;

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.screen.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _TripHeader(orderLabel: work.orderLabel),
          SizedBox(height: AppSpacing.lg.h),
          _SectionHeader(
            title: Strings.orderPickupTitle,
            stepLabel: Strings.orderStepLabel(1),
          ),
          SizedBox(height: AppSpacing.sm.h),
          TripStepCard(
            icon: Icons.storefront_rounded,
            title: work.storeName,
            subtitleLines: <String>[work.storeAddress],
            actionIcon: Icons.map_outlined,
            actionLabel: Strings.orderMapButton,
            onActionTap: storeLat == null || storeLng == null
                ? null
                : () => openMapsDirections(
                    latitude: storeLat,
                    longitude: storeLng,
                    context: context,
                  ),
          ),
          SizedBox(height: AppSpacing.lg.h),
          _SectionHeader(
            title: Strings.orderDeliveryTitle,
            stepLabel: Strings.orderStepLabel(2),
          ),
          SizedBox(height: AppSpacing.sm.h),
          TripStepCard(
            icon: Icons.location_on_rounded,
            title: work.customerName,
            subtitleLines: <String>[
              work.deliveryAddress,
              if (work.customerPhone.isNotEmpty)
                '$_ltrMark${work.customerPhone}',
            ],
            actionIcon: Icons.call_outlined,
            actionLabel: Strings.orderCallButton,
            onActionTap: work.customerPhone.isEmpty
                ? null
                : () => makePhoneCall(
                    phoneNumber: work.customerPhone,
                    context: context,
                  ),
          ),
          if (note != null && note.isNotEmpty) ...<Widget>[
            SizedBox(height: AppSpacing.lg.h),
            TintedNote(
              text: '${Strings.orderNoteLabel}: $note',
              backgroundColor: c.secondaryLight,
              textColor: c.secondaryDark,
            ),
          ],
          if (work.isCashOnDelivery) ...<Widget>[
            SizedBox(height: AppSpacing.lg.h),
            TripCodSummary(
              label: Strings.orderCodLabel,
              cashNote: Strings.orderCodCashNote,
              amount: work.paymentLabel,
            ),
          ],
          SizedBox(height: AppSpacing.xl.h),
          // The next step follows the server status: before pickup the
          // Driver heads to the store (pickup is confirmed there); after it,
          // straight to the customer (start delivery → complete with OTP).
          // Every step reads the same app-wide cubit, so the status stays in
          // sync everywhere.
          work.awaitingPickup || work.status == null
              ? AppButton(
                  btnText: Strings.orderNavigateToStoreButton,
                  onPressed: () =>
                      context.pushNamed(AppRoutes.navigateToStoreName),
                )
              : AppButton(
                  btnText: Strings.orderContinueToCustomerButton,
                  onPressed: () =>
                      context.pushNamed(AppRoutes.deliveryToCustomerName),
                ),
          ReportProblemButton(work: work),
        ],
      ),
    );
  }
}

class _TripHeader extends StatelessWidget {
  /// `null` while the order is still loading (no id pill yet).
  final String? orderLabel;

  const _TripHeader({required this.orderLabel});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final String? label = orderLabel;

    return Row(
      children: <Widget>[
        FlowBackButton(fillColor: c.surface, showBorder: false),
        Expanded(
          child: Center(
            child: Text(
              Strings.orderDetailsTitle,
              style: AppTextStyles.h1(color: c.textPrimary),
            ),
          ),
        ),
        if (label != null)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.sm.w,
              vertical: AppSpacing.xxs.h,
            ),
            decoration: BoxDecoration(
              color: c.secondaryLight,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(
              label,
              textDirection: TextDirection.ltr,
              style: AppTextStyles.label(color: c.secondary),
            ),
          ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String stepLabel;

  const _SectionHeader({required this.title, required this.stepLabel});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(title, style: AppTextStyles.title(color: c.textPrimary)),
        Text(stepLabel, style: AppTextStyles.caption(color: c.textSecondary)),
      ],
    );
  }
}
