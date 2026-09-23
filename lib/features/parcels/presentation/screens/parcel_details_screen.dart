import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../orders/presentation/widgets/maps_call_buttons.dart';
import '../widgets/parcel_details_customer_card.dart';
import '../widgets/parcel_details_footer_banner.dart';
import '../widgets/parcel_details_header.dart';
import '../widgets/parcel_details_source_card.dart';
import '../widgets/parcel_details_status_card.dart';
import 'package:ssm_driver/core/utils/values/strings.dart';

class ParcelDetailsScreen extends StatelessWidget {
  const ParcelDetailsScreen({super.key});

  static const String _parcelId = 'SSM-P2048#';

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
              const ParcelDetailsHeader(parcelId: _parcelId),
              SizedBox(height: AppSpacing.lg.h),
              const ParcelDetailsStatusCard(),
              SizedBox(height: AppSpacing.xl.h),
              Text(
                Strings.parcelSourceTitle,
                style: AppTextStyles.h2(color: c.primaryDark),
              ),
              SizedBox(height: AppSpacing.sm.h),
              const ParcelDetailsSourceCard(),
              SizedBox(height: AppSpacing.xl.h),
              Text(
                Strings.parcelCustomerData,
                style: AppTextStyles.h2(color: c.primaryDark),
              ),
              SizedBox(height: AppSpacing.sm.h),
              const ParcelDetailsCustomerCard(),
              SizedBox(height: AppSpacing.xl.h),
              MapsCallButtons(
                mapsLabel: Strings.parcelActionMaps,
                callLabel: Strings.parcelActionCall,
                onMapsTap: () {},
                onCallTap: () {},
              ),
              SizedBox(height: AppSpacing.lg.h),
              const ParcelDetailsFooterBanner(),
              SizedBox(height: AppSpacing.lg.h),
            ],
          ),
        ),
      ),
    );
  }
}
