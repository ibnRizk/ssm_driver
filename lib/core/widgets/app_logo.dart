import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_decorations.dart';
import '../utils/values/app_assets.dart';
import '../utils/values/strings.dart';

/// Circular SSM badge. The source JPEG has white corners, so it's clipped to
/// its circle and sat on a white disc — the badge stays white in dark mode too.
class AppLogo extends StatelessWidget {
  /// Diameter in design units (ScreenUtil `.r` is applied here).
  final double size;

  const AppLogo({super.key, this.size = 96});

  @override
  Widget build(BuildContext context) {
    final double diameter = size.r;

    return Container(
      width: diameter,
      height: diameter,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Palette.surface,
        boxShadow: AppShadows.card,
      ),
      child: ClipOval(
        child: Image.asset(
          AppAssets.logo,
          fit: BoxFit.cover,
          cacheWidth: (diameter * MediaQuery.devicePixelRatioOf(context))
              .round(),
          semanticLabel: Strings.authAppLogoName,
        ),
      ),
    );
  }
}
