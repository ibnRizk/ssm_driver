import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_driver/core/services/ringtone/ringtone_service.dart';

/// Records what the service asks of the player. [setSource] waits on
/// [sourceGate] when set, holding the setup open mid-flight.
class FakeAudioPlayer implements AudioPlayer {
  Completer<void>? sourceGate;
  Object? setupError;
  Object? resumeError;

  bool isPlaying = false;
  bool disposed = false;
  ReleaseMode? setMode;
  Source? setSourceArg;

  @override
  Future<void> setAudioContext(AudioContext ctx) async {}

  @override
  Future<void> setReleaseMode(ReleaseMode mode) async => setMode = mode;

  @override
  Future<void> setSource(Source source) async {
    await sourceGate?.future;
    if (setupError != null) throw setupError!;
    setSourceArg = source;
  }

  @override
  Future<void> resume() async {
    if (resumeError != null) throw resumeError!;
    isPlaying = true;
  }

  @override
  Future<void> stop() async => isPlaying = false;

  @override
  Future<void> dispose() async => disposed = true;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late List<FakeAudioPlayer> created;
  late void Function(FakeAudioPlayer) configure;
  late AssetRingtoneService service;

  setUp(() {
    created = <FakeAudioPlayer>[];
    configure = (_) {};
    service = AssetRingtoneService(
      playerFactory: () {
        final FakeAudioPlayer player = FakeAudioPlayer();
        configure(player);
        created.add(player);
        return player;
      },
    );
  });

  test('play loops the bundled asset', () async {
    await service.play();

    final FakeAudioPlayer player = created.single;
    expect(player.isPlaying, isTrue);
    expect(player.setMode, ReleaseMode.loop);
    expect((player.setSourceArg! as AssetSource).path, 'sound/sound.mp3');
  });

  test('stop silences the player', () async {
    await service.play();
    await service.stop();

    expect(created.single.isPlaying, isFalse);
  });

  test('play → stop → play during setup uses one player and rings', () async {
    final Completer<void> gate = Completer<void>();
    configure = (FakeAudioPlayer p) => p.sourceGate = gate;

    final Future<void> first = service.play();
    final Future<void> stopped = service.stop();
    final Future<void> second = service.play();
    gate.complete();
    await Future.wait(<Future<void>>[first, stopped, second]);

    expect(created, hasLength(1));
    expect(created.single.isPlaying, isTrue);
  });

  test('play → stop during setup ends silent', () async {
    final Completer<void> gate = Completer<void>();
    configure = (FakeAudioPlayer p) => p.sourceGate = gate;

    final Future<void> first = service.play();
    final Future<void> stopped = service.stop();
    gate.complete();
    await Future.wait(<Future<void>>[first, stopped]);

    expect(created.single.isPlaying, isFalse);
  });

  test('a failed setup disposes the player and the next play retries', () async {
    configure = (FakeAudioPlayer p) =>
        p.setupError = PlatformException(code: 'no-asset');

    await service.play();
    configure = (_) {};
    await service.play();

    expect(created, hasLength(2));
    expect(created.first.disposed, isTrue);
    expect(created.last.isPlaying, isTrue);
  });

  test('a failed resume does not make the next play a no-op', () async {
    configure = (FakeAudioPlayer p) =>
        p.resumeError = PlatformException(code: 'busy');
    await service.play();

    created.single.resumeError = null;
    await service.play();

    expect(created.single.isPlaying, isTrue);
  });

  test('stop before any play is a no-op', () async {
    await service.stop();

    expect(created, isEmpty);
  });
}
