import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' show Color;

import 'package:dartz/dartz.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../error/failures.dart';
import '../../utils/log_utils.dart';
import '../local_storage/app_secure_storage.dart';
import 'push_hint.dart';
import 'push_service.dart';
import 'push_token_repository.dart';

/// The single high-importance channel for offers, orders and parcels.
/// [id] must match `default_notification_channel_id` in AndroidManifest.xml,
/// which Android uses for pushes it displays itself.
abstract class PushChannel {
  static const String id = 'ssm_driver_alerts';
  static const String name = 'Orders & parcels';
  static const String description =
      'New delivery offers and updates to your orders and parcels.';

  /// `res/drawable/ic_notification.xml` — monochrome, as Android requires.
  static const String icon = 'ic_notification';
  static const Color accent = Color(0xFF173C66);
}

/// Runs in a background isolate while the app is backgrounded or killed.
///
/// Pushes with a `notification` block are displayed by the OS; a data-only
/// push that carries a title/body is shown here, so it isn't lost.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (message.notification != null) return;
  try {
    final FlutterLocalNotificationsPlugin plugin =
        FlutterLocalNotificationsPlugin();
    await _initLocalNotifications(plugin);
    await _showLocally(plugin, message);
  } on Exception catch (e) {
    Log.w('Background push not shown: $e');
  }
}

class FirebasePushService implements PushService {
  final PushTokenRepository _tokens;
  final AppSecureStorage _storage;
  final FlutterLocalNotificationsPlugin _local;

  FirebasePushService({
    required PushTokenRepository tokens,
    required AppSecureStorage storage,
    FlutterLocalNotificationsPlugin? local,
  }) : _tokens = tokens,
       _storage = storage,
       _local = local ?? FlutterLocalNotificationsPlugin();

  /// Initialises Firebase and the background handler. Call from `main`
  /// before [init]; a failure (e.g. a missing config file) is logged and
  /// leaves push off, never blocks startup.
  static Future<void> bootstrap() async {
    try {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    } on Exception catch (e) {
      Log.w('Push disabled, Firebase failed to start: $e');
    }
  }

  /// Null until [init] succeeds; every other method is a no-op without it.
  FirebaseMessaging? _messaging;
  bool _initStarted = false;

  final StreamController<PushHint> _hints =
      StreamController<PushHint>.broadcast();
  final StreamController<void> _tapped = StreamController<void>.broadcast();
  final List<StreamSubscription<Object?>> _subscriptions =
      <StreamSubscription<Object?>>[];
  PushHint? _pendingTap;

  @override
  Stream<PushHint> get hints => _hints.stream;

  @override
  Stream<void> get tapped => _tapped.stream;

  @override
  PushHint? takePendingTap() {
    final PushHint? tap = _pendingTap;
    _pendingTap = null;
    return tap;
  }

  @override
  Future<void> init() async {
    if (_initStarted) return;
    _initStarted = true;
    if (Firebase.apps.isEmpty) return; // bootstrap() failed and logged why.

    try {
      final FirebaseMessaging messaging = FirebaseMessaging.instance;
      await _initLocalNotifications(
        _local,
        onTap: (NotificationResponse response) => _onLocalTap(response),
      );
      // iOS displays notification pushes itself, even in the foreground;
      // Android doesn't, so _onForeground shows those locally.
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      _subscriptions
        ..add(FirebaseMessaging.onMessage.listen(_onForeground))
        ..add(
          FirebaseMessaging.onMessageOpenedApp.listen(
            (RemoteMessage message) => _onTap(PushHint.fromData(message.data)),
          ),
        )
        ..add(messaging.onTokenRefresh.listen(_sendToken));
      _messaging = messaging;

      // A tap that launched the app from killed: held until the shell routes.
      final RemoteMessage? initial = await messaging.getInitialMessage();
      if (initial != null) _onTap(PushHint.fromData(initial.data));
      final NotificationAppLaunchDetails? launch = await _local
          .getNotificationAppLaunchDetails();
      final NotificationResponse? launchResponse = launch?.notificationResponse;
      if ((launch?.didNotificationLaunchApp ?? false) &&
          launchResponse != null) {
        _onLocalTap(launchResponse);
      }
    } on Exception catch (e) {
      Log.w('Push setup failed, relying on polling: $e');
    }
  }

  @override
  Future<void> registerDevice() async {
    final FirebaseMessaging? messaging = _messaging;
    if (messaging == null) return;
    try {
      // Prompts once (iOS, Android 13+); afterwards returns the saved choice.
      await messaging.requestPermission();
      // iOS can't mint an FCM token before APNs answers; onTokenRefresh
      // delivers it once it does.
      if (Platform.isIOS && await messaging.getAPNSToken() == null) return;
      await _sendToken(await messaging.getToken());
    } on Exception catch (e) {
      Log.w('Push registration failed: $e');
    }
  }

  @override
  Future<void> unregisterDevice() async {
    _pendingTap = null;
    final FirebaseMessaging? messaging = _messaging;
    if (messaging == null) return;
    try {
      await _local.cancelAll();
      await messaging.deleteToken();
    } on Exception catch (e) {
      Log.w('Push unregistration failed: $e');
    }
  }

  /// Only for a signed-in Driver: a refresh while signed out is picked up
  /// by the next sign-in's [registerDevice].
  Future<void> _sendToken(String? token) async {
    if (token == null || token.isEmpty) return;
    try {
      final String? session = await _storage.getAccessToken();
      if (session == null || session.isEmpty) return;
      final Either<Failure, Unit> result = await _tokens.updateFcmToken(token);
      result.fold(
        (Failure f) => Log.w('FCM token not registered: ${f.message}'),
        (_) => Log.i('FCM token registered'),
      );
    } on Exception catch (e) {
      Log.w('FCM token not registered: $e');
    }
  }

  Future<void> _onForeground(RemoteMessage message) async {
    _hints.add(PushHint.fromData(message.data));
    if (Platform.isIOS && message.notification != null) return;
    try {
      await _showLocally(_local, message);
    } on Exception catch (e) {
      Log.w('Foreground push not shown: $e');
    }
  }

  void _onLocalTap(NotificationResponse response) {
    final String? payload = response.payload;
    if (payload == null || payload.isEmpty) return;
    try {
      final Object? data = jsonDecode(payload);
      if (data is Map<String, dynamic>) _onTap(PushHint.fromData(data));
    } on FormatException catch (e) {
      Log.w('Unreadable notification payload: $e');
    }
  }

  void _onTap(PushHint hint) {
    _pendingTap = hint;
    _hints.add(hint);
    _tapped.add(null);
  }
}

/// Shared by the main and background isolates.
Future<void> _initLocalNotifications(
  FlutterLocalNotificationsPlugin plugin, {
  DidReceiveNotificationResponseCallback? onTap,
}) async {
  await plugin.initialize(
    settings: const InitializationSettings(
      android: AndroidInitializationSettings(PushChannel.icon),
      // Permission is requested through FirebaseMessaging after sign-in,
      // not by this plugin at app start.
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    ),
    onDidReceiveNotificationResponse: onTap,
  );
  await plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(
        const AndroidNotificationChannel(
          PushChannel.id,
          PushChannel.name,
          description: PushChannel.description,
          importance: Importance.high,
        ),
      );
}

String? _stringOf(Object? value) => value is String ? value : null;

/// A push with nothing to say (no title or body) stays a silent hint.
Future<void> _showLocally(
  FlutterLocalNotificationsPlugin plugin,
  RemoteMessage message,
) async {
  final String? title =
      message.notification?.title ?? _stringOf(message.data['title']);
  final String? body =
      message.notification?.body ?? _stringOf(message.data['body']);
  if ((title == null || title.isEmpty) && (body == null || body.isEmpty)) {
    return;
  }
  await plugin.show(
    id: (message.messageId ?? '${message.sentTime}').hashCode,
    title: title,
    body: body,
    payload: jsonEncode(message.data),
    notificationDetails: const NotificationDetails(
      android: AndroidNotificationDetails(
        PushChannel.id,
        PushChannel.name,
        channelDescription: PushChannel.description,
        importance: Importance.high,
        priority: Priority.high,
        icon: PushChannel.icon,
        color: PushChannel.accent,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    ),
  );
}
