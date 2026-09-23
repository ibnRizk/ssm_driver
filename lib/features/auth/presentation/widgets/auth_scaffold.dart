import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:flutter_base/core/utils/values/strings.dart';

/// Shared layout for the auth flow (login, and register once it exists):
/// a centered brand mark, a bold title + subtitle, the screen's form as
/// [child], and a two-line footer pinned near the bottom.
///
/// There's no `AuthScaffold` in `core/widgets/` yet — this one is local to
/// the auth feature until a second consumer (register) needs it, at which
/// point it's a one-line move to `core/widgets/`.
class AuthScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? greeting;
  final Widget child;
  final String footerPrimary;
  final String footerSecondary;

  /// Optional back-button app bar — login (the initial route) has none;
  /// register (pushed on top of it) sets one for the back action.
  final PreferredSizeWidget? appBar;

  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    required this.footerPrimary,
    required this.footerSecondary,
    this.greeting,
    this.appBar,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Scaffold(
      backgroundColor: c.surface,
      appBar: appBar,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            // Soft decorative blob in the top-right corner — purely
            // decorative, matches the design's subtle background tint.
            Positioned.directional(
              textDirection: Directionality.of(context),
              top: -60.r,
              start: -60.r,
              child: Container(
                width: 220.r,
                height: 220.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: c.background,
                ),
              ),
            ),
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints viewport) {
                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl.w,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: viewport.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          SizedBox(height: AppSpacing.xxl.h),
                          const _BrandMark(),
                          SizedBox(height: AppSpacing.xl.h),
                          if (greeting != null) ...<Widget>[
                            Text(
                              greeting!,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.body(
                                color: c.textSecondary,
                              ),
                            ),
                            SizedBox(height: AppSpacing.xxs.h),
                          ],
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.display(
                              color: c.primary,
                            ),
                          ),
                          SizedBox(height: AppSpacing.xs.h),
                          Text(
                            subtitle,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.body(
                              color: c.textSecondary,
                            ),
                          ),
                          SizedBox(height: AppSpacing.xxl.h),
                          child,
                          const Spacer(),
                          SizedBox(height: AppSpacing.xxl.h),
                          Text(
                            footerPrimary,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.caption(
                              color: c.textHint,
                            ),
                          ),
                          SizedBox(height: AppSpacing.xxs.h),
                          Text(
                            footerSecondary,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.caption(
                              color: c.textHint,
                            ),
                          ),
                          SizedBox(height: AppSpacing.lg.h),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Circular placeholder brand mark. Swap for the real "SSM" logo asset
/// (`AppAssets.logo`) once it's dropped into `assets/images/`.
class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Center(
      child: Container(
        width: 88.r,
        height: 88.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: c.surface,
          border: Border.all(color: c.primary, width: 2),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'SSM',
              style: AppTextStyles.title(color: c.secondary).copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
            Text(
              Strings.authAppLogoName,
              style: AppTextStyles.label(color: c.primary),
            ),
          ],
        ),
      ),
    );
  }
}
