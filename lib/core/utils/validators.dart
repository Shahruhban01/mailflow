class Validators {
  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required.';
    final re = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.]+$');
    if (!re.hasMatch(v.trim())) return 'Enter a valid email address.';
    return null;
  }

  static String? required(String? v, [String field = 'This field']) {
    if (v == null || v.trim().isEmpty) return '$field is required.';
    return null;
  }

  static String? password(String? v) {
    if (v == null || v.trim().isEmpty) return 'Password is required.';
    if (v.length < 8) return 'Password must be at least 8 characters.';
    return null;
  }

  static String? name(String? v) {
    if (v == null || v.trim().isEmpty) return 'Name is required.';
    if (v.trim().length < 2) return 'Name must be at least 2 characters.';
    return null;
  }
}
