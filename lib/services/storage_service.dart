// Dart imports:
import 'dart:io';
import 'dart:typed_data';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';
import '../core/config/app_config.dart';
import '../core/di/base_service.dart';
import '../utils/log_utils.dart';

/// Tipos de acesso de armazenamento
enum StorageAccessType {
  /// Acesso público (qualquer pessoa pode ler)
  public,
  
  /// Acesso privado (apenas o proprietário pode ler)
  private,
  
  /// Acesso apenas por administradores
  admin
}

/// Tipos de armazenamento (buckets)
enum StorageBucketType {
  /// Fotos de perfil de usuários
  profilePictures,
  
  /// Imagens de refeições
  mealImages,
  
  /// Imagens de exercícios
  workoutImages,
  
  /// Documentos
  documents,
  
  /// Imagens para conteúdo geral
  contentImages,
  
  /// Mídia temporária (thumbnails, uploads parciais)
  temporary
}

/// Interface para serviços de armazenamento
abstract class StorageService implements BaseService {
  /// Nome do bucket atualmente configurado
  String get currentBucket;
  
  /// Define o bucket ativo para operações subsequentes
  Future<void> setBucket(StorageBucketType bucketType);
  
  /// Define a política de acesso para uploads subsequentes
  void setAccessPolicy(StorageAccessType accessType);
  
  /// Faz upload de um arquivo para o storage atual
  /// 
  /// [file] - O arquivo para fazer upload
  /// [path] - O caminho relativo no bucket onde o arquivo será armazenado
  /// [contentType] - Tipo de conteúdo do arquivo (MIME)
  /// [metadata] - Metadados opcionais para o arquivo
  /// 
  /// Retorna a URL pública do arquivo (se disponível) ou o caminho do arquivo
  Future<String> uploadFile({
    required File file, 
    required String path,
    String? contentType,
    Map<String, String>? metadata,
  });
  
  /// Faz download de um arquivo do storage
  /// 
  /// [remotePath] - Caminho remoto do arquivo
  /// [localPath] - Caminho local onde o arquivo será salvo
  /// 
  /// Retorna o arquivo baixado
  Future<File> downloadFile({
    required String remotePath,
    required String localPath,
  });
  
  /// Obtém uma URL pública para um arquivo (temporária ou permanente)
  /// 
  /// [path] - Caminho do arquivo no bucket
  /// [expiresIn] - Tempo de expiração da URL (se aplicável)
  Future<String> getPublicUrl(String path, {Duration? expiresIn});
  
  /// Verifica se um arquivo existe no storage
  /// 
  /// [path] - Caminho do arquivo no bucket
  Future<bool> fileExists(String path);
  
  /// Remove um arquivo do storage
  /// 
  /// [path] - Caminho do arquivo no bucket
  Future<void> deleteFile(String path);
  
  /// Lista arquivos em um diretório do storage
  /// 
  /// [directory] - Diretório a ser listado
  /// [limit] - Número máximo de arquivos a retornar
  /// [prefix] - Prefixo para filtrar arquivos
  Future<List<String>> listFiles({
    required String directory,
    int? limit,
    String? prefix,
  });
  
  /// Limpa arquivos temporários expirados
  Future<void> cleanupExpiredTempFiles();
  
  /// Obtém o caminho para um arquivo temporário
  Future<String> getTempFilePath(String filename);
  
  /// Cria um bucket no storage (se ele ainda não existir)
  Future<void> createBucketIfNotExists(String bucketName, {bool isPublic = false});
  
  /// Verifica se um bucket existe
  Future<bool> bucketExists(String bucketName);
  
  /// Faz upload de dados binários para o storage
  Future<String> uploadData({
    required Uint8List data,
    required String path,
    String? contentType,
    Map<String, String>? metadata,
  });
  
  /// Prepara uma imagem para upload (redimensiona e comprime se necessário)
  Future<Uint8List> prepareImageForUpload(
    File imageFile, {
    int maxWidth = 1920,
    int maxHeight = 1920,
    int quality = 85,
  });
  
  /// Libera recursos alocados pelo serviço
  Future<void> dispose();
}

/// Validador de arquivos para upload
abstract class FileValidator {
  Future<void> validate(File file);
}

/// Validador de tamanho máximo de arquivo
class FileSizeValidator implements FileValidator {
  final int maxSizeInBytes;
  
  FileSizeValidator({required this.maxSizeInBytes});
  
  @override
  Future<void> validate(File file) async {
    final size = await file.length();
    
    if (size > maxSizeInBytes) {
      throw FileValidationException(
        message: 'Arquivo muito grande. Tamanho máximo: ${maxSizeInBytes / 1024 / 1024} MB',
        code: 'file_too_large',
      );
    }
  }
}

/// Validador de tipo de arquivo
class FileTypeValidator implements FileValidator {
  final List<String> allowedExtensions;
  
  FileTypeValidator({required this.allowedExtensions});
  
  @override
  Future<void> validate(File file) async {
    final filePath = file.path.toLowerCase();
    final hasValidExtension = allowedExtensions.any((ext) => filePath.endsWith('.$ext'));
    
    if (!hasValidExtension) {
      throw FileValidationException(
        message: 'Tipo de arquivo não permitido. Tipos aceitos: ${allowedExtensions.join(", ")}',
        code: 'invalid_file_type',
      );
    }
  }
}

/// Provider para o serviço de armazenamento
/// Este provider foi movido para lib/core/providers/service_providers.dart
/// para evitar conflitos de importação
// final storageServiceProvider = Provider<StorageService>((ref) {
//   throw UnimplementedError('StorageService deve ser fornecido pela implementação concreta');
// });
