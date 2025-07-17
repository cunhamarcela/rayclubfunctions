// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

// Project imports:
import 'package:ray_club_app/features/auth/models/auth_state.dart';
import 'package:ray_club_app/features/auth/repositories/auth_repository.dart';
import 'package:ray_club_app/features/auth/viewmodels/auth_view_model.dart';
import 'package:ray_club_app/features/home/models/home_model.dart';
import 'package:ray_club_app/features/home/repositories/home_repository.dart';
import 'package:ray_club_app/features/home/viewmodels/states/home_state.dart';
import 'package:ray_club_app/features/home/screens/home_screen.dart';
import 'package:ray_club_app/features/home/viewmodels/home_view_model.dart';
import 'package:ray_club_app/features/home/widgets/challenge/challenge_card.dart';
import 'package:ray_club_app/features/home/widgets/workout/workout_card.dart';

// Mock do AuthViewModel estendendo a classe real para compatibilidade de tipo
class MockAuthViewModel extends AuthViewModel {
  MockAuthViewModel() : super(repository: _MockAuthRepository());
  
  // Sobrescrever o estado com um valor inicial conhecido
  @override
  AuthState get state => const AuthState.unauthenticated();
}

// Mock do Repository de Auth para permitir a criação do MockAuthViewModel
class _MockAuthRepository implements IAuthRepository {
  @override
  Future<supabase.User?> getCurrentUser() async => null;

  @override
  Future<String> getCurrentUserId() async => '';

  @override
  Future<bool> isEmailRegistered(String email) async => false;

  @override
  Future<supabase.User> signUp(String email, String password, String name) {
    throw UnimplementedError();
  }

  @override
  Future<supabase.User> signIn(String email, String password) {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<void> resetPassword(String email) async {}

  @override
  Future<void> updateProfile({String? name, String? photoUrl}) async {}

  @override
  Future<supabase.Session?> signInWithGoogle() {
    throw UnimplementedError();
  }

  @override
  supabase.Session? getCurrentSession() => null;
  
  @override
  Future<supabase.User?> getUserProfile() async => null;

  @override
  Future<void> refreshSession() async {}
}

// Mock do HomeViewModel estendendo a classe real para compatibilidade de tipo
class MockHomeViewModel extends HomeViewModel {
  // Construtor que inicializa com um mock repository
  MockHomeViewModel() : super(_MockHomeRepository());
  
  void setLoaded() {
    // Criando um HomeData mock para passar ao estado
    final mockData = HomeData(
      activeBanner: BannerItem(
        id: '1', 
        title: 'Banner Teste', 
        subtitle: 'Subtítulo do banner',
        imageUrl: 'assets/images/banner.jpg'
      ),
      banners: [],
      progress: UserProgress.empty(),
      categories: [],
      popularWorkouts: [
        PopularWorkout(
          id: '1',
          title: 'Treino Teste',
          imageUrl: 'assets/images/workout.jpg',
          duration: '30 min',
          difficulty: 'Iniciante',
        ),
        PopularWorkout(
          id: '2',
          title: 'Treino Teste 2',
          imageUrl: 'assets/images/workout2.jpg',
          duration: '45 min',
          difficulty: 'Intermediário',
        ),
      ],
      lastUpdated: DateTime.now(),
    );
    
    state = HomeState.loaded(mockData);
  }

  void setError() {
    state = HomeState.error('Erro de teste');
  }

  void setLoading() {
    state = HomeState.loading();
  }
}

// Mock do Repository de Home para permitir a criação do MockHomeViewModel
class _MockHomeRepository implements HomeRepository {
  @override
  Future<HomeData> getHomeData() async {
    return HomeData.empty();
  }
  
  @override
  Future<UserProgress> getUserProgress() async {
    return UserProgress.empty();
  }
  
  @override
  Future<List<BannerItem>> getBanners() async {
    return [];
  }
  
  @override
  Future<List<WorkoutCategory>> getWorkoutCategories() async {
    return [];
  }
  
  @override
  Future<List<PopularWorkout>> getPopularWorkouts() async {
    return [];
  }
}

void main() {
  late MockHomeViewModel mockHomeViewModel;
  late MockAuthViewModel mockAuthViewModel;

  setUp(() {
    mockHomeViewModel = MockHomeViewModel();
    mockAuthViewModel = MockAuthViewModel();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        homeViewModelProvider.overrideWith((_) => mockHomeViewModel),
        authViewModelProvider.overrideWith((_) => mockAuthViewModel),
      ],
      child: const MaterialApp(
        home: HomeScreen(),
      ),
    );
  }

  group('HomeScreen', () {
    testWidgets('deve mostrar o título na AppBar', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.text('Ray Club'), findsOneWidget);
    });

    testWidgets('deve mostrar tela de carregamento quando isLoading é true', (WidgetTester tester) async {
      mockHomeViewModel.setLoading();
      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('deve mostrar mensagem de erro quando há erro', (WidgetTester tester) async {
      mockHomeViewModel.setError();
      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.textContaining('Erro'), findsOneWidget);
    });

    testWidgets('deve mostrar desafios e treinos quando carregado', (WidgetTester tester) async {
      mockHomeViewModel.setLoaded();
      await tester.pumpWidget(createWidgetUnderTest());
      
      await tester.pump();
      
      // Verifica os títulos das seções
      expect(find.text('Desafios Ativos'), findsOneWidget);
      expect(find.text('Sugestões para você'), findsOneWidget);
      
      // Verifica se os cards estão sendo exibidos
      expect(find.byType(ChallengeCard), findsWidgets);
      expect(find.byType(WorkoutCard), findsWidgets);
    });

    testWidgets('deve mostrar o banner de boas-vindas', (WidgetTester tester) async {
      mockHomeViewModel.setLoaded();
      await tester.pumpWidget(createWidgetUnderTest());
      
      expect(find.text('Bem-vinda ao Ray Club'), findsOneWidget);
      expect(find.text('Sua jornada fitness personalizada'), findsOneWidget);
    });

    testWidgets('deve mostrar FAB para registrar treino', (WidgetTester tester) async {
      mockHomeViewModel.setLoaded();
      await tester.pumpWidget(createWidgetUnderTest());
      
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.text('Registrar treino'), findsOneWidget);
    });
  });
} 
