# Ray Club App - Melhores Práticas de Arquitetura

Este documento serve como guia de melhores práticas para desenvolvedores que trabalham no Ray Club App, garantindo consistência e qualidade em todo o código.

## Princípios Gerais

1. **Seguir o padrão MVVM com Riverpod**
   - Models: Representação dos dados
   - ViewModels: Gerenciamento de estado e lógica de apresentação
   - Views: Interface do usuário
   - Repositories: Acesso a dados e APIs

2. **Evitar acoplamento forte**
   - Use injeção de dependências via Riverpod
   - Trabalhe com interfaces e não implementações concretas
   - Teste cada componente de forma isolada

3. **Centralização de código compartilhado**
   - Serviços comuns devem estar em `/lib/core/services/`
   - Componentes de UI reutilizáveis em `/lib/shared/widgets/`
   - Utilitários em `/lib/utils/`

4. **Tratamento adequado de erros**
   - Capture exceções no nível apropriado (geralmente ViewModel)
   - Use tipos específicos de exceção para diferentes situações
   - Forneça mensagens de erro claras para os usuários

## Providers

1. **Localização Centralizada**
   - Providers de recurso global: `/lib/core/providers/`
   - Providers de feature: `/lib/features/feature_name/providers/`

2. **Definição Única**
   - Cada provider deve ser definido em apenas um local
   - Use comentários para indicar a localização de um provider importado

3. **Hierarquia de Dependências**
   - Repository providers → Service providers → ViewModel providers → UI providers

## Repositórios

1. **Estrutura**
   - Interface: `abstract class FeatureRepository`
   - Implementação: `class SupabaseFeatureRepository implements FeatureRepository`

2. **Responsabilidades**
   - Acesso a dados (Supabase, APIs, local storage)
   - Mapeamento de respostas para models
   - Tratamento de erros específicos de dados
   - Não deve conter lógica de negócio complexa

3. **Convenções de Nomenclatura**
   - Métodos descritivos: `getUserById`, `createWorkout`, etc.
   - Padronização de retornos: objetos para operações de leitura, void/bool para operações de escrita

## ViewModels

1. **Estrutura**
   - Extends `StateNotifier<T>` ou classe padrão se não gerenciar estado
   - Estado imutável: `class FeatureState`
   - Provider: `StateNotifierProvider<FeatureViewModel, FeatureState>`

2. **Responsabilidades**
   - Lógica de negócio e apresentação
   - Gerenciamento de estado
   - Tratamento de erros de alto nível
   - Coordenação entre múltiplos repositórios

3. **Convenções de Nomenclatura**
   - `NomeFeatureViewModel`: nome descritivo
   - Métodos públicos para ações do usuário: `login()`, `saveWorkout()`, etc.

## Models

1. **Estrutura**
   - Imutáveis com `copyWith` para modificações
   - Serialização com fromJson/toJson
   - Documentação clara de campos

2. **Boas Práticas**
   - Usar tipos seguros (evitar dynamic)
   - Validação no construtor
   - Implementar toString() para depuração

## Testes

1. **Categorias**
   - Unit tests: para lógica isolada e pura
   - Widget tests: para componentes de UI
   - Integration tests: para fluxos completos

2. **Estrutura**
   - Usar mocks para dependências (Mockito ou Mocktail)
   - Testar casos de sucesso e falha
   - Agrupar testes relacionados com `group()`

3. **Padrões**
   - Arrange-Act-Assert
   - Nomes descritivos: should_do_something_when_condition

## Supabase e Persistência de Dados

1. **Boas Práticas**
   - Encapsular toda lógica do Supabase em repositories
   - Tratar erros específicos do Supabase
   - Definir tipos fortemente tipados para as tabelas

2. **Gerenciamento de Estado**
   - Usar streams para dados em tempo real
   - Cache local para dados frequentemente acessados
   - Estratégias de offline-first para operações críticas

## Controle de Versão

1. **Branching**
   - feature/nome-da-feature: para novas features
   - fix/descricao-do-bug: para correções
   - refactor/escopo: para refatorações

2. **Commits**
   - Mensagens claras e descritivas
   - Commits pequenos e focados
   - Referência a issues/tasks quando aplicável

## Análise de Código

1. **Lint e Formatação**
   - Seguir as regras do análise.yaml
   - Executar `flutter analyze` antes de commits
   - Tratar todos os warnings como erros

2. **Code Review**
   - Verificar arquitetura e design
   - Garantir teste adequado
   - Validar tratamento de erros
   - Checar desempenho e manutenibilidade 