import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

import '../../utils/log_utils.dart';

/// A looping "incoming order" alert. This is the boundary for the platform
/// plugin: nothing past it throws — a device that can't play stays silent.
abstract class RingtoneService {
  /// Rings until [stop]. A no-op while already ringing.
  Future<void> play();

  /// Silences it. Safe to call when not ringing.
  Future<void> stop();
}

/// The app's own order alert (`assets/sound/sound.mp3`), looped.
///
/// It plays as a ringtone-class sound rather than media, so Android routes
/// it through the ring/notification volume — a driver with media turned
/// down still hears it — and iOS plays it even with the silent switch on.
class AssetRingtoneService implements RingtoneService {
  /// Relative to `assets/` (audioplayers adds that prefix itself).
  static const String assetPath = 'sound/sound.mp3';

  /// On iOS this sets the app-wide AVAudioSession category, and it stays
  /// set after [stop]; audioplayers deactivates the session once nothing
  /// plays, so other apps' audio is only ducked while the alert rings.
  /// Any future in-app audio inherits this category.
  static final AudioContext _alertContext = AudioContext(
    android: const AudioContextAndroid(
      contentType: AndroidContentType.sonification,
      usageType: AndroidUsageType.notificationRingtone,
      // Other apps' audio (e.g. navigation voice) dips, not stops.
      audioFocus: AndroidAudioFocus.gainTransientMayDuck,
    ),
    iOS: AudioContextIOS(
      category: AVAudioSessionCategory.playback,
      options: const <AVAudioSessionOptions>{AVAudioSessionOptions.duckOthers},
    ),
  );

  final AudioPlayer Function() _newPlayer;

  AssetRingtoneService({AudioPlayer Function()? playerFactory})
    : _newPlayer = playerFactory ?? AudioPlayer.new;

  /// Shared so overlapping play/stop/play calls set up a single player.
  Future<AudioPlayer>? _player;
  bool _ringing = false;

  @override
  Future<void> play() async {
    if (_ringing) return;
    _ringing = true;
    final bool started = await _guard(() async {
      final AudioPlayer player = await (_player ??= _createPlayer());
      // stop() may have landed while the player was being set up.
      if (_ringing) await player.resume();
    });
    // Nothing is ringing, so don't let a later play() be skipped as a no-op.
    if (!started) _ringing = false;
  }

  /// Always reaches the player, even when [_ringing] is already false, so a
  /// stale flag can never leave the loop playing.
  @override
  Future<void> stop() async {
    _ringing = false;
    final Future<AudioPlayer>? player = _player;
    if (player == null) return;
    await _guard(() async => (await player).stop());
  }

  /// Created on first ring so no platform channel is touched at startup.
  Future<AudioPlayer> _createPlayer() async {
    final AudioPlayer player = _newPlayer();
    try {
      await player.setAudioContext(_alertContext);
      await player.setReleaseMode(ReleaseMode.loop);
      await player.setSource(AssetSource(assetPath));
      return player;
    } on Exception {
      _player = null; // Let the next offer retry the setup.
      unawaited(player.dispose());
      rethrow;
    }
  }

  /// `false` when [call] failed (and was logged).
  Future<bool> _guard(Future<void> Function() call) async {
    try {
      await call();
      return true;
    } on Exception catch (e) {
      Log.w('Order alert sound unavailable: $e');
      return false;
    }
  }
}
