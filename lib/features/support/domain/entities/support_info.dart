import 'package:equatable/equatable.dart';

/// Driver support contacts (`GET /delivery-man/support-info`). Any contact
/// may be missing when it isn't configured in the backend settings.
class SupportInfo extends Equatable {
  final String? phone;
  final String? whatsapp;
  final String? email;
  final String? workingHours;

  /// Empty until FAQs are configured on the backend.
  final List<SupportFaq> faqs;

  const SupportInfo({
    this.phone,
    this.whatsapp,
    this.email,
    this.workingHours,
    this.faqs = const <SupportFaq>[],
  });

  @override
  List<Object?> get props => [phone, whatsapp, email, workingHours, faqs];
}

class SupportFaq extends Equatable {
  final String question;
  final String answer;

  const SupportFaq({required this.question, required this.answer});

  @override
  List<Object?> get props => [question, answer];
}
