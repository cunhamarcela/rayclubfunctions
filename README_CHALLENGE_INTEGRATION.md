# Integração de Treinos e Desafios

## Visão Geral

No aplicativo, qualquer registro de treino automaticamente atualiza o progresso do usuário nos desafios ativos, especialmente o "Desafio da Ray". Essa integração permite que os usuários ganhem pontos em tempo real ao registrarem seus treinos.

## Estrutura Implementada

### Serviços
- **WorkoutChallengeService**: Processa a conclusão de treinos e atualiza os desafios ativos.
  - Chamado tanto pelo `UserWorkoutViewModel.completeWorkout()` (treinos do app) quanto pelo `RegisterWorkoutViewModel.registerWorkout()` (treinos manuais)
  - Verifica desafios ativos e registra check-ins
  - Atualiza a pontuação e classificação do usuário

### Fluxos de Registro de Treino

Existem dois fluxos principais para o registro de treinos:

1. **Treinos do App**:
   - Usuário assiste a um treino através da tela de detalhes do treino
   - Ao concluir, chama `completeWorkout()` no `UserWorkoutViewModel`
   - O treino é registrado e o `WorkoutChallengeService` é chamado

2. **Registro Manual**:
   - Usuário registra manualmente um treino através do `RegisterExerciseSheet`
   - Ao enviar o formulário, chama `registerWorkout()` no `RegisterWorkoutViewModel`
   - Um objeto `WorkoutRecord` é criado e enviado para o `WorkoutChallengeService`

### Tabelas do Banco de Dados
- `challenge_check_ins`: Registra cada check-in individual de treino para um desafio
- `challenge_progress`: Armazena o progresso acumulado de cada usuário em cada desafio

## Como Testar a Integração

1. Verifique que você está participando de pelo menos um desafio ativo
2. Registre um treino por qualquer um dos dois métodos:
   - Complete um treino através da tela de detalhes do treino
   - Use o botão "+ Registrar Treino" na tela inicial para registrar manualmente
3. Após registrar, verifique a tela de desafios para confirmar que seus pontos aumentaram
4. No banco de dados, você deve ver novos registros em `challenge_check_ins` e pontuação atualizada em `challenge_progress`

## Lógica de Pontuação

1. Quando um treino é concluído (tanto manualmente quanto pelo app):
   - O `WorkoutChallengeService.processWorkoutCompletion()` é chamado
   - O serviço verifica se o usuário participa de desafios ativos
   - Para cada desafio, verifica se já houve check-in no dia
   - Se não, registra um check-in e atualiza o progresso

2. Detalhes do processamento:
   - Cada desafio tem uma pontuação definida por check-in
   - Check-ins são limitados a um por dia por desafio
   - O sistema mantém um ranking atualizado dos participantes

3. Feedback ao usuário:
   - Após completar um treino, o usuário recebe uma mensagem indicando os pontos ganhos
   - A tela de desafios mostra o progresso atualizado e a posição no ranking

## Próximos Passos

- Implementar lógica de bônus para sequências de treinos
- Criar telas para check-ins manuais em desafios específicos
- Implementar notificações para lembrar usuários de completar treinos para os desafios 