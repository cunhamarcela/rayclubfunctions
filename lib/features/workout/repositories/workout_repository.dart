// Package imports:
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart' as app_errors;
import 'package:ray_club_app/features/workout/models/workout_category.dart';
import 'package:ray_club_app/features/workout/models/workout_model.dart';
import 'package:ray_club_app/features/workout/models/exercise.dart';
import 'package:ray_club_app/features/workout/models/workout_record.dart';

/// Interface para o repositório de treinos
abstract class WorkoutRepository {
  /// Obtém todos os treinos
  Future<List<Workout>> getWorkouts();

  /// Obtém treinos por categoria
  Future<List<Workout>> getWorkoutsByCategory(String category);

  /// Obtém um treino específico pelo ID
  Future<Workout> getWorkoutById(String id);
  
  /// Cria um novo treino
  Future<Workout> createWorkout(Workout workout);
  
  /// Atualiza um treino existente
  Future<Workout> updateWorkout(Workout workout);
  
  /// Exclui um treino
  Future<void> deleteWorkout(String id);
  
  /// Obtém todas as categorias de treino
  Future<List<WorkoutCategory>> getWorkoutCategories();
  
  /// Obtém o histórico de treinos do usuário
  Future<List<WorkoutRecord>> getWorkoutHistory();
  
  /// Adiciona um novo registro de treino
  Future<WorkoutRecord> addWorkoutRecord(WorkoutRecord record);
  
  /// Atualiza um registro de treino existente
  Future<WorkoutRecord> updateWorkoutRecord(WorkoutRecord record);
  
  /// Exclui um registro de treino
  Future<void> deleteWorkoutRecord(String recordId);

  /// Buscar categoria por nome
  Future<WorkoutCategory?> getCategoryByName(String name);
}

/// Implementação mock do repositório para desenvolvimento
class MockWorkoutRepository implements WorkoutRepository {
  // Função auxiliar para gerar IDs únicos para exercícios
  String _generateExerciseId(String name) {
    // Converte o nome para um formato de ID, trocando espaços por traços e deixando em lowercase
    String baseId = name.toLowerCase().replaceAll(' ', '-');
    // Adiciona um timestamp para garantir unicidade
    return '$baseId-${DateTime.now().millisecondsSinceEpoch}';
  }

  // Função auxiliar para criar objetos Exercise com os campos obrigatórios
  Exercise _createExercise(String name, {
    String? id,
    String? description,
    int? sets,
    int? reps,
    int? duration,
    String? imageUrl,
    String? videoUrl,
  }) {
    return Exercise(
      id: id ?? _generateExerciseId(name),
      name: name,
      detail: description ?? '$name - Detalhes do exercício',
      description: description,
      sets: sets,
      reps: reps,
      duration: duration,
      imageUrl: imageUrl,
      videoUrl: videoUrl,
    );
  }

  @override
  Future<List<Workout>> getWorkouts() async {
    // Simulando um delay de rede
    await Future.delayed(const Duration(milliseconds: 800));
    
    try {
      return _getMockWorkouts();
    } catch (e) {
      throw app_errors.StorageException(
        message: 'Erro ao carregar treinos',
        originalError: e,
      );
    }
  }

  @override
  Future<List<WorkoutCategory>> getWorkoutCategories() async {
    // Simulando um delay de rede
    await Future.delayed(const Duration(milliseconds: 600));
    
    try {
      return _getMockCategories();
    } catch (e) {
      throw app_errors.StorageException(
        message: 'Erro ao carregar categorias de treino',
        originalError: e,
      );
    }
  }

  @override
  Future<List<Workout>> getWorkoutsByCategory(String category) async {
    // Simulando um delay de rede
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final allWorkouts = _getMockWorkouts();
      return allWorkouts
          .where((workout) => workout.type.toLowerCase() == category.toLowerCase())
          .toList();
    } catch (e) {
      throw app_errors.StorageException(
        message: 'Erro ao carregar treinos por categoria',
        originalError: e,
      );
    }
  }

  @override
  Future<Workout> getWorkoutById(String id) async {
    // Simulando um delay de rede
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      final allWorkouts = _getMockWorkouts();
      return allWorkouts.firstWhere(
        (workout) => workout.id == id,
        orElse: () => throw app_errors.NotFoundException(
          message: 'Treino não encontrado',
          code: 'workout_not_found',
        ),
      );
    } catch (e) {
      if (e is app_errors.NotFoundException) rethrow;
      
      throw app_errors.StorageException(
        message: 'Erro ao carregar treino',
        originalError: e,
      );
    }
  }
  
  @override
  Future<Workout> createWorkout(Workout workout) async {
    // Simulando um delay de rede
    await Future.delayed(const Duration(milliseconds: 1000));
    
    try {
      // Em um ambiente real, o ID seria gerado pelo backend
      return workout.copyWith(
        id: 'new-${DateTime.now().millisecondsSinceEpoch}',
        createdAt: DateTime.now(),
      );
    } catch (e) {
      throw app_errors.StorageException(
        message: 'Erro ao criar treino',
        originalError: e,
      );
    }
  }

  @override
  Future<Workout> updateWorkout(Workout workout) async {
    // Simulando um delay de rede
    await Future.delayed(const Duration(milliseconds: 800));
    
    try {
      // Verificar se o treino existe
      final allWorkouts = _getMockWorkouts();
      final exists = allWorkouts.any((w) => w.id == workout.id);
      
      if (!exists) {
        throw app_errors.NotFoundException(
          message: 'Treino não encontrado para atualização',
          code: 'workout_not_found',
        );
      }
      
      // Em um ambiente real, o updatedAt seria atualizado
      return workout.copyWith(updatedAt: DateTime.now());
    } catch (e) {
      if (e is app_errors.NotFoundException) rethrow;
      
      throw app_errors.StorageException(
        message: 'Erro ao atualizar treino',
        originalError: e,
      );
    }
  }

  @override
  Future<void> deleteWorkout(String id) async {
    // Simulando um delay de rede
    await Future.delayed(const Duration(milliseconds: 600));
    
    try {
      // Verificar se o treino existe
      final allWorkouts = _getMockWorkouts();
      final exists = allWorkouts.any((workout) => workout.id == id);
      
      if (!exists) {
        throw app_errors.NotFoundException(
          message: 'Treino não encontrado para exclusão',
          code: 'workout_not_found',
        );
      }
      
      // Em um ambiente real, o treino seria removido do banco de dados
      return;
    } catch (e) {
      if (e is app_errors.NotFoundException) rethrow;
      
      throw app_errors.StorageException(
        message: 'Erro ao excluir treino',
        originalError: e,
      );
    }
  }

  @override
  Future<List<WorkoutRecord>> getWorkoutHistory() async {
    // Simulando um delay de rede
    await Future.delayed(const Duration(milliseconds: 800));
    
    try {
      // Retorna uma lista simulada de registros de treino
      final now = DateTime.now();
      return [
        WorkoutRecord(
          id: '1',
          userId: 'user123',
          workoutId: '1',
          workoutName: 'Yoga para Iniciantes',
          workoutType: 'Yoga',
          date: now.subtract(const Duration(days: 1)),
          durationMinutes: 20,
          isCompleted: true,
          notes: 'Senti melhora na flexibilidade',
          createdAt: now.subtract(const Duration(days: 1)),
        ),
        WorkoutRecord(
          id: '2',
          userId: 'user123',
          workoutId: '4',
          workoutName: 'Treino de Força Total',
          workoutType: 'Força',
          date: now.subtract(const Duration(days: 3)),
          durationMinutes: 45,
          isCompleted: true,
          createdAt: now.subtract(const Duration(days: 3)),
        ),
      ];
    } catch (e) {
      throw app_errors.StorageException(
        message: 'Erro ao carregar histórico de treinos',
        originalError: e,
      );
    }
  }
  
  @override
  Future<WorkoutRecord> addWorkoutRecord(WorkoutRecord record) async {
    // Simulando um delay de rede
    await Future.delayed(const Duration(milliseconds: 1000));
    
    try {
      // Em um ambiente real, o ID seria gerado pelo backend
      return record.copyWith(
        id: 'new-${DateTime.now().millisecondsSinceEpoch}',
        createdAt: DateTime.now(),
      );
    } catch (e) {
      throw app_errors.StorageException(
        message: 'Erro ao adicionar registro de treino',
        originalError: e,
      );
    }
  }
  
  @override
  Future<WorkoutRecord> updateWorkoutRecord(WorkoutRecord record) async {
    // Simulando um delay de rede
    await Future.delayed(const Duration(milliseconds: 800));
    
    try {
      // Em um ambiente real, verificaríamos se o registro existe
      return record;
    } catch (e) {
      throw app_errors.StorageException(
        message: 'Erro ao atualizar registro de treino',
        originalError: e,
      );
    }
  }
  
  @override
  Future<void> deleteWorkoutRecord(String recordId) async {
    // Simulando um delay de rede
    await Future.delayed(const Duration(milliseconds: 600));
    
    try {
      // Em um ambiente real, verificaríamos se o registro existe
      return;
    } catch (e) {
      throw app_errors.StorageException(
        message: 'Erro ao excluir registro de treino',
        originalError: e,
      );
    }
  }

  @override
  Future<WorkoutCategory?> getCategoryByName(String name) async {
    // Simulando um delay de rede
    await Future.delayed(const Duration(milliseconds: 300));
    
    try {
      final categories = _getMockCategories();
      
      // Buscar categoria por nome (case insensitive)
      final category = categories.firstWhere(
        (cat) => cat.name.toLowerCase() == name.toLowerCase(),
        orElse: () => throw app_errors.NotFoundException(
          message: 'Categoria não encontrada',
          code: 'category_not_found',
        ),
      );
      
      return category;
    } catch (e) {
      if (e is app_errors.NotFoundException) {
        // Retornar null se não encontrar
        return null;
      }
      
      throw app_errors.StorageException(
        message: 'Erro ao buscar categoria por nome',
        originalError: e,
      );
    }
  }

  // TEMPORÁRIO: Método para gerar dados mockados
  List<Workout> _getMockWorkouts() {
    final now = DateTime.now();
    
    return [
      Workout(
        id: '1',
        title: 'Yoga para Iniciantes',
        description: 'Um treino de yoga suave para quem está começando a praticar.',
        imageUrl: 'assets/images/categories/yoga.png',
        type: 'Yoga',
        durationMinutes: 20,
        difficulty: 'Iniciante',
        equipment: ['Tapete', 'Bloco de yoga'],
        sections: [
          WorkoutSection(
            name: 'Aquecimento',
            exercises: [
              _createExercise('Respiração profunda', description: 'Respiração lenta e profunda para relaxar'),
              _createExercise('Alongamento leve', description: 'Alongamento suave para preparar o corpo'),
            ],
          ),
          WorkoutSection(
            name: 'Parte principal',
            exercises: [
              _createExercise('Postura do cachorro olhando para baixo'),
              _createExercise('Postura da montanha'),
              _createExercise('Postura da árvore'),
            ],
          ),
          WorkoutSection(
            name: 'Finalização',
            exercises: [
              _createExercise('Relaxamento final'),
            ],
          ),
        ],
        creatorId: 'instrutor1',
        createdAt: now.subtract(const Duration(days: 10)),
      ),
      Workout(
        id: '2',
        title: 'Pilates Abdominal',
        description: 'Treino focado no fortalecimento do core e abdômen usando técnicas de pilates.',
        imageUrl: 'assets/images/categories/pilates.png',
        type: 'Pilates',
        durationMinutes: 30,
        difficulty: 'Intermediário',
        equipment: ['Tapete', 'Bola pequena'],
        sections: [
          WorkoutSection(
            name: 'Aquecimento',
            exercises: [
              Exercise(
                id: 'pilates-breathing',
                name: 'Respiração de pilates',
                detail: '3 séries'),
              Exercise(
                id: 'spine-mobility',
                name: 'Mobilidade de coluna',
                detail: '8-10 repetições'),
            ],
          ),
          WorkoutSection(
            name: 'Parte principal',
            exercises: [
              Exercise(
                id: 'hundred',
                name: 'The hundred',
                detail: '100 batidas de braço'),
              Exercise(
                id: 'single-leg-stretch',
                name: 'Single leg stretch',
                detail: '10 repetições cada lado'),
              Exercise(
                id: 'double-leg-stretch',
                name: 'Double leg stretch',
                detail: '10 repetições'),
              Exercise(
                id: 'criss-cross',
                name: 'Criss cross',
                detail: '10 repetições cada lado'),
            ],
          ),
          WorkoutSection(
            name: 'Finalização',
            exercises: [
              Exercise(
                id: 'spine-stretch',
                name: 'Spine stretch forward',
                detail: '8 repetições'),
            ],
          ),
        ],
        creatorId: 'instrutor2',
        createdAt: now.subtract(const Duration(days: 7)),
      ),
      Workout(
        id: '3',
        title: 'HIIT 15 minutos',
        description: 'Treino de alta intensidade para queimar calorias em pouco tempo.',
        imageUrl: 'assets/images/workout_default.jpg',
        type: 'HIIT',
        durationMinutes: 15,
        difficulty: 'Avançado',
        equipment: ['Tapete'],
        sections: [
          WorkoutSection(
            name: 'Aquecimento',
            exercises: [
              Exercise(
                id: 'jumping-jacks',
                name: 'Jumping jacks',
                detail: '30 segundos'),
              Exercise(
                id: 'running-in-place',
                name: 'Corrida no lugar',
                detail: '45 segundos'),
            ],
          ),
          WorkoutSection(
            name: 'Parte principal',
            exercises: [
              Exercise(
                id: 'burpees',
                name: 'Burpees',
                detail: '10 repetições'),
              Exercise(
                id: 'mountain-climbers',
                name: 'Mountain climbers',
                detail: '30 segundos'),
              Exercise(
                id: 'jumping-squats',
                name: 'Jumping squats',
                detail: '12 repetições'),
              Exercise(
                id: 'push-ups',
                name: 'Push-ups',
                detail: '8-10 repetições'),
            ],
          ),
          WorkoutSection(
            name: 'Finalização',
            exercises: [
              Exercise(
                id: 'general-stretching',
                name: 'Alongamentos gerais',
                detail: '5 minutos'),
            ],
          ),
        ],
        creatorId: 'instrutor3',
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      Workout(
        id: '4',
        title: 'Treino de Força Total',
        description: 'Treino completo para ganho de força muscular em todo o corpo.',
        imageUrl: 'assets/images/categories/musculacao.jpg',
        type: 'Musculação',
        durationMinutes: 45,
        difficulty: 'Intermediário',
        equipment: ['Halteres', 'Banco'],
        sections: [
          WorkoutSection(
            name: 'Aquecimento',
            exercises: [
              Exercise(
                id: 'joint-mobility',
                name: 'Mobilidade articular',
                detail: '2 minutos'),
              Exercise(
                id: 'muscle-activation',
                name: 'Ativação muscular',
                detail: '2 minutos'),
            ],
          ),
          WorkoutSection(
            name: 'Parte principal',
            exercises: [
              Exercise(
                id: 'weighted-squat',
                name: 'Agachamento com peso',
                detail: '3 séries de 12 repetições'),
              Exercise(
                id: 'dumbbell-bench-press',
                name: 'Supino com halteres',
                detail: '3 séries de 10 repetições'),
              Exercise(
                id: 'rowing',
                name: 'Remada',
                detail: '3 séries de 12 repetições'),
              Exercise(
                id: 'lateral-raise',
                name: 'Elevação lateral',
                detail: '3 séries de 15 repetições'),
            ],
          ),
          WorkoutSection(
            name: 'Finalização',
            exercises: [
              Exercise(
                id: 'chest-stretch',
                name: 'Alongamento de peito',
                detail: '30 segundos cada lado'),
              Exercise(
                id: 'back-stretch',
                name: 'Alongamento de costas',
                detail: '30 segundos'),
              Exercise(
                id: 'leg-stretch',
                name: 'Alongamento de pernas',
                detail: '30 segundos cada perna'),
            ],
          ),
        ],
        creatorId: 'instrutor4',
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      Workout(
        id: '5',
        title: 'Yoga Flow',
        description: 'Sequência fluida de posturas de yoga para melhorar flexibilidade e equilíbrio.',
        imageUrl: 'assets/images/categories/yoga.png',
        type: 'Yoga',
        durationMinutes: 40,
        difficulty: 'Intermediário',
        equipment: ['Tapete', 'Bloco de yoga'],
        sections: [
          WorkoutSection(
            name: 'Aquecimento',
            exercises: [
              Exercise(
                id: 'sun-salutation-a',
                name: 'Saudação ao sol A',
                detail: '3 ciclos completos'),
              Exercise(
                id: 'sun-salutation-b',
                name: 'Saudação ao sol B',
                detail: '3 ciclos completos'),
            ],
          ),
          WorkoutSection(
            name: 'Parte principal',
            exercises: [
              Exercise(
                id: 'warrior-1',
                name: 'Guerreiro I',
                detail: '5 respirações cada lado'),
              Exercise(
                id: 'warrior-2',
                name: 'Guerreiro II',
                detail: '5 respirações cada lado'),
              Exercise(
                id: 'triangle',
                name: 'Triângulo',
                detail: '5 respirações cada lado'),
              Exercise(
                id: 'half-moon',
                name: 'Meia lua',
                detail: '3 respirações cada lado'),
            ],
          ),
          WorkoutSection(
            name: 'Finalização',
            exercises: [
              Exercise(
                id: 'child-pose',
                name: 'Postura da criança',
                detail: '1 minuto'),
              Exercise(
                id: 'savasana',
                name: 'Savasana',
                detail: '5 minutos'),
            ],
          ),
        ],
        creatorId: 'instrutor1',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      Workout(
        id: '6',
        title: 'HIIT para Iniciantes',
        description: 'Versão mais acessível de HIIT para quem está começando.',
        imageUrl: 'assets/images/workout_default.jpg',
        type: 'HIIT',
        durationMinutes: 20,
        difficulty: 'Iniciante',
        equipment: ['Tapete', 'Garrafa de água como peso'],
        sections: [
          WorkoutSection(
            name: 'Aquecimento',
            exercises: [
              Exercise(
                id: 'marching-in-place',
                name: 'Marcha no lugar',
                detail: '1 minuto'),
              Exercise(
                id: 'trunk-rotation',
                name: 'Rotação de tronco',
                detail: '30 segundos cada lado'),
            ],
          ),
          WorkoutSection(
            name: 'Parte principal',
            exercises: [
              Exercise(
                id: 'simple-squat',
                name: 'Agachamento simples',
                detail: '12 repetições'),
              Exercise(
                id: 'plank',
                name: 'Prancha',
                detail: '30 segundos'),
              Exercise(
                id: 'knee-raise',
                name: 'Elevação de joelhos',
                detail: '15 repetições cada lado'),
              Exercise(
                id: 'modified-pushup',
                name: 'Flexão modificada',
                detail: '8 repetições'),
            ],
          ),
          WorkoutSection(
            name: 'Finalização',
            exercises: [
              Exercise(
                id: 'quad-stretch',
                name: 'Alongamento de quadríceps',
                detail: '30 segundos cada perna'),
              Exercise(
                id: 'calf-stretch',
                name: 'Alongamento de panturrilhas',
                detail: '30 segundos cada perna'),
            ],
          ),
        ],
        creatorId: 'instrutor3',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  }

  // TEMPORÁRIO: Método para gerar categorias mockadas
  List<WorkoutCategory> _getMockCategories() {
    // Categorias permitidas após remoção das duplicadas (Cardio, Yoga, HIIT)
    return [
      const WorkoutCategory(
        id: 'category-2',
        name: 'Força',
        description: 'Treinos para desenvolver força muscular e resistência',
        imageUrl: 'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?q=80&w=1000',
        workoutsCount: 12,
        colorHex: '#4285F4',
      ),
      const WorkoutCategory(
        id: 'category-4',
        name: 'Pilates',
        description: 'Treinos focados no core para melhorar postura e força',
        imageUrl: 'https://images.unsplash.com/photo-1518611012118-696072aa579a?q=80&w=1000',
        workoutsCount: 5,
        colorHex: '#009688',
      ),
      const WorkoutCategory(
        id: 'category-6',
        name: 'Alongamento',
        description: 'Treinos para melhorar flexibilidade e recuperação muscular',
        imageUrl: 'https://images.unsplash.com/photo-1616699002805-0741e1e4a9c5?q=80&w=1000',
        workoutsCount: 4,
        colorHex: '#4CAF50',
      ),
      // Categorias dos parceiros (sem duplicação)
      const WorkoutCategory(
        id: 'category-7',
        name: 'Musculação',
        description: 'Treinos de musculação para fortalecimento e definição muscular',
        imageUrl: 'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?q=80&w=1000',
        workoutsCount: 5, // Atualizando para refletir os vídeos corretos
        colorHex: '#2E8B57',
      ),
      const WorkoutCategory(
        id: 'category-8',
        name: 'Funcional',
        description: 'Treinos funcionais com movimentos naturais do corpo',
        imageUrl: 'https://images.unsplash.com/photo-1571019613540-996a69c9aecc?q=80&w=1000',
        workoutsCount: 9, // Atualizando para refletir os vídeos corretos
        colorHex: '#E74C3C',
      ),
      const WorkoutCategory(
        id: 'category-9',
        name: 'Corrida',
        description: 'Treinos e orientações para corrida e running',
        imageUrl: 'https://images.unsplash.com/photo-1486218119243-13883505764c?q=80&w=1000',
        workoutsCount: 3,
        colorHex: '#3498DB',
      ),
      const WorkoutCategory(
        id: 'category-10',
        name: 'Fisioterapia',
        description: 'Exercícios terapêuticos e de reabilitação',
        imageUrl: 'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?q=80&w=1000',
        workoutsCount: 4,
        colorHex: '#9B59B6',
      ),
    ];
  }
}

/// Implementação real do repositório de treinos usando Supabase
class SupabaseWorkoutRepository implements WorkoutRepository {
  final SupabaseClient _supabaseClient;
  
  SupabaseWorkoutRepository(this._supabaseClient);
  
  @override
  Future<List<Workout>> getWorkouts() async {
    try {
      final response = await _supabaseClient
          .from('workouts')
          .select()
          .order('created_at', ascending: false);
          
      return (response as List<dynamic>)
          .map((data) => _mapToWorkout(data as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw app_errors.DatabaseException(
        message: 'Erro ao carregar treinos do Supabase',
        originalError: e,
        code: e.code,
      );
    } catch (e) {
      throw app_errors.StorageException(
        message: 'Erro ao carregar treinos',
        originalError: e,
      );
    }
  }

  @override
  Future<List<WorkoutCategory>> getWorkoutCategories() async {
    try {
      print('🔍 SupabaseWorkoutRepository.getWorkoutCategories: Iniciando busca...');
      
      final response = await _supabaseClient
          .from('workout_categories')
          .select()
          .order('order', ascending: true);
      
      print('🔍 Response type: ${response.runtimeType}');
      print('🔍 Response: $response');
      
      if (response == null) {
        print('⚠️ Response é null');
        return [];
      }
      
      final allCategories = (response as List<dynamic>)
          .map((data) {
            print('🔍 Processando categoria raw: $data');
            return WorkoutCategory.fromJson(data as Map<String, dynamic>);
          })
          .toList();
      
      // Filtrar categorias indesejadas (Cardio, Yoga, HIIT) conforme solicitado
      final categoriesToExclude = ['cardio', 'yoga', 'hiit'];
      final filteredCategories = allCategories.where((category) {
        final shouldExclude = categoriesToExclude.contains(category.name.toLowerCase());
        if (shouldExclude) {
          print('🚫 Excluindo categoria da interface: ${category.name}');
        }
        return !shouldExclude;
      }).toList();
      
      // Remover duplicatas baseado no nome (case-insensitive)
      final uniqueCategories = <String, WorkoutCategory>{};
      for (final category in filteredCategories) {
        final key = category.name.toLowerCase();
        if (!uniqueCategories.containsKey(key)) {
          uniqueCategories[key] = category;
          print('✅ Categoria única adicionada: ${category.name}');
        } else {
          print('🔄 Categoria duplicada ignorada: ${category.name}');
        }
      }
      
      final finalCategories = uniqueCategories.values.toList();
      print('✅ Categorias carregadas: ${finalCategories.length}');
      return finalCategories;
    } on PostgrestException catch (e) {
      print('❌ PostgrestException: ${e.message}, code: ${e.code}');
      throw app_errors.DatabaseException(
        message: 'Erro ao carregar categorias de treino do Supabase',
        originalError: e,
        code: e.code,
      );
    } catch (e) {
      print('❌ Erro genérico: $e');
      print('❌ Stack trace: ${StackTrace.current}');
      throw app_errors.StorageException(
        message: 'Erro ao carregar categorias de treino',
        originalError: e,
      );
    }
  }

  @override
  Future<List<Workout>> getWorkoutsByCategory(String category) async {
    try {
      final response = await _supabaseClient
          .from('workouts')
          .select()
          .eq('type', category)
          .order('created_at', ascending: false);
          
      return (response as List<dynamic>)
          .map((data) => _mapToWorkout(data as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw app_errors.DatabaseException(
        message: 'Erro ao carregar treinos por categoria do Supabase',
        originalError: e,
        code: e.code,
      );
    } catch (e) {
      throw app_errors.StorageException(
        message: 'Erro ao carregar treinos por categoria',
        originalError: e,
      );
    }
  }

  @override
  Future<Workout> getWorkoutById(String id) async {
    try {
      final response = await _supabaseClient
          .from('workouts')
          .select()
          .eq('id', id)
          .single();
          
      return _mapToWorkout(response as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw app_errors.NotFoundException(
          message: 'Treino não encontrado',
          code: 'workout_not_found',
        );
      }
      throw app_errors.DatabaseException(
        message: 'Erro ao carregar treino do Supabase',
        originalError: e,
        code: e.code,
      );
    } catch (e) {
      throw app_errors.StorageException(
        message: 'Erro ao carregar treino',
        originalError: e,
      );
    }
  }
  
  @override
  Future<Workout> createWorkout(Workout workout) async {
    try {
      final workoutJson = workout.toJson();
      // Remover o ID se for criar um novo
      workoutJson.remove('id');
      
      final response = await _supabaseClient
          .from('workouts')
          .insert(workoutJson)
          .select()
          .single();
          
      return _mapToWorkout(response as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      throw app_errors.DatabaseException(
        message: 'Erro ao criar treino no Supabase',
        originalError: e,
        code: e.code,
      );
    } catch (e) {
      throw app_errors.StorageException(
        message: 'Erro ao criar treino',
        originalError: e,
      );
    }
  }

  @override
  Future<Workout> updateWorkout(Workout workout) async {
    try {
      final workoutJson = workout.toJson();
      
      final response = await _supabaseClient
          .from('workouts')
          .update(workoutJson)
          .eq('id', workout.id)
          .select()
          .single();
          
      return _mapToWorkout(response as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw app_errors.NotFoundException(
          message: 'Treino não encontrado para atualização',
          code: 'workout_not_found',
        );
      }
      throw app_errors.DatabaseException(
        message: 'Erro ao atualizar treino no Supabase',
        originalError: e,
        code: e.code,
      );
    } catch (e) {
      throw app_errors.StorageException(
        message: 'Erro ao atualizar treino',
        originalError: e,
      );
    }
  }
  
  @override
  Future<void> deleteWorkout(String id) async {
    try {
      await _supabaseClient.from('workouts').delete().eq('id', id);
    } catch (e) {
      throw app_errors.DatabaseException(
        message: 'Erro ao excluir treino',
        originalError: e,
      );
    }
  }

  // Métodos auxiliares para converter dados do Supabase
  Workout _mapToWorkout(Map<String, dynamic> data) {
    // Ajusta o mapeamento para funcionar com as colunas vistas nas imagens
    // Verifica o nome das colunas e usa o equivalente com fallback
    final title = data['title'] as String? ?? data['name'] as String? ?? '';
    final type = data['type'] as String? ?? data['category'] as String? ?? '';
    final imageUrl = data['image_url'] as String? ?? data['imageUrl'] as String? ?? 'assets/images/workout_default.jpg';
    final difficulty = data['difficulty'] as String? ?? data['level'] as String? ?? 'Intermediário';
    final level = data['level'] as String?;
    
    return Workout(
      id: data['id'] as String,
      title: title,
      description: data['description'] as String? ?? '',
      imageUrl: imageUrl,
      type: type,
      durationMinutes: data['duration_minutes'] as int? ?? 30,
      difficulty: difficulty,
      level: level,
      equipment: _parseList(data['equipment']),
      sections: _parseSections(data['sections']),
      creatorId: data['creator_id'] as String? ?? '',
      createdAt: data['created_at'] != null 
          ? DateTime.parse(data['created_at'] as String) 
          : DateTime.now(),
    );
  }
  
  List<String> _parseList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e.toString()).toList();
    if (value is Map) {
      try {
        final list = value.values.toList();
        return list.map((e) => e.toString()).toList();
      } catch (_) {
        return [];
      }
    }
    return [];
  }
  
  List<WorkoutSection> _parseSections(dynamic sectionsData) {
    if (sectionsData == null) return [];
    
    try {
      final sections = <WorkoutSection>[];
      final List<dynamic> sectionsList = sectionsData is String 
          ? jsonDecode(sectionsData) as List<dynamic>
          : sectionsData as List<dynamic>;
          
      for (final section in sectionsList) {
        final exercises = <Exercise>[];
        final exercisesData = section['exercises'] as List<dynamic>? ?? [];
        
        for (final exerciseData in exercisesData) {
          // Ajuste para permitir campos variados do banco de dados
          final id = exerciseData['id'] as String? ?? 
              'exercise-${DateTime.now().millisecondsSinceEpoch}-${exercises.length}';
          
          final name = exerciseData['name'] as String? ?? 
              exerciseData['nome'] as String? ?? 
              'Exercício ${exercises.length + 1}';
              
          final detail = exerciseData['detail'] as String? ?? 
              exerciseData['detalhe'] as String? ?? 
              exerciseData['description'] as String? ?? 
              name;
              
          final description = exerciseData['description'] as String? ?? 
              exerciseData['descricao'] as String? ?? 
              null;
              
          final sets = exerciseData['sets'] as int? ?? 
              exerciseData['series'] as int? ?? 
              3;
              
          final reps = exerciseData['reps'] as int? ?? 
              exerciseData['repetitions'] as int? ?? 
              exerciseData['repeticoes'] as int? ?? 
              12;
              
          final restTime = exerciseData['rest_seconds'] as int? ?? 
              exerciseData['restTime'] as int? ?? 
              exerciseData['tempo_descanso'] as int? ?? 
              60;
              
          final imageUrl = exerciseData['image_url'] as String? ?? 
              exerciseData['imageUrl'] as String? ?? 
              exerciseData['url_imagem'] as String?;
              
          final videoUrl = exerciseData['video_url'] as String? ?? 
              exerciseData['videoUrl'] as String? ?? 
              exerciseData['url_video'] as String?;
          
          exercises.add(Exercise(
            id: id,
            name: name,
            detail: detail,
            description: description,
            sets: sets,
            reps: reps,
            restTime: restTime,
            imageUrl: imageUrl,
            videoUrl: videoUrl,
          ));
        }
        
        sections.add(WorkoutSection(
          name: section['name'] as String? ?? section['nome'] as String? ?? 'Seção ${sections.length + 1}',
          exercises: exercises,
        ));
      }
      
      return sections;
    } catch (e) {
      print('Erro ao analisar seções: $e');
      return [];
    }
  }

  @override
  Future<List<WorkoutRecord>> getWorkoutHistory() async {
    try {
      // Obter usuário atual
      final currentUser = _supabaseClient.auth.currentUser;
      if (currentUser == null) {
        throw app_errors.AuthException(message: 'Usuário não autenticado');
      }
      
      // Buscar registros de treino do usuário
      final response = await _supabaseClient
          .from('workout_records')
          .select()
          .eq('user_id', currentUser.id)
          .order('date', ascending: false);
      
      // Converter para objetos WorkoutRecord
      return (response as List<dynamic>)
          .map((data) => _mapToWorkoutRecord(data as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw app_errors.DatabaseException(
        message: 'Erro ao carregar histórico de treinos',
        originalError: e,
        code: e.code,
      );
    } catch (e) {
      throw app_errors.StorageException(
        message: 'Erro ao carregar histórico de treinos',
        originalError: e,
      );
    }
  }

  @override
  Future<WorkoutRecord> addWorkoutRecord(WorkoutRecord record) async {
    try {
      // Obter usuário atual
      final currentUser = _supabaseClient.auth.currentUser;
      if (currentUser == null) {
        throw app_errors.AuthException(message: 'Usuário não autenticado');
      }
      
      // Preparar dados para inserção no formato do banco
      final recordData = _mapWorkoutRecordToDatabase(record);
      
      // Garantir que o usuário só pode inserir registros para si mesmo
      recordData['user_id'] = currentUser.id;
      
      // Inserir o registro
      final response = await _supabaseClient
          .from('workout_records')
          .insert(recordData)
          .select()
          .single();
      
      // Retornar o registro inserido com ID e outros campos preenchidos
      return _mapToWorkoutRecord(response as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      throw app_errors.DatabaseException(
        message: 'Erro ao adicionar registro de treino',
        originalError: e,
        code: e.code,
      );
    } catch (e) {
      throw app_errors.StorageException(
        message: 'Erro ao adicionar registro de treino',
        originalError: e,
      );
    }
  }

  @override
  Future<WorkoutRecord> updateWorkoutRecord(WorkoutRecord record) async {
    try {
      // Obter usuário atual
      final currentUser = _supabaseClient.auth.currentUser;
      if (currentUser == null) {
        throw app_errors.AuthException(message: 'Usuário não autenticado');
      }
      
      // Verificar se o registro existe e pertence ao usuário
      final exists = await _supabaseClient
          .from('workout_records')
          .select('id')
          .eq('id', record.id)
          .eq('user_id', currentUser.id)
          .maybeSingle();
      
      if (exists == null) {
        throw app_errors.NotFoundException(
          message: 'Registro de treino não encontrado ou não pertence ao usuário',
          code: 'workout_record_not_found',
        );
      }
      
      // Preparar dados para atualização
      final recordData = _mapWorkoutRecordToDatabase(record);
      
      // Atualizar o registro
      final response = await _supabaseClient
          .from('workout_records')
          .update(recordData)
          .eq('id', record.id)
          .eq('user_id', currentUser.id)
          .select()
          .single();
      
      // Retornar o registro atualizado
      return _mapToWorkoutRecord(response as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      throw app_errors.DatabaseException(
        message: 'Erro ao atualizar registro de treino',
        originalError: e,
        code: e.code,
      );
    } catch (e) {
      if (e is app_errors.NotFoundException) rethrow;
      
      throw app_errors.StorageException(
        message: 'Erro ao atualizar registro de treino',
        originalError: e,
      );
    }
  }

  @override
  Future<void> deleteWorkoutRecord(String recordId) async {
    try {
      // Obter usuário atual
      final currentUser = _supabaseClient.auth.currentUser;
      if (currentUser == null) {
        throw app_errors.AuthException(message: 'Usuário não autenticado');
      }
      
      // Excluir o registro, garantindo que pertence ao usuário correto
      final response = await _supabaseClient
          .from('workout_records')
          .delete()
          .eq('id', recordId)
          .eq('user_id', currentUser.id);
      
    } on PostgrestException catch (e) {
      throw app_errors.DatabaseException(
        message: 'Erro ao excluir registro de treino',
        originalError: e,
        code: e.code,
      );
    } catch (e) {
      throw app_errors.StorageException(
        message: 'Erro ao excluir registro de treino',
        originalError: e,
      );
    }
  }
  
  // Método auxiliar para converter Map do banco para WorkoutRecord
  WorkoutRecord _mapToWorkoutRecord(Map<String, dynamic> data) {
    // Converter snake_case para camelCase
    return WorkoutRecord(
      id: data['id'] as String,
      userId: data['user_id'] as String,
      workoutId: data['workout_id'] as String?,
      workoutName: data['workout_name'] as String,
      workoutType: data['workout_type'] as String,
      date: DateTime.parse(data['date'] as String),
      durationMinutes: (data['duration_minutes'] as num).toInt(),
      isCompleted: data['is_completed'] as bool? ?? true,
      completionStatus: data['completion_status'] as String? ?? 'completed',
      notes: data['notes'] as String?,
      imageUrls: data['image_urls'] != null 
          ? (data['image_urls'] as List<dynamic>).cast<String>() 
          : [],
      createdAt: data['created_at'] != null 
          ? DateTime.parse(data['created_at'] as String) 
          : null,
    );
  }
  
  // Método auxiliar para converter WorkoutRecord para Map para o banco
  Map<String, dynamic> _mapWorkoutRecordToDatabase(WorkoutRecord record) {
    // Converter camelCase para snake_case para o banco
    final Map<String, dynamic> data = {
      'user_id': record.userId,
      'workout_name': record.workoutName,
      'workout_type': record.workoutType,
      'date': record.date.toIso8601String(),
      'duration_minutes': record.durationMinutes,
      'is_completed': record.isCompleted,
      'completion_status': record.completionStatus,
      'image_urls': record.imageUrls,
      'updated_at': DateTime.now().toIso8601String(),
    };
    
    // Adicionar campos opcionais se não forem nulos
    if (record.workoutId != null) data['workout_id'] = record.workoutId;
    if (record.notes != null) data['notes'] = record.notes;
    
    // Não incluir id se for um novo registro (será gerado pelo banco)
    if (record.id.isNotEmpty && !record.id.contains('temp_')) {
      data['id'] = record.id;
    }
    
    return data;
  }

  // Buscar categoria por nome
  @override
  Future<WorkoutCategory?> getCategoryByName(String name) async {
    try {
      final response = await _supabaseClient
          .from('workout_categories')
          .select()
          .ilike('name', name)
          .maybeSingle();

      if (response == null) return null;
      
      return WorkoutCategory.fromJson(response as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      throw app_errors.DatabaseException(
        message: 'Erro ao buscar categoria por nome',
        originalError: e,
        code: e.code,
      );
    } catch (e) {
      throw app_errors.StorageException(
        message: 'Erro ao buscar categoria por nome',
        originalError: e,
      );
    }
  }
}

// O provider workoutRepositoryProvider foi movido para lib/features/workout/providers/workout_providers.dart
// Referência à implementação real sem definir o provider diretamente aqui
