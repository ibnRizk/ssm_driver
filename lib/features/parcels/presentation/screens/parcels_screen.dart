import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../config/routes/app_routes.dart';
import 'package:go_router/go_router.dart';
import '../widgets/parcel_route_card.dart';
import '../widgets/parcels_header.dart';
import '../widgets/parcels_list_header.dart';
import '../widgets/parcels_summary_card.dart';
import 'package:ssm_driver/core/utils/values/strings.dart';

class ParcelsScreen extends StatelessWidget {
  const ParcelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(AppSpacing.screen.w),
                children: <Widget>[
                  const ParcelsHeader(),
                  SizedBox(height: AppSpacing.xl.h),
                  const ParcelsSummaryCard(),
                  SizedBox(height: AppSpacing.xl.h),
                  const ParcelsListHeader(),
                  SizedBox(height: AppSpacing.md.h),
                  ParcelRouteCard(
                    orderId: 'SSM-P2048#',
                    customerDetails: Strings.parcelMockCustomer1,
                    phone: Strings.profileMockPhone,
                    station: Strings.parcelMockStation1,
                    status: Strings.parcelStatusInDelivery,
                    onTap: () {
                      context.pushNamed(AppRoutes.parcelDetailsName);
                    },
                  ),
                  SizedBox(height: AppSpacing.md.h),
                  ParcelRouteCard(
                    orderId: 'SSM-P2049#',
                    customerDetails: Strings.parcelMockCustomer2,
                    phone: Strings.profileMockPhone,
                    station: Strings.parcelMockStation2,
                    status: Strings.parcelStatusPending,
                    onTap: () {
                      context.pushNamed(AppRoutes.parcelDetailsName);
                    },
                  ),
                  SizedBox(height: AppSpacing.md.h),
                  ParcelRouteCard(
                    orderId: 'SSM-P2050#',
                    customerDetails: Strings.parcelMockCustomer3,
                    phone: Strings.profileMockPhone,
                    station: Strings.parcelMockStation3,
                    status: Strings.parcelStatusPending,
                    onTap: () {
                      context.pushNamed(AppRoutes.parcelDetailsName);
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(AppSpacing.screen.w),
              child: AppButton(
                btnText: Strings.parcelActionStartTour,
                onPressed: () {
                  context.pushNamed(AppRoutes.parcelDetailsName);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
