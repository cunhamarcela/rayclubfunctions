// Dart imports:
import 'dart:io';
import 'dart:typed_data';

// Flutter imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:ray_club_app/services/storage_service.dart';

// Esta classe implementa StorageService diretamente em vez de herdar de SupabaseStorageService
class MockStorageService implements StorageService {
  bool _initialized = false;
  String _currentBucket = '';
  final List<String> _existingBuckets = ['profile_pictures', 'meal_images', 'temporary'];
  final Map<String, Map<String, Uint8List>> _storage = {};
  StorageAccessType _accessPolicy = StorageAccessType.private;

  @override
  String get currentBucket => _currentBucket;

  @override
  bool get isInitialized => _initialized;

  @override
  Future<bool> bucketExists(String bucketName) async {
    return _existingBuckets.contains(bucketName);
  }

  @override
  Future<void> cleanupExpiredTempFiles() async {}

  @override
  Future<void> createBucketIfNotExists(String bucketName, {bool isPublic = false}) async {
    if (!_existingBuckets.contains(bucketName)) {
      _existingBuckets.add(bucketName);
    }
  }

  @override
  Future<void> deleteFile(String path) async {
    if (_storage.containsKey(_currentBucket)) {
      _storage[_currentBucket]?.remove(path);
    }
  }

  @override
  Future<void> dispose() async {}

  @override
  Future<File> downloadFile({required String remotePath, required String localPath}) async {
    // Simula o download criando um arquivo temporário
    if (!_storage.containsKey(_currentBucket) || 
        !_storage[_currentBucket]!.containsKey(remotePath)) {
      throw Exception('Arquivo não encontrado: $remotePath');
    }
    
    final file = File(localPath);
    await file.writeAsBytes(_storage[_currentBucket]![remotePath]!);
    return file;
  }

  @override
  Future<bool> fileExists(String path) async {
    return _storage.containsKey(_currentBucket) && 
           _storage[_currentBucket]!.containsKey(path);
  }

  @override
  Future<String> getPublicUrl(String path, {Duration? expiresIn}) async {
    return 'https://exemplo.com/$_currentBucket/$path';
  }

  @override
  Future<String> getTempFilePath(String filename) async {
    return '/tmp/$filename';
  }

  @override
  Future<void> initialize() async {
    _initialized = true;
    _currentBucket = 'temporary';
    
    // Inicializar buckets no armazenamento em memória
    for (final bucket in _existingBuckets) {
      _storage[bucket] = {};
    }
  }

  @override
  Future<List<String>> listFiles({required String directory, int? limit, String? prefix}) async {
    if (!_storage.containsKey(_currentBucket)) {
      return [];
    }
    
    final files = _storage[_currentBucket]!.keys
        .where((path) => path.startsWith(directory))
        .toList();
    
    if (limit != null && files.length > limit) {
      return files.sublist(0, limit);
    }
    
    return files;
  }

  @override
  Future<Uint8List> prepareImageForUpload(File imageFile, {int maxWidth = 1920, int maxHeight = 1920, int quality = 85}) async {
    // Apenas retorna alguns bytes fictícios para simular uma imagem
    return Uint8List.fromList([1, 2, 3, 4, 5]);
  }

  @override
  void setAccessPolicy(StorageAccessType accessType) {
    _accessPolicy = accessType;
  }

  @override
  Future<void> setBucket(StorageBucketType bucketType) async {
    // Mapeia o enum para os nomes de bucket correspondentes
    final Map<StorageBucketType, String> bucketMap = {
      StorageBucketType.profilePictures: 'profile_pictures',
      StorageBucketType.mealImages: 'meal_images',
      StorageBucketType.workoutImages: 'workout_images',
      StorageBucketType.documents: 'documents',
      StorageBucketType.contentImages: 'content_images',
      StorageBucketType.temporary: 'temporary',
    };
    
    final bucketName = bucketMap[bucketType];
    if (bucketName == null) {
      throw Exception('Tipo de bucket inválido: $bucketType');
    }
    
    if (!_existingBuckets.contains(bucketName)) {
      throw Exception('Bucket não encontrado: $bucketName');
    }
    
    _currentBucket = bucketName;
  }

  @override
  Future<String> uploadData({required Uint8List data, required String path, String? contentType, Map<String, String>? metadata}) async {
    _ensureInitialized();
    
    if (!_storage.containsKey(_currentBucket)) {
      _storage[_currentBucket] = {};
    }
    
    _storage[_currentBucket]![path] = data;
    
    if (_accessPolicy == StorageAccessType.public) {
      return await getPublicUrl(path);
    } else {
      return path;
    }
  }

  @override
  Future<String> uploadFile({required File file, required String path, String? contentType, Map<String, String>? metadata}) async {
    _ensureInitialized();
    
    final data = await file.readAsBytes();
    return uploadData(data: data, path: path, contentType: contentType, metadata: metadata);
  }
  
  void _ensureInitialized() {
    if (!_initialized) {
      throw Exception('StorageService não inicializado. Chame initialize() primeiro.');
    }
  }
}

void main() {
  group('MockStorageService', () {
    late MockStorageService storageService;

    setUp(() {
      storageService = MockStorageService();
    });

    test('initialize deve configurar o serviço corretamente', () async {
      // Arrange & Act
      await storageService.initialize();

      // Assert
      expect(storageService.isInitialized, true);
      expect(storageService.currentBucket, 'temporary');
    });

    test('setBucket deve atualizar o bucket atual quando o bucket existe', () async {
      // Arrange
      await storageService.initialize();

      // Act
      await storageService.setBucket(StorageBucketType.profilePictures);

      // Assert
      expect(storageService.currentBucket, 'profile_pictures');
    });

    test('setBucket deve lançar uma exceção quando o bucket não existe', () async {
      // Arrange
      await storageService.initialize();

      // Act & Assert
      expect(
        () async => await storageService.setBucket(StorageBucketType.workoutImages),
        throwsException,
      );
    });

    test('uploadFile e downloadFile devem funcionar corretamente', () async {
      // Este teste precisa de um arquivo temporário real para funcionar
      // No ambiente de CI pode ser necessário usar skipIfCI
      final tempDir = Directory.systemTemp.createTempSync();
      try {
        // Arrange
        await storageService.initialize();
        await storageService.setBucket(StorageBucketType.mealImages);
        
        // Criar arquivo de teste
        final testFile = File('${tempDir.path}/test.txt');
        await testFile.writeAsString('Conteúdo de teste');
        
        // Act - Upload
        final uploadPath = await storageService.uploadFile(
          file: testFile,
          path: 'uploads/test.txt',
        );
        
        // Assert - Verificar se o arquivo existe no storage
        final exists = await storageService.fileExists('uploads/test.txt');
        expect(exists, true);
        
        // Act - Download
        final downloadedFile = await storageService.downloadFile(
          remotePath: 'uploads/test.txt',
          localPath: '${tempDir.path}/downloaded.txt',
        );
        
        // Assert - Verificar conteúdo do arquivo baixado
        final downloadedContent = await downloadedFile.readAsString();
        expect(downloadedContent, 'Conteúdo de teste');
      } finally {
        // Cleanup
        tempDir.deleteSync(recursive: true);
      }
    });

    test('getPublicUrl deve retornar uma URL formatada corretamente', () async {
      // Arrange
      await storageService.initialize();
      await storageService.setBucket(StorageBucketType.profilePictures);
      
      // Act
      final url = await storageService.getPublicUrl('image.jpg');
      
      // Assert
      expect(url, 'https://exemplo.com/profile_pictures/image.jpg');
    });
  });
} 

