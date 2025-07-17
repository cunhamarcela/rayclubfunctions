import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ray_club_app/features/auth/viewmodels/auth_view_model.dart';
import 'package:ray_club_app/features/workout/providers/user_access_provider.dart';
import 'package:ray_club_app/features/workout/repositories/workout_videos_repository.dart';

/// Serviço para verificar usuário logo na inicialização do app
class UserVerificationService {
  static Future<void> verifyUserOnAppStart(WidgetRef ref) async {
    print('');
    print('🚀 ========================================');
    print('🚀 USER VERIFICATION SERVICE - APP START');
    print('🚀 ========================================');
    print('');
    
    try {
      // 1. Verificar estado de autenticação
      print('📋 STEP 1: Verificando autenticação...');
      final authState = ref.read(authViewModelProvider);
      
      authState.maybeWhen(
        authenticated: (user) {
          print('✅ AUTENTICADO:');
          print('   👤 User ID: ${user.id}');
          print('   📧 Email: ${user.email}');
          print('   👤 Nome: ${user.name ?? "Não informado"}');
          print('   🔑 IsAdmin: ${user.isAdmin}');
        },
        unauthenticated: () {
          print('❌ NÃO AUTENTICADO');
          print('   ⚠️ Usuário precisa fazer login');
          return;
        },
        loading: () {
          print('⏳ CARREGANDO autenticação...');
          return;
        },
        orElse: () {
          print('❓ ESTADO DESCONHECIDO de autenticação');
          return;
        },
      );
      
      // 2. Verificar dados no banco
      print('');
      print('📋 STEP 2: Verificando dados no banco...');
      final repository = ref.read(workoutVideosRepositoryProvider);
      
      try {
        final userLevel = await repository.getCurrentUserLevel();
        print('✅ NÍVEL NO BANCO: "$userLevel"');
        
        // 3. Verificar provider de nível
        print('');
        print('📋 STEP 3: Testando userLevelProvider...');
        final providerLevel = await ref.read(userLevelProvider.future);
        print('✅ PROVIDER LEVEL: "$providerLevel"');
        
        // 4. Verificar provider expert
        print('');
        print('📋 STEP 4: Testando isExpertUserProvider...');
        final isExpert = await ref.read(isExpertUserProvider.future);
        print('✅ IS EXPERT: $isExpert');
        
        // 5. Resultado final
        print('');
        print('🎯 ========== RESULTADO FINAL ==========');
        if (isExpert) {
          print('🌟 USUÁRIO CLASSIFICADO COMO: EXPERT');
          print('🌟 ✅ Deve ter acesso a todos os vídeos');
        } else {
          print('⚠️ USUÁRIO CLASSIFICADO COMO: BASIC');
          print('⚠️ ❌ Deve ver overlay de bloqueio nos vídeos');
        }
        print('=====================================');
        
      } catch (e, stackTrace) {
        print('❌ ERRO ao verificar banco de dados:');
        print('   🔥 Error: $e');
        print('   📚 Stack: $stackTrace');
      }
      
    } catch (e, stackTrace) {
      print('❌ ERRO CRÍTICO na verificação:');
      print('   🔥 Error: $e');
      print('   📚 Stack: $stackTrace');
    }
    
    print('');
    print('🏁 ========================================');
    print('🏁 USER VERIFICATION SERVICE - COMPLETE');
    print('🏁 ========================================');
    print('');
  }
  
  /// Verifica acesso a um vídeo específico com logs
  static Future<void> verifyVideoAccess(WidgetRef ref, String videoId) async {
    print('');
    print('🎬 ========================================');
    print('🎬 VIDEO ACCESS VERIFICATION');
    print('🎬 Video ID: $videoId');
    print('🎬 ========================================');
    
    try {
      final hasAccess = await ref.read(checkVideoAccessProvider(videoId).future);
      
      print('🎯 RESULTADO:');
      if (hasAccess) {
        print('✅ 🎬 ACESSO LIBERADO para vídeo $videoId');
      } else {
        print('❌ 🔒 ACESSO NEGADO para vídeo $videoId');
      }
      
    } catch (e) {
      print('❌ ERRO na verificação de vídeo:');
      print('   🔥 Error: $e');
    }
    
    print('🎬 ========================================');
    print('');
  }
}

/// Provider para o serviço
final userVerificationServiceProvider = Provider<UserVerificationService>((ref) {
  return UserVerificationService();
}); 