import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ray_club_app/models/material.dart';
import 'package:ray_club_app/services/pdf_service.dart';

/// Provider para materiais de um vídeo de treino específico
final workoutVideoMaterialsProvider = FutureProvider.family<List<Material>, String>((ref, workoutVideoId) async {
  final pdfService = ref.watch(pdfServiceProvider);
  return pdfService.getMaterialsByWorkoutVideo(workoutVideoId);
});

/// Provider para materiais de nutrição
final nutritionMaterialsProvider = FutureProvider<List<Material>>((ref) async {
  final pdfService = ref.watch(pdfServiceProvider);
  return pdfService.getMaterialsByContext(MaterialContext.nutrition);
});

/// Provider para materiais de corrida (planilhas de treino)
final runningMaterialsProvider = FutureProvider<List<Material>>((ref) async {
  final pdfService = ref.watch(pdfServiceProvider);
  
  // Buscar todos os materiais de treino e filtrar por corrida
  final allWorkoutMaterials = await pdfService.getMaterialsByContext(MaterialContext.workout);
  
  // Filtrar materiais relacionados à corrida
  return allWorkoutMaterials.where((material) {
    final titleLower = material.title.toLowerCase();
    final descriptionLower = material.description.toLowerCase();
    
    return titleLower.contains('corrida') || 
           titleLower.contains('running') ||
           titleLower.contains('km') ||
           descriptionLower.contains('corrida') ||
           descriptionLower.contains('running');
  }).toList();
}); 