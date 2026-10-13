import 'dart:async';

import 'package:ssm_driver/core/services/push/push_hint.dart';
import 'package:ssm_driver/core/services/push/push_service.dart';

/// Records registration calls; [emit] and [tap] stand in for Firebase.
class FakePushService implements PushService {
  int registerCalls = 0;
  int unregisterCalls = 0;
  PushHint? pendingTap;

  final StreamController<PushHint> _hints =
      StreamController<PushHint>.broadcast();
  final StreamController<void> _tapped = StreamController<void>.broadcast();

  void emit(PushHint hint) => _hints.add(hint);

  void tap(PushHint hint) {
    pendingTap = hint;
    _tapped.add(null);
  }

  @override
  Stream<PushHint> get hints => _hints.stream;

  @override
  Stream<void> get tapped => _tapped.stream;

  @override
  PushHint? takePendingTap() {
    final PushHint? tap = pendingTap;
    pendingTap = null;
    return tap;
  }

  @override
  Future<void> init() async {}

  @override
  Future<void> registerDevice() async => registerCalls++;

  @override
  Future<void> unregisterDevice() async => unregisterCalls++;
}
