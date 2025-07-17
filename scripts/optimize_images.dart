import 'dart:io';
import 'package:path/path.dart' as path;

/// Script para otimizar imagens no projeto
/// Execute com: dart scripts/optimize_images.dart
void main() async {
  final imagesDir = Directory('assets/images');
  
  if (!imagesDir.existsSync()) {
    print('❌ Diretório de imagens não encontrado!');
    return;
  }
  
  print('🔍 Analisando imagens para otimização...');
  int count = 0;
  int savedSize = 0;
  
  // Processar todas as imagens recursivamente
  await _processDirectory(imagesDir, (file, stats) {
    count++;
    savedSize += stats.savedSize;
  });
  
  print('✅ Otimização concluída!');
  print('📊 Total de imagens otimizadas: $count');
  print('💾 Economia total: ${(savedSize / 1024 / 1024).toStringAsFixed(2)} MB');
}

Future<void> _processDirectory(Directory dir, Function(File, ImageOptStats) onProcess) async {
  final entities = dir.listSync(recursive: false);
  
  for (final entity in entities) {
    if (entity is Directory) {
      await _processDirectory(entity, onProcess);
    } else if (entity is File) {
      final ext = path.extension(entity.path).toLowerCase();
      if (['.jpg', '.jpeg', '.png'].contains(ext)) {
        final stats = await _optimizeImage(entity);
        onProcess(entity, stats);
      }
    }
  }
}

Future<ImageOptStats> _optimizeImage(File file) async {
  final origSize = file.lengthSync();
  final ext = path.extension(file.path).toLowerCase();
  final tempFile = File('${file.path}.temp$ext');
  
  ProcessResult result;
  
  try {
    if (ext == '.png') {
      // Otimização para PNG
      result = await Process.run('pngquant', [
        '--force',
        '--quality=65-80',
        '--speed=1',
        '--output=${tempFile.path}',
        file.path
      ]);
    } else {
      // Otimização para JPG/JPEG
      result = await Process.run('convert', [
        file.path,
        '-sampling-factor', '4:2:0',
        '-strip',
        '-quality', '80',
        '-interlace', 'JPEG',
        '-colorspace', 'RGB',
        tempFile.path
      ]);
    }
    
    if (result.exitCode != 0) {
      print('⚠️ Falha ao otimizar ${file.path}: ${result.stderr}');
      if (tempFile.existsSync()) await tempFile.delete();
      return ImageOptStats(file.path, origSize, origSize, false);
    }
    
    // Verifica se a imagem otimizada é realmente menor
    final newSize = tempFile.lengthSync();
    if (newSize < origSize) {
      await tempFile.rename(file.path);
      print('✅ Otimizado: ${file.path} - ${_formatSize(origSize)} → ${_formatSize(newSize)} (${_formatPercent(newSize, origSize)})');
      return ImageOptStats(file.path, origSize, origSize - newSize, true);
    } else {
      await tempFile.delete();
      print('ℹ️ Já otimizado: ${file.path} (${_formatSize(origSize)})');
      return ImageOptStats(file.path, origSize, 0, true);
    }
  } catch (e) {
    print('⚠️ Erro ao processar ${file.path}: $e');
    if (tempFile.existsSync()) await tempFile.delete();
    return ImageOptStats(file.path, origSize, 0, false);
  }
}

String _formatSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
}

String _formatPercent(int newSize, int origSize) {
  final percent = ((origSize - newSize) / origSize * 100).toStringAsFixed(1);
  return '-$percent%';
}

class ImageOptStats {
  final String path;
  final int originalSize;
  final int savedSize;
  final bool success;
  
  ImageOptStats(this.path, this.originalSize, this.savedSize, this.success);
} 