// 🔍 SCRIPT TEMPORÁRIO - VERIFICAÇÃO DE MIGRAÇÃO DE SUBCATEGORIAS
// Para ser removido após confirmação da migração

import 'package:flutter/foundation.dart';
import 'package:ray_club_app/features/workout/repositories/workout_videos_repository.dart';

class SubcategoryMigrationChecker {
  static Future<void> checkMigrationStatus(WorkoutVideosRepository repository) async {
    if (!kDebugMode) return; // Só rodar em modo debug
    
    try {
      print('\n🔍 ===== VERIFICAÇÃO DE MIGRAÇÃO DE SUBCATEGORIAS =====');
      
      // Buscar todos os vídeos de fisioterapia
      const fisioterapiaCategory = 'da178dba-ae94-425a-aaed-133af7b1bb0f';
      final fisioterapiaVideos = await repository.getVideosByCategory(fisioterapiaCategory);
      
      print('📊 Total de vídeos de fisioterapia: ${fisioterapiaVideos.length}');
      
      // Contar vídeos por status de migração
      int comSubcategoria = 0;
      int semSubcategoria = 0;
      final Map<String, int> contagemPorSubcategoria = {};
      
      for (final video in fisioterapiaVideos) {
        if (video.subcategory != null && video.subcategory!.isNotEmpty) {
          comSubcategoria++;
          contagemPorSubcategoria[video.subcategory!] = 
              (contagemPorSubcategoria[video.subcategory!] ?? 0) + 1;
          
          print('✅ ${video.title} → subcategory: "${video.subcategory}"');
        } else {
          semSubcategoria++;
          print('⚠️ ${video.title} → subcategory: null (usará fallback)');
        }
      }
      
      print('\n📈 ===== RESUMO DA MIGRAÇÃO =====');
      print('✅ Vídeos migrados: $comSubcategoria');
      print('⚠️ Vídeos pendentes: $semSubcategoria');
      print('📊 Progresso: ${(comSubcategoria / fisioterapiaVideos.length * 100).toStringAsFixed(1)}%');
      
      if (contagemPorSubcategoria.isNotEmpty) {
        print('\n🏷️ ===== DISTRIBUIÇÃO POR SUBCATEGORIA =====');
        contagemPorSubcategoria.forEach((subcategoria, quantidade) {
          print('$subcategoria: $quantidade vídeos');
        });
      }
      
      if (semSubcategoria == 0) {
        print('\n🎉 ===== MIGRAÇÃO COMPLETA! =====');
        print('Todos os vídeos de fisioterapia foram migrados.');
        print('Você pode remover os logs temporários do provider.');
      } else {
        print('\n⏳ ===== MIGRAÇÃO EM PROGRESSO =====');
        print('Execute o script SQL para classificar os vídeos restantes.');
      }
      
      print('🔍 ===== FIM DA VERIFICAÇÃO =====\n');
      
    } catch (e) {
      print('❌ Erro na verificação de migração: $e');
    }
  }
  
  /// Função de conveniência para testar subcategorias específicas
  static Future<void> testSubcategoryFiltering(
    WorkoutVideosRepository repository,
    String subcategoryName,
  ) async {
    if (!kDebugMode) return;
    
    try {
      print('\n🧪 ===== TESTE DE FILTRO: $subcategoryName =====');
      
      const fisioterapiaCategory = 'da178dba-ae94-425a-aaed-133af7b1bb0f';
      final allVideos = await repository.getVideosByCategory(fisioterapiaCategory);
      
      // Simular o filtro do provider
      final filteredVideos = allVideos.where((video) {
        if (video.subcategory != null && video.subcategory!.isNotEmpty) {
          return video.subcategory!.toLowerCase() == subcategoryName.toLowerCase();
        }
        
        // Fallback (mesmo código do provider)
        final title = video.title.toLowerCase();
        final description = video.description?.toLowerCase() ?? '';
        
        switch (subcategoryName.toLowerCase()) {
          case 'testes':
            return title.contains('apresentação') || 
                   title.contains('teste') || 
                   title.contains('avaliação') ||
                   description.contains('apresentação') ||
                   description.contains('introdução');
                   
          case 'mobilidade':
            return title.contains('mobilidade') ||
                   description.contains('mobilidade') ||
                   description.contains('amplitude');
                   
                case 'estabilidade':
        return title.contains('prevenção') || 
               title.contains('lesões') || 
               title.contains('joelho') || 
               title.contains('coluna') ||
               title.contains('fortalecimento') ||
               title.contains('estabilidade') ||
               title.contains('prancha') ||
               title.contains('dor') ||
               description.contains('prevenção') ||
               description.contains('fortaleça') ||
               description.contains('estabilidade');
                   
          default:
            return false;
        }
      }).toList();
      
      print('📊 Vídeos encontrados para "$subcategoryName": ${filteredVideos.length}');
      
      for (final video in filteredVideos) {
        final usingDatabase = video.subcategory != null && video.subcategory!.isNotEmpty;
        final source = usingDatabase ? '🗄️ Banco' : '🔍 Fallback';
        print('  $source: ${video.title}');
      }
      
      print('🧪 ===== FIM DO TESTE =====\n');
      
    } catch (e) {
      print('❌ Erro no teste de filtro: $e');
    }
  }
} 