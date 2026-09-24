import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/launch_url_method.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/destination_map.dart';
import '../../../../core/widgets/tinted_note.dart';
import '../../domain/entities/current_work.dart';
import '../cubit/current_work_cubit.dart';
import '../widgets/current_work_view.dart';
import '../widgets/flow_back_button.dart';
import '../widgets/store_location_card.dart';
import '../work_status_label.dart';

/// Step 1 of the delivery flow: guides the Driver to the store's pickup
/// point. No bottom nav — pushed on top of the trip screen; reads the
/// app-wide [CurrentWorkCubit].
class NavigateToStoreScreen extends StatelessWidget {
  const NavigateToStoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: CurrentWorkView(
          header: const _Header(orderId: null),
          builder: (_, CurrentWork work) => _Content(work: work),
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
    final double? lat = work.storeLatitude;
    final double? lng = work.storeLongitude;

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.screen.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _Header(orderId: work.orderLabel),
          SizedBox(height: AppSpacing.lg.h),
          StoreLocationCard(
            storeName: work.storeName,
            pickupPointLabel: Strings.orderPickupPointLabel,
            address: work.storeAddress,
          ),
          SizedBox(height: AppSpacing.lg.h),
          DestinationMap(
            latitude: lat,
            longitude: lng,
            markerTitle: work.storeName,
          ),
          SizedBox(height: AppSpacing.lg.h),
          AppButton(
            btnText: Strings.orderOpenGoogleMapsButton,
            icon: Icons.open_in_new_rounded,
            onPressed: lat == null || lng == null
                ? null
                : () => openMapsDirections(
                    latitude: lat,
                    longitude: lng,
                    context: context,
                  ),
          ),
          SizedBox(height: AppSpacing.lg.h),
          TintedNote(
            text: Strings.orderNavigateWarningNote,
            backgroundColor: c.secondaryLight,
            textColor: c.secondary,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.xl.h),
          AppButton(
            btnText: Strings.confirm,
            onPressed: () =>
                context.pushReplacementNamed(AppRoutes.pickupConfirmationName),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  /// `null` while the order is still loading (no id pill yet).
  final String? orderId;

  const _Header({required this.orderId});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final String? id = orderId;

    return Row(
      children: <Widget>[
        const FlowBackButton(),
        Expanded(
          child: Center(
            child: Text(
              Strings.orderNavigateTitle,
              style: AppTextStyles.h1(color: c.textPrimary),
            ),
          ),
        ),
        if (id != null)
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
              id,
              textDirection: TextDirection.ltr,
              style: AppTextStyles.label(color: c.secondary),
            ),
          ),
      ],
    );
  }
}
