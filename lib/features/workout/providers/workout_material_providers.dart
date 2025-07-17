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