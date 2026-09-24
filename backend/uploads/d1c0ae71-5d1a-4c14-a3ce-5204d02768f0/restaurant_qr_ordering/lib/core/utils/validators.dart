/// Simple, reusable form validators.
class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final regex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
    if (!regex.hasMatch(value.trim())) return 'Enter a valid email';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? required(String? value, {String label = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$label is required';
    return null;
  }

  static String? positiveNumber(String? value, {String label = 'Value'}) {
    if (value == null || value.trim().isEmpty) return '$label is required';
    final n = double.tryParse(value);
    if (n == null || n <= 0) return '$label must be a positive number';
    return null;
  }
}
