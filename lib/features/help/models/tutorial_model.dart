// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

part 'tutorial_model.freezed.dart';
part 'tutorial_model.g.dart';

/// Modelo para representar um tutorial
@freezed
class Tutorial with _$Tutorial {
  /// Construtor
  const factory Tutorial({
    /// ID do tutorial
    required String id,
    
    /// Título do tutorial
    required String title,
    
    /// Descrição do tutorial
    String? description,
    
    /// Conteúdo principal do tutorial
    required String content,
    
    /// URL da imagem do tutorial
    String? imageUrl,
    
    /// URL do vídeo do tutorial
    String? videoUrl,
    
    /// Categoria do tutorial
    @Default('') String category,
    
    /// Índice para ordenação
    @Default(0) int order,
    
    /// Indica se o tutorial está ativo
    @Default(true) bool isActive,
    
    /// Indica se o tutorial está em destaque
    @Default(false) bool isFeatured,
    
    /// ID do usuário que atualizou o tutorial
    String? updatedBy,
    
    /// Data da última atualização
    DateTime? lastUpdated,
    
    /// Conteúdo relacionado (outros tutoriais, FAQs, etc.)
    @Default({}) Map<String, dynamic> relatedContent,
  }) = _Tutorial;

  /// Cria um tutorial a partir de JSON
  factory Tutorial.fromJson(Map<String, dynamic> json) => _$TutorialFromJson(json);
} 