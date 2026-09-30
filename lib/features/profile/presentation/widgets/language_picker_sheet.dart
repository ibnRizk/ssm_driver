import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/locale/locale_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/enum_extensions.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/utils/values/strings.dart';

/// Opens the language picker. The locale only changes when the user taps a
/// language; dismissing the sheet leaves everything as it was.
Future<void> showLanguagePicker(BuildContext context) async {
  final LocaleCubit localeCubit = context.read<LocaleCubit>();
  final LanguageCode current = LanguageCodeExtension.fromString(
    localeCubit.state.languageCode,
  );

  final LanguageCode? picked = await showModalBottomSheet<LanguageCode>(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => _LanguagePickerSheet(current: current),
  );

  // Applied after the sheet closes so the RTL/LTR flip doesn't happen
  // mid-animation.
  if (picked != null) await localeCubit.changeLocale(picked);
}

class _LanguagePickerSheet extends StatelessWidget {
  final LanguageCode current;

  const _LanguagePickerSheet({required this.current});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md.w,
        0,
        AppSpacing.md.w,
        AppSpacing.lg.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            Strings.selectLanguage,
            textAlign: TextAlign.center,
            style: AppTextStyles.h2(color: c.textPrimary),
          ),
          SizedBox(height: AppSpacing.md.h),
          for (final LanguageCode code in LanguageCode.values)
            _LanguageOption(
              code: code,
              selected: code == current,
              onTap: () => Navigator.of(context).pop(code),
            ),
        ],
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final LanguageCode code;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.code,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.xs.h),
      child: ListTile(
        onTap: onTap,
        selected: selected,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md.r),
          side: BorderSide(color: selected ? c.secondary : c.border),
        ),
        tileColor: c.surface,
        selectedTileColor: c.secondaryLight,
        contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md.w),
        title: Text(
          code.nativeName,
          style: AppTextStyles.title(color: c.textPrimary),
        ),
        trailing: selected
            ? Icon(Icons.check_circle_rounded, color: c.secondary, size: 22.r)
            : null,
      ),
    );
  }
}
