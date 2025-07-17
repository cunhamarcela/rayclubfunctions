// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

part 'faq_model.freezed.dart';
part 'faq_model.g.dart';

/// Modelo para representar uma FAQ
@freezed
class Faq with _$Faq {
  /// Construtor
  const factory Faq({
    /// ID da FAQ
    required String id,
    
    /// Pergunta
    required String question,
    
    /// Resposta
    required String answer,
    
    /// Categoria da FAQ
    @Default('') String category,
    
    /// Indica se a FAQ está ativa
    @Default(true) bool isActive,
    
    /// ID do usuário que atualizou a FAQ
    String? updatedBy,
    
    /// Data da última atualização
    DateTime? lastUpdated,
  }) = _Faq;

  /// Cria uma FAQ a partir de JSON
  factory Faq.fromJson(Map<String, dynamic> json) => _$FaqFromJson(json);
} 