# Lógica de Registro de Treino e Check-in no Ray Club

## Visão Geral
O sistema de registro de treino e check-in é um componente central do aplicativo Ray Club, permitindo que os usuários registrem suas atividades físicas e, simultaneamente, façam check-in em desafios. Este documento explica como este sistema funciona, a integração entre as diferentes tabelas e a lógica por trás da função centralizada.

## Estrutura de Dados

### Tabelas Principais
1. **workout_records**
   - Armazena os registros de treinos dos usuários
   - Cada registro contém: tipo de treino, duração, data, usuário, etc.

2. **challenge_check_ins**
   - Registra os check-ins em desafios 
   - Conecta um treino a um desafio específico

3. **challenge_progress**
   - Mantém o progresso do usuário em cada desafio
   - Campos: pontos, posição no ranking, streak, check-ins totais

4. **user_progress**
   - Mantém estatísticas gerais do usuário
   - Campos: pontos totais, nível, workouts, streaks

5. **challenge_participants**
   - Registra a participação de usuários em desafios

## Fluxo de Execução

### 1. Registro de Treino via App
```
Flutter App → RegisterExerciseSheet → RegisterWorkoutViewModel → SupabaseWorkoutRepository → record_challenge_check_in_v2
```

O usuário inicia o processo através do botão de registro na barra inferior (botão central) ou na tela de detalhe de um desafio específico.

### 2. Processamento no Backend

#### Através da Função Centralizada `record_challenge_check_in_v2`:

1. **Verificação Inicial**
   - Verifica se já existe check-in para o usuário/desafio/data
   - Obtém informações do desafio (pontos base)
   - Obtém informações do usuário (nome, foto)

2. **Cálculo de Streak e Pontos**
   - Verifica último check-in para calcular dias consecutivos
   - Aplica bônus de pontos baseado no streak:
     - 3-6 dias: +1 ponto
     - 7-14 dias: +2 pontos
     - 15-29 dias: +3 pontos
     - 30+ dias: +5 pontos

3. **Inserção de Dados**
   - Insere check-in na tabela `challenge_check_ins`
   - Atualiza ou cria progresso na tabela `challenge_progress`
   - Verifica e atualiza participação na tabela `challenge_participants`
   - Atualiza estatísticas gerais em `user_progress`

4. **Atualização de Ranking**
   - Recalcula posições de todos os participantes no desafio

### 3. Tratamento de Erros
- Em caso de erro, a função registra detalhes na tabela `check_in_error_logs`
- O sistema mostra uma mensagem amigável ao usuário no app
- A estrutura transacional garante que nenhum dado parcial seja salvo em caso de erro

## Detalhes Técnicos

### Pontos Importantes
1. **Transação Atômica**: Todas as operações são executadas em uma única transação
2. **Prevenção de Condições de Corrida**: Uso de `SELECT FOR UPDATE` em consultas críticas
3. **Validação de Duplicidade**: Verificação explícita de check-ins duplicados
4. **Nomenclatura de Colunas**: Respeito às convenções específicas de cada tabela:
   - `check_ins_count` em `challenge_progress`
   - `total_check_ins` em `user_progress`
5. **Qualificação de Referências**: Uso de aliases para evitar ambiguidades em nomes de colunas

### Diferenças da Implementação Anterior
A implementação anterior dependia de múltiplos triggers que:
- Causavam erros por tentar acessar campos inexistentes
- Criavam problemas de concorrência
- Dificultavam a manutenção e depuração

A nova implementação centraliza toda a lógica em uma função única, tornando o sistema mais robusto e facilitando futuras manutenções.

## Exemplos de Uso

### 1. Registro de Treino Regular
```dart
// No app Flutter
final result = await registerWorkoutViewModel.registerWorkout(
  name: "Treino de Musculação",
  type: "Força",
  durationMinutes: 60,
  intensity: 4.0,
);
```

### 2. Check-in em Desafio Específico
```dart
// No app Flutter
final result = await registerWorkoutViewModel.registerWorkoutForSpecificChallenge(
  name: "Corrida Matinal",
  type: "Cardio",
  durationMinutes: 30,
  intensity: 3.5,
  challengeId: "c7e921a3-f66c-4c9d-b8d7-5ec7d69e3675",
);
```

## Conclusão
A arquitetura de registro de treino e check-in do Ray Club foi projetada para ser robusta, eficiente e íntegra. A centralização da lógica em uma única função transacional garante consistência dos dados e elimina erros comuns associados a sistemas baseados em triggers. 