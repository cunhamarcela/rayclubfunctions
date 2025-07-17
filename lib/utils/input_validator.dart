// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';

/// Utilitário para validação e sanitização de inputs
class InputValidator {
  // Expressões regulares comuns para validação
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  
  static final RegExp _passwordRegex = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*#?&]{8,}$',
  );
  
  static final RegExp _phoneRegex = RegExp(
    r'^\(\d{2}\) \d{5}-\d{4}$',
  );
  
  static final RegExp _nameRegex = RegExp(
    r'^[A-Za-zÀ-ÖØ-öø-ÿ\s]+$',
  );
  
  static final RegExp _numericRegex = RegExp(
    r'^\d+$',
  );
  
  static final RegExp _weightRegex = RegExp(
    r'^\d{1,3}([.,]\d{1,2})?$',
  );
  
  static final RegExp _heightRegex = RegExp(
    r'^\d{1,3}([.,]\d{1,2})?$',
  );
  
  /// Valida e limpa um email
  static String validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      throw ValidationException(
        message: 'O email é obrigatório',
      );
    }
    
    final trimmedEmail = email.trim().toLowerCase();
    
    if (!_emailRegex.hasMatch(trimmedEmail)) {
      throw ValidationException(
        message: 'Email inválido',
      );
    }
    
    return trimmedEmail;
  }
  
  /// Valida e limpa uma senha
  static String validatePassword(String? password, {bool isLogin = false}) {
    if (password == null || password.trim().isEmpty) {
      throw ValidationException(
        message: 'A senha é obrigatória',
      );
    }
    
    final trimmedPassword = password.trim();
    
    // Se for login, apenas verifica se não está vazio
    if (!isLogin && !_passwordRegex.hasMatch(trimmedPassword)) {
      throw ValidationException(
        message: 'A senha deve ter pelo menos 8 caracteres, incluindo letras e números',
      );
    }
    
    return trimmedPassword;
  }
  
  /// Valida e limpa um nome
  static String validateName(String? name) {
    if (name == null || name.trim().isEmpty) {
      throw ValidationException(
        message: 'O nome é obrigatório',
      );
    }
    
    final trimmedName = name.trim();
    
    if (!_nameRegex.hasMatch(trimmedName)) {
      throw ValidationException(
        message: 'Nome inválido',
      );
    }
    
    // Capitalize words
    final words = trimmedName.split(' ');
    final capitalizedWords = words.map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).toList();
    
    return capitalizedWords.join(' ');
  }
  
  /// Valida e formata um número de telefone
  static String validatePhone(String? phone) {
    if (phone == null || phone.trim().isEmpty) {
      throw ValidationException(
        message: 'O telefone é obrigatório',
      );
    }
    
    // Remove todos os caracteres não numéricos
    final digitsOnly = phone.replaceAll(RegExp(r'\D'), '');
    
    if (digitsOnly.length != 11) {
      throw ValidationException(
        message: 'Telefone inválido',
      );
    }
    
    // Formata como (XX) XXXXX-XXXX
    final formattedPhone = '(${digitsOnly.substring(0, 2)}) ${digitsOnly.substring(2, 7)}-${digitsOnly.substring(7)}';
    
    return formattedPhone;
  }
  
  /// Valida e formata um número (texto)
  static String validateNumericText(String? text, {String? fieldName}) {
    final name = fieldName ?? 'Campo';
    
    if (text == null || text.trim().isEmpty) {
      throw ValidationException(
        message: '$name é obrigatório',
      );
    }
    
    final trimmedText = text.trim();
    
    if (!_numericRegex.hasMatch(trimmedText)) {
      throw ValidationException(
        message: '$name deve conter apenas números',
      );
    }
    
    return trimmedText;
  }
  
  /// Valida e formata um peso
  static double validateWeight(String? weight) {
    if (weight == null || weight.trim().isEmpty) {
      throw ValidationException(
        message: 'O peso é obrigatório',
      );
    }
    
    // Normaliza o separador decimal
    final normalizedWeight = weight.trim().replaceAll(',', '.');
    
    if (!_weightRegex.hasMatch(normalizedWeight)) {
      throw ValidationException(
        message: 'Peso inválido',
      );
    }
    
    final double value = double.parse(normalizedWeight);
    
    if (value < 20 || value > 300) {
      throw ValidationException(
        message: 'Peso deve estar entre 20 e 300 kg',
      );
    }
    
    return value;
  }
  
  /// Valida e formata uma altura
  static double validateHeight(String? height) {
    if (height == null || height.trim().isEmpty) {
      throw ValidationException(
        message: 'A altura é obrigatória',
      );
    }
    
    // Normaliza o separador decimal
    final normalizedHeight = height.trim().replaceAll(',', '.');
    
    if (!_heightRegex.hasMatch(normalizedHeight)) {
      throw ValidationException(
        message: 'Altura inválida',
      );
    }
    
    final double value = double.parse(normalizedHeight);
    
    // Se o valor for maior que 3, assume-se que está em centímetros e converte para metros
    final double heightInMeters = value > 3 ? value / 100 : value;
    
    if (heightInMeters < 1 || heightInMeters > 2.5) {
      throw ValidationException(
        message: 'Altura deve estar entre 1.00 e 2.50 metros',
      );
    }
    
    return heightInMeters;
  }
  
  /// Sanitiza texto para evitar injeção de código
  static String sanitizeText(String? text) {
    if (text == null) return '';
    
    // Remove tags HTML e JavaScript
    var sanitized = text
      .replaceAll(RegExp(r'<[^>]*>'), '')
      .replaceAll(RegExp(r'javascript:'), '');
    
    // Remove eventos JavaScript (como onclick, onmouseover, etc.)
    sanitized = sanitized.replaceAll(RegExp(r'on\w+\s*=\s*"[^"]*"'), '');
    sanitized = sanitized.replaceAll(RegExp(r"on\w+\s*=\s*'[^']*'"), '');
    
    return sanitized;
  }
  
  /// Sanitiza texto para uso em consultas SQL
  static String sanitizeForSql(String? text) {
    if (text == null) return '';
    
    // Escapa aspas simples e remove caracteres potencialmente perigosos
    return text
      .replaceAll("'", "''")
      .replaceAll(RegExp(r'[;\\]'), '');
  }
  
  /// Cria um TextInputFormatter para formatação de telefone
  static List<TextInputFormatter> phoneInputFormatter() {
    return [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(11),
      _PhoneInputFormatter(),
    ];
  }
  
  /// Cria um TextInputFormatter para formatação de peso
  static List<TextInputFormatter> weightInputFormatter() {
    return [
      FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
      _DecimalInputFormatter(2),
    ];
  }
  
  /// Cria um TextInputFormatter para formatação de altura
  static List<TextInputFormatter> heightInputFormatter() {
    return [
      FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
      _DecimalInputFormatter(2),
    ];
  }
}

/// Formatter para telefone no formato (XX) XXXXX-XXXX
class _PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    
    if (text.isEmpty) {
      return newValue;
    }
    
    String formatted = '';
    int index = 0;
    
    // Cria o formato (XX) XXXXX-XXXX
    for (int i = 0; i < text.length && i < 11; i++) {
      if (i == 0) formatted += '(';
      if (i == 2) formatted += ') ';
      if (i == 7) formatted += '-';
      
      formatted += text[i];
      index++;
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: index + (index > 7 ? 3 : (index > 2 ? 2 : 1))),
    );
  }
}

/// Formatter para valores decimais
class _DecimalInputFormatter extends TextInputFormatter {
  final int decimalPlaces;
  
  _DecimalInputFormatter(this.decimalPlaces);
  
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text;
    
    // Permitir vazio
    if (text.isEmpty) {
      return newValue;
    }
    
    // Substituir vírgulas por pontos
    if (text.contains(',')) {
      text = text.replaceAll(',', '.');
    }
    
    // Verificar se é um número válido
    if (double.tryParse(text) == null) {
      return oldValue;
    }
    
    // Limitar casas decimais
    if (text.contains('.')) {
      final parts = text.split('.');
      if (parts[1].length > decimalPlaces) {
        text = '${parts[0]}.${parts[1].substring(0, decimalPlaces)}';
      }
    }
    
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
} 
