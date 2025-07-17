// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/features/workout/models/workout_video_model.dart';
import 'package:ray_club_app/features/workout/repositories/workout_videos_repository.dart';

/// Modelo para representar um estúdio parceiro na home
class HomePartnerStudio {
  final String id;
  final String name;
  final String tagline;
  final Color logoColor;
  final Color backgroundColor;
  final IconData icon;
  final List<WorkoutVideo> videos;
  final String workoutCategory;
  final List<WorkoutSection>? sections; // Nova propriedade para seções organizadas
  
  const HomePartnerStudio({
    required this.id,
    required this.name,
    required this.tagline,
    required this.logoColor,
    required this.backgroundColor,
    required this.icon,
    required this.videos,
    required this.workoutCategory,
    this.sections,
  });
}

/// Modelo para representar seções dentro de um parceiro (ex: Semana 1, Full Body, etc.)
class WorkoutSection {
  final String id;
  final String name;
  final String description;
  final List<WorkoutVideo> videos;
  final IconData? icon;
  
  const WorkoutSection({
    required this.id,
    required this.name,
    required this.description,
    required this.videos,
    this.icon,
  });
}

/// Provider que organiza os workout videos por categoria para exibição na home
final homeWorkoutVideosProvider = FutureProvider<List<HomePartnerStudio>>((ref) async {
  final repository = ref.watch(workoutVideosRepositoryProvider);
  
  try {
    // Buscar vídeos por cada categoria (usando os UUIDs corretos do banco)
    final musculacaoVideos = await repository.getVideosByCategory('495f6111-00f1-4484-974f-5213a5a44ed8');
    final pilatesVideos = await repository.getVideosByCategory('fe034f6d-aa79-436c-b0b7-7aea572f08c1');
    final funcionalVideos = await repository.getVideosByCategory('43eb2044-38cf-4193-848c-da46fd7e9cb4');
    final corridaVideos = await repository.getVideosByCategory('07754890-b092-4386-be56-bb088a2a96f1');
    final fisioterapiaVideos = await repository.getVideosByCategory('da178dba-ae94-425a-aaed-133af7b1bb0f');
    
    // Organizar em estúdios parceiros
    final studios = <HomePartnerStudio>[];
    
    // 1. 💪 Treinos de Musculação - Organizados por Semanas
    if (musculacaoVideos.isNotEmpty) {
      // 🎯 FILTRO ESPECÍFICO: Mostrar apenas Treinos A, B, C, D, E, F na home
      final treinosEspecificos = musculacaoVideos.where((video) {
        final titulo = video.title.toLowerCase();
        return titulo.contains('treino a') || 
               titulo.contains('treino b') || 
               titulo.contains('treino c') || 
               titulo.contains('treino d') || 
               titulo.contains('treino e') || 
               titulo.contains('treino f');
      }).toList();
      
      // Filtrar apenas os treinos principais (não "Semana 02")
      final treinosPrincipais = treinosEspecificos.where((video) => 
        !video.title.toLowerCase().contains('semana 02')
      ).toList();
      
      if (treinosPrincipais.isNotEmpty) {
        studios.add(
          HomePartnerStudio(
            id: 'musculacao',
            name: 'Treinos de Musculação',
            tagline: 'Treinos completos A-F com vídeos e PDFs',
            videos: treinosPrincipais,
            logoColor: const Color(0xFF27AE60),
            backgroundColor: const Color(0xFFE9F7EF),
            icon: Icons.fitness_center,
            workoutCategory: '495f6111-00f1-4484-974f-5213a5a44ed8',
          ),
        );
      }
    }
    
    // 2. 🧘‍♀️ Goya Health Club (Pilates)
    if (pilatesVideos.isNotEmpty) {
      studios.add(HomePartnerStudio(
        id: 'pilates',
        name: 'Goya Health Club',
        tagline: 'Pilates e bem-estar integral',
        videos: pilatesVideos,
        logoColor: const Color(0xFF8E44AD),
        backgroundColor: const Color(0xFFF4ECF7),
        icon: Icons.spa,
        workoutCategory: 'fe034f6d-aa79-436c-b0b7-7aea572f08c1',
      ));
    }

    // 3. 🏃‍♂️ Fight Fit (Funcional)
    if (funcionalVideos.isNotEmpty) {
      studios.add(HomePartnerStudio(
        id: 'funcional',
        name: 'Fight Fit',
        tagline: 'Treinos funcionais intensos',
        videos: funcionalVideos,
        logoColor: const Color(0xFFE74C3C),
        backgroundColor: const Color(0xFFFDEDEC),
        icon: Icons.sports_mma,
        workoutCategory: '43eb2044-38cf-4193-848c-da46fd7e9cb4',
      ));
    }

    // 4. 🏃‍♀️ Bora Assessoria (Corrida)
    if (corridaVideos.isNotEmpty) {
      studios.add(HomePartnerStudio(
        id: 'corrida',
        name: 'Bora Assessoria',
        tagline: 'Assessoria especializada em corrida',
        videos: corridaVideos,
        logoColor: const Color(0xFF3498DB),
        backgroundColor: const Color(0xFFEBF5FB),
        icon: Icons.directions_run,
        workoutCategory: '07754890-b092-4386-be56-bb088a2a96f1',
      ));
    }

    // 5. 🏥 The Unit (Fisioterapia)
    if (fisioterapiaVideos.isNotEmpty) {
      studios.add(HomePartnerStudio(
        id: 'fisioterapia',
        name: 'The Unit',
        tagline: 'Fisioterapia e reabilitação',
        videos: fisioterapiaVideos,
        logoColor: const Color(0xFF16A085),
        backgroundColor: const Color(0xFFE9F7EF),
        icon: Icons.medical_services,
        workoutCategory: 'da178dba-ae94-425a-aaed-133af7b1bb0f',
      ));
    }
    
    return studios;
    
  } catch (e) {
    // Em caso de erro, retornar lista vazia
    print('🏠 PROVIDER DEBUG: ERRO ao carregar vídeos: $e');
    return [];
  }
});

/// Provider para buscar vídeos de uma categoria específica para navegação
final categoryVideosProvider = FutureProvider.family<List<WorkoutVideo>, String>((ref, category) async {
  final repository = ref.watch(workoutVideosRepositoryProvider);
  return repository.getVideosByCategory(category);
});

/// Provider para buscar vídeos de uma seção específica
final sectionVideosProvider = FutureProvider.family<List<WorkoutVideo>, String>((ref, sectionId) async {
  final studios = await ref.watch(homeWorkoutVideosProvider.future);
  
  for (final studio in studios) {
    if (studio.sections != null) {
      for (final section in studio.sections!) {
        if (section.id == sectionId) {
          return section.videos;
        }
      }
    }
  }
  
  return [];
}); 