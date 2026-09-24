import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/error_retry_view.dart';
import '../../domain/entities/current_work.dart';
import '../cubit/current_work_cubit.dart';
import '../cubit/current_work_state.dart';
import 'no_active_work_view.dart';

/// Shared body for every screen of the delivery flow: [builder] once the
/// active order is loaded; otherwise a spinner, retry, or empty state under
/// [header], so back always works.
class CurrentWorkView extends StatelessWidget {
  final Widget header;
  final Widget Function(BuildContext context, CurrentWork work) builder;

  /// Lets a screen that is navigating away ignore the state it caused
  /// (e.g. the empty state right after completing the delivery).
  final BlocBuilderCondition<CurrentWorkState>? buildWhen;

  const CurrentWorkView({
    super.key,
    required this.header,
    required this.builder,
    this.buildWhen,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;

    return BlocBuilder<CurrentWorkCubit, CurrentWorkState>(
      buildWhen: buildWhen,
      builder: (BuildContext context, CurrentWorkState state) =>
          switch (state) {
            CurrentWorkLoaded(:final CurrentWork work) => builder(
              context,
              work,
            ),
            _ => Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(AppSpacing.screen.w),
                  child: header,
                ),
                Expanded(
                  child: switch (state) {
                    CurrentWorkError(:final String message) => ErrorRetryView(
                      message: message,
                      onRetry: context.read<CurrentWorkCubit>().loadCurrentWork,
                    ),
                    CurrentWorkEmpty() => const NoActiveWorkView(),
                    _ => Center(
                      child: CircularProgressIndicator(color: c.secondary),
                    ),
                  },
                ),
              ],
            ),
          },
    );
  }
}
