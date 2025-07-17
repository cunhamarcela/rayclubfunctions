# Documentação Técnica do Fluxo de Check-in

## Visão Geral da Arquitetura

O fluxo de check-in e registro de treinos no Ray Club foi simplificado para usar uma única função central (`record_challenge_check_in`) que controla todo o processo, eliminando a necessidade de triggers e simplificando o rastreamento do fluxo de dados.

## Fluxo de Dados

1. **App Flutter** chama a função RPC `record_challenge_check_in` com os seguintes parâmetros:
   - `challenge_id`: ID do desafio
   - `user_id`: ID do usuário
   - `workout_id`: ID do treino
   - `workout_name`: Nome do treino
   - `workout_type`: Tipo de treino
   - `duration_minutes`: Duração em minutos
   - `check_in_date`: Data do check-in

2. **Função `record_challenge_check_in`** executa:
   - Validação do desafio e usuário
   - Verificação de check-in duplicado para o mesmo dia/desafio
   - Registro do treino em `workout_records`
   - Atualização de `user_progress` (estatísticas gerais do usuário)
   - Se o treino for elegível para check-in no desafio (duração ≥ 45min):
     - Inserção em `challenge_check_ins`
     - Atualização de `challenge_progress`
     - Atualização do ranking do desafio

3. **Resultado** retornado ao App Flutter:
   - Sucesso ou falha
   - Pontos ganhos
   - Streak atual
   - Mensagem para o usuário

## Tabelas Principais

### `workout_records`
- Registra todos os treinos do usuário
- Contém `challenge_id` para associação direta com desafio
- Contém `points` para rastrear pontos concedidos pelo treino

### `challenge_check_ins`
- Registra apenas check-ins válidos para desafios
- Check-ins são inseridos apenas pela função RPC

### `challenge_progress`
- Rastreia o progresso do usuário em cada desafio
- Atualizada diretamente pela função RPC, não por triggers

### `user_progress`
- Rastreia estatísticas gerais do usuário
- Também atualizada diretamente pela função RPC

## Regras de Negócio

1. **Registro de Treino**:
   - Sempre registra treino em `workout_records`, independente da duração
   - Sempre atualiza `user_progress`, independente da duração

2. **Check-in no Desafio**:
   - Requer duração mínima de 45 minutos
   - Usuário deve ser participante do desafio
   - Máximo um check-in por desafio por dia

3. **Cálculo de Pontos**:
   - Pontos base definidos no desafio
   - Bônus por streak consecutivo (3, 7, 15, 30 dias)

4. **Atualização de Ranking**:
   - Posições recalculadas após cada check-in

## IMPORTANTE: Arquitetura Simplificada

A arquitetura atual não utiliza triggers para atualizar o progresso ou posições de ranking. Todas essas operações são realizadas diretamente pela função RPC `record_challenge_check_in`.

Tentativas anteriores de arquitetura usando triggers (`update_challenge_progress_on_check_in`, `update_progress_after_checkin`, etc.) foram descontinuadas para simplificar o fluxo e prevenir problemas de sincronização, loops infinitos e duplicação de processamento.

## Logs e Depuração

Para depurar o fluxo de check-in, use a função RPC expandida `record_challenge_check_in_v2` que inclui logs detalhados via `RAISE NOTICE`. Isso ajudará a identificar em qual etapa do processo possíveis problemas estão ocorrendo. 