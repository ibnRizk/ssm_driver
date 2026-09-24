import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_driver/core/api/log_redactor.dart';

void main() {
  test('masks the Authorization header line', () {
    expect(
      LogRedactor.redact(' authorization: Bearer 12|abc.def'),
      ' authorization: ***',
    );
  });

  test('masks Authorization inside a printed header map', () {
    expect(
      LogRedactor.redact(
        '{Authorization: Bearer abc, Accept: application/json}',
      ),
      '{Authorization: ***, Accept: application/json}',
    );
  });

  test('masks the OTP in a Dart map body', () {
    expect(
      LogRedactor.redact(
        '{proof_method: otp, otp: 123456, cod_collected: true}',
      ),
      '{proof_method: otp, otp: ***, cod_collected: true}',
    );
  });

  test('masks a JSON password, spaces and all', () {
    expect(
      LogRedactor.redact(
        '{"phone":"+966500000000","password":"Str0ng Pass#1"}',
      ),
      '{"phone":"+966500000000","password":***}',
    );
  });

  test('masks token fields such as fcm_token', () {
    expect(
      LogRedactor.redact('{"fcm_token": "abc123", "token": "xyz"}'),
      '{"fcm_token": ***, "token": ***}',
    );
  });

  test('masks a query-string OTP', () {
    expect(LogRedactor.redact('otp=123456&page=1'), 'otp=***&page=1');
  });

  test('leaves ordinary fields untouched', () {
    const String line =
        '{order_id: 9001, latitude: 24.71, Idempotency-Key: 3f2a-uuid}';

    expect(LogRedactor.redact(line), line);
  });
}
