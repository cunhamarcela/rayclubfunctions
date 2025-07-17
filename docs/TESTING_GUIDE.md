# Guia de Testes do Ray Club App

Este documento descreve a abordagem de testes adotada no Ray Club App, com foco especial nos testes de ViewModels dentro do padrão MVVM.

## Índice
1. [Introdução](#introdução)
2. [Estrutura de Testes](#estrutura-de-testes)
3. [Testando ViewModels](#testando-viewmodels)
4. [Mocks e Simulações](#mocks-e-simulações)
5. [Exemplos Práticos](#exemplos-práticos)
6. [Melhores Práticas](#melhores-práticas)

## Introdução

Testes automatizados são essenciais para garantir a qualidade e manutenibilidade do Ray Club App. Nossa estratégia de testes segue a pirâmide de testes, com:

- **Testes Unitários**: Testam componentes individuais (models, viewmodels, repositories)
- **Testes de Integração**: Testam a integração entre componentes
- **Testes de Widget**: Testam a interface do usuário e interações

Este guia foca principalmente nos testes unitários para ViewModels, que são fundamentais para validar a lógica de negócios e o gerenciamento de estado na arquitetura MVVM.

## Estrutura de Testes

Os testes seguem uma estrutura espelhada da estrutura do código fonte:

```
test/
├── features/
│   ├── auth/
│   │   ├── models/
│   │   ├── repositories/
│   │   └── viewmodels/
│   │       └── auth_view_model_test.dart
│   ├── nutrition/
│   ├── workout/
│   │   └── viewmodels/
│   │       └── workout_view_model_test.dart
│   └── ...
├── core/
│   ├── errors/
│   ├── services/
│   └── providers/
└── integration/
    └── ...
```

Cada teste de ViewModel deve estar na pasta correspondente à feature que está sendo testada.

## Testando ViewModels

Os ViewModels no Ray Club seguem o padrão StateNotifier com Riverpod, o que os torna ideais para testes unitários. Ao testar um ViewModel, concentramos nos seguintes aspectos:

1. **Estado Inicial**: Verificar se o ViewModel inicializa com o estado correto
2. **Transições de Estado**: Testar se o estado muda corretamente em resposta a ações
3. **Tratamento de Erros**: Verificar se erros são capturados e apresentados adequadamente
4. **Interações com Repositórios**: Testar se as chamadas para repositórios são feitas corretamente

### Estrutura Básica de um Teste de ViewModel

```dart
void main() {
  late MyViewModel viewModel;
  late MockRepository mockRepository;

  setUp(() {
    mockRepository = MockRepository();
    viewModel = MyViewModel(mockRepository);
  });

  group('MyViewModel', () {
    test('should initialize with correct state', () {
      // Arrange
      // Act - pode ser apenas a inicialização no setUp
      // Assert
      expect(viewModel.state, isA<InitialState>());
    });

    test('should update state when action is called', () async {
      // Arrange
      when(() => mockRepository.someMethod())
          .thenAnswer((_) async => someExpectedValue);
      
      // Act
      await viewModel.someAction();
      
      // Assert
      expect(viewModel.state, isA<SuccessState>());
    });
  });
}
```

## Mocks e Simulações

Usamos o pacote `mocktail` para criar mocks dos repositórios e outros serviços que o ViewModel depende. 

### Criando Mocks com Mocktail

```dart
// Criar classe mock que implementa a interface do repositório
class MockAuthRepository extends Mock implements IAuthRepository {}

// Para classes concretas que precisam ser mockadas
class MockSupabaseUser extends Mock implements supabase.User {}
```

### Configurando Comportamentos de Mock

```dart
// Configurar comportamento para retornar um valor específico
when(() => mockRepository.getUser()).thenAnswer((_) async => mockUser);

// Configurar comportamento para lançar exceção
when(() => mockRepository.getUser()).thenThrow(AuthException(message: 'Error'));

// Verificar se o método foi chamado
verify(() => mockRepository.getUser()).called(1);
```

## Exemplos Práticos

### Exemplo 1: Testando AuthViewModel

O AuthViewModel gerencia o processo de autenticação, com estados para login, registro, recuperação de senha, etc.

```dart
// Trecho do auth_view_model_test.dart
group('signIn', () {
  test('should update state to authenticated when login succeeds', () async {
    // Arrange
    when(() => mockRepository.signIn('test@example.com', 'password123'))
        .thenAnswer((_) async => mockSupabaseUser);

    // Act
    await viewModel.signIn('test@example.com', 'password123');

    // Assert
    expect(
      viewModel.state,
      isA<AuthState>().having(
        (state) => state.maybeWhen(
          authenticated: (user) => user.id == 'test-id',
          orElse: () => false,
        ),
        'state is authenticated with correct user',
        true,
      ),
    );
  });
});
```

### Exemplo 2: Testando WorkoutViewModel

O WorkoutViewModel gerencia o carregamento, filtragem e seleção de treinos.

```dart
// Trecho do workout_view_model_test.dart
group('filterByCategory', () {
  test('deve filtrar treinos por categoria corretamente', () async {
    // Arrange
    when(() => mockRepository.getWorkouts()).thenAnswer((_) async => testWorkouts);
    await viewModel.loadWorkouts();

    // Act
    viewModel.filterByCategory('Yoga');

    // Assert
    expect(
      viewModel.state,
      isA<WorkoutState>().having(
        (state) => state.maybeWhen(
          loaded: (_, filteredWorkouts, __, filter) => 
            filteredWorkouts.length == 1 && 
            filteredWorkouts.first.type == 'Yoga',
          orElse: () => false,
        ),
        'estado com treinos filtrados por categoria Yoga',
        true,
      ),
    );
  });
});
```

## Melhores Práticas

### Estrutura de Testes

1. **Organize pelo padrão AAA**: Arrange (preparar), Act (agir), Assert (verificar)
2. **Use `group` para agrupar testes relacionados**: Agrupe testes por funcionalidade ou método
3. **Nomeie testes descritivamente**: Use nomes que descrevam o comportamento esperado, não a implementação

### Mocks e Dados de Teste

1. **Configure mocks no `setUp`**: Defina comportamentos comuns no `setUp` para reduzir repetição
2. **Crie factories para dados de teste**: Facilita a criação de objetos para teste
3. **Evite dados aleatórios**: Use dados determinísticos para garantir resultados consistentes

### Asserções

1. **Verifique o estado específico**: Use `isA<T>().having()` para verificar propriedades específicas
2. **Prefira matchers a comparações diretas**: Use `equals`, `contains`, `isA`, etc.
3. **Teste transições de estado**: Verifique se o estado muda corretamente em resposta a ações

### Tratamento de Erros

1. **Teste casos de erro**: Certifique-se de testar o comportamento quando erros ocorrem
2. **Verifique mensagens de erro**: Confirme se as mensagens são apropriadas

## Conclusão

Seguindo estas diretrizes, podemos garantir que os ViewModels do Ray Club App funcionem conforme esperado e continuem funcionando à medida que o código evolui. Os testes de ViewModel são particularmente valiosos na arquitetura MVVM, pois eles validam a lógica central de negócios e gerenciamento de estado do aplicativo. 