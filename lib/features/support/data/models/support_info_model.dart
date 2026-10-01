import '../../domain/entities/support_info.dart';

class SupportInfoModel extends SupportInfo {
  const SupportInfoModel({
    super.phone,
    super.whatsapp,
    super.email,
    super.workingHours,
    super.faqs,
  });

  /// `{ phone, whatsapp, email, working_hours, faqs: [] }`. The FAQ item
  /// shape isn't documented yet, so `{question, answer}` entries are read
  /// and anything else is skipped rather than shown half-empty.
  factory SupportInfoModel.fromJson(Map<String, dynamic> json) {
    final dynamic faqs = json['faqs'];
    return SupportInfoModel(
      phone: _text(json['phone']),
      whatsapp: _text(json['whatsapp']),
      email: _text(json['email']),
      workingHours: _text(json['working_hours']),
      faqs: <SupportFaq>[
        if (faqs is List)
          for (final dynamic faq in faqs)
            if (faq is Map)
              if ((_text(faq['question']), _text(faq['answer']))
                  case (final String question, final String answer))
                SupportFaq(question: question, answer: answer),
      ],
    );
  }

  static String? _text(dynamic value) =>
      value is String && value.trim().isNotEmpty ? value.trim() : null;
}
