import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        title: Text(Strings.navProfile, style: AppTextStyles.h2(color: c.textPrimary)),
        backgroundColor: c.background,
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.screen.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _ProfileHeader(name: 'محمد', phone: '+966 50 123 4567', rating: '4.9'),
            SizedBox(height: AppSpacing.xl.h),
            _SectionTitle(title: 'المركبة'),
            SizedBox(height: AppSpacing.sm.h),
            _VehicleInfoCard(model: 'تويوتا كامري', plate: 'أ ب ج 1234', year: '2022'),
            SizedBox(height: AppSpacing.xl.h),
            _SectionTitle(title: 'الإعدادات'),
            SizedBox(height: AppSpacing.sm.h),
            _SettingsTile(
              icon: Icons.language_outlined,
              title: 'اللغة',
              value: 'العربية',
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.dark_mode_outlined,
              title: 'المظهر',
              value: 'النظام',
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.help_outline,
              title: 'مركز المساعدة',
              onTap: () {},
            ),
            SizedBox(height: AppSpacing.xl.h),
            _SettingsTile(
              icon: Icons.logout,
              title: 'تسجيل الخروج',
              textColor: c.error,
              iconColor: c.error,
              onTap: () {},
              showArrow: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String name;
  final String phone;
  final String rating;

  const _ProfileHeader({
    required this.name,
    required this.phone,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Row(
      children: <Widget>[
        Container(
          width: 72.r,
          height: 72.r,
          decoration: BoxDecoration(color: c.primary, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Text(
            name.characters.first,
            style: AppTextStyles.h1(color: Colors.white).copyWith(fontSize: 32.sp),
          ),
        ),
        SizedBox(width: AppSpacing.lg.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(name, style: AppTextStyles.h2(color: c.textPrimary)),
              SizedBox(height: AppSpacing.xxs.h),
              Text(phone, style: AppTextStyles.body(color: c.textSecondary)),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm.w, vertical: AppSpacing.xs.h),
          decoration: BoxDecoration(
            color: c.secondaryLight,
            borderRadius: BorderRadius.circular(AppRadius.md.r),
          ),
          child: Row(
            children: <Widget>[
              Icon(Icons.star_rounded, color: c.secondary, size: 20.r),
              SizedBox(width: AppSpacing.xxs.w),
              Text(rating, style: AppTextStyles.title(color: c.secondaryDark)),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Text(
      title,
      style: AppTextStyles.title(color: c.textPrimary),
    );
  }
}

class _VehicleInfoCard extends StatelessWidget {
  final String model;
  final String plate;
  final String year;

  const _VehicleInfoCard({
    required this.model,
    required this.plate,
    required this.year,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md.w),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg.r),
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(AppSpacing.md.r),
            decoration: BoxDecoration(
              color: c.background,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.directions_car_outlined, color: c.primary, size: 28.r),
          ),
          SizedBox(width: AppSpacing.md.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(model, style: AppTextStyles.title(color: c.textPrimary)),
                SizedBox(height: AppSpacing.xxs.h),
                Text('$plate • $year', style: AppTextStyles.body(color: c.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? value;
  final VoidCallback onTap;
  final Color? textColor;
  final Color? iconColor;
  final bool showArrow;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.value,
    required this.onTap,
    this.textColor,
    this.iconColor,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.md.h),
        child: Row(
          children: <Widget>[
            Icon(icon, color: iconColor ?? c.textSecondary, size: 24.r),
            SizedBox(width: AppSpacing.md.w),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.title(color: textColor ?? c.textPrimary),
              ),
            ),
            if (value != null) ...<Widget>[
              Text(
                value!,
                style: AppTextStyles.body(color: c.textSecondary),
              ),
              SizedBox(width: AppSpacing.sm.w),
            ],
            if (showArrow)
              Icon(Icons.chevron_left_rounded, color: c.textHint, size: 24.r),
          ],
        ),
      ),
    );
  }
}
