// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart' as app;
import 'package:ray_club_app/services/storage_service.dart';
import 'package:ray_club_app/utils/log_utils.dart';

/// Implementação do serviço de armazenamento usando Supabase
class SupabaseStorageService implements StorageService {
  final SupabaseClient _supabaseClient;
  final List<FileValidator> _validators = [];
  
  String _currentBucket = '';
  StorageAccessType _currentAccessPolicy = StorageAccessType.private;
  bool _initialized = false;
  
  /// Mapeamento de tipos de bucket para nomes de bucket no Supabase
  /// Os nomes dos buckets são lidos do .env para permitir configuração entre ambientes
  final Map<StorageBucketType, String> _bucketNames = {
    StorageBucketType.profilePictures: dotenv.env['BUCKET_PROFILE_PICTURES'] ?? 'profile_pictures',
    StorageBucketType.mealImages: dotenv.env['BUCKET_MEAL_IMAGES'] ?? 'meal_images',
    StorageBucketType.workoutImages: dotenv.env['BUCKET_WORKOUT_IMAGES'] ?? 'workout_images',
    StorageBucketType.documents: dotenv.env['BUCKET_DOCUMENTS'] ?? 'documents',
    StorageBucketType.contentImages: dotenv.env['BUCKET_CONTENT_IMAGES'] ?? 'content_images',
    StorageBucketType.temporary: dotenv.env['BUCKET_TEMPORARY'] ?? 'temporary',
  };
  
  /// Cria uma instância do serviço de armazenamento Supabase
  SupabaseStorageService({
    required SupabaseClient supabaseClient,
  }) : _supabaseClient = supabaseClient {
    // Adicionar validadores padrão
    _validators.add(FileSizeValidator(maxSizeInBytes: 5 * 1024 * 1024)); // 5MB
    _validators.add(
      FileTypeValidator(allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'pdf']),
    );
  }
  
  @override
  String get currentBucket => _currentBucket;
  
  @override
  bool get isInitialized => _initialized;
  
  @override
  Future<void> initialize() async {
    try {
      final defaultBucketType = StorageBucketType.temporary;
      await setBucket(defaultBucketType);
      _initialized = true;
      LogUtils.info('Serviço de armazenamento Supabase inicializado', tag: 'SupabaseStorageService');
    } catch (e, stackTrace) {
      final error = app.StorageException(
        message: 'Erro ao inicializar serviço de armazenamento',
        originalError: e,
        stackTrace: stackTrace,
      );
      LogUtils.error(
        'Falha ao inicializar SupabaseStorageService',
        error: error,
        stackTrace: stackTrace,
        tag: 'SupabaseStorageService',
      );
      throw error;
    }
  }
  
  @override
  Future<void> setBucket(StorageBucketType bucketType) async {
    final bucketName = _bucketNames[bucketType];
    if (bucketName == null) {
      throw app.StorageException(
        message: 'Tipo de bucket não configurado: $bucketType',
        code: 'invalid_bucket_type',
      );
    }
    
    try {
      // Verifica se o bucket existe
      final buckets = await _supabaseClient.storage.listBuckets();
      final bucketExists = buckets.any((b) => b.name == bucketName);
      
      if (!bucketExists) {
        // Em um ambiente de produção, os buckets devem ser criados durante o deploy,
        // não dinamicamente pela aplicação, que geralmente não terá permissões para isso
        LogUtils.warning(
          'Bucket $bucketName não encontrado. Os buckets devem ser criados previamente.',
          tag: 'SupabaseStorageService',
        );
        throw app.StorageException(
          message: 'Bucket $bucketName não encontrado',
          code: 'bucket_not_found',
        );
      }
      
      _currentBucket = bucketName;
      LogUtils.debug(
        'Bucket definido para: $_currentBucket',
        tag: 'SupabaseStorageService',
      );
    } catch (e, stackTrace) {
      if (e is app.StorageException) {
        rethrow;
      }
      
      final error = app.StorageException(
        message: 'Erro ao definir bucket: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
      
      LogUtils.error(
        'Falha ao definir bucket',
        error: error,
        stackTrace: stackTrace,
        tag: 'SupabaseStorageService',
      );
      
      throw error;
    }
  }
  
  @override
  void setAccessPolicy(StorageAccessType accessType) {
    _currentAccessPolicy = accessType;
    LogUtils.debug(
      'Política de acesso definida para: $_currentAccessPolicy',
      tag: 'SupabaseStorageService',
    );
  }
  
  @override
  Future<String> uploadFile({
    required File file,
    required String path,
    String? contentType,
    Map<String, String>? metadata,
  }) async {
    _ensureInitialized();
    _validatePath(path);
    
    try {
      // Validar o arquivo usando todos os validadores registrados
      for (final validator in _validators) {
        await validator.validate(file);
      }
      
      // Definir opções de upload com base na política de acesso
      final fileOptions = FileOptions(
        cacheControl: '3600',
        contentType: contentType ?? _determineContentType(file.path),
        upsert: true,
      );
      
      // Adicionar caminho de usuário em buckets privados quando aplicável
      String uploadPath = path;
      if (_currentAccessPolicy == StorageAccessType.private) {
        final userId = _supabaseClient.auth.currentUser?.id;
        if (userId != null) {
          // Adicionar ID do usuário ao caminho para segmentação de arquivos
          uploadPath = 'users/$userId/$path';
        }
      }
      
      // Realizar o upload
      await _supabaseClient.storage
          .from(_currentBucket)
          .upload(uploadPath, file, fileOptions: fileOptions);
      
      // Retornar a URL pública para arquivos públicos ou o caminho para arquivos privados
      if (_currentAccessPolicy == StorageAccessType.public) {
        return await getPublicUrl(uploadPath);
      } else {
        return uploadPath;
      }
    } catch (e, stackTrace) {
      if (e is app.FileValidationException) {
        rethrow;
      }
      
      final error = app.StorageException(
        message: 'Erro ao fazer upload do arquivo',
        originalError: e,
        stackTrace: stackTrace,
      );
      LogUtils.error(
        'Falha ao fazer upload do arquivo',
        error: error,
        stackTrace: stackTrace,
        tag: 'SupabaseStorageService',
      );
      throw error;
    }
  }
  
  @override
  Future<File> downloadFile({
    required String remotePath,
    required String localPath,
  }) async {
    _ensureInitialized();
    _validatePath(remotePath);
    
    try {
      final bytes = await _supabaseClient.storage
          .from(_currentBucket)
          .download(remotePath);
      
      final file = File(localPath);
      await file.writeAsBytes(bytes);
      return file;
    } catch (e, stackTrace) {
      final error = app.StorageException(
        message: 'Erro ao baixar arquivo',
        originalError: e,
        stackTrace: stackTrace,
      );
      LogUtils.error(
        'Falha ao baixar arquivo',
        error: error,
        stackTrace: stackTrace,
        tag: 'SupabaseStorageService',
      );
      throw error;
    }
  }
  
  @override
  Future<String> getPublicUrl(String path, {Duration? expiresIn}) async {
    _ensureInitialized();
    _validatePath(path);
    
    try {
      if (expiresIn != null) {
        // Gerar URL temporária assinada
        final signedUrl = await _supabaseClient.storage
            .from(_currentBucket)
            .createSignedUrl(path, expiresIn.inSeconds);
        return signedUrl;
      } else {
        // Gerar URL pública permanente
        final publicUrl = _supabaseClient.storage
            .from(_currentBucket)
            .getPublicUrl(path);
        return publicUrl;
      }
    } catch (e, stackTrace) {
      final error = app.StorageException(
        message: 'Erro ao obter URL pública',
        originalError: e,
        stackTrace: stackTrace,
      );
      LogUtils.error(
        'Falha ao obter URL pública',
        error: error,
        stackTrace: stackTrace,
        tag: 'SupabaseStorageService',
      );
      throw error;
    }
  }
  
  @override
  Future<bool> fileExists(String path) async {
    _ensureInitialized();
    _validatePath(path);
    
    try {
      // O Supabase não tem uma API direta para verificar se um arquivo existe
      // Tentamos obter metadados do arquivo, se ele não existir, uma exceção será lançada
      final directory = path.contains('/') ? path.substring(0, path.lastIndexOf('/')) : '';
      final filename = path.contains('/') ? path.substring(path.lastIndexOf('/') + 1) : path;
      
      final files = await _supabaseClient.storage
          .from(_currentBucket)
          .list(path: directory);
      
      return files.any((file) => file.name == filename);
    } catch (e) {
      LogUtils.debug(
        'Verificação de existência de arquivo falhou',
        tag: 'SupabaseStorageService',
        data: {'path': path, 'error': e.toString()},
      );
      return false;
    }
  }
  
  @override
  Future<void> deleteFile(String path) async {
    _ensureInitialized();
    _validatePath(path);
    
    try {
      await _supabaseClient.storage
          .from(_currentBucket)
          .remove([path]);
    } catch (e, stackTrace) {
      final error = app.StorageException(
        message: 'Erro ao excluir arquivo',
        originalError: e,
        stackTrace: stackTrace,
      );
      LogUtils.error(
        'Falha ao excluir arquivo',
        error: error,
        stackTrace: stackTrace,
        tag: 'SupabaseStorageService',
      );
      throw error;
    }
  }
  
  @override
  Future<List<String>> listFiles({
    required String directory,
    int? limit,
    String? prefix,
  }) async {
    _ensureInitialized();
    
    try {
      // O Supabase Storage Client não suporta limit via FileOptions
      // Vamos tratar isso manualmente
      
      final searchPrefix = prefix != null ? '$directory/$prefix' : directory;
      
      final files = await _supabaseClient.storage
          .from(_currentBucket)
          .list(path: directory);
      
      // Filtrar arquivos com prefixo, se fornecido
      final filteredFiles = files
          .where((file) => prefix == null || file.name.startsWith(prefix))
          .map((file) => '$directory/${file.name}')
          .toList();
      
      // Aplicar limite manualmente, se fornecido
      if (limit != null && filteredFiles.length > limit) {
        return filteredFiles.sublist(0, limit);
      }
      
      return filteredFiles;
    } catch (e, stackTrace) {
      final error = app.StorageException(
        message: 'Erro ao listar arquivos',
        originalError: e,
        stackTrace: stackTrace,
      );
      LogUtils.error(
        'Falha ao listar arquivos',
        error: error,
        stackTrace: stackTrace,
        tag: 'SupabaseStorageService',
      );
      throw error;
    }
  }
  
  @override
  Future<String> copyFile({
    required String sourcePath,
    required String destinationPath,
    StorageBucketType? sourceBucket,
  }) async {
    _ensureInitialized();
    _validatePath(sourcePath);
    _validatePath(destinationPath);
    
    try {
      final String sourceActualBucket;
      if (sourceBucket != null) {
        sourceActualBucket = _bucketNames[sourceBucket]!;
      } else {
        sourceActualBucket = _currentBucket;
      }
      
      // O Supabase não tem uma API direta para copiar arquivos
      // Precisamos baixar o arquivo e depois fazer o upload novamente
      final bytes = await _supabaseClient.storage
          .from(sourceActualBucket)
          .download(sourcePath);
      
      final tempFilePath = await _saveTempFile(bytes, path.basename(sourcePath));
      final tempFile = File(tempFilePath);
      
      final contentType = _determineContentType(sourcePath);
      
      final fileOptions = FileOptions(
        cacheControl: '3600',
        contentType: contentType,
        upsert: true,
      );
      
      await _supabaseClient.storage
          .from(_currentBucket)
          .upload(destinationPath, tempFile, fileOptions: fileOptions);
      
      // Limpar arquivo temporário
      await tempFile.delete();
      
      // Retornar o caminho de destino
      return destinationPath;
    } catch (e, stackTrace) {
      final error = app.StorageException(
        message: 'Erro ao copiar arquivo',
        originalError: e,
        stackTrace: stackTrace,
      );
      LogUtils.error(
        'Falha ao copiar arquivo',
        error: error,
        stackTrace: stackTrace,
        tag: 'SupabaseStorageService',
      );
      throw error;
    }
  }
  
  @override
  Future<void> dispose() async {
    // Nada específico para liberar nesta implementação
    _initialized = false;
  }
  
  /// Adiciona um novo validador de arquivo
  void addValidator(FileValidator validator) {
    _validators.add(validator);
  }
  
  /// Limpa todos os validadores registrados
  void clearValidators() {
    _validators.clear();
  }
  
  /// Verifica se o serviço está inicializado
  void _ensureInitialized() {
    if (!_initialized) {
      throw app.StorageException(
        message: 'Serviço de armazenamento não inicializado',
        code: 'service_not_initialized',
      );
    }
    
    if (_currentBucket.isEmpty) {
      throw app.StorageException(
        message: 'Nenhum bucket selecionado',
        code: 'no_bucket_selected',
      );
    }
  }
  
  /// Valida um caminho para garantir que ele seja aceitável
  void _validatePath(String path) {
    if (path.isEmpty) {
      throw app.StorageException(
        message: 'Caminho de arquivo não pode ser vazio',
        code: 'empty_path',
      );
    }
    
    // Verificar se o caminho contém caracteres não permitidos
    if (path.contains('..') || path.contains('//')) {
      throw app.StorageException(
        message: 'Caminho de arquivo contém sequências de caracteres não permitidas',
        code: 'invalid_path',
      );
    }
  }
  
  /// Determina o tipo de conteúdo com base na extensão do arquivo
  String _determineContentType(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    
    switch (extension) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.pdf':
        return 'application/pdf';
      case '.json':
        return 'application/json';
      case '.txt':
        return 'text/plain';
      default:
        return 'application/octet-stream';
    }
  }
  
  /// Salva bytes em um arquivo temporário
  Future<String> _saveTempFile(Uint8List bytes, String filename) async {
    final tempDir = Directory.systemTemp;
    final tempFilePath = '${tempDir.path}/$filename';
    final tempFile = File(tempFilePath);
    
    await tempFile.writeAsBytes(bytes);
    return tempFilePath;
  }
  
  // Implementação dos métodos adicionados à interface
  
  @override
  Future<void> cleanupExpiredTempFiles() async {
    try {
      final tempBucket = _bucketNames[StorageBucketType.temporary] ?? 'temporary';
      final tempFiles = await _supabaseClient.storage.from(tempBucket).list();
      final now = DateTime.now().millisecondsSinceEpoch;
      const maxAge = 24 * 60 * 60 * 1000; // 24 horas
      
      for (var file in tempFiles) {
        // Assumindo que o nome do arquivo tem um timestamp no início: timestamp_filename
        final parts = file.name.split('_');
        if (parts.length > 1) {
          final timestamp = int.tryParse(parts[0]);
          if (timestamp != null && (now - timestamp) > maxAge) {
            await _supabaseClient.storage.from(tempBucket).remove([file.name]);
          }
        }
      }
    } catch (e) {
      // Apenas log, não propagamos exceção para não interromper outras operações
      LogUtils.error(
        'Erro ao limpar arquivos temporários',
        error: e,
        tag: 'SupabaseStorageService',
      );
    }
  }
  
  @override
  Future<String> getTempFilePath(String filename) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '$timestamp\_$filename';
  }
  
  @override
  Future<void> createBucketIfNotExists(String bucketName, {bool isPublic = false}) async {
    try {
      _ensureInitialized();
      
      final buckets = await _supabaseClient.storage.listBuckets();
      final exists = buckets.any((b) => b.name == bucketName);
      
      if (!exists) {
        final options = BucketOptions(public: isPublic);
        await _supabaseClient.storage.createBucket(bucketName, options);
      }
    } catch (e, stackTrace) {
      final error = app.StorageException(
        message: 'Erro ao criar bucket: $bucketName',
        originalError: e,
        stackTrace: stackTrace,
      );
      
      LogUtils.error(
        'Falha ao criar bucket',
        error: error,
        stackTrace: stackTrace,
        tag: 'SupabaseStorageService',
      );
      
      throw error;
    }
  }
  
  @override
  Future<bool> bucketExists(String bucketName) async {
    try {
      _ensureInitialized();
      
      final buckets = await _supabaseClient.storage.listBuckets();
      return buckets.any((b) => b.name == bucketName);
    } catch (e, stackTrace) {
      final error = app.StorageException(
        message: 'Erro ao verificar existência do bucket: $bucketName',
        originalError: e,
        stackTrace: stackTrace,
      );
      
      LogUtils.error(
        'Falha ao verificar bucket',
        error: error,
        stackTrace: stackTrace,
        tag: 'SupabaseStorageService',
      );
      
      throw error;
    }
  }
  
  @override
  Future<String> uploadData({
    required Uint8List data,
    required String path,
    String? contentType,
    Map<String, String>? metadata,
  }) async {
    try {
      _ensureInitialized();
      _validatePath(path);
      
      final FileOptions options = FileOptions(
        contentType: contentType,
        upsert: true,
      );
      
      await _supabaseClient.storage
          .from(_currentBucket)
          .uploadBinary(path, data, fileOptions: options);
      
      // Retorna a URL pública baseada na política de acesso
      if (_currentAccessPolicy == StorageAccessType.public) {
        return getPublicUrl(path);
      } else {
        return path;
      }
    } catch (e, stackTrace) {
      if (e is app.StorageException) {
        rethrow;
      }
      
      final error = app.StorageException(
        message: 'Erro ao fazer upload de dados binários',
        originalError: e,
        stackTrace: stackTrace,
      );
      
      LogUtils.error(
        'Falha ao fazer upload de dados',
        error: error,
        stackTrace: stackTrace,
        tag: 'SupabaseStorageService',
      );
      
      throw error;
    }
  }
  
  @override
  Future<Uint8List> prepareImageForUpload(
    File imageFile, {
    int maxWidth = 1920,
    int maxHeight = 1920,
    int quality = 85,
  }) async {
    try {
      // Nesta implementação simplificada, apenas retornamos os bytes do arquivo
      // Uma implementação real faria o redimensionamento e a compressão
      return await imageFile.readAsBytes();
    } catch (e, stackTrace) {
      final error = app.StorageException(
        message: 'Erro ao preparar imagem para upload',
        originalError: e,
        stackTrace: stackTrace,
      );
      
      LogUtils.error(
        'Falha ao preparar imagem',
        error: error,
        stackTrace: stackTrace,
        tag: 'SupabaseStorageService',
      );
      
      throw error;
    }
  }
} 
