/// Utility class for string operations and validations
class StringUtils {
  /// Capitalizes the first letter of a string and converts the rest to lowercase
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// Truncates a string to a maximum length and adds ellipsis if needed
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Removes all special characters from a string, leaving only letters, numbers and spaces
  static String removeSpecialCharacters(String text) {
    return text.replaceAll(RegExp(r'[^\w\s]+'), '');
  }

  /// Validates if a string is a valid email address
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Validates if a string is a valid password
  /// Requirements:
  /// - At least 8 characters
  /// - At least one uppercase letter
  /// - At least one lowercase letter
  /// - At least one number
  static bool isValidPassword(String password) {
    return password.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password);
  }

  /// Formats a CPF string with dots and dash (XXX.XXX.XXX-XX)
  static String maskCPF(String cpf) {
    final numbers = cpf.replaceAll(RegExp(r'[^\d]'), '');
    if (numbers.length != 11) return cpf;
    return '${numbers.substring(0, 3)}.${numbers.substring(3, 6)}.${numbers.substring(6, 9)}-${numbers.substring(9)}';
  }

  /// Formats a phone number string with parentheses and dash ((XX) XXXXX-XXXX)
  static String maskPhone(String phone) {
    final numbers = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (numbers.length != 11) return phone;
    return '(${numbers.substring(0, 2)}) ${numbers.substring(2, 7)}-${numbers.substring(7)}';
  }

  /// Validates if a string is a valid CPF
  static bool isValidCPF(String cpf) {
    final numbers = cpf.replaceAll(RegExp(r'[^\d]'), '');
    if (numbers.length != 11) return false;

    if (RegExp(r'^(\d)\1*$').hasMatch(numbers)) return false;

    List<int> digits = numbers.split('').map(int.parse).toList();

    // First digit validation
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += digits[i] * (10 - i);
    }
    int firstDigit = (sum * 10) % 11;
    if (firstDigit == 10) firstDigit = 0;
    if (firstDigit != digits[9]) return false;

    // Second digit validation
    sum = 0;
    for (int i = 0; i < 10; i++) {
      sum += digits[i] * (11 - i);
    }
    int secondDigit = (sum * 10) % 11;
    if (secondDigit == 10) secondDigit = 0;
    if (secondDigit != digits[10]) return false;

    return true;
  }
}
