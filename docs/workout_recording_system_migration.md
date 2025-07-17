# Migração do Sistema de Registro de Treinos

## Visão Geral

Este documento detalha a migração do sistema de registro de treinos do Ray Club App, movendo de uma arquitetura monolítica para um modelo split mais resiliente.

### Contexto

O sistema atual utiliza uma única função RPC grande (`record_challenge_check_in_v2`) que:
1. Registra treinos
2. Atualiza ranking de desafios
3. Atualiza dashboard do usuário

### Problemas Identificados

- Ponto único de falha
- Falhas em qualquer etapa afetam o registro principal
- Tempos de resposta variáveis
- Sobrecarga de bloqueios de banco de dados

### Nova Arquitetura

A nova arquitetura implementa um modelo split onde:

1. **Função de Registro Básico**: Garante apenas que o treino é registrado
2. **Função de Processamento de Ranking**: Atualiza pontuações e ranking em desafios
3. **Função de Atualização de Dashboard**: Atualiza métricas gerais do usuário
4. **Sistema de Logs Detalhados**: Rastreia todo o processo com múltiplas garantias

## Mudanças Técnicas

### 1. Novas Tabelas

```sql
-- Rastreamento de processamento
CREATE TABLE IF NOT EXISTS workout_processing_queue (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workout_id UUID NOT NULL REFERENCES workout_records(id) ON DELETE CASCADE,
    user_id UUID NOT NULL,
    challenge_id UUID,
    processed_for_ranking BOOLEAN DEFAULT FALSE,
    processed_for_dashboard BOOLEAN DEFAULT FALSE,
    processing_error TEXT,
    tracking_log_id UUID,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    processed_at TIMESTAMP WITH TIME ZONE
);

-- Logs ampliados
CREATE TABLE IF NOT EXISTS workout_tracking_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workout_id UUID,
    user_id UUID NOT NULL,
    challenge_id UUID,
    action TEXT NOT NULL,
    status TEXT NOT NULL,
    request_data JSONB NOT NULL,
    response_data JSONB,
    error_message TEXT,
    error_detail TEXT,
    stack_trace TEXT,
    processing_time_ms INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    client_info JSONB,
    is_exported BOOLEAN DEFAULT FALSE
);
```

### 2. Novas Funções

- `record_workout_basic`: Registra treino com garantias de consistência
- `process_workout_for_ranking`: Atualiza ranking de desafios
- `process_workout_for_dashboard`: Atualiza dashboard do usuário
- `diagnose_and_recover_workout_records`: Recupera registros com falhas

### 3. Função Wrapper para Compatibilidade

Mantém compatibilidade com o código Flutter existente, usando o mesmo nome e assinatura.

## Benefícios da Nova Arquitetura

- **Maior resiliência**: Falhas em um componente não afetam os outros
- **Rastreabilidade completa**: Logs detalhados em cada etapa
- **Performance melhorada**: Menor tempo de resposta para o usuário
- **Recuperação automatizada**: Sistema busca e corrige falhas
- **Menor contenção de recursos**: Bloqueios mais granulares no banco de dados

## Impacto na Experiência do Usuário

- Confirmação mais rápida de registro de treino
- Dashboard e rankings podem ter leve atraso (milissegundos a segundos)
- Sistema mais estável com menos erros visíveis

## Plano de Monitoramento

Após implementação, monitorar:
- Taxa de falhas em cada etapa
- Tempo médio de processamento
- Volume de registros pendentes

## Planos Futuros

Em versões futuras:
- Adicionar mais métricas de telemetria
- Interface visual para diagnóstico de problemas
- Processamento em batch para otimizações adicionais 