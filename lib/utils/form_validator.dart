// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';
import 'package:ray_club_app/utils/input_validator.dart';

/// Utilitário para validação de formulários
/// 
/// Centraliza a validação de formulários e fornece métodos padronizados
/// para validar diferentes tipos de campos, utilizando o InputValidator.
class FormValidator {
  /// Valida um campo de e-mail
  static String? validateEmail(String? value) {
    try {
      if (value == null || value.isEmpty) {
        return 'O e-mail é obrigatório';
      }
      
      InputValidator.validateEmail(value);
      return null;
    } on ValidationException catch (e) {
      return e.message;
    } catch (e) {
      return 'E-mail inválido';
    }
  }
  
  /// Valida um campo de senha
  static String? validatePassword(String? value, {bool isLogin = false}) {
    try {
      if (value == null || value.isEmpty) {
        return 'A senha é obrigatória';
      }
      
      InputValidator.validatePassword(value, isLogin: isLogin);
      return null;
    } on ValidationException catch (e) {
      return e.message;
    } catch (e) {
      return 'Senha inválida';
    }
  }
  
  /// Valida um campo de nome
  static String? validateName(String? value) {
    try {
      if (value == null || value.isEmpty) {
        return 'O nome é obrigatório';
      }
      
      InputValidator.validateName(value);
      return null;
    } on ValidationException catch (e) {
      return e.message;
    } catch (e) {
      return 'Nome inválido';
    }
  }
  
  /// Valida um campo de telefone
  static String? validatePhone(String? value) {
    try {
      if (value == null || value.isEmpty) {
        return 'O telefone é obrigatório';
      }
      
      InputValidator.validatePhone(value);
      return null;
    } on ValidationException catch (e) {
      return e.message;
    } catch (e) {
      return 'Telefone inválido';
    }
  }
  
  /// Valida um campo numérico
  static String? validateNumeric(String? value, {String? fieldName}) {
    try {
      if (value == null || value.isEmpty) {
        return '${fieldName ?? 'O campo'} é obrigatório';
      }
      
      InputValidator.validateNumericText(value, fieldName: fieldName);
      return null;
    } on ValidationException catch (e) {
      return e.message;
    } catch (e) {
      return '${fieldName ?? 'Campo'} inválido';
    }
  }
  
  /// Valida um campo de peso
  static String? validateWeight(String? value) {
    try {
      if (value == null || value.isEmpty) {
        return 'O peso é obrigatório';
      }
      
      InputValidator.validateWeight(value);
      return null;
    } on ValidationException catch (e) {
      return e.message;
    } catch (e) {
      return 'Peso inválido';
    }
  }
  
  /// Valida um campo de altura
  static String? validateHeight(String? value) {
    try {
      if (value == null || value.isEmpty) {
        return 'A altura é obrigatória';
      }
      
      InputValidator.validateHeight(value);
      return null;
    } on ValidationException catch (e) {
      return e.message;
    } catch (e) {
      return 'Altura inválida';
    }
  }
  
  /// Valida campos de confirmação (Ex: senha e confirmação de senha)
  static String? validateConfirmation(String? value, String? confirmation, {String fieldName = 'Os campos'}) {
    if (value == null || confirmation == null) {
      return '$fieldName não podem estar vazios';
    }
    
    if (value != confirmation) {
      return '$fieldName não correspondem';
    }
    
    return null;
  }
  
  /// Valida se um campo não está vazio
  static String? validateRequired(String? value, {String fieldName = 'Este campo'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName é obrigatório';
    }
    
    return null;
  }
  
  /// Valida o tamanho mínimo de um campo
  static String? validateMinLength(String? value, int minLength, {String fieldName = 'Este campo'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName é obrigatório';
    }
    
    if (value.length < minLength) {
      return '$fieldName deve ter pelo menos $minLength caracteres';
    }
    
    return null;
  }
  
  /// Valida o tamanho máximo de um campo
  static String? validateMaxLength(String? value, int maxLength, {String fieldName = 'Este campo'}) {
    if (value == null) {
      return null;
    }
    
    if (value.length > maxLength) {
      return '$fieldName deve ter no máximo $maxLength caracteres';
    }
    
    return null;
  }
  
  /// Fornece um objeto de decoração padronizado para os campos de formulário
  static InputDecoration getInputDecoration({
    String? labelText,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool isDense = true,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      isDense: isDense,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0, 
        vertical: 12.0,
      ),
    );
  }
  
  /// Sanitiza todos os inputs em um Map (útil para envio de dados ao servidor)
  static Map<String, dynamic> sanitizeMap(Map<String, dynamic> data) {
    final sanitized = <String, dynamic>{};
    
    data.forEach((key, value) {
      if (value is String) {
        sanitized[key] = InputValidator.sanitizeText(value);
      } else {
        sanitized[key] = value;
      }
    });
    
    return sanitized;
  }
} 
