# Ray Club App - Architectural Pattern Guide

## MVVM with Riverpod

O Ray Club App segue o padrão MVVM (Model-View-ViewModel) utilizando o Riverpod para gerenciamento de estado. Este documento estabelece os princípios e padrões a serem seguidos em todo o desenvolvimento.

## Estrutura de Diretórios

Cada feature deve seguir esta estrutura consistente:

```
features/
  feature_name/
    models/          # Modelos de dados
    repositories/    # Interfaces e implementações de acesso a dados
      interface.dart # Interface abstrata do repositório
      implementation.dart # Implementação concreta (ex: usando Supabase)
    viewmodels/      # Lógica de apresentação e manipulação de estado
    providers/       # Providers Riverpod para injeção de dependências
    screens/         # Telas completas 
    widgets/         # Componentes reutilizáveis específicos da feature
```

## Princípios

1. **Separação de Responsabilidades**
   - Models: Representam os dados e regras de negócio
   - Repositories: Responsáveis pelo acesso a dados
   - ViewModels: Gerenciam o estado e a lógica de apresentação
   - Screens/Widgets: Responsáveis apenas pela UI

2. **Injeção de Dependências com Riverpod**
   - Use Provider para dependências simples
   - Use StateNotifierProvider para estado gerenciável
   - Use FutureProvider para dados assíncronos

3. **Tratamento de Erros**
   - Utilize exceções específicas do domínio (ex: AuthException, NetworkException)
   - Sempre trate erros no nível apropriado, preferencialmente no ViewModel

4. **Testes**
   - Cada componente deve ser testável isoladamente
   - Use mocks para dependências externas

## Boas Práticas

1. **Nunca use setState()**
   - Todo gerenciamento de estado deve ser feito através de ViewModels e Providers

2. **Tratamento de Null Safety**
   - Não use force-unwrap (!) em variáveis opcionais
   - Sempre trate nulls explicitamente
   - Use operadores de null safety (?., ??, ?..)

3. **Uso do Supabase**
   - Abstraia toda a lógica do Supabase nos repositories
   - Nunca acesse o cliente Supabase diretamente nas Views ou ViewModels

4. **Convenções de Nomenclatura**
   - ViewModels: NomeFeatureViewModel
   - Repositories: NomeFeatureRepository (interface) e SupabaseNomeFeatureRepository (implementação)
   - Providers: nomeFeatureRepositoryProvider, nomeFeatureViewModelProvider 