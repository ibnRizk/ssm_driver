import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';
import '../utils/values/strings.dart';
import '../../config/locale/locale_cubit.dart';
import '../../features/home/presentation/cubit/availability_cubit.dart';
import '../../features/home/presentation/cubit/availability_state.dart';
import 'app_button.dart';

class SmartEmptyStateWidget extends StatelessWidget {
  const SmartEmptyStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, locale) {
        return BlocBuilder<AvailabilityCubit, AvailabilityState>(
          builder: (BuildContext context, AvailabilityState state) {
            final bool isOnline = state.isOnline ?? false;
            if (isOnline) {
              return const _OnlineRadarState();
            } else {
              return const _OfflineState();
            }
          },
        );
      },
    );
  }
}

class _OfflineState extends StatelessWidget {
  const _OfflineState();

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final AvailabilityState state = context.watch<AvailabilityCubit>().state;
    final bool isLoading =
        state is AvailabilityLoading ||
        (state is AvailabilityLoaded && state.isUpdating);

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(AppSpacing.lg.r),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.surface,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 15,
                    spreadRadius: 5,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                Icons.power_settings_new_rounded,
                size: 64.r,
                color: c.textHint.withOpacity(0.5),
              ),
            ),
            SizedBox(height: AppSpacing.xl.h),
            Text(
              Strings.emptyStateOfflineTitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.h2(color: c.textPrimary).copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: AppSpacing.xs.h),
            Text(
              Strings.emptyStateOfflineSubtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.body(color: c.textSecondary).copyWith(
                height: 1.4,
              ),
            ),
            SizedBox(height: AppSpacing.xxl.h),
            AppButton(
              btnText: Strings.emptyStateGoOnlineButton,
              isLoading: isLoading,
              onPressed: () => context.read<AvailabilityCubit>().toggle(),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnlineRadarState extends StatefulWidget {
  const _OnlineRadarState();

  @override
  State<_OnlineRadarState> createState() => _OnlineRadarStateState();
}

class _OnlineRadarStateState extends State<_OnlineRadarState>
    with TickerProviderStateMixin {
  late AnimationController _rippleController;
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;

  @override
  void initState() {
    super.initState();
    // Ripples run continuously in one direction
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    // Breathing effect scales up and down smoothly
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _breathingAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _rippleController.dispose();
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              height: 200.r,
              width: 200.r,
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  // 1. The staggered sonar ripples
                  AnimatedBuilder(
                    animation: _rippleController,
                    builder: (BuildContext context, Widget? child) {
                      return CustomPaint(
                        size: Size(200.r, 200.r),
                        painter: _RipplePainter(
                          animationValue: _rippleController.value,
                          color: c.primary,
                        ),
                      );
                    },
                  ),
                  // 2. The central icon with breathing effect
                  AnimatedBuilder(
                    animation: _breathingAnimation,
                    builder: (BuildContext context, Widget? child) {
                      return Transform.scale(
                        scale: _breathingAnimation.value,
                        child: Container(
                          height: 72.r,
                          width: 72.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: c.primary,
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: c.primary.withOpacity(0.4),
                                blurRadius: 20,
                                spreadRadius: 4,
                                offset: const Offset(0, 8),
                              ),
                              BoxShadow(
                                color: c.primary.withOpacity(0.2),
                                blurRadius: 10,
                                spreadRadius: -2,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.radar_rounded,
                            size: 36.r,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.xl.h),
            Text(
              Strings.emptyStateOnlineTitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.title(color: c.textSecondary).copyWith(
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for the staggered ripple effect.
class _RipplePainter extends CustomPainter {
  final double animationValue;
  final Color color;

  _RipplePainter({required this.animationValue, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..style = PaintingStyle.fill;
    final double maxRadius = size.width / 2;
    const int ringCount = 3;

    for (int i = 0; i < ringCount; i++) {
      // Offset each ring by 1/ringCount (staggered effect)
      double progress = animationValue - (i * (1.0 / ringCount));
      if (progress < 0) {
        progress += 1.0;
      }

      // Use easeOutQuad for a smooth expansion that slows down outward
      final double curve = Curves.easeOutQuad.transform(progress);

      // Opacity fades out beautifully as it expands
      final double opacity = 0.35 * (1.0 - curve);
      paint.color = color.withOpacity(opacity);

      final double radius = maxRadius * curve;

      canvas.drawCircle(Offset(size.width / 2, size.height / 2), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RipplePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.color != color;
  }
}
