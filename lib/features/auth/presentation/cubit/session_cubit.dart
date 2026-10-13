import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/services/push/push_service.dart';
import '../../../../core/utils/values/strings.dart';
import '../../domain/entities/approval_status.dart';
import '../../domain/entities/onboarding_status.dart';
import '../../domain/repositories/auth_repository.dart';
import 'session_state.dart';

/// App-wide session gate: restores and validates the stored token at startup,
/// re-reads the approval status for pending drivers, and logs out. Keeps
/// this device's push registration in step with the session.
class SessionCubit extends Cubit<SessionState> {
  final AuthRepository _authRepository;
  final PushService _push;

  SessionCubit(this._authRepository, this._push)
    : super(const SessionInitial());

  Future<void> checkSession() async {
    emit(const SessionChecking());

    if (!await _authRepository.hasStoredSession()) {
      emit(const SessionUnauthenticated());
      return;
    }

    final Failure? failure = (await _authRepository.validateSession()).fold(
      (Failure f) => f,
      (_) => null,
    );
    if (failure != null) {
      await _handleFailure(failure);
      return;
    }

    // Re-sent on every restore so the backend never holds a stale token.
    // Not awaited: the permission prompt mustn't hold up the splash.
    unawaited(_push.registerDevice());
    await refreshStatus();
  }

  Future<void> refreshStatus() async {
    final SessionState current = state;
    emit(
      current is SessionNotApproved
          ? SessionNotApproved(status: current.status, isRefreshing: true)
          : const SessionChecking(),
    );

    final result = await _authRepository.getOnboardingStatus();
    await result.fold(_handleFailure, (OnboardingStatus status) async {
      emit(
        status.approvalStatus == ApprovalStatus.approved
            ? const SessionApproved()
            : SessionNotApproved(status: status),
      );
    });
  }

  Future<void> logout() async {
    await _authRepository.logout();
    // After the session is gone, so a token FCM mints on deletion isn't
    // sent for the Driver signing out. Not awaited: offline it can't stall
    // the way back to login.
    unawaited(_push.unregisterDevice());
    emit(const SessionUnauthenticated());
  }

  Future<void> _handleFailure(Failure failure) async {
    if (failure is UnauthorizedFailure) {
      await logout();
      return;
    }
    emit(SessionError(message: failure.message ?? Strings.somethingWentWrong));
  }
}
