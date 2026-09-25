import 'package:ssm_driver/core/services/ringtone/ringtone_service.dart';

/// Records play/stop instead of making a sound.
class FakeRingtoneService implements RingtoneService {
  int playCalls = 0;
  int stopCalls = 0;
  bool isRinging = false;

  @override
  Future<void> play() async {
    playCalls++;
    isRinging = true;
  }

  @override
  Future<void> stop() async {
    stopCalls++;
    isRinging = false;
  }
}
