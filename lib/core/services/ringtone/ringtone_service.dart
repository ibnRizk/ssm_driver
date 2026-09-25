import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

import '../../utils/log_utils.dart';

/// A looping "incoming call" alert. This is the boundary for the platform
/// plugin: nothing past it throws — a device that can't play stays silent.
abstract class RingtoneService {
  /// Rings until [stop]. A no-op while already ringing.
  Future<void> play();

  /// Silences it. Safe to call when not ringing.
  Future<void> stop();
}

/// The device's own ringtone, so no audio file ships with the app.
class SystemRingtoneService implements RingtoneService {
  final FlutterRingtonePlayer _player;

  SystemRingtoneService({FlutterRingtonePlayer? player})
    : _player = player ?? FlutterRingtonePlayer();

  /// iOS only plays a short system sound, once, and has no stop — so the
  /// loop is ours there: the sound is replayed on this interval.
  static const Duration _iosRepeat = Duration(seconds: 2);

  Timer? _iosLoop;
  bool _ringing = false;

  @override
  Future<void> play() async {
    if (_ringing) return;
    _ringing = true;
    if (Platform.isIOS) {
      _iosLoop = Timer.periodic(_iosRepeat, (_) => _guard(_playOnce));
    }
    await _guard(_playOnce);
  }

  @override
  Future<void> stop() async {
    if (!_ringing) return;
    _ringing = false;
    _iosLoop?.cancel();
    _iosLoop = null;
    await _guard(_player.stop);
  }

  // Loops natively on Android; a single play on iOS.
  Future<void> _playOnce() => _player.playRingtone(looping: true);

  Future<void> _guard(Future<void> Function() call) async {
    try {
      await call();
    } on Exception catch (e) {
      Log.w('Ringtone unavailable: $e');
    }
  }
}
