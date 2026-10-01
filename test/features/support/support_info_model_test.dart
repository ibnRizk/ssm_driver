import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_driver/features/support/data/models/support_info_model.dart';
import 'package:ssm_driver/features/support/domain/entities/support_info.dart';

void main() {
  test('parses the documented support-info response', () {
    final SupportInfoModel info = SupportInfoModel.fromJson(<String, dynamic>{
      'phone': '+966500000000',
      'whatsapp': '+966500000001',
      'email': 'support@ssm.sa',
      'working_hours': '09:00 - 22:00',
      'faqs': <dynamic>[],
    });

    expect(
      info,
      const SupportInfoModel(
        phone: '+966500000000',
        whatsapp: '+966500000001',
        email: 'support@ssm.sa',
        workingHours: '09:00 - 22:00',
      ),
    );
  });

  test('missing or blank contacts are null', () {
    final SupportInfoModel info = SupportInfoModel.fromJson(<String, dynamic>{
      'phone': '',
      'email': null,
    });

    expect(info.phone, isNull);
    expect(info.email, isNull);
    expect(info.faqs, isEmpty);
  });

  test('reads question/answer FAQs and skips malformed ones', () {
    final SupportInfoModel info = SupportInfoModel.fromJson(<String, dynamic>{
      'faqs': <dynamic>[
        <String, dynamic>{'question': 'How?', 'answer': 'Like this.'},
        <String, dynamic>{'question': 'No answer'},
        'junk',
      ],
    });

    expect(info.faqs, const <SupportFaq>[
      SupportFaq(question: 'How?', answer: 'Like this.'),
    ]);
  });
}
