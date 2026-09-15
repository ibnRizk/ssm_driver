import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../widgets/logout_button.dart';
import '../widgets/profile_card.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_settings_list.dart';
import '../widgets/vehicle_info_card.dart';

/// Driver profile — the `profile` tab's body. `MainScaffold` already
/// supplies the outer Scaffold and bottom nav; this only builds the
/// scrollable content.
///
/// TODO: Replace the mock values below with a real driver-profile use case
/// once the driver-account API exists (same shape as `HomeScreen`'s TODO).
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const String _name = 'محمد العتيبي';
  static const String _phone = '05X XXX XXXX';
  static const String _location = 'مندوب معتمد - محافظة تربة';
  static const String _rating = '4.9';
  static const String _vehicleName = 'دراجة SSM';
  static const String _vehicleSubtitle = 'مركبة نشطة لمنطقة التوصيل المحلي';

  bool _notificationsEnabled = true;

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
              ProfileHeader(onSettingsTap: () {}),
              SizedBox(height: AppSpacing.lg.h),
              const ProfileCard(
                name: _name,
                phone: _phone,
                location: _location,
                rating: _rating,
              ),
              SizedBox(height: AppSpacing.xl.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'المركبة',
                    style: AppTextStyles.h2(color: c.textPrimary),
                  ),
                  Text(
                    'معلومات التشغيل',
                    style: AppTextStyles.titleSmall(color: c.secondary),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.sm.h),
              const VehicleInfoCard(
                name: _vehicleName,
                subtitle: _vehicleSubtitle,
              ),
              SizedBox(height: AppSpacing.xl.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'الإعدادات',
                    style: AppTextStyles.h2(color: c.textPrimary),
                  ),
                  Text(
                    'حسابك',
                    style: AppTextStyles.titleSmall(color: c.secondary),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.sm.h),
              ProfileSettingsList(
                items: <ProfileSettingsItem>[
                  ProfileSettingsItem(
                    icon: Icons.badge_outlined,
                    title: 'بياناتي',
                    subtitle: 'الاسم ورقم الجوال',
                    onTap: () {},
                  ),
                  ProfileSettingsItem(
                    icon: Icons.access_time_outlined,
                    title: 'أوقات العمل',
                    subtitle: 'تحديد ساعات استقبال الطلبات',
                    onTap: () {},
                  ),
                  ProfileSettingsItem.toggle(
                    icon: Icons.notifications_outlined,
                    title: 'إعدادات الإشعارات',
                    subtitle: 'تنبيهات الطلبات والطرود',
                    value: _notificationsEnabled,
                    onChanged: (bool value) {
                      setState(() => _notificationsEnabled = value);
                    },
                  ),
                  ProfileSettingsItem(
                    icon: Icons.support_agent_outlined,
                    title: 'المساعدة والدعم',
                    subtitle: 'نحن هنا لخدمتك',
                    onTap: () {},
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.xl.h),
              LogoutButton(
                onTap: () => context.goNamed(AppRoutes.loginName),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
