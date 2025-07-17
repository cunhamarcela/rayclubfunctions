// Dart imports:
import 'dart:io';

// Package imports:
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';
import 'package:ray_club_app/features/nutrition/models/meal.dart';
import 'package:ray_club_app/features/nutrition/repositories/meal_repository_interface.dart';
import 'package:ray_club_app/services/storage_service.dart';
import 'package:ray_club_app/utils/log_utils.dart';
import 'package:ray_club_app/utils/performance_monitor.dart';

/// Implementação do repositório de refeições usando Supabase
class SupabaseMealRepository implements MealRepository {
  final SupabaseClient _supabaseClient;
  final StorageService _storageService;
  
  /// Nome da tabela no banco de dados
  static const String _tableName = 'meals';
  
  /// Construtor do repositório
  SupabaseMealRepository({
    required SupabaseClient supabaseClient,
    required StorageService storageService,
  })  : _supabaseClient = supabaseClient,
        _storageService = storageService;
  
  @override
  Future<List<Meal>> getAllMeals() async {
    try {
      final response = await _supabaseClient
          .from(_tableName)
          .select()
          .order('meal_time', ascending: false);
      
      return response.map((json) => Meal.fromJson(json)).toList();
    } catch (e, stackTrace) {
      final error = _handleError(e, stackTrace, 'Erro ao buscar refeições');
      LogUtils.error(
        'Falha ao buscar todas as refeições',
        error: error,
        stackTrace: stackTrace,
        tag: 'SupabaseMealRepository',
      );
      throw error;
    }
  }
  
  @override
  Future<Meal?> getMealById(String id) async {
    try {
      final response = await _supabaseClient
          .from(_tableName)
          .select()
          .eq('id', id)
          .maybeSingle();
      
      if (response == null) {
        return null;
      }
      
      return Meal.fromJson(response);
    } catch (e, stackTrace) {
      final error = _handleError(e, stackTrace, 'Erro ao buscar refeição');
      LogUtils.error(
        'Falha ao buscar refeição por ID',
        error: error,
        stackTrace: stackTrace,
        tag: 'SupabaseMealRepository',
        data: {'id': id},
      );
      throw error;
    }
  }
  
  @override
  Future<List<Meal>> getMealsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      // Validar que as datas estão em ordem correta
      if (startDate.isAfter(endDate)) {
        throw ValidationException(
          message: 'Data inicial não pode ser posterior à data final',
          code: 'invalid_date_range',
        );
      }
    
      final response = await _supabaseClient
          .from(_tableName)
          .select()
          .gte('meal_time', startDate.toIso8601String())
          .lte('meal_time', endDate.toIso8601String())
          .order('meal_time');
      
      return response.map((json) => Meal.fromJson(json)).toList();
    } catch (e, stackTrace) {
      final error = _handleError(
        e,
        stackTrace,
        'Erro ao buscar refeições por período',
      );
      LogUtils.error(
        'Falha ao buscar refeições por período',
        error: error,
        stackTrace: stackTrace,
        tag: 'SupabaseMealRepository',
        data: {
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        },
      );
      throw error;
    }
  }
  
  @override
  Future<List<Meal>> getMealsByType(String type) async {
    try {
      final response = await _supabaseClient
          .from(_tableName)
          .select()
          .eq('meal_type', type)
          .order('meal_time', ascending: false);
      
      return response.map((json) => Meal.fromJson(json)).toList();
    } catch (e, stackTrace) {
      final error = _handleError(
        e,
        stackTrace,
        'Erro ao buscar refeições por tipo',
      );
      LogUtils.error(
        'Falha ao buscar refeições por tipo',
        error: error,
        stackTrace: stackTrace,
        tag: 'SupabaseMealRepository',
        data: {'type': type},
      );
      throw error;
    }
  }
  
  @override
  Future<Meal> saveMeal(Meal meal) async {
    try {
      // Validar valores numéricos
      if (meal.calories < 0) {
        throw ValidationException(
          message: 'Calorias não podem ser negativas',
          code: 'invalid_calories',
        );
      }
      
      if (meal.proteins < 0) {
        throw ValidationException(
          message: 'Proteínas não podem ser negativas',
          code: 'invalid_proteins',
        );
      }
      
      if (meal.carbs < 0) {
        throw ValidationException(
          message: 'Carboidratos não podem ser negativos',
          code: 'invalid_carbs',
        );
      }
      
      if (meal.fats < 0) {
        throw ValidationException(
          message: 'Gorduras não podem ser negativas',
          code: 'invalid_fats',
        );
      }
      
      // Garantir que user_id está definido como o usuário atual
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw AuthException(
          message: 'Usuário não autenticado',
          code: 'unauthenticated',
        );
      }
      
      final mealWithUserId = meal.copyWith(userId: userId);
      final isUpdate = meal.id != null;
      
      Map<String, dynamic> response;
      if (isUpdate) {
        // Atualizar refeição existente
        response = await _supabaseClient
            .from(_tableName)
            .update(mealWithUserId.toJson())
            .eq('id', meal.id)
            .select()
            .single();
      } else {
        // Criar nova refeição
        response = await _supabaseClient
            .from(_tableName)
            .insert(mealWithUserId.toJson())
            .select()
            .single();
      }
      
      return Meal.fromJson(response);
    } catch (e, stackTrace) {
      final error = _handleError(
        e,
        stackTrace,
        'Erro ao ${meal.id != null ? 'atualizar' : 'criar'} refeição',
      );
      LogUtils.error(
        'Falha ao salvar refeição',
        error: error,
        stackTrace: stackTrace,
        tag: 'SupabaseMealRepository',
        data: {'mealId': meal.id, 'isUpdate': meal.id != null},
      );
      throw error;
    }
  }
  
  @override
  Future<void> deleteMeal(String id) async {
    try {
      // Buscar a refeição para verificar se tem imagem
      final meal = await getMealById(id);
      
      // Excluir a refeição do banco
      await _supabaseClient.from(_tableName).delete().eq('id', id);
      
      // Se existir uma imagem, excluí-la
      if (meal?.imageUrl != null && meal!.imageUrl!.isNotEmpty) {
        final imagePath = _extractImagePathFromUrl(meal.imageUrl!);
        if (imagePath != null) {
          await _storageService.setBucket(StorageBucketType.mealImages);
          // Ignorar erro de exclusão de imagem para não interromper o fluxo
          try {
            await _storageService.deleteFile(imagePath);
          } catch (e) {
            LogUtils.warning(
              'Não foi possível excluir a imagem da refeição',
              tag: 'SupabaseMealRepository',
              data: {'mealId': id, 'imagePath': imagePath},
            );
          }
        }
      }
    } catch (e, stackTrace) {
      final error = _handleError(e, stackTrace, 'Erro ao excluir refeição');
      LogUtils.error(
        'Falha ao excluir refeição',
        error: error,
        stackTrace: stackTrace,
        tag: 'SupabaseMealRepository',
        data: {'id': id},
      );
      throw error;
    }
  }
  
  @override
  Future<void> toggleFavorite(String id, bool isFavorite) async {
    try {
      await _supabaseClient
          .from(_tableName)
          .update({'is_favorite': isFavorite})
          .eq('id', id);
    } catch (e, stackTrace) {
      final error = _handleError(
        e,
        stackTrace,
        'Erro ao ${isFavorite ? 'marcar' : 'desmarcar'} refeição como favorita',
      );
      LogUtils.error(
        'Falha ao alterar status de favorito da refeição',
        error: error,
        stackTrace: stackTrace,
        tag: 'SupabaseMealRepository',
        data: {'id': id, 'isFavorite': isFavorite},
      );
      throw error;
    }
  }
  
  @override
  Future<String> uploadMealImage(String mealId, String localImagePath) async {
    return PerformanceMonitor.trackAsync('meal_image_upload', () async {
      try {
        // Configurar bucket de imagens de refeições
        await _storageService.setBucket(StorageBucketType.mealImages);
        _storageService.setAccessPolicy(StorageAccessType.public);
        
        // Definir caminho da imagem no storage
        final file = File(localImagePath);
        final extension = localImagePath.split('.').last;
        final imagePath = 'meal_$mealId.$extension';
        
        // Fazer upload da imagem
        final imageUrl = await _storageService.uploadFile(
          file: file,
          path: imagePath,
        );
        
        // Atualizar URL da imagem na refeição
        await _supabaseClient
            .from(_tableName)
            .update({'image_url': imageUrl})
            .eq('id', mealId);
        
        return imageUrl;
      } catch (e, stackTrace) {
        final error = _handleError(e, stackTrace, 'Erro ao fazer upload de imagem');
        LogUtils.error(
          'Falha ao fazer upload de imagem para refeição',
          error: error,
          stackTrace: stackTrace,
          tag: 'SupabaseMealRepository',
          data: {'mealId': mealId, 'localImagePath': localImagePath},
        );
        throw error;
      }
    }, metadata: {'mealId': mealId, 'fileSize': File(localImagePath).lengthSync()});
  }
  
  @override
  Future<List<Meal>> getFavoriteMeals() async {
    try {
      final response = await _supabaseClient
          .from(_tableName)
          .select()
          .eq('is_favorite', true)
          .order('meal_time', ascending: false);
      
      return response.map((json) => Meal.fromJson(json)).toList();
    } catch (e, stackTrace) {
      final error = _handleError(e, stackTrace, 'Erro ao buscar refeições favoritas');
      LogUtils.error(
        'Falha ao buscar refeições favoritas',
        error: error,
        stackTrace: stackTrace,
        tag: 'SupabaseMealRepository',
      );
      throw error;
    }
  }
  
  @override
  Future<Map<String, dynamic>> getNutritionStats(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final meals = await getMealsByDateRange(startDate, endDate);
      
      // Calcular estatísticas de nutrição
      double totalCalories = 0;
      double totalProtein = 0;
      double totalCarbs = 0;
      double totalFat = 0;
      Map<String, int> mealTypeCounts = {};
      
      for (final meal in meals) {
        totalCalories += meal.calories ?? 0;
        totalProtein += meal.protein ?? 0;
        totalCarbs += meal.carbs ?? 0;
        totalFat += meal.fat ?? 0;
        
        if (meal.mealType != null) {
          mealTypeCounts[meal.mealType!] = (mealTypeCounts[meal.mealType!] ?? 0) + 1;
        }
      }
      
      return {
        'totalMeals': meals.length,
        'totalCalories': totalCalories,
        'totalProtein': totalProtein,
        'totalCarbs': totalCarbs,
        'totalFat': totalFat,
        'mealTypeCounts': mealTypeCounts,
        'avgCaloriesPerDay': meals.isEmpty
            ? 0
            : totalCalories / (endDate.difference(startDate).inDays + 1),
      };
    } catch (e, stackTrace) {
      final error = _handleError(
        e,
        stackTrace,
        'Erro ao calcular estatísticas de nutrição',
      );
      LogUtils.error(
        'Falha ao calcular estatísticas de nutrição',
        error: error,
        stackTrace: stackTrace,
        tag: 'SupabaseMealRepository',
        data: {
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        },
      );
      throw error;
    }
  }
  
  /// Função auxiliar para extrair o caminho da imagem de uma URL
  String? _extractImagePathFromUrl(String imageUrl) {
    try {
      // Exemplo: https://domain.com/storage/v1/object/public/bucket_name/path/to/image.jpg
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      
      // Encontrar o índice do bucket nas path segments
      int bucketIndex = -1;
      for (int i = 0; i < pathSegments.length; i++) {
        if (pathSegments[i] == 'public' && i + 1 < pathSegments.length) {
          bucketIndex = i + 1;
          break;
        }
      }
      
      if (bucketIndex >= 0 && bucketIndex + 1 < pathSegments.length) {
        // Pegar todos os segmentos após o bucket
        return pathSegments.sublist(bucketIndex + 1).join('/');
      }
      
      return null;
    } catch (e) {
      LogUtils.warning(
        'Erro ao extrair caminho da imagem da URL',
        tag: 'SupabaseMealRepository',
        data: {'imageUrl': imageUrl, 'error': e.toString()},
      );
      return null;
    }
  }
  
  /// Função auxiliar para tratar erros do Supabase
  AppException _handleError(Object error, StackTrace stackTrace, String message) {
    if (error is PostgrestException) {
      // Mapear erros específicos do Postgrest
      if (error.code == '23505') {
        return ValidationException(
          message: 'Refeição com esse nome já existe',
          originalError: error,
          stackTrace: stackTrace,
          code: 'duplicate_entry',
        );
      } else if (error.code == '23503') {
        return ValidationException(
          message: 'Referência inválida',
          originalError: error,
          stackTrace: stackTrace,
          code: 'invalid_reference',
        );
      }
      
      return StorageException(
        message: message,
        originalError: error,
        stackTrace: stackTrace,
        code: error.code,
      );
    } else if (error is AuthException) {
      return error;
    } else if (error is StorageException) {
      return error;
    } else if (error is ValidationException) {
      return error;
    }
    
    return AppException(
      message: message,
      originalError: error,
      stackTrace: stackTrace,
    );
  }
} 
