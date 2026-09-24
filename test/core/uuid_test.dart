import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_driver/core/utils/uuid.dart';

void main() {
  test('generates an RFC 4122 version-4 UUID', () {
    expect(
      generateUuidV4(),
      matches(
        RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        ),
      ),
    );
  });

  test('every call gives a new key', () {
    final Set<String> keys = <String>{
      for (int i = 0; i < 1000; i++) generateUuidV4(),
    };

    expect(keys, hasLength(1000));
  });
}
