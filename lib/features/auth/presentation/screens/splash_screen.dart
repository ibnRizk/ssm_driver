import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_logo.dart';
import '../cubit/session_cubit.dart';
import '../cubit/session_state.dart';
import '../../../../core/widgets/error_retry_view.dart';

/// Startup gate: validates any restored token before choosing the first
/// screen, since a newer login elsewhere silently invalidates it.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  /// Completes when the intro finishes; routing waits on it so a fast
  /// session check doesn't cut the animation off.
  TickerFuture? _intro;

  late final Animation<double> _logoScale = Tween<double>(
    begin: 0.6,
    end: 1,
  ).animate(_curve(0, 0.6, Curves.easeOutBack));
  late final Animation<double> _logoFade = _curve(0, 0.4, Curves.easeOut);
  late final Animation<double> _textFade = _curve(0.4, 0.85, Curves.easeOut);
  late final Animation<Offset> _textSlide = Tween<Offset>(
    begin: const Offset(0, 0.4),
    end: Offset.zero,
  ).animate(_curve(0.4, 0.85, Curves.easeOutCubic));
  late final Animation<double> _loaderFade = _curve(0.75, 1, Curves.easeOut);

  CurvedAnimation _curve(double begin, double end, Curve curve) =>
      CurvedAnimation(
        parent: _controller,
        curve: Interval(begin, end, curve: curve),
      );

  @override
  void initState() {
    super.initState();
    context.read<SessionCubit>().checkSession();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_intro != null) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.duration = Duration.zero;
    }
    _intro = _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _route(BuildContext context, SessionState state) async {
    final String? destination = switch (state) {
      SessionUnauthenticated() => AppRoutes.loginName,
      SessionApproved() => AppRoutes.homeName,
      SessionNotApproved() => AppRoutes.onboardingStatusName,
      SessionInitial() || SessionChecking() || SessionError() => null,
    };
    if (destination == null) return;

    await _intro;
    if (context.mounted) context.goNamed(destination);
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return Scaffold(
      backgroundColor: c.surface,
      body: Stack(
        children: <Widget>[
          _Blob(top: -90, start: -70, size: 280, color: c.primaryLight),
          _Blob(bottom: -110, end: -80, size: 300, color: c.secondaryLight),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const Spacer(flex: 3),
                  FadeTransition(
                    opacity: _logoFade,
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: const Center(child: AppLogo(size: 168)),
                    ),
                  ),
                  SizedBox(height: AppSpacing.xl.h),
                  FadeTransition(
                    opacity: _textFade,
                    child: SlideTransition(
                      position: _textSlide,
                      child: Column(
                        children: <Widget>[
                          Text(
                            Strings.splashTitle,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.h1(color: c.textPrimary),
                          ),
                          SizedBox(height: AppSpacing.xxs.h),
                          Text(
                            Strings.splashTagline,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.body(color: c.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(flex: 2),
                  BlocConsumer<SessionCubit, SessionState>(
                    listener: _route,
                    builder: (BuildContext context, SessionState state) {
                      if (state is SessionError) {
                        return ErrorRetryView(
                          message: state.message,
                          onRetry: context.read<SessionCubit>().checkSession,
                        );
                      }
                      return FadeTransition(
                        opacity: _loaderFade,
                        child: const _BrandLoader(),
                      );
                    },
                  ),
                  SizedBox(height: AppSpacing.xxl.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandLoader extends StatelessWidget {
  const _BrandLoader();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 120.w,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: LinearProgressIndicator(
            minHeight: 4.h,
            color: context.colors.secondary,
            backgroundColor: context.colors.secondaryLight,
          ),
        ),
      ),
    );
  }
}

/// Soft brand-tinted circle bleeding off a corner.
class _Blob extends StatelessWidget {
  final double? top;
  final double? bottom;
  final double? start;
  final double? end;
  final double size;
  final Color color;

  const _Blob({
    required this.size,
    required this.color,
    this.top,
    this.bottom,
    this.start,
    this.end,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.directional(
      textDirection: Directionality.of(context),
      top: top?.r,
      bottom: bottom?.r,
      start: start?.r,
      end: end?.r,
      child: Container(
        width: size.r,
        height: size.r,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}
