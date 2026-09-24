import '../core/constants/app_constants.dart';

/// Parses / builds the QR deep link used to identify a table.
/// Format: restaurant://menu?table=1
class QrService {
  QrService._();

  static String buildLink(String tableId) =>
      '${AppConstants.qrScheme}://${AppConstants.qrHost}?table=$tableId';

  /// Returns the tableId encoded in the link, or null if the link is
  /// not a valid restaurant table QR code.
  static String? parseTableId(String rawLink) {
    try {
      final uri = Uri.parse(rawLink);
      if (uri.scheme != AppConstants.qrScheme) return null;
      if (uri.host != AppConstants.qrHost) return null;
      final table = uri.queryParameters['table'];
      if (table == null || table.isEmpty) return null;
      return table;
    } catch (_) {
      return null;
    }
  }
}
