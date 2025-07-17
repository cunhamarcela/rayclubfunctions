// Project imports:
import '../models/profile_model.dart';

/// Interface para o repositório de perfil
abstract class ProfileRepository {
  /// Obtém o perfil do usuário atual
  Future<Profile?> getCurrentUserProfile();
  
  /// Obtém um perfil de usuário por ID
  Future<Profile?> getProfileById(String userId);
  
  /// Obtém todos os perfis
  Future<List<Profile>> getAllProfiles();
  
  /// Atualiza o perfil do usuário
  Future<Profile> updateProfile(Profile profile);
  
  /// Atualiza a foto de perfil do usuário
  Future<String> updateProfilePhoto(String userId, String filePath);
  
  /// Adiciona um treino aos favoritos
  Future<Profile> addWorkoutToFavorites(String userId, String workoutId);
  
  /// Remove um treino dos favoritos
  Future<Profile> removeWorkoutFromFavorites(String userId, String workoutId);
  
  /// Incrementa o contador de treinos completados
  Future<Profile> incrementCompletedWorkouts(String userId);
  
  /// Atualiza a sequência de dias de treino
  Future<Profile> updateStreak(String userId, int streak);
  
  /// Adiciona pontos ao usuário
  Future<Profile> addPoints(String userId, int points);
  
  /// Atualiza o email do usuário
  Future<void> updateEmail(String userId, String email);
  
  /// Envia link para redefinir senha
  Future<void> sendPasswordResetLink(String email);
  
  /// Verifica se um nome de usuário está disponível
  Future<bool> isUsernameAvailable(String username);
  
  /// Exclui a conta do usuário
  Future<void> deleteAccount(String userId);
  
  /// Atualiza metas específicas do perfil
  Future<Profile> updateProfileGoals({
    required String userId,
    int? dailyWaterGoal,
    int? dailyWorkoutGoal,
    int? weeklyWorkoutGoal,
    double? weightGoal,
    double? currentWeight,
    List<String>? preferredWorkoutTypes,
  });
}

/// Implementação Mock do repositório de perfil para desenvolvimento
class MockProfileRepository implements ProfileRepository {
  // Lista de perfis mockados para desenvolvimento
  final List<Profile> _mockProfiles = [
    Profile(
      id: 'user-1',
      name: 'Maria Silva',
      email: 'maria@exemplo.com',
      photoUrl: null,
      completedWorkouts: 24,
      streak: 3,
      points: 750,
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      bio: 'Entusiasta de fitness e bem-estar',
      goals: ['Perder peso', 'Melhorar condicionamento'],
      favoriteWorkoutIds: ['workout-1', 'workout-3'],
      phone: '(11) 98765-4321',
      gender: 'Feminino',
      birthDate: DateTime(1990, 5, 15),
      instagram: '@mariasilva',
    ),
    Profile(
      id: 'user-2',
      name: 'João Pereira',
      email: 'joao@exemplo.com',
      photoUrl: null,
      completedWorkouts: 15,
      streak: 1,
      points: 350,
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      bio: 'Corredor amador',
      goals: ['Ganhar massa muscular'],
      favoriteWorkoutIds: ['workout-2'],
      phone: '(21) 99876-5432',
      gender: 'Masculino',
      birthDate: DateTime(1988, 10, 20),
      instagram: '@joaopereira',
    ),
  ];
  
  // ID do usuário atual simulado
  final String _currentUserId = 'user-1';
  
  // Atraso simulado da rede
  Future<void> _simulateNetworkDelay() async {
    await Future.delayed(const Duration(milliseconds: 800));
  }
  
  @override
  Future<Profile?> getCurrentUserProfile() async {
    await _simulateNetworkDelay();
    try {
      return _mockProfiles.firstWhere((profile) => profile.id == _currentUserId);
    } catch (e) {
      return null;
    }
  }
  
  @override
  Future<Profile?> getProfileById(String userId) async {
    await _simulateNetworkDelay();
    try {
      return _mockProfiles.firstWhere((profile) => profile.id == userId);
    } catch (e) {
      return null;
    }
  }
  
  @override
  Future<List<Profile>> getAllProfiles() async {
    await _simulateNetworkDelay();
    return List.from(_mockProfiles);
  }
  
  @override
  Future<Profile> updateProfile(Profile profile) async {
    await _simulateNetworkDelay();
    
    final index = _mockProfiles.indexWhere((p) => p.id == profile.id);
    if (index >= 0) {
      final updatedProfile = profile.copyWith(
        updatedAt: DateTime.now(),
      );
      
      _mockProfiles[index] = updatedProfile;
      return updatedProfile;
    }
    
    throw Exception('Perfil não encontrado');
  }
  
  @override
  Future<String> updateProfilePhoto(String userId, String filePath) async {
    await _simulateNetworkDelay();
    
    final index = _mockProfiles.indexWhere((p) => p.id == userId);
    if (index >= 0) {
      // Em um ambiente real, o caminho do arquivo seria processado e armazenado
      final mockPhotoUrl = 'https://exemplo.com/fotos/$userId.jpg';
      
      _mockProfiles[index] = _mockProfiles[index].copyWith(
        photoUrl: mockPhotoUrl,
        updatedAt: DateTime.now(),
      );
      
      return mockPhotoUrl;
    }
    
    throw Exception('Perfil não encontrado');
  }
  
  @override
  Future<Profile> addWorkoutToFavorites(String userId, String workoutId) async {
    await _simulateNetworkDelay();
    
    final index = _mockProfiles.indexWhere((p) => p.id == userId);
    if (index >= 0) {
      final currentFavorites = List<String>.from(_mockProfiles[index].favoriteWorkoutIds);
      
      if (!currentFavorites.contains(workoutId)) {
        currentFavorites.add(workoutId);
        
        final updatedProfile = _mockProfiles[index].copyWith(
          favoriteWorkoutIds: currentFavorites,
          updatedAt: DateTime.now(),
        );
        
        _mockProfiles[index] = updatedProfile;
        return updatedProfile;
      }
      
      return _mockProfiles[index];
    }
    
    throw Exception('Perfil não encontrado');
  }
  
  @override
  Future<Profile> removeWorkoutFromFavorites(String userId, String workoutId) async {
    await _simulateNetworkDelay();
    
    final index = _mockProfiles.indexWhere((p) => p.id == userId);
    if (index >= 0) {
      final currentFavorites = List<String>.from(_mockProfiles[index].favoriteWorkoutIds);
      
      if (currentFavorites.contains(workoutId)) {
        currentFavorites.remove(workoutId);
        
        final updatedProfile = _mockProfiles[index].copyWith(
          favoriteWorkoutIds: currentFavorites,
          updatedAt: DateTime.now(),
        );
        
        _mockProfiles[index] = updatedProfile;
        return updatedProfile;
      }
      
      return _mockProfiles[index];
    }
    
    throw Exception('Perfil não encontrado');
  }
  
  @override
  Future<Profile> incrementCompletedWorkouts(String userId) async {
    await _simulateNetworkDelay();
    
    final index = _mockProfiles.indexWhere((p) => p.id == userId);
    if (index >= 0) {
      final updatedProfile = _mockProfiles[index].copyWith(
        completedWorkouts: _mockProfiles[index].completedWorkouts + 1,
        updatedAt: DateTime.now(),
      );
      
      _mockProfiles[index] = updatedProfile;
      return updatedProfile;
    }
    
    throw Exception('Perfil não encontrado');
  }
  
  @override
  Future<Profile> updateStreak(String userId, int streak) async {
    await _simulateNetworkDelay();
    
    final index = _mockProfiles.indexWhere((p) => p.id == userId);
    if (index >= 0) {
      final updatedProfile = _mockProfiles[index].copyWith(
        streak: streak,
        updatedAt: DateTime.now(),
      );
      
      _mockProfiles[index] = updatedProfile;
      return updatedProfile;
    }
    
    throw Exception('Perfil não encontrado');
  }
  
  @override
  Future<Profile> addPoints(String userId, int points) async {
    await _simulateNetworkDelay();
    
    final index = _mockProfiles.indexWhere((p) => p.id == userId);
    if (index >= 0) {
      final updatedProfile = _mockProfiles[index].copyWith(
        points: _mockProfiles[index].points + points,
        updatedAt: DateTime.now(),
      );
      
      _mockProfiles[index] = updatedProfile;
      return updatedProfile;
    }
    
    throw Exception('Perfil não encontrado');
  }
  
  @override
  Future<void> updateEmail(String userId, String email) async {
    await _simulateNetworkDelay();
    
    final index = _mockProfiles.indexWhere((p) => p.id == userId);
    if (index >= 0) {
      _mockProfiles[index] = _mockProfiles[index].copyWith(
        email: email,
        updatedAt: DateTime.now(),
      );
      return;
    }
    
    throw Exception('Perfil não encontrado');
  }
  
  @override
  Future<void> sendPasswordResetLink(String email) async {
    await _simulateNetworkDelay();
    
    final userExists = _mockProfiles.any((profile) => profile.email == email);
    if (!userExists) {
      throw Exception('Email não encontrado');
    }
    
    // Simulação de envio de email de redefinição
    return;
  }
  
  @override
  Future<bool> isUsernameAvailable(String username) async {
    await _simulateNetworkDelay();
    return !_mockProfiles.any((profile) => profile.name == username);
  }
  
  @override
  Future<void> deleteAccount(String userId) async {
    await _simulateNetworkDelay();
    
    final index = _mockProfiles.indexWhere((p) => p.id == userId);
    if (index >= 0) {
      _mockProfiles.removeAt(index);
      return;
    }
    
    throw Exception('Perfil não encontrado');
  }
  
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
    await _simulateNetworkDelay();
    
    final index = _mockProfiles.indexWhere((p) => p.id == userId);
    if (index >= 0) {
      final currentProfile = _mockProfiles[index];
      final updatedProfile = currentProfile.copyWith(
        dailyWaterGoal: dailyWaterGoal ?? currentProfile.dailyWaterGoal,
        dailyWorkoutGoal: dailyWorkoutGoal ?? currentProfile.dailyWorkoutGoal,
        weeklyWorkoutGoal: weeklyWorkoutGoal ?? currentProfile.weeklyWorkoutGoal,
        weightGoal: weightGoal,
        currentWeight: currentWeight,
        preferredWorkoutTypes: preferredWorkoutTypes ?? currentProfile.preferredWorkoutTypes,
        updatedAt: DateTime.now(),
      );
      
      _mockProfiles[index] = updatedProfile;
      return updatedProfile;
    }
    
    throw Exception('Perfil não encontrado');
  }
} 
