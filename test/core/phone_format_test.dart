import 'package:flutter_base/core/utils/string_extension.dart';
import 'package:flutter_base/features/auth/domain/entities/approval_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('toInternationalPhone', () {
    const Map<String, String> cases = <String, String>{
      '0501234567': '+966501234567',
      '501234567': '+966501234567',
      '050 123 4567': '+966501234567',
      '+966501234567': '+966501234567',
      '966501234567': '+966501234567',
      '+971501234567': '+971501234567',
    };

    cases.forEach((String input, String expected) {
      test('$input -> $expected', () {
        expect(input.toInternationalPhone(), expected);
      });
    });
  });

  group('ApprovalStatus.fromApi', () {
    test('maps known values', () {
      expect(ApprovalStatus.fromApi('approved'), ApprovalStatus.approved);
      expect(ApprovalStatus.fromApi('rejected'), ApprovalStatus.rejected);
      expect(ApprovalStatus.fromApi('pending'), ApprovalStatus.pending);
    });

    test('unknown values never grant access', () {
      expect(ApprovalStatus.fromApi('something-new'), ApprovalStatus.pending);
      expect(ApprovalStatus.fromApi(null), ApprovalStatus.pending);
    });
  });
}
