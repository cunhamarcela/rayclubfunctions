# Exemplo de Implementação MVVM

Este documento apresenta um exemplo passo a passo de como implementar o padrão Model-View-ViewModel (MVVM) em uma nova feature ou ao refatorar uma feature existente no projeto Ray Club App.

## Estrutura de Arquivos

Para cada feature, devemos seguir a seguinte estrutura de diretórios:

```
lib/
  └── features/
      └── feature_name/
          ├── models/
          │   ├── entity_model.dart
          │   ├── entity_model.freezed.dart (gerado)
          │   ├── entity_model.g.dart (gerado)
          │   └── feature_state.dart
          ├── repositories/
          │   ├── feature_repository_interface.dart
          │   └── feature_repository.dart
          ├── screens/
          │   └── feature_screen.dart
          └── viewmodels/
              ├── feature_view_model.dart
              └── feature_view_model.freezed.dart (gerado)
```

## Passo 1: Definir os Modelos

Primeiro, definimos os modelos de dados usando o pacote Freezed.

### Exemplo: `user_profile_model.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile_model.freezed.dart';
part 'user_profile_model.g.dart';

@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    required String name,
    String? email,
    String? photoUrl,
    @Default(false) bool isVerified,
    DateTime? createdAt,
  }) = _UserProfile;
  
  factory UserProfile.fromJson(Map<String, dynamic> json) => 
      _$UserProfileFromJson(json);
}
```

## Passo 2: Definir o Estado

Em seguida, definimos o estado que será gerenciado pelo ViewModel.

### Exemplo: `user_profile_state.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'user_profile_model.dart';

part 'user_profile_state.freezed.dart';

@freezed
class UserProfileState with _$UserProfileState {
  const factory UserProfileState({
    UserProfile? profile,
    @Default(false) bool isLoading,
    String? errorMessage,
    @Default(false) bool isUpdated,
  }) = _UserProfileState;
}
```

## Passo 3: Definir a Interface do Repositório

Definimos a interface do repositório que será responsável pelo acesso a dados.

### Exemplo: `user_profile_repository_interface.dart`

```dart
import '../models/user_profile_model.dart';

abstract class UserProfileRepositoryInterface {
  Future<UserProfile> getUserProfile(String userId);
  Future<UserProfile> updateUserProfile(UserProfile profile);
  Future<void> deleteUserProfile(String userId);
}
```

## Passo 4: Implementar o Repositório

Agora implementamos o repositório concreto com acesso ao Supabase.

### Exemplo: `user_profile_repository.dart`

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ray_club_app/core/errors/app_exception.dart';
import '../models/user_profile_model.dart';
import 'user_profile_repository_interface.dart';

class UserProfileRepository implements UserProfileRepositoryInterface {
  final SupabaseClient _client = Supabase.instance.client;
  
  @override
  Future<UserProfile> getUserProfile(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      
      return UserProfile.fromJson(response);
    } catch (e, stackTrace) {
      throw DatabaseException(
        message: 'Erro ao obter perfil de usuário',
        originalException: e,
        stackTrace: stackTrace,
      );
    }
  }
  
  @override
  Future<UserProfile> updateUserProfile(UserProfile profile) async {
    try {
      final response = await _client
          .from('profiles')
          .update(profile.toJson())
          .eq('id', profile.id)
          .select()
          .single();
      
      return UserProfile.fromJson(response);
    } catch (e, stackTrace) {
      throw DatabaseException(
        message: 'Erro ao atualizar perfil de usuário',
        originalException: e,
        stackTrace: stackTrace,
      );
    }
  }
  
  @override
  Future<void> deleteUserProfile(String userId) async {
    try {
      await _client
          .from('profiles')
          .delete()
          .eq('id', userId);
    } catch (e, stackTrace) {
      throw DatabaseException(
        message: 'Erro ao excluir perfil de usuário',
        originalException: e,
        stackTrace: stackTrace,
      );
    }
  }
}
```

## Passo 5: Implementar o ViewModel

O ViewModel é responsável pela lógica de negócios e gerenciamento de estado.

### Exemplo: `user_profile_view_model.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ray_club_app/core/errors/error_handler.dart';
import '../models/user_profile_state.dart';
import '../models/user_profile_model.dart';
import '../repositories/user_profile_repository_interface.dart';

// Provider para o repositório
final userProfileRepositoryProvider = Provider<UserProfileRepositoryInterface>((ref) {
  throw UnimplementedError();
});

// Provider para o ViewModel
final userProfileViewModelProvider = StateNotifierProvider<UserProfileViewModel, UserProfileState>((ref) {
  final repository = ref.watch(userProfileRepositoryProvider);
  final errorHandler = ref.watch(errorHandlerProvider);
  return UserProfileViewModel(repository, errorHandler);
});

class UserProfileViewModel extends StateNotifier<UserProfileState> {
  final UserProfileRepositoryInterface _repository;
  final ErrorHandler _errorHandler;
  
  UserProfileViewModel(this._repository, this._errorHandler) 
      : super(const UserProfileState());
  
  Future<void> loadUserProfile(String userId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null, isUpdated: false);
      
      final profile = await _repository.getUserProfile(userId);
      
      state = state.copyWith(
        profile: profile,
        isLoading: false,
      );
    } catch (e, stackTrace) {
      final message = _errorHandler.getUserFriendlyMessage(e);
      _errorHandler.handle(e, stackTrace);
      
      state = state.copyWith(
        isLoading: false,
        errorMessage: message,
      );
    }
  }
  
  Future<void> updateUserProfile(UserProfile updatedProfile) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null, isUpdated: false);
      
      final profile = await _repository.updateUserProfile(updatedProfile);
      
      state = state.copyWith(
        profile: profile,
        isLoading: false,
        isUpdated: true,
      );
    } catch (e, stackTrace) {
      final message = _errorHandler.getUserFriendlyMessage(e);
      _errorHandler.handle(e, stackTrace);
      
      state = state.copyWith(
        isLoading: false,
        errorMessage: message,
      );
    }
  }
  
  Future<void> deleteUserProfile(String userId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      await _repository.deleteUserProfile(userId);
      
      state = state.copyWith(
        profile: null,
        isLoading: false,
      );
    } catch (e, stackTrace) {
      final message = _errorHandler.getUserFriendlyMessage(e);
      _errorHandler.handle(e, stackTrace);
      
      state = state.copyWith(
        isLoading: false,
        errorMessage: message,
      );
    }
  }
}
```

## Passo 6: Implementar a Tela

Finalmente, implementamos a tela que utilizará o ViewModel.

### Exemplo: `user_profile_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:ray_club_app/core/widgets/error_widget.dart';
import '../viewmodels/user_profile_view_model.dart';
import '../models/user_profile_model.dart';

@RoutePage()
class UserProfileScreen extends HookConsumerWidget {
  final String userId;
  
  const UserProfileScreen({
    Key? key,
    @PathParam('id') required this.userId,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(userProfileViewModelProvider);
    final viewModel = ref.read(userProfileViewModelProvider.notifier);
    
    // Efeito para carregar o perfil quando a tela for construída
    useEffect(() {
      viewModel.loadUserProfile(userId);
      return null;
    }, const []);
    
    // Efeito para mostrar snackbar quando o perfil for atualizado
    useEffect(() {
      if (state.isUpdated) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Perfil atualizado com sucesso!')),
          );
        });
      }
      return null;
    }, [state.isUpdated]);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil do Usuário'),
        centerTitle: true,
      ),
      body: _buildBody(context, state, viewModel),
    );
  }
  
  Widget _buildBody(BuildContext context, UserProfileState state, UserProfileViewModel viewModel) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (state.errorMessage != null) {
      return Center(
        child: AppErrorWidget(
          message: state.errorMessage!,
          onRetry: () => viewModel.loadUserProfile(userId),
        ),
      );
    }
    
    final profile = state.profile;
    if (profile == null) {
      return const Center(child: Text('Perfil não encontrado'));
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar
          CircleAvatar(
            radius: 60,
            backgroundImage: profile.photoUrl != null
                ? NetworkImage(profile.photoUrl!)
                : null,
            child: profile.photoUrl == null
                ? const Icon(Icons.person, size: 60)
                : null,
          ),
          
          const SizedBox(height: 16),
          
          // Nome
          Text(
            profile.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Email
          if (profile.email != null)
            Text(
              profile.email!,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          
          const SizedBox(height: 16),
          
          // Status de verificação
          if (profile.isVerified)
            const Chip(
              backgroundColor: Colors.green,
              label: Text(
                'Verificado',
                style: TextStyle(color: Colors.white),
              ),
            ),
          
          const SizedBox(height: 32),
          
          // Botão de edição
          ElevatedButton.icon(
            onPressed: () {
              // Navegação para tela de edição
            },
            icon: const Icon(Icons.edit),
            label: const Text('Editar Perfil'),
          ),
        ],
      ),
    );
  }
}
```

## Passo 7: Registrar Providers

Registre os providers no arquivo `provider_setup.dart` para injeção de dependências.

```dart
// Em lib/core/di/provider_setup.dart
List<Override> get appProviders => [
  // ...outros providers
  
  // Repositório de perfil de usuário
  userProfileRepositoryProvider.overrideWithValue(
    UserProfileRepository(),
  ),
];
```

## Passo 8: Configurar Rotas

Configure as rotas no sistema de navegação.

```dart
// Em lib/core/router/app_router.dart
@AutoRouterConfig()
class AppRouter extends $AppRouter {
  @override
  List<AutoRoute> get routes => [
    // ...outras rotas
    AutoRoute(
      path: '/profile/:id',
      page: UserProfileRoute.page,
    ),
  ];
}
```

## Passo 9: Executar o Build Runner

Depois de definir os modelos com Freezed, execute o comando:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Este comando gera os arquivos `.freezed.dart` e `.g.dart` necessários.

## Passo 10: Testar o ViewModel

Crie testes unitários para o ViewModel usando mocks.

```dart
// Em test/features/user_profile/viewmodels/user_profile_view_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:ray_club_app/features/user_profile/models/user_profile_model.dart';
import 'package:ray_club_app/features/user_profile/viewmodels/user_profile_view_model.dart';

class MockUserProfileRepository extends Mock implements UserProfileRepositoryInterface {}
class MockErrorHandler extends Mock implements ErrorHandler {}

void main() {
  late UserProfileViewModel viewModel;
  late MockUserProfileRepository mockRepository;
  late MockErrorHandler mockErrorHandler;
  
  setUp(() {
    mockRepository = MockUserProfileRepository();
    mockErrorHandler = MockErrorHandler();
    viewModel = UserProfileViewModel(mockRepository, mockErrorHandler);
  });
  
  group('UserProfileViewModel Tests', () {
    test('initial state is correct', () {
      expect(viewModel.state.profile, null);
      expect(viewModel.state.isLoading, false);
      expect(viewModel.state.errorMessage, null);
      expect(viewModel.state.isUpdated, false);
    });
    
    test('loadUserProfile sets state correctly on success', () async {
      // Arrange
      const userId = 'user123';
      final testProfile = UserProfile(
        id: userId,
        name: 'Test User',
        email: 'test@example.com',
      );
      
      when(mockRepository.getUserProfile(userId))
          .thenAnswer((_) async => testProfile);
      
      // Act
      await viewModel.loadUserProfile(userId);
      
      // Assert
      expect(viewModel.state.profile, testProfile);
      expect(viewModel.state.isLoading, false);
      expect(viewModel.state.errorMessage, null);
    });
    
    // Mais testes...
  });
}
```

## Conclusão

Seguindo estes passos, você implementa corretamente o padrão MVVM em uma feature. Esta abordagem proporciona:

1. **Separação de responsabilidades**: Cada componente tem uma função bem definida
2. **Testabilidade**: Fácil criar testes unitários isolados
3. **Manutenção**: Código mais organizado e legível
4. **Reusabilidade**: Componentes podem ser reutilizados
5. **Tratamento de erros**: Centralizado no ViewModel 