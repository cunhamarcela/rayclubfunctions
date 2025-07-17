# Guia de Contribuição para o Ray Club App

Este guia apresenta as diretrizes para contribuir com o projeto Ray Club App.

## Princípios Gerais

1. **Seguir o padrão MVVM**: Sempre use ViewModels e Providers (Riverpod) para gerenciar estado - nunca use setState().
2. **Manter a documentação atualizada**: Atualize a documentação técnica ao fazer alterações no código.
3. **Escrever testes**: Toda feature/fix deve ter testes apropriados.
4. **Code review**: Todo código deve passar por pelo menos um revisor antes de ser integrado.

## Fluxo de Desenvolvimento

1. Escolha uma tarefa do checklist (UPDATED_CHECKLIST.md)
2. Crie uma branch no formato `feature/nome-da-feature` ou `fix/nome-do-fix`
3. Desenvolva com testes correspondentes
4. Atualize a documentação técnica (TECHNICAL_DOCUMENTATION.md)
5. Abra um Pull Request detalhando as mudanças
6. Após a aprovação, faça o merge para a branch `develop`

## Atualização da Documentação

Sempre que fizer alterações significativas no código, atualize o documento TECHNICAL_DOCUMENTATION.md:

1. **Adicione uma entrada no Changelog**: Na seção 12.3, inclua uma linha com a data, seu nome e a descrição da alteração.
2. **Atualize a seção relevante**: Modifique as seções do documento que correspondem à sua mudança.
3. **Detalhe padrões e decisões**: Explique o porquê das decisões técnicas tomadas.

É obrigatório atualizar a documentação nas seguintes situações:
- Adição de novos serviços ou providers
- Mudanças na arquitetura
- Alterações em políticas de segurança
- Adição de novas dependências externas

## Padrões de Código

### Dart/Flutter
- Siga as [diretrizes oficiais de estilo do Dart](https://dart.dev/guides/language/effective-dart/style)
- Use o formatter `dart format` antes de submeter código
- Resolva todos os warnings do lint

### Nomenclatura
- Classes: PascalCase
- Variáveis e métodos: camelCase
- Constantes: SNAKE_CASE maiúsculo
- Arquivos: snake_case minúsculo

### Estrutura de Features
Mantenha a estrutura organizada por features, com cada feature contendo:
- `models/`: Modelos de dados e definições
- `repositories/`: Acesso a dados e operações CRUD
- `viewmodels/`: Lógica de negócios e estado
- `screens/`: Componentes de UI de nível superior
- `widgets/`: Componentes de UI reutilizáveis

## Segurança

- **Nunca** exponha chaves ou credenciais no código
- Sempre use variáveis de ambiente via `.env`
- Valide todos os inputs do usuário
- Implementar tratamento de erros adequado para todos os casos
- Utilizar o SecureStorageService para dados sensíveis

## Dúvidas e Esclarecimentos

Se precisar de ajuda, entre em contato com a equipe de desenvolvimento ou consulte o documento TECHNICAL_DOCUMENTATION.md para informações detalhadas sobre a arquitetura e implementação. 