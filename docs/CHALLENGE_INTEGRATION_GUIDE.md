# Guia de Integração do Sistema de Desafios do Ray Club

Este guia explica como configurar e integrar corretamente o sistema de desafios do Ray Club com treinos, garantindo que o progresso dos usuários seja registrado e monitorado adequadamente.

## 1. Configuração do Banco de Dados Supabase

### Pré-requisitos
- Acesso ao console do Supabase
- Permissões para executar scripts SQL

### Executando o Script de Configuração

1. Acesse o painel de administração do Supabase
2. Navegue até "SQL Editor"
3. Copie o conteúdo do arquivo `db/supabase_challenge_setup.sql`
4. Cole no editor SQL e execute

Este script irá:
- Criar as tabelas necessárias (`challenge_participants`, `challenge_check_ins`, `challenge_bonuses`)
- Configurar índices para melhor performance
- Ativar Row Level Security (RLS) nas tabelas
- Criar políticas de segurança
- Adicionar campos extras à tabela `challenge_progress` se necessário
- Configurar triggers para atualização automática de progresso

### Verificando a Instalação

Após executar o script, verifique:

1. As tabelas foram criadas corretamente:
   ```sql
   SELECT * FROM pg_tables WHERE tablename LIKE 'challenge%';
   ```

2. As políticas de segurança estão ativas:
   ```sql
   SELECT * FROM pg_policies WHERE tablename LIKE 'challenge%';
   ```

3. Os triggers estão funcionando:
   ```sql
   SELECT * FROM pg_trigger WHERE tgname LIKE 'trg_%';
   ```

## 2. Integração de Código

O código necessário já está implementado no projeto, mas certifique-se de que os seguintes componentes estão funcionando corretamente:

### WorkoutChallengeService

Este serviço é responsável por processar a conclusão de treinos e registrar o progresso nos desafios. Está localizado em `lib/services/workout_challenge_service.dart` e deve ser chamado quando um treino é concluído.

Principais métodos:
- `processWorkoutCompletion`: Registra a conclusão de um treino em todos os desafios ativos do usuário
- `_processRayChallengeCheckIn`: Processamento específico para desafios oficiais
- `_processConsecutiveDaysBonus`: Adiciona bônus para sequências de dias consecutivos

### ChallengeRepository

O repositório (implementado em `lib/features/challenges/repositories/challenge_repository.dart`) possui métodos para interagir com as tabelas de desafios:

- `hasCheckedInOnDate`: Verifica se um usuário já fez check-in em um desafio em uma data específica
- `recordChallengeCheckIn`: Registra um check-in para um desafio
- `getConsecutiveDaysCount`: Calcula dias consecutivos de check-in
- `addBonusPoints`: Adiciona pontos de bônus

### ChallengeImageService

Este serviço foi atualizado para lidar com problemas de URLs de imagens que retornam 404:

- Mantém uma lista de URLs conhecidas que falham
- Substitui por URLs validadas
- Tem fallbacks para imagens locais

## 3. Fluxo de Integração

### Quando um Treino é Concluído

1. O `UserWorkoutViewModel` chama o `WorkoutChallengeService.processWorkoutCompletion()`
2. O serviço busca todos os desafios ativos do usuário
3. Para cada desafio:
   - Verifica se já houve check-in na data atual
   - Se não, registra um check-in
   - Calcula e adiciona bônus por dias consecutivos

### Quando o Usuário Visualiza Desafios

1. O aplicativo carrega os desafios usando `ChallengeViewModel`
2. Para exibir imagens, utiliza o `ChallengeImageService` 
3. O serviço verifica se a URL da imagem é válida
4. Se não for, substitui por uma URL validada ou imagem local

## 4. Troubleshooting

### Erros de Imagem

Se você continuar vendo erros 404 para imagens:

1. Adicione as URLs problemáticas à lista `_knownBadUrls` em `ChallengeImageService`
2. Verifique se as imagens locais de fallback existem no projeto

### Erros de Banco de Dados

Se ocorrerem erros ao acessar as tabelas:

1. Verifique se o script SQL foi executado corretamente
2. Confira se as políticas RLS estão permitindo o acesso esperado
3. Teste as queries diretamente no SQL Editor do Supabase

### Pontos de Verificação

Se o progresso não estiver sendo atualizado:

1. Verifique se o `WorkoutChallengeService` está sendo chamado corretamente
2. Teste o método `hasCheckedInOnDate` para garantir que está funcionando
3. Confirme se a tabela `challenge_check_ins` está recebendo registros

## 5. Testando a Integração

Siga estes passos para testar a integração:

1. Crie um desafio de teste
2. Participe do desafio
3. Complete um treino
4. Verifique se um check-in foi registrado na tabela `challenge_check_ins`
5. Confirme se os pontos foram adicionados na tabela `challenge_progress`
6. Complete treinos em dias consecutivos e verifique se o bônus é aplicado

## 6. Melhorias Futuras

- Implementar sistema de notificações para lembrar usuários de completar desafios
- Adicionar suporte para desafios com regras mais complexas
- Criar dashboard de administração para monitorar progresso em desafios
- Implementar sistema de exportação de resultados

---

Para mais informações, consulte:
- `README.md` do projeto
- Documentação do Supabase
- Arquitetura MVVM com Riverpod em `ARCHITECTURE.md` 