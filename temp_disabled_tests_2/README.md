# Estratégia de Testes do Ray Club App

Este diretório contém os testes automatizados para o Ray Club App. A estratégia de testes segue a arquitetura MVVM do aplicativo, focando em cada camada:

## Estrutura de Testes

Os testes são organizados de acordo com a estrutura de features do aplicativo:

```
test/
├── core/                 # Testes para componentes do core (utilidades, serviços comuns)
└── features/             # Testes para features específicas
    ├── auth/             # Testes para autenticação
    ├── nutrition/        # Testes para funcionalidade de nutrição
    ├── profile/          # Testes para perfil de usuário
    └── workout/          # Testes para funcionalidade de treinos
        ├── models/       # Testes para modelos de dados
        ├── repositories/ # Testes para repositórios
        ├── viewmodels/   # Testes para ViewModels
        └── widgets/      # Testes de widgets e UI
```

## Tipos de Testes

### Testes de Unidade
- **Modelos**: Validam a serialização/deserialização e lógica de negócios
- **Repositórios**: Testam a comunicação com APIs e armazenamento usando mocks
- **ViewModels**: Verificam o gerenciamento de estado e lógica de apresentação

### Testes de Widgets
- Validam a renderização correta da UI
- Testam interações do usuário
- Verificam o fluxo de dados entre UI e ViewModels

### Testes de Integração
- Verificam a comunicação entre diferentes componentes
- Testam fluxos de usuário completos

## Estratégia de Mock

Para isolar os componentes durante os testes, utilizamos:

- **Mocktail**: Para criar mocks de classes e interfaces
- **Mock ViewModels**: Em alguns casos, criamos implementações simplificadas para facilitar os testes

## Cobertura de Testes

Nosso objetivo é manter uma cobertura de testes de pelo menos 80% para ViewModels e Repositórios, garantindo que a lógica principal do aplicativo esteja bem testada.

Para verificar a cobertura, execute:

```bash
flutter test --coverage
```

## Implementação Atual

Atualmente, as seguintes áreas possuem boa cobertura de testes:

- **Workout ViewModels**: ~80% de cobertura
- **Authentication**: ~70% de cobertura

Áreas em desenvolvimento de testes:

- **Nutrition**
- **Profile**

## Como Adicionar Novos Testes

1. Identifique o componente a ser testado
2. Crie o arquivo de teste na estrutura adequada
3. Implemente os casos de teste cobrindo os fluxos principais e de erro
4. Execute os testes e verifique a cobertura
5. Documente abordagens específicas em um README.md no diretório de testes 