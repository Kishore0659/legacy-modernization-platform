import 'package:intl/intl.dart';

/// Central place for all date/time formatting used across the app.
class DateFormatter {
  DateFormatter._();

  static String time(DateTime dt) => DateFormat('hh:mm a').format(dt);

  static String date(DateTime dt) => DateFormat('MMM d, yyyy').format(dt);

  static String dateTime(DateTime dt) =>
      DateFormat('MMM d, yyyy • hh:mm a').format(dt);

  /// e.g. "5 min ago", "just now"
  static String relative(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    return date(dt);
  }
}
