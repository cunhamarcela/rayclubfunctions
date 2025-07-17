-- ================================================================
-- SCRIPT PARA CORRIGIR ESTRUTURA DAS TABELAS EXISTENTES
-- Execute este script se você receber erro de "column does not exist"
-- ================================================================

\echo '🔧 CORRIGINDO ESTRUTURA DAS TABELAS EXISTENTES'
\echo '=============================================='

-- ================================================================
-- 1. VERIFICAR E CORRIGIR check_in_error_logs
-- ================================================================

\echo ''
\echo '📋 1. VERIFICANDO TABELA check_in_error_logs'

-- Verificar se a tabela existe
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'check_in_error_logs') 
        THEN '✅ Tabela check_in_error_logs encontrada'
        ELSE '❌ Tabela check_in_error_logs não existe - será criada'
    END as status_tabela;

-- Criar tabela se não existir
CREATE TABLE IF NOT EXISTS check_in_error_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    challenge_id UUID,
    workout_id UUID,
    request_data JSONB,
    response_data JSONB,
    error_message TEXT,
    error_detail TEXT,
    error_type TEXT,
    status TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    resolved_at TIMESTAMP WITH TIME ZONE
);

SELECT '✅ Tabela check_in_error_logs verificada/criada' as resultado;

-- Verificar e adicionar colunas que podem estar faltando
SELECT 
    'VERIFICAÇÃO COLUNAS' as categoria,
    required_columns.column_name as coluna,
    CASE 
        WHEN c.column_name IS NOT NULL THEN '✅ Já existe'
        ELSE '❌ Não existe'
    END as status
FROM (
    VALUES 
        ('error_type'),
        ('error_detail'), 
        ('status'),
        ('resolved_at'),
        ('request_data'),
        ('response_data')
) AS required_columns(column_name)
LEFT JOIN information_schema.columns c 
    ON c.table_name = 'check_in_error_logs' 
    AND c.column_name = required_columns.column_name;

-- Adicionar colunas que faltam
ALTER TABLE check_in_error_logs ADD COLUMN IF NOT EXISTS error_type TEXT;
ALTER TABLE check_in_error_logs ADD COLUMN IF NOT EXISTS error_detail TEXT;
ALTER TABLE check_in_error_logs ADD COLUMN IF NOT EXISTS status TEXT;
ALTER TABLE check_in_error_logs ADD COLUMN IF NOT EXISTS resolved_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE check_in_error_logs ADD COLUMN IF NOT EXISTS request_data JSONB;
ALTER TABLE check_in_error_logs ADD COLUMN IF NOT EXISTS response_data JSONB;

SELECT '✅ Colunas da tabela check_in_error_logs verificadas/adicionadas' as resultado;

-- ================================================================
-- 2. VERIFICAR E CORRIGIR workout_processing_queue
-- ================================================================

\echo ''
\echo '📋 2. VERIFICANDO TABELA workout_processing_queue'

-- Verificar se a tabela existe
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'workout_processing_queue') 
        THEN '✅ Tabela workout_processing_queue encontrada'
        ELSE '❌ Tabela workout_processing_queue não existe - será criada'
    END as status_tabela;

-- Criar tabela se não existir
CREATE TABLE IF NOT EXISTS workout_processing_queue (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workout_id UUID NOT NULL,
    user_id UUID NOT NULL,
    challenge_id UUID,
    processed_for_ranking BOOLEAN DEFAULT FALSE,
    processed_for_dashboard BOOLEAN DEFAULT FALSE,
    processing_error TEXT,
    retry_count INTEGER DEFAULT 0,
    max_retries INTEGER DEFAULT 3,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    processed_at TIMESTAMP WITH TIME ZONE,
    next_retry_at TIMESTAMP WITH TIME ZONE
);

SELECT '✅ Tabela workout_processing_queue verificada/criada' as resultado;

-- Verificar e adicionar colunas que podem estar faltando
SELECT 
    'VERIFICAÇÃO COLUNAS' as categoria,
    required_columns.column_name as coluna,
    CASE 
        WHEN c.column_name IS NOT NULL THEN '✅ Já existe'
        ELSE '❌ Não existe'
    END as status
FROM (
    VALUES 
        ('processed_for_dashboard'),
        ('retry_count'), 
        ('max_retries'),
        ('next_retry_at')
) AS required_columns(column_name)
LEFT JOIN information_schema.columns c 
    ON c.table_name = 'workout_processing_queue' 
    AND c.column_name = required_columns.column_name;

-- Adicionar colunas que faltam
ALTER TABLE workout_processing_queue ADD COLUMN IF NOT EXISTS processed_for_dashboard BOOLEAN DEFAULT FALSE;
ALTER TABLE workout_processing_queue ADD COLUMN IF NOT EXISTS retry_count INTEGER DEFAULT 0;
ALTER TABLE workout_processing_queue ADD COLUMN IF NOT EXISTS max_retries INTEGER DEFAULT 3;
ALTER TABLE workout_processing_queue ADD COLUMN IF NOT EXISTS next_retry_at TIMESTAMP WITH TIME ZONE;

SELECT '✅ Colunas da tabela workout_processing_queue verificadas/adicionadas' as resultado;

-- ================================================================
-- 3. CRIAR ÍNDICES NECESSÁRIOS
-- ================================================================

\echo ''
\echo '📋 3. CRIANDO ÍNDICES NECESSÁRIOS'

-- Índices para check_in_error_logs
CREATE INDEX IF NOT EXISTS idx_checkin_error_logs_user_date
ON check_in_error_logs(user_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_checkin_error_logs_status
ON check_in_error_logs(status, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_checkin_error_logs_error_type
ON check_in_error_logs(error_type, created_at DESC);

-- Índices para workout_processing_queue
CREATE INDEX IF NOT EXISTS idx_workout_queue_pending
ON workout_processing_queue(processed_for_ranking, processed_for_dashboard, next_retry_at)
WHERE processed_for_ranking = FALSE OR processed_for_dashboard = FALSE;

-- Verificar índices criados
SELECT 
    'ÍNDICES CRIADOS' as categoria,
    indexname as nome_indice,
    tablename as tabela,
    '✅ Criado' as status
FROM pg_indexes 
WHERE tablename IN ('check_in_error_logs', 'workout_processing_queue')
AND indexname LIKE 'idx_%'
ORDER BY tablename, indexname;

-- ================================================================
-- 4. VERIFICAÇÃO FINAL
-- ================================================================

\echo ''
\echo '📋 4. VERIFICAÇÃO FINAL DA ESTRUTURA'

-- Mostrar estrutura atual das tabelas
SELECT 
    'check_in_error_logs' as tabela,
    column_name as coluna,
    data_type as tipo,
    is_nullable as permite_null
FROM information_schema.columns 
WHERE table_name = 'check_in_error_logs'
ORDER BY ordinal_position;

SELECT 
    'workout_processing_queue' as tabela,
    column_name as coluna,
    data_type as tipo,
    is_nullable as permite_null
FROM information_schema.columns 
WHERE table_name = 'workout_processing_queue'
ORDER BY ordinal_position;

\echo ''
\echo '✅ ESTRUTURA DAS TABELAS CORRIGIDA COM SUCESSO!'
\echo 'Agora você pode executar o script principal.' 