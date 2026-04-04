class PhoneUtils {
  static String toWhatsApp(String phone) {
    final digits = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.startsWith('20') && digits.length >= 12) return digits;
    if (digits.startsWith('0') && digits.length >= 10) {
      return '20${digits.substring(1)}';
    }
    return '20$digits';
  }

  static String normalize(String phone) {
    final digits = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.startsWith('20') && digits.length >= 12) {
      return '0${digits.substring(2)}';
    }
    return digits;
  }

  static bool isValid(String phone) {
    final d = phone.replaceAll(RegExp(r'[^\d]'), '');
    return d.length == 11 && d.startsWith('01');
  }
}
