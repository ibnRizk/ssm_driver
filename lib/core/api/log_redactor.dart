/// Masks secrets in anything headed for a log (API docs §21): the
/// `Authorization` header and every `password` / `otp` / `token` field —
/// including variants like `fcm_token` — whether printed as JSON
/// (`"otp": "123456"`), a Dart map (`{otp: 123456}`), a header line
/// (`authorization: Bearer …`) or a query string (`otp=123456`).
///
/// Only the values are replaced; the logs stay readable otherwise.
abstract class LogRedactor {
  static const String mask = '***';

  static final RegExp _secret = RegExp(
    // key: the header, or any field name containing a sensitive word.
    r'(authorization|[a-z_]*(?:password|otp|token)[a-z_]*)'
    // separator, with the key's own closing quote if it had one.
    r'(["\x27]?\s*[:=]\s*)'
    // value: a quoted string (may contain spaces or commas), or everything
    // up to the next field / end of line (covers "Bearer abc.def").
    r'("(?:[^"\\]|\\.)*"|\x27(?:[^\x27\\]|\\.)*\x27|[^,&}\n]+)',
    caseSensitive: false,
  );

  static String redact(String text) =>
      text.replaceAllMapped(_secret, (Match m) => '${m[1]}${m[2]}$mask');
}
