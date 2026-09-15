import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';

/// One row's data for [ProfileSettingsList]. A row is either navigable
/// (shows a chevron and calls [onTap]) or a toggle (shows a `Switch` bound
/// to [value] and calls [onChanged]) — never both.
class ProfileSettingsItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool? value;
  final ValueChanged<bool>? onChanged;

  const ProfileSettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  }) : value = null,
       onChanged = null;

  const ProfileSettingsItem.toggle({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  }) : onTap = null;
}

/// Single white card holding the account-settings list, each row a
/// [ListTile] separated by hairline dividers.
class ProfileSettingsList extends StatelessWidget {
  final List<ProfileSettingsItem> items;

  const ProfileSettingsList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Container(
      decoration: AppDecorations.card(c),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: Column(
          children: <Widget>[
            for (int i = 0; i < items.length; i++) ...<Widget>[
              if (i > 0) Divider(color: c.border, height: 1, indent: AppSpacing.md.w, endIndent: AppSpacing.md.w),
              _SettingsTile(item: items[i]),
            ],
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final ProfileSettingsItem item;

  const _SettingsTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final bool isToggle = item.onChanged != null;

    return ListTile(
      onTap: item.onTap,
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md.w,
        vertical: AppSpacing.xxs.h,
      ),
      leading: Container(
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          color: c.secondaryLight,
          shape: BoxShape.circle,
        ),
        child: Icon(item.icon, color: c.secondary, size: 22.r),
      ),
      title: Text(item.title, style: AppTextStyles.title(color: c.primaryDark)),
      subtitle: Text(
        item.subtitle,
        style: AppTextStyles.caption(color: c.textSecondary),
      ),
      trailing: isToggle
          ? Switch(
              value: item.value!,
              onChanged: item.onChanged,
              activeThumbColor: c.secondary,
            )
          : Icon(Icons.chevron_left_rounded, color: c.textHint, size: 24.r),
    );
  }
}
