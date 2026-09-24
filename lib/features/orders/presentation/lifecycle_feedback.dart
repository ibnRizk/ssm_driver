import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/widgets/app_snack_bar.dart'
    show ToastType, showAppSnackBar;
import 'cubit/current_work_cubit.dart';
import 'cubit/order_lifecycle_state.dart';

/// Shared by the delivery step screens: shows the server's error (wrong OTP,
/// 409 sequence/version conflict, …) and, when the answer was definitive,
/// re-reads `current-work` before the next action (API docs §15).
void showLifecycleFailure(BuildContext context, LifecycleFailure failure) {
  showAppSnackBar(
    context: context,
    message: failure.message,
    type: ToastType.error,
  );
  if (failure.shouldRefreshWork) {
    context.read<CurrentWorkCubit>().loadCurrentWork();
  }
}
