import 'push_hint.dart';

/// The app's push channel. A boundary like `RingtoneService`: nothing past
/// it throws, and without Firebase the app keeps working on polling alone.
///
/// Pushes are hints, never state: listeners refetch over REST, and the
/// existing polling stays on as the fallback for pushes that never arrive.
abstract class PushService {
  /// Creates the notification channel and starts listening. Call once,
  /// after Firebase is initialised.
  Future<void> init();

  /// Every push the running app learns of — one arriving in the foreground,
  /// or one the Driver opened. A cue to refetch the resource it concerns.
  Stream<PushHint> get hints;

  /// Only the pushes that arrived while the app was in the foreground — a
  /// subset of [hints] without the opened ones, which [tapped] routes. For
  /// in-app alerts that must not repeat what a tap already shows.
  Stream<PushHint> get received;

  /// Fires when the Driver opens a notification. Read it with
  /// [takePendingTap], which also covers a tap that launched the app before
  /// anything was listening.
  Stream<void> get tapped;

  /// The last opened notification not yet routed, cleared on read.
  PushHint? takePendingTap();

  /// Asks for notification permission and sends this device's token to the
  /// backend. Call after sign-in and on every validated session restore.
  Future<void> registerDevice();

  /// Stops pushes for the signed-out Driver: deletes the device token (the
  /// API has no unregister endpoint) and clears shown notifications.
  Future<void> unregisterDevice();
}
