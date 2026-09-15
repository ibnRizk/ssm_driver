import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/app_button.dart';
import '../widgets/parcel_route_card.dart';
import '../widgets/parcels_header.dart';
import '../widgets/parcels_list_header.dart';
import '../widgets/parcels_summary_card.dart';

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
                  const ParcelRouteCard(
                    orderId: 'SSM-P2048#',
                    customerDetails: 'سارة أحمد • حي المروج',
                    phone: '05X XXX XXXX',
                    station: 'المحطة 1',
                    status: 'قيد التوصيل',
                  ),
                  SizedBox(height: AppSpacing.md.h),
                  const ParcelRouteCard(
                    orderId: 'SSM-P2049#',
                    customerDetails: 'خالد العتيبي • حي الملك فهد',
                    phone: '05X XXX XXXX',
                    station: 'المحطة 2',
                    status: 'بانتظار الاستلام',
                  ),
                  SizedBox(height: AppSpacing.md.h),
                  const ParcelRouteCard(
                    orderId: 'SSM-P2050#',
                    customerDetails: 'نورة محمد • حي النخيل',
                    phone: '05X XXX XXXX',
                    station: 'المحطة 3',
                    status: 'بانتظار الاستلام',
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(AppSpacing.screen.w),
              child: AppButton(
                btnText: 'ابدأ جولة الطرود',
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
