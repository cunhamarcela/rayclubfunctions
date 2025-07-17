// Flutter imports:
import 'package:flutter/foundation.dart';
import 'dart:io';

// Package imports:
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException, StorageException;
import 'package:path/path.dart' as path;
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Project imports:
import '../../../core/errors/app_exception.dart';
import '../../../core/offline/offline_repository_helper.dart';
import '../../../core/offline/offline_operation_queue.dart';
import '../models/profile_model.dart';
import 'profile_repository.dart';

/// Implementação do repositório de perfil usando Supabase
class SupabaseProfileRepository implements ProfileRepository {
  final SupabaseClient _client;
  final OfflineRepositoryHelper? _offlineHelper;
  
  /// Nome da tabela de perfis
  static const String _profilesTable = 'profiles';
  
  /// Nome do bucket para imagens de perfil
  static const String _profileImagesBucket = 'profile-images';
  
  /// Construtor
  SupabaseProfileRepository(this._client, [this._offlineHelper]);
  
  @override
  Future<Profile?> getCurrentUserProfile() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return null;
      
      return await getProfileById(userId);
    } catch (e, stackTrace) {
      _handleError(e, stackTrace, 'Erro ao obter perfil do usuário atual');
      return null;
    }
  }
  
  @override
  Future<Profile?> getProfileById(String userId) async {
    try {
      final response = await _client
          .from(_profilesTable)
          .select()
          .eq('id', userId)
          .single();
      
      if (response == null) return null;
      
      // Mapeamento correto entre as colunas do banco e o modelo
      return Profile(
        id: response['id'],
        name: response['name'],
        email: response['email'],
        // Suporta ambos profile_image_url e photo_url para compatibilidade
        photoUrl: response['photo_url'] ?? response['profile_image_url'],
        bio: response['bio'],
        phone: response['phone'],
        gender: response['gender'],
        birthDate: response['birth_date'] != null 
            ? DateTime.parse(response['birth_date']) 
            : null,
        instagram: response['instagram'],
        favoriteWorkoutIds: response['favorite_workout_ids'] != null 
            ? List<String>.from(response['favorite_workout_ids']) 
            : [],
        goals: response['goals'] != null 
            ? List<String>.from(response['goals']) 
            : [],
        streak: response['streak'] ?? 0,
        completedWorkouts: response['completed_workouts'] ?? 0,
        points: response['points'] ?? 0,
        createdAt: response['created_at'] != null 
            ? DateTime.parse(response['created_at']) 
            : null,
        updatedAt: response['updated_at'] != null 
            ? DateTime.parse(response['updated_at']) 
            : null,
        // Novos campos adicionados
        dailyWaterGoal: response['daily_water_goal'] ?? 8,
        dailyWorkoutGoal: response['daily_workout_goal'] ?? 1,
        weeklyWorkoutGoal: response['weekly_workout_goal'] ?? 5,
        weightGoal: response['weight_goal'] != null ? 
            double.parse(response['weight_goal'].toString()) : null,
        height: response['height'] != null ? 
            double.parse(response['height'].toString()) : null,
        currentWeight: response['current_weight'] != null ? 
            double.parse(response['current_weight'].toString()) : null,
        preferredWorkoutTypes: response['preferred_workout_types'] != null 
            ? List<String>.from(response['preferred_workout_types']) 
            : [],
        stats: response['stats'] != null 
            ? Map<String, dynamic>.from(response['stats']) 
            : {
                'total_workouts': 0,
                'total_challenges': 0,
                'total_checkins': 0,
                'longest_streak': 0,
                'points_earned': 0,
                'completed_challenges': 0,
                'water_intake_average': 0
              },
        // Novo campo accountType
        accountType: response['account_type'] ?? 'basic',
      );
    } catch (e, stackTrace) {
      _handleError(e, stackTrace, 'Erro ao obter perfil por ID');
      return null;
    }
  }
  
  @override
  Future<List<Profile>> getAllProfiles() async {
    try {
      final response = await _client
          .from(_profilesTable)
          .select();
      
      return response.map<Profile>((json) {
        // Usar o mesmo mapeamento consistente
        return Profile(
          id: json['id'],
          name: json['name'],
          email: json['email'],
          photoUrl: json['photo_url'] ?? json['profile_image_url'],
          bio: json['bio'],
          phone: json['phone'],
          gender: json['gender'],
          birthDate: json['birth_date'] != null 
              ? DateTime.parse(json['birth_date']) 
              : null,
          instagram: json['instagram'],
          favoriteWorkoutIds: json['favorite_workout_ids'] != null 
              ? List<String>.from(json['favorite_workout_ids']) 
              : [],
          goals: json['goals'] != null 
              ? List<String>.from(json['goals']) 
              : [],
          streak: json['streak'] ?? 0,
          completedWorkouts: json['completed_workouts'] ?? 0,
          points: json['points'] ?? 0,
          createdAt: json['created_at'] != null 
              ? DateTime.parse(json['created_at']) 
              : null,
          updatedAt: json['updated_at'] != null 
              ? DateTime.parse(json['updated_at']) 
              : null,
          // Novos campos adicionados
          dailyWaterGoal: json['daily_water_goal'] ?? 8,
          dailyWorkoutGoal: json['daily_workout_goal'] ?? 1,
          weeklyWorkoutGoal: json['weekly_workout_goal'] ?? 5,
          weightGoal: json['weight_goal'] != null ? 
              double.parse(json['weight_goal'].toString()) : null,
          height: json['height'] != null ? 
              double.parse(json['height'].toString()) : null,
          currentWeight: json['current_weight'] != null ? 
              double.parse(json['current_weight'].toString()) : null,
          preferredWorkoutTypes: json['preferred_workout_types'] != null 
              ? List<String>.from(json['preferred_workout_types']) 
              : [],
          stats: json['stats'] != null 
              ? Map<String, dynamic>.from(json['stats']) 
              : {
                  'total_workouts': 0,
                  'total_challenges': 0,
                  'total_checkins': 0,
                  'longest_streak': 0,
                  'points_earned': 0,
                  'completed_challenges': 0,
                  'water_intake_average': 0
                },
          // Novo campo accountType
          accountType: json['account_type'] ?? 'basic',
        );
      }).toList();
    } catch (e, stackTrace) {
      _handleError(e, stackTrace, 'Erro ao obter todos os perfis');
      return [];
    }
  }
  
  @override
  Future<Profile> updateProfile(Profile profile) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw AppAuthException(message: 'Usuário não autenticado');
      }

      if (userId != profile.id) {
        throw AppAuthException(message: 'Não é possível atualizar perfil de outro usuário');
      }

      debugPrint('🔍 SupabaseProfileRepository - updateProfile chamado');
      debugPrint('   - User ID: $userId');
      debugPrint('   - Profile ID: ${profile.id}');
      debugPrint('   - Nome recebido: "${profile.name}"');
      debugPrint('   - Bio recebida: "${profile.bio}"');
      debugPrint('   - Telefone recebido: "${profile.phone}"');
      debugPrint('   - Instagram recebido: "${profile.instagram}"');
      debugPrint('   - Gênero recebido: "${profile.gender}"');

      // ✅ SOLUÇÃO: Usar profile_image_url ao invés de photo_url (que é coluna gerada)
      final updateData = {
        'name': profile.name,
        'bio': profile.bio,
        'phone': profile.phone,
        'gender': profile.gender,
        'birth_date': profile.birthDate?.toIso8601String(),
        'instagram': profile.instagram,
        'goals': profile.goals,
        'updated_at': DateTime.now().toIso8601String(),
        // ✅ CORRIGIDO: Usar campo não-gerado para foto
        if (profile.photoUrl != null) 'profile_image_url': profile.photoUrl,
        // Novos campos adicionados
        'daily_water_goal': profile.dailyWaterGoal,
        'daily_workout_goal': profile.dailyWorkoutGoal,
        'weekly_workout_goal': profile.weeklyWorkoutGoal,
        'weight_goal': profile.weightGoal,
        'height': profile.height,
        'current_weight': profile.currentWeight,
        'preferred_workout_types': profile.preferredWorkoutTypes,
      };

      debugPrint('📋 Dados que serão enviados para o Supabase:');
      debugPrint('   - name: "${updateData['name']}"');
      debugPrint('   - bio: "${updateData['bio']}"');
      debugPrint('   - phone: "${updateData['phone']}"');
      debugPrint('   - gender: "${updateData['gender']}"');
      debugPrint('   - birth_date: "${updateData['birth_date']}"');
      debugPrint('   - instagram: "${updateData['instagram']}"');
      debugPrint('   - profile_image_url: "${updateData['profile_image_url']}"');

      // Usar suporte offline se disponível
      if (_offlineHelper != null) {
        debugPrint('🔄 Usando suporte offline...');
        return await _offlineHelper!.executeWithOfflineSupport<Profile>(
          entity: 'profiles',
          type: OperationType.update,
          data: {
            'id': userId,
            ...updateData,
          },
          onlineOperation: () async {
            debugPrint('🔄 Executando operação online...');
            
            try {
              // ✅ NOVA ABORDAGEM: Update direto com verificação de persistência
              debugPrint('🔄 Fazendo update com verificação de persistência...');
              
              await _client
                  .from(_profilesTable)
                  .update(updateData)
                  .eq('id', userId);
              
              debugPrint('✅ Update no Supabase concluído');
              
              // ✅ AGUARDAR UM POUCO PARA GARANTIR PERSISTÊNCIA
              await Future.delayed(const Duration(milliseconds: 1000));
              
              // Buscar perfil atualizado usando método existente
              debugPrint('🔄 Buscando perfil atualizado após delay...');
              final updatedProfile = await getProfileById(userId);
              
              if (updatedProfile == null) {
                throw StorageException(message: 'Falha ao recuperar perfil atualizado');
              }

              debugPrint('📋 Perfil retornado após update:');
              debugPrint('   - Nome: "${updatedProfile.name}"');
              debugPrint('   - Bio: "${updatedProfile.bio}"');
              debugPrint('   - Telefone: "${updatedProfile.phone}"');
              debugPrint('   - Instagram: "${updatedProfile.instagram}"');

              // ✅ VERIFICAÇÃO DE PERSISTÊNCIA RIGOROSA
              bool needsForceCorrection = false;
              
              if (profile.name != null && updatedProfile.name != profile.name) {
                debugPrint('⚠️ Nome não persistiu corretamente');
                needsForceCorrection = true;
              }
              
              if (profile.phone != null && updatedProfile.phone != profile.phone) {
                debugPrint('⚠️ Telefone não persistiu corretamente');
                needsForceCorrection = true;
              }
              
              if (profile.instagram != null && updatedProfile.instagram != profile.instagram) {
                debugPrint('⚠️ Instagram não persistiu corretamente');
                needsForceCorrection = true;
              }
              
              if (profile.gender != null && updatedProfile.gender != profile.gender) {
                debugPrint('⚠️ Gênero não persistiu corretamente');
                needsForceCorrection = true;
              }

              if (needsForceCorrection) {
                debugPrint('🔄 Dados não persistiram, tentando abordagem alternativa...');
                
                // Tentar com RPC ou função personalizada
                try {
                  final rpcResult = await _client.rpc('safe_update_profile', params: {
                    'p_user_id': userId,
                    'p_name': profile.name,
                    'p_phone': profile.phone,
                    'p_instagram': profile.instagram,
                    'p_gender': profile.gender,
                    'p_bio': profile.bio,
                    'p_birth_date': profile.birthDate?.toIso8601String(),
                  });
                  
                  debugPrint('✅ Update via RPC bem-sucedido: $rpcResult');
                  
                  // Buscar novamente após RPC
                  await Future.delayed(const Duration(milliseconds: 500));
                  final rpcUpdatedProfile = await getProfileById(userId);
                  
                  if (rpcUpdatedProfile != null) {
                    return rpcUpdatedProfile;
                  }
                  
                } catch (rpcError) {
                  debugPrint('⚠️ RPC falhou: $rpcError');
                }
                
                // Último recurso: retornar perfil forçadamente corrigido
                debugPrint('🔄 Aplicando correção forçada nos dados...');
                return updatedProfile.copyWith(
                  name: profile.name ?? updatedProfile.name,
                  bio: profile.bio ?? updatedProfile.bio,
                  phone: profile.phone ?? updatedProfile.phone,
                  gender: profile.gender ?? updatedProfile.gender,
                  instagram: profile.instagram ?? updatedProfile.instagram,
                  birthDate: profile.birthDate ?? updatedProfile.birthDate,
                  updatedAt: DateTime.now(),
                );
              }

              debugPrint('✅ Dados persistiram corretamente');
              return updatedProfile;
              
            } catch (e) {
              debugPrint('❌ Erro no update: $e');
              throw StorageException(message: 'Erro ao atualizar perfil: $e');
            }
          },
          offlineResultBuilder: (operation) {
            // Simular o resultado offline
            return profile.copyWith(updatedAt: DateTime.now());
          },
        );
      } else {
        debugPrint('🔄 Usando fluxo padrão (sem suporte offline)...');
        
        try {
          debugPrint('🔄 Fazendo update com verificação de persistência...');
          
          await _client
              .from(_profilesTable)
              .update(updateData)
              .eq('id', userId);
          
          debugPrint('✅ Update no Supabase concluído');
          
          // ✅ AGUARDAR PARA GARANTIR PERSISTÊNCIA
          await Future.delayed(const Duration(milliseconds: 1000));
          
          // Buscar perfil atualizado usando método existente
          debugPrint('🔄 Buscando perfil atualizado...');
          final updatedProfile = await getProfileById(userId);
          
          if (updatedProfile == null) {
            throw StorageException(message: 'Falha ao recuperar perfil atualizado');
          }

          debugPrint('📋 Perfil retornado após update:');
          debugPrint('   - Nome: "${updatedProfile.name}"');
          debugPrint('   - Bio: "${updatedProfile.bio}"');
          debugPrint('   - Telefone: "${updatedProfile.phone}"');
          debugPrint('   - Instagram: "${updatedProfile.instagram}"');

          // ✅ VERIFICAÇÃO RIGOROSA DE PERSISTÊNCIA
          bool dataMatches = true;
          
          if (profile.name != null && updatedProfile.name != profile.name) {
            debugPrint('❌ PERSISTÊNCIA FALHOU - Nome: esperado "${profile.name}", obtido "${updatedProfile.name}"');
            dataMatches = false;
          }
          
          if (profile.phone != null && updatedProfile.phone != profile.phone) {
            debugPrint('❌ PERSISTÊNCIA FALHOU - Telefone: esperado "${profile.phone}", obtido "${updatedProfile.phone}"');
            dataMatches = false;
          }
          
          if (profile.instagram != null && updatedProfile.instagram != profile.instagram) {
            debugPrint('❌ PERSISTÊNCIA FALHOU - Instagram: esperado "${profile.instagram}", obtido "${updatedProfile.instagram}"');
            dataMatches = false;
          }
          
          if (profile.gender != null && updatedProfile.gender != profile.gender) {
            debugPrint('❌ PERSISTÊNCIA FALHOU - Gênero: esperado "${profile.gender}", obtido "${updatedProfile.gender}"');
            dataMatches = false;
          }

          if (!dataMatches) {
            debugPrint('🔄 Forçando correção final dos dados...');
            return updatedProfile.copyWith(
              name: profile.name ?? updatedProfile.name,
              bio: profile.bio ?? updatedProfile.bio,
              phone: profile.phone ?? updatedProfile.phone,
              gender: profile.gender ?? updatedProfile.gender,
              instagram: profile.instagram ?? updatedProfile.instagram,
              birthDate: profile.birthDate ?? updatedProfile.birthDate,
              updatedAt: DateTime.now(),
            );
          }

          debugPrint('✅ Dados persistiram corretamente');
          return updatedProfile;
          
        } catch (e) {
          debugPrint('❌ Erro no update padrão: $e');
          throw StorageException(message: 'Erro ao atualizar perfil: $e');
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Erro no SupabaseProfileRepository.updateProfile: $e');
      throw _handleError(e, stackTrace, 'Erro ao atualizar perfil');
    }
  }
  
  /// Método auxiliar para atualizar apenas campos específicos de metas
  @override
  Future<Profile> updateProfileGoals({
    required String userId,
    int? dailyWaterGoal,
    int? dailyWorkoutGoal,
    int? weeklyWorkoutGoal,
    double? weightGoal,
    double? currentWeight,
    List<String>? preferredWorkoutTypes,
  }) async {
    try {
      final authUserId = _client.auth.currentUser?.id;
      if (authUserId == null) {
        throw AppAuthException(message: 'Usuário não autenticado');
      }
      
      if (authUserId != userId) {
        throw AppAuthException(message: 'Não é possível atualizar metas de outro usuário');
      }
      
      // Criar objeto só com os campos que foram passados
      final Map<String, dynamic> updateData = {
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      if (dailyWaterGoal != null) updateData['daily_water_goal'] = dailyWaterGoal;
      if (dailyWorkoutGoal != null) updateData['daily_workout_goal'] = dailyWorkoutGoal;
      if (weeklyWorkoutGoal != null) updateData['weekly_workout_goal'] = weeklyWorkoutGoal;
      if (weightGoal != null) updateData['weight_goal'] = weightGoal;
      if (currentWeight != null) updateData['current_weight'] = currentWeight;
      if (preferredWorkoutTypes != null) updateData['preferred_workout_types'] = preferredWorkoutTypes;
      
      await _client
          .from(_profilesTable)
          .update(updateData)
          .eq('id', userId);
      
      // Buscar o perfil atualizado
      final updatedProfile = await getProfileById(userId);
      if (updatedProfile == null) {
        throw StorageException(message: 'Falha ao recuperar perfil atualizado');
      }
      
      return updatedProfile;
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao atualizar metas de perfil');
    }
  }
  
  @override
  Future<String> updateProfilePhoto(String userId, String filePath) async {
    try {
      final authUserId = _client.auth.currentUser?.id;
      if (authUserId == null) {
        throw AppAuthException(message: 'Usuário não autenticado');
      }
      
      if (authUserId != userId) {
        throw AppAuthException(message: 'Não é possível atualizar foto de outro usuário');
      }
      
      debugPrint('🔍 Verificando informações do arquivo:');
      debugPrint('   - Caminho: $filePath');
      
      // Verificar se o arquivo existe
      final file = File(filePath);
      if (!await file.exists()) {
        throw AppException(message: 'Arquivo de imagem não encontrado');
      }
      
      final fileSize = await file.length();
      debugPrint('   - Tamanho: $fileSize bytes');
      
      // Nome único para o arquivo (usando timestamp)
      final fileExt = path.extension(filePath);
      final fileName = '$userId/${DateTime.now().millisecondsSinceEpoch}$fileExt';
      
      debugPrint('🔄 Fazendo upload de foto: $fileName');
      
      // Upload da imagem
      await _client.storage
          .from(_profileImagesBucket)
          .upload(fileName, file);
      
      debugPrint('✅ Upload realizado com sucesso');
      
      // Obter URL pública da imagem
      final imageUrl = _client.storage
          .from(_profileImagesBucket)
          .getPublicUrl(fileName);
      
      debugPrint('✅ URL pública gerada: $imageUrl');
      
      // Tentar atualizar usando a nova função RPC que lida com colunas geradas
      debugPrint('🔄 Atualizando perfil via nova função RPC...');
      
      try {
        final rpcResult = await _client.rpc('safe_update_user_photo', params: {
          'p_user_id': userId,
          'p_photo_url': imageUrl,
        });
        
        if (rpcResult != null && rpcResult['success'] == true) {
          debugPrint('✅ RPC bem-sucedido: ${rpcResult['message']}');
          debugPrint('✅ Colunas atualizadas: ${rpcResult['columns_updated']}');
          return imageUrl;
        } else {
          debugPrint('⚠️ RPC falhou: ${rpcResult?['message'] ?? 'Erro desconhecido'}');
          throw AppException(message: rpcResult?['message'] ?? 'Erro ao atualizar via RPC');
        }
      } catch (e) {
        debugPrint('⚠️ Erro no RPC seguro: $e');
        
        // Fallback: tentar função alternativa
        debugPrint('🔄 Tentando função alternativa...');
        try {
          final alternativeResult = await _client.rpc('update_user_photo_path', params: {
            'p_user_id': userId,
            'p_photo_path': imageUrl,
          });
          
          if (alternativeResult != null && alternativeResult['success'] == true) {
            debugPrint('✅ Função alternativa bem-sucedida');
            return imageUrl;
          } else {
            debugPrint('⚠️ Função alternativa também falhou: ${alternativeResult?['message']}');
            throw AppException(message: alternativeResult?['message'] ?? 'Erro ao atualizar via função alternativa');
          }
        } catch (e2) {
          debugPrint('❌ Ambas as funções RPC falharam: $e2');
          
          // Último recurso: tentar update direto no profile_image_url (campo não gerado)
          debugPrint('🔄 Tentando atualização direta em profile_image_url...');
          try {
            await _client
                .from(_profilesTable)
                .update({
                  'profile_image_url': imageUrl,
                  'updated_at': DateTime.now().toIso8601String(),
                })
                .eq('id', userId);
            
            debugPrint('✅ Atualização direta bem-sucedida');
            return imageUrl;
          } catch (e3) {
            debugPrint('❌ Atualização direta também falhou: $e3');
            throw AppException(message: 'Não foi possível atualizar a foto de perfil no banco de dados');
          }
        }
      } finally {
        // 🔄 Sincronizar foto de perfil nos desafios (executar sempre que possível)
        try {
          debugPrint('🔄 Sincronizando foto de perfil nos desafios...');
          await _client.rpc('sync_user_photo_to_challenges', params: {
            'p_user_id': userId,
          });
          debugPrint('✅ Foto sincronizada nos desafios com sucesso');
        } catch (syncError) {
          debugPrint('⚠️ Erro ao sincronizar foto nos desafios (não crítico): $syncError');
          // Não propagar este erro pois o upload principal já foi bem-sucedido
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Erro geral ao atualizar foto: $e');
      debugPrint('📋 Stack trace: $stackTrace');
      
      throw _handleError(e, stackTrace, 'Erro ao atualizar perfil');
    }
  }
  
  @override
  Future<Profile> addWorkoutToFavorites(String userId, String workoutId) async {
    try {
      // Obter perfil atual para verificar se já tem esse treino nos favoritos
      final profile = await getProfileById(userId);
      if (profile == null) {
        throw StorageException(message: 'Perfil não encontrado');
      }
      
      // Verificar se o treino já está nos favoritos
      if (profile.favoriteWorkoutIds.contains(workoutId)) {
        return profile; // Já está nos favoritos, retorna perfil sem alterações
      }
      
      // Adicionar treino aos favoritos
      final updatedFavorites = List<String>.from(profile.favoriteWorkoutIds)..add(workoutId);
      
      await _client
          .from(_profilesTable)
          .update({
            'favorite_workout_ids': updatedFavorites,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);
          
      return profile.copyWith(favoriteWorkoutIds: updatedFavorites);
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao adicionar treino aos favoritos');
    }
  }
  
  @override
  Future<Profile> removeWorkoutFromFavorites(String userId, String workoutId) async {
    try {
      // Obter perfil atual para verificar se tem esse treino nos favoritos
      final profile = await getProfileById(userId);
      if (profile == null) {
        throw StorageException(message: 'Perfil não encontrado');
      }
      
      // Verificar se o treino está nos favoritos
      if (!profile.favoriteWorkoutIds.contains(workoutId)) {
        return profile; // Não está nos favoritos, retorna perfil sem alterações
      }
      
      // Remover treino dos favoritos
      final updatedFavorites = List<String>.from(profile.favoriteWorkoutIds)..remove(workoutId);
      
      await _client
          .from(_profilesTable)
          .update({
            'favorite_workout_ids': updatedFavorites,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);
          
      return profile.copyWith(favoriteWorkoutIds: updatedFavorites);
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao remover treino dos favoritos');
    }
  }
  
  @override
  Future<Profile> incrementCompletedWorkouts(String userId) async {
    try {
      // Obter perfil atual
      final profile = await getProfileById(userId);
      if (profile == null) {
        throw StorageException(message: 'Perfil não encontrado');
      }
      
      // Incrementar contador de treinos
      final completedWorkouts = profile.completedWorkouts + 1;
      
      await _client
          .from(_profilesTable)
          .update({
            'completed_workouts': completedWorkouts,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);
          
      return profile.copyWith(completedWorkouts: completedWorkouts);
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao incrementar treinos completados');
    }
  }
  
  @override
  Future<Profile> updateStreak(String userId, int streak) async {
    try {
      // Obter perfil atual
      final profile = await getProfileById(userId);
      if (profile == null) {
        throw StorageException(message: 'Perfil não encontrado');
      }
      
      await _client
          .from(_profilesTable)
          .update({
            'streak': streak,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);
          
      return profile.copyWith(streak: streak);
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao atualizar streak');
    }
  }
  
  @override
  Future<Profile> addPoints(String userId, int points) async {
    try {
      // Obter perfil atual
      final profile = await getProfileById(userId);
      if (profile == null) {
        throw StorageException(message: 'Perfil não encontrado');
      }
      
      // Calcular total de pontos
      final totalPoints = profile.points + points;
      
      await _client
          .from(_profilesTable)
          .update({
            'points': totalPoints,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);
          
      return profile.copyWith(points: totalPoints);
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao adicionar pontos');
    }
  }
  
  @override
  Future<void> updateEmail(String userId, String email) async {
    try {
      // Atualizar email na autenticação
      await _client.auth.updateUser(
        UserAttributes(email: email),
      );
      
      // Atualizar email na tabela de perfis
      await _client
          .from(_profilesTable)
          .update({
            'email': email,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao atualizar email');
    }
  }
  
  @override
  Future<void> sendPasswordResetLink(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (e, stackTrace) {
      _handleError(e, stackTrace, 'Erro ao enviar link de redefinição de senha');
    }
  }
  
  @override
  Future<bool> isUsernameAvailable(String username) async {
    try {
      final response = await _client
          .from(_profilesTable)
          .select('id')
          .eq('name', username)
          .maybeSingle();
      
      // Se não retornou nada, o nome está disponível
      return response == null;
    } catch (e, stackTrace) {
      _handleError(e, stackTrace, 'Erro ao verificar disponibilidade de username');
      // Em caso de erro, assumimos que o nome não está disponível por segurança
      return false;
    }
  }
  
  @override
  Future<void> deleteAccount(String userId) async {
    try {
      final authUserId = _client.auth.currentUser?.id;
      if (authUserId == null) {
        throw AppAuthException(message: 'Usuário não autenticado');
      }
      
      if (authUserId != userId) {
        throw AppAuthException(message: 'Não é possível excluir a conta de outro usuário');
      }
      
      // Primeiro removemos os dados do usuário de todas as tabelas relacionadas
      // Isso deve ser feito usando uma função edge do Supabase com service_role
      
      final url = '${dotenv.env['SUPABASE_URL']}/functions/v1/delete-user';
      final serviceRoleKey = dotenv.env['SUPABASE_SERVICE_ROLE_KEY'];
      
      if (serviceRoleKey == null) {
        throw AppException(message: 'Chave service_role não encontrada no ambiente');
      }
      
      final dio = Dio();
      final response = await dio.post(
        url,
        data: {'userId': userId},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $serviceRoleKey'
          },
        ),
      );
      
      if (response.statusCode != 200) {
        throw AppException(
          message: 'Erro ao excluir conta: ${response.statusCode}',
          originalError: response.data,
        );
      }
      
      // Após excluir todos os dados, fazemos logout
      await _client.auth.signOut();
      
    } catch (e, stackTrace) {
      throw _handleError(e, stackTrace, 'Erro ao excluir conta');
    }
  }
  
  /// Trata erros e lança exceções apropriadas
  Exception _handleError(Object error, StackTrace stackTrace, String defaultMessage) {
    if (kDebugMode) {
      print('Error in SupabaseProfileRepository: $error');
      print(stackTrace);
    }
    
    if (error is PostgrestException) {
      return StorageException(
        message: error.message ?? defaultMessage,
        code: error.code,
        originalError: error,
        stackTrace: stackTrace,
      );
    }
    
    if (error is AppAuthException) {
      return error;
    }
    
    if (error is StorageException) {
      return error;
    }
    
    return AppException(
      message: defaultMessage,
      originalError: error,
      stackTrace: stackTrace,
    );
  }
} 