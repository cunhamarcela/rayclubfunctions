// Package imports:
import 'package:intl/intl.dart';

/// Date format constants
final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');
final DateFormat _timeFormat = DateFormat('HH:mm');

/// Format date
String formatDate(DateTime? date) {
  if (date == null) return '';
  return _dateFormat.format(date);
}

/// Format date with time
String formatDateTime(DateTime? dateTime) {
  if (dateTime == null) return '';
  return _dateTimeFormat.format(dateTime);
}

/// Format time
String formatTime(DateTime? time) {
  if (time == null) return '';
  return _timeFormat.format(time);
}

/// Format number with thousands separator
String formatNumber(num? value) {
  if (value == null) return '0';
  final formatter = NumberFormat.decimalPattern('pt_BR');
  return formatter.format(value);
}

/// Format currency
String formatCurrency(num? value) {
  if (value == null) return 'R\$ 0,00';
  
  // Format with decimal places
  final formatted = value.toStringAsFixed(2).replaceAll('.', ',');
  
  // Add thousands separators
  final parts = formatted.split(',');
  final intPart = parts[0];
  final decPart = parts.length > 1 ? parts[1] : '00';
  
  // Build the formatted string with thousands separators
  final buffer = StringBuffer();
  final length = intPart.length;
  
  for (int i = 0; i < length; i++) {
    if (i > 0 && (length - i) % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(intPart[i]);
  }
  
  return 'R\$ ${buffer.toString()},$decPart';
}

/// Format duration in minutes to "Xh Ymin" format
String formatDuration(int? minutes) {
  if (minutes == null || minutes == 0) return '0min';
  
  final hours = minutes ~/ 60;
  final remainingMinutes = minutes % 60;
  
  if (hours > 0) {
    if (remainingMinutes > 0) {
      return '${hours}h ${remainingMinutes}min';
    } else {
      return '${hours}h';
    }
  } else {
    return '${remainingMinutes}min';
  }
}

/// Format name (capitalize first letter of each word)
String formatName(String? name) {
  if (name == null || name.isEmpty) return '';
  
  return name
      .split(' ')
      .map((word) => word.isNotEmpty 
          ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
          : '')
      .join(' ');
}

/// Format email to partially mask with asterisks
String formatPartialEmail(String? email) {
  if (email == null || email.isEmpty || !email.contains('@')) return '';
  
  final parts = email.split('@');
  final username = parts[0];
  final domain = parts[1];
  
  String maskedUsername;
  if (username.length <= 3) {
    maskedUsername = username;
  } else {
    maskedUsername = '${username.substring(0, 3)}${'*' * (username.length - 3)}';
  }
  
  return '$maskedUsername@$domain';
}

/// Format phone number to (XX) XXXXX-XXXX format
String formatPhoneNumber(String? phone) {
  if (phone == null || phone.isEmpty) return '';
  
  // Remove non-numeric characters
  final digitsOnly = phone.replaceAll(RegExp(r'\D'), '');
  
  if (digitsOnly.length < 10) return digitsOnly;
  
  if (digitsOnly.length == 10) {
    return '(${digitsOnly.substring(0, 2)}) ${digitsOnly.substring(2, 6)}-${digitsOnly.substring(6)}';
  }
  
  return '(${digitsOnly.substring(0, 2)}) ${digitsOnly.substring(2, 7)}-${digitsOnly.substring(7, 11)}';
} 