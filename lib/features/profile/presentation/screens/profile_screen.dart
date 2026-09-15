import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/locale/locale_cubit.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/utils/values/strings.dart';

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
  // TODO: Move to real data source
  static String get _name => Strings.profileMockName;
  static String get _phone => Strings.profileMockPhone;
  static String get _location => Strings.profileMockLocation;
  static const String _rating = '4.9';
  static String get _vehicleName => Strings.profileMockVehicle;
  static String get _vehicleSubtitle => Strings.profileMockVehicleSubtitle;

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
              ProfileCard(
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
                    Strings.profileVehicleSection,
                    style: AppTextStyles.h2(color: c.textPrimary),
                  ),
                  Text(
                    Strings.profileVehicleSubtitle,
                    style: AppTextStyles.titleSmall(color: c.secondary),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.sm.h),
              VehicleInfoCard(
                name: _vehicleName,
                subtitle: _vehicleSubtitle,
              ),
              SizedBox(height: AppSpacing.xl.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    Strings.settings,
                    style: AppTextStyles.h2(color: c.textPrimary),
                  ),
                  Text(
                    Strings.navProfile,
                    style: AppTextStyles.titleSmall(color: c.secondary),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.sm.h),
              BlocBuilder<LocaleCubit, Locale?>(
                builder: (BuildContext context, Locale? locale) {
                  final bool isArabic =
                      (locale?.languageCode ?? Localizations.localeOf(context).languageCode) == 'ar';

                  return ProfileSettingsList(
                    items: <ProfileSettingsItem>[
                      ProfileSettingsItem(
                        icon: Icons.badge_outlined,
                        title: Strings.profilePersonalData,
                        subtitle: Strings.profilePersonalDataSubtitle,
                        onTap: () {},
                      ),
                      ProfileSettingsItem(
                        icon: Icons.access_time_outlined,
                        title: Strings.profileWorkingHours,
                        subtitle: Strings.profileWorkingHoursSubtitle,
                        onTap: () {},
                      ),
                      ProfileSettingsItem.toggle(
                        icon: Icons.notifications_outlined,
                        title: Strings.profileNotifications,
                        subtitle: Strings.profileNotificationsSubtitle,
                        value: _notificationsEnabled,
                        onChanged: (bool value) {
                          setState(() => _notificationsEnabled = value);
                        },
                      ),
                      ProfileSettingsItem.toggle(
                        icon: Icons.language_outlined,
                        title: Strings.language,
                        subtitle: isArabic ? Strings.arabic : Strings.english,
                        value: isArabic,
                        onChanged: (bool value) {
                          context.read<LocaleCubit>().changeLocale(
                                value ? LanguageCode.ar : LanguageCode.en,
                              );
                        },
                      ),
                      ProfileSettingsItem.toggle(
                        icon: Icons.dark_mode_outlined,
                        title: Strings.profileThemeMode,
                        subtitle: Strings.profileThemeModeSubtitle,
                        value: context.watch<ThemeCubit>().state == ThemeMode.dark,
                        onChanged: (bool value) {
                          context.read<ThemeCubit>().setThemeMode(
                                value ? ThemeMode.dark : ThemeMode.light,
                              );
                        },
                      ),
                      ProfileSettingsItem(
                        icon: Icons.support_agent_outlined,
                        title: Strings.profileSupport,
                        subtitle: Strings.profileSupportSubtitle,
                        onTap: () {},
                      ),
                    ],
                  );
                },
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
