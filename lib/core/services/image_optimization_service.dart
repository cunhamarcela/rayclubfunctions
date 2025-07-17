// Dart imports:
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';
import 'cache_service.dart';
import 'smart_cache_service.dart';

/// Provider para o serviço de otimização de imagens
final imageOptimizationServiceProvider = Provider<ImageOptimizationService>((ref) {
  final cacheService = ref.watch(smartCacheServiceProvider);
  return ImageOptimizationService(cacheService);
});

/// Serviço para otimização de imagens na aplicação
class ImageOptimizationService {
  final CacheService _cacheService;
  
  /// Cache LRU para imagens em memória
  final Map<String, ui.Image> _imageCache = {};
  
  /// Lista LRU para gerenciar o tamanho do cache
  final List<String> _lruKeys = [];
  
  /// Tamanho máximo do cache de imagens em memória
  static const int _MAX_IMAGE_CACHE_SIZE = 100;
  
  /// Construtor
  ImageOptimizationService(this._cacheService);
  
  /// Pré-carrega uma imagem e a coloca no cache
  Future<void> preloadImage(String imageUrl) async {
    try {
      await _loadAndCacheImage(imageUrl);
    } catch (e) {
      debugPrint('Erro ao pré-carregar imagem: $e');
    }
  }
  
  /// Pré-carrega múltiplas imagens
  Future<void> preloadImages(List<String> imageUrls) async {
    final futures = <Future>[];
    
    for (final url in imageUrls) {
      futures.add(_loadAndCacheImage(url));
    }
    
    // Aguarda todas as imagens com timeout
    await Future.wait(
      futures.map((future) => future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('Timeout ao pré-carregar imagem');
          return null;
        },
      )),
    );
  }
  
  /// Carrega uma imagem com otimização
  Future<ui.Image?> loadOptimizedImage(String imageUrl, {
    int? targetWidth,
    int? targetHeight,
    bool useCache = true,
  }) async {
    try {
      // Gera uma chave de cache com as dimensões
      final cacheKey = _getCacheKey(imageUrl, targetWidth, targetHeight);
      
      // Verifica no cache de memória primeiro
      if (useCache && _imageCache.containsKey(cacheKey)) {
        _updateLRU(cacheKey);
        return _imageCache[cacheKey];
      }
      
      // Carrega a imagem (do cache de disco ou rede)
      final image = await _loadAndCacheImage(
        imageUrl,
        targetWidth: targetWidth,
        targetHeight: targetHeight,
        useCache: useCache,
      );
      
      return image;
    } catch (e) {
      debugPrint('Erro ao carregar imagem otimizada: $e');
      return null;
    }
  }
  
  /// Limpa o cache de imagens em memória
  void clearMemoryCache() {
    _imageCache.clear();
    _lruKeys.clear();
  }
  
  /// Limpa todo o cache de imagens (memória e disco)
  Future<void> clearCache() async {
    clearMemoryCache();
    
    // Lista todas as chaves do cache relacionadas a imagens
    final keys = await _getImageCacheKeys();
    
    // Remove cada chave do cache
    for (final key in keys) {
      await _cacheService.remove(key);
    }
  }
  
  /// Carrega uma imagem e coloca no cache
  Future<ui.Image?> _loadAndCacheImage(
    String imageUrl, {
    int? targetWidth,
    int? targetHeight,
    bool useCache = true,
  }) async {
    // Gera uma chave de cache com as dimensões
    final cacheKey = _getCacheKey(imageUrl, targetWidth, targetHeight);
    
    try {
      // Verifica se existe no cache de disco
      if (useCache) {
        final cachedImageBytes = await _cacheService.get(cacheKey);
        
        if (cachedImageBytes != null) {
          final image = await _decodeImage(
            Uint8List.fromList(cachedImageBytes.cast<int>()),
            targetWidth,
            targetHeight,
          );
          
          if (image != null) {
            _cacheInMemory(cacheKey, image);
            return image;
          }
        }
      }
      
      // Se não estiver em cache, baixa da rede
      final imageBytes = await _downloadImage(imageUrl);
      
      if (imageBytes != null) {
        // Decodifica a imagem com redimensionamento
        final image = await _decodeImage(imageBytes, targetWidth, targetHeight);
        
        if (image != null) {
          // Coloca no cache
          if (useCache) {
            // Cache em memória
            _cacheInMemory(cacheKey, image);
            
            // Cache em disco (como bytes)
            await _cacheService.set(
              cacheKey,
              imageBytes,
              expiry: const Duration(days: 7),
            );
          }
          
          return image;
        }
      }
      
      return null;
    } catch (e) {
      debugPrint('Erro ao carregar e armazenar imagem: $e');
      return null;
    }
  }
  
  /// Baixa uma imagem da rede
  Future<Uint8List?> _downloadImage(String imageUrl) async {
    try {
      if (imageUrl.startsWith('http')) {
        // Imagem da web
        final response = await http.get(Uri.parse(imageUrl));
        
        if (response.statusCode == 200) {
          return response.bodyBytes;
        }
      } else if (imageUrl.startsWith('assets/')) {
        // Imagem de asset
        final byteData = await rootBundle.load(imageUrl);
        return byteData.buffer.asUint8List();
      } else if (imageUrl.startsWith('/')) {
        // Imagem local
        final file = File(imageUrl);
        if (await file.exists()) {
          return await file.readAsBytes();
        }
      }
      
      return null;
    } catch (e) {
      debugPrint('Erro ao baixar imagem: $e');
      return null;
    }
  }
  
  /// Decodifica bytes em uma imagem, com suporte a redimensionamento
  Future<ui.Image?> _decodeImage(
    Uint8List bytes, 
    int? targetWidth, 
    int? targetHeight,
  ) async {
    try {
      // Decodifica a imagem
      final codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: targetWidth,
        targetHeight: targetHeight,
      );
      
      final frameInfo = await codec.getNextFrame();
      return frameInfo.image;
    } catch (e) {
      debugPrint('Erro ao decodificar imagem: $e');
      return null;
    }
  }
  
  /// Gera uma chave de cache para a imagem com dimensões
  String _getCacheKey(String imageUrl, int? width, int? height) {
    if (width != null || height != null) {
      return 'image_${imageUrl}_${width ?? 0}x${height ?? 0}';
    }
    return 'image_$imageUrl';
  }
  
  /// Armazena uma imagem no cache em memória
  void _cacheInMemory(String key, ui.Image image) {
    // Verifica se o cache está cheio
    if (_imageCache.length >= _MAX_IMAGE_CACHE_SIZE) {
      // Remove a imagem menos recentemente usada
      final oldestKey = _lruKeys.removeAt(0);
      _imageCache.remove(oldestKey);
    }
    
    // Adiciona ao cache e LRU
    _imageCache[key] = image;
    _updateLRU(key);
  }
  
  /// Atualiza a lista LRU
  void _updateLRU(String key) {
    // Remove e adiciona ao final (indicando uso recente)
    _lruKeys.remove(key);
    _lruKeys.add(key);
  }
  
  /// Obtém todas as chaves de cache relacionadas a imagens
  Future<List<String>> _getImageCacheKeys() async {
    final allKeys = <String>[];
    
    // Pedir para o cacheService listar todas as chaves que começam com "image_"
    // Depende da implementação específica do CacheService
    
    return allKeys.where((key) => key.startsWith('image_')).toList();
  }
  
  /// Salva uma imagem no armazenamento local e retorna o caminho
  Future<String?> saveImageToLocalStorage(Uint8List imageBytes, String imageName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = path.join(directory.path, imageName);
      
      final file = File(filePath);
      await file.writeAsBytes(imageBytes);
      
      return filePath;
    } catch (e) {
      debugPrint('Erro ao salvar imagem localmente: $e');
      return null;
    }
  }
  
  /// Converte uma ui.Image para Uint8List
  Future<Uint8List?> imageToBytes(ui.Image image) async {
    try {
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Erro ao converter imagem para bytes: $e');
      return null;
    }
  }
} 