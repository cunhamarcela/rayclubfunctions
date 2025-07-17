import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

import '../core/errors/app_exception.dart';
import '../utils/log_utils.dart';
import '../features/challenges/models/challenge.dart';

/// Provider para o serviço de imagens
final imageServiceProvider = Provider<ImageService>((ref) {
  return ImageService();
});

/// Serviço para manipulação de imagens
class ImageService {
  // Cache de URLs que falharam para evitar tentativas repetidas
  final Map<String, bool> _failedUrls = {};
  
  /// Lista de imagens locais padrão
  static const _defaultImages = [
    'assets/images/challenge_default.jpg',
    'assets/images/art_office.jpg',
    'assets/images/art_bodyweight.jpg',
    'assets/images/art_hiit.jpg',
    'assets/images/art_yoga.jpg',
    'assets/images/art_travel.jpg',
  ];
  
  /// Imagem específica para o desafio oficial da Ray
  static const _rayOfficialImage = 'assets/images/art_bodyweight.jpg';
  
  /// URLs validadas que são garantidas de funcionar
  static const _workingUrls = [
    'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=500', // running
    'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?q=80&w=500', // fitness
    'https://images.unsplash.com/photo-1518611012118-696072aa579a?q=80&w=500', // workout
    'https://images.unsplash.com/photo-1576678927484-cc907957088c?q=80&w=500', // yoga
    'https://images.unsplash.com/photo-1549576490-b0b4831ef60a?q=80&w=500'  // hiking
  ];
  
  /// Verifica se uma URL de imagem é válida
  bool isValidImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty || !imageUrl.startsWith('http')) {
      return false;
    }
    
    // Verificar se a URL já falhou anteriormente
    if (_failedUrls.containsKey(imageUrl) && _failedUrls[imageUrl] == true) {
      return false;
    }
    
    return true;
  }
  
  /// Registra uma URL que falhou para não tentar novamente
  void markUrlAsFailed(String url) {
    _failedUrls[url] = true;
    debugPrint('Marcando URL como falha: $url');
  }
  
  /// Limpa o cache de URLs que falharam
  void clearCache() {
    _failedUrls.clear();
    debugPrint('Cache de imagens limpo');
  }
  
  /// Retorna uma URL de imagem válida garantida de funcionar
  String getValidImageUrl(String? originalUrl, {String? id}) {
    // Se a URL original for válida, use-a
    if (isValidImageUrl(originalUrl)) {
      return originalUrl!;
    }
    
    // Caso contrário, retorne uma URL garantida de funcionar
    if (id != null) {
      final index = id.hashCode.abs() % _workingUrls.length;
      return _workingUrls[index];
    }
    
    // Se não houver ID, retorne uma URL aleatória
    final index = DateTime.now().millisecondsSinceEpoch % _workingUrls.length;
    return _workingUrls[index];
  }
  
  /// Retorna uma imagem padrão local
  String getDefaultImage({String? id}) {
    try {
      if (id != null) {
        // Usar um algoritmo determinístico para escolher uma imagem consistente
        final index = id.hashCode.abs() % (_defaultImages.length - 1);
        return _defaultImages[index];
      }
      
      // Se não houver ID, retorne uma imagem aleatória
      final index = DateTime.now().millisecondsSinceEpoch % _defaultImages.length;
      return _defaultImages[index];
    } catch (e) {
      // Em caso de erro, retornar a primeira imagem
      debugPrint('Error getting default image: $e');
      return _defaultImages.first;
    }
  }
  
  /// Retorna uma imagem padrão para um desafio
  String getDefaultImageForChallenge(Challenge challenge) {
    if (challenge.isOfficial) {
      return _rayOfficialImage;
    }
    
    try {
      // Usar um algoritmo determinístico para escolher uma imagem consistente
      final index = challenge.id.hashCode.abs() % (_defaultImages.length - 1);
      return _defaultImages[index];
    } catch (e) {
      // Em caso de erro, retornar a primeira imagem
      debugPrint('Error getting default image: $e');
      return _defaultImages.first;
    }
  }
  
  /// Widget para exibir uma imagem do desafio com fallback para imagem local
  Widget buildChallengeImage(Challenge challenge, {
    double? height,
    double? width,
    BoxFit fit = BoxFit.cover,
  }) {
    final imageUrl = getValidImageUrl(challenge.imageUrl, id: challenge.id);
    final defaultImage = getDefaultImageForChallenge(challenge);
    
    return FadeInImage(
      placeholder: AssetImage(defaultImage),
      image: NetworkImage(imageUrl),
      height: height,
      width: width,
      fit: fit,
      fadeInDuration: const Duration(milliseconds: 300),
      imageErrorBuilder: (context, error, stackTrace) {
        // Marcar URL como falha para não tentar novamente
        markUrlAsFailed(imageUrl);
        
        LogUtils.error(
          'Erro ao carregar imagem do desafio',
          error: error,
          stackTrace: stackTrace,
          tag: 'ImageService',
        );
        
        return Image.asset(
          defaultImage,
          height: height,
          width: width,
          fit: fit,
        );
      },
    );
  }
  
  /// Widget para exibir uma imagem com fallback para imagem local
  Widget buildImage(String? imageUrl, {
    double? height,
    double? width,
    BoxFit fit = BoxFit.cover,
    String? id,
    String? defaultImage,
  }) {
    final validImageUrl = getValidImageUrl(imageUrl, id: id);
    final localDefaultImage = defaultImage ?? getDefaultImage(id: id);
    
    return FadeInImage(
      placeholder: AssetImage(localDefaultImage),
      image: NetworkImage(validImageUrl),
      height: height,
      width: width,
      fit: fit,
      fadeInDuration: const Duration(milliseconds: 300),
      imageErrorBuilder: (context, error, stackTrace) {
        // Marcar URL como falha para não tentar novamente
        markUrlAsFailed(validImageUrl);
        
        LogUtils.error(
          'Erro ao carregar imagem',
          error: error,
          stackTrace: stackTrace,
          tag: 'ImageService',
        );
        
        return Image.asset(
          localDefaultImage,
          height: height,
          width: width,
          fit: fit,
        );
      },
    );
  }
  
  /// Widget para exibir uma imagem como background de um container com gradiente
  Widget buildImageWithGradient({
    required String? imageUrl,
    String? id,
    double? height,
    double? width,
    required Widget child,
    Color? overlayColor,
  }) {
    final validImageUrl = getValidImageUrl(imageUrl, id: id);
    final localDefaultImage = getDefaultImage(id: id);
    
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: _getImageProvider(validImageUrl, localDefaultImage),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            overlayColor ?? Colors.black.withOpacity(0.3),
            BlendMode.darken,
          ),
          onError: (exception, stackTrace) {
            LogUtils.error(
              'Error loading image as background',
              error: exception,
              stackTrace: stackTrace,
              tag: 'ImageService',
            );
          },
        ),
      ),
      child: child,
    );
  }
  
  /// Retorna o provider de imagem apropriado (rede ou asset)
  ImageProvider _getImageProvider(String imageUrl, String defaultImage) {
    try {
      return NetworkImage(
        imageUrl,
        // Adicionar headers personalizados para melhorar o carregamento
        headers: {
          HttpHeaders.cacheControlHeader: 'max-age=86400', // Cache por 24h
        },
      );
    } catch (e) {
      LogUtils.error(
        'Erro ao criar NetworkImage',
        error: e,
        tag: 'ImageService',
      );
      return AssetImage(defaultImage);
    }
  }
  
  /// Método para pré-carregar imagens para melhorar a experiência do usuário
  Future<void> precacheImages(BuildContext context, List<String> imageUrls) async {
    try {
      for (final url in imageUrls) {
        if (isValidImageUrl(url)) {
          try {
            await precacheImage(NetworkImage(url), context);
          } catch (e) {
            // Se falhar, marcar como falha
            markUrlAsFailed(url);
            LogUtils.error(
              'Failed to precache image',
              error: e,
              tag: 'ImageService',
            );
          }
        }
      }
    } catch (e) {
      LogUtils.error(
        'Error in precacheImages',
        error: e,
        tag: 'ImageService',
      );
    }
  }
} 