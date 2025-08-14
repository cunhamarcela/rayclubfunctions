-- =====================================================
-- 🔍 DIAGNÓSTICO COMPLETO DE ESTRUTURA E ALINHAMENTO
-- =====================================================
-- Data: 2025-01-30
-- Objetivo: Verificar alinhamento entre código Flutter e Supabase
-- =====================================================

-- 1. ESTRUTURA ATUAL DA TABELA user_goals
SELECT 
    '📋 ESTRUTURA ATUAL DA TABELA user_goals' AS diagnostico,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'user_goals' 
  AND table_schema = 'public'
ORDER BY ordinal_position;

-- 2. VERIFICAR COLUNAS OBRIGATÓRIAS PARA O SISTEMA UNIFICADO
WITH required_columns AS (
    SELECT unnest(ARRAY[
        'id', 'user_id', 'title', 'description', 'type', 
        'category', 'target', 'progress', 'unit', 'measurement_type',
        'start_date', 'end_date', 'completed_at', 'created_at', 'updated_at'
    ]) AS column_name
),
existing_columns AS (
    SELECT column_name
    FROM information_schema.columns 
    WHERE table_name = 'user_goals' 
      AND table_schema = 'public'
)
SELECT 
    '🔍 COLUNAS OBRIGATÓRIAS vs EXISTENTES' AS diagnostico,
    r.column_name,
    CASE 
        WHEN e.column_name IS NOT NULL THEN '✅ EXISTE'
        ELSE '❌ FALTANDO'
    END AS status
FROM required_columns r
LEFT JOIN existing_columns e ON r.column_name = e.column_name
ORDER BY r.column_name;

-- 3. MAPEAMENTO FLUTTER ↔ SUPABASE
SELECT '🔗 MAPEAMENTO CÓDIGO ↔ BANCO' AS info;

SELECT 'Flutter Field' AS flutter_field, 'Supabase Column' AS supabase_column, 'Tipo' AS tipo, 'Observação' AS observacao
UNION ALL
SELECT '═══════════', '═══════════', '════', '═══════════'
UNION ALL
SELECT 'id', 'id', 'UUID', 'Chave primária'
UNION ALL
SELECT 'userId', 'user_id', 'UUID', 'FK para auth.users'
UNION ALL
SELECT 'title', 'title', 'TEXT', 'Título da meta'
UNION ALL
SELECT 'description', 'description', 'TEXT', 'Descrição (pode ser null)'
UNION ALL
SELECT 'type.value', 'type', 'TEXT', 'workout_category/custom/etc'
UNION ALL
SELECT 'category?.displayName', 'category', 'TEXT', 'Funcional/Musculação/etc'
UNION ALL
SELECT 'targetValue', 'target', 'DECIMAL', 'Valor alvo'
UNION ALL
SELECT 'currentValue', 'progress', 'DECIMAL', 'Progresso atual'
UNION ALL
SELECT 'unit.value', 'unit', 'TEXT', 'minutos/dias/sessoes'
UNION ALL
SELECT 'measurementType', 'measurement_type', 'TEXT', 'minutes/days'
UNION ALL
SELECT 'startDate', 'start_date', 'TIMESTAMPTZ', 'Data de início'
UNION ALL
SELECT 'endDate', 'end_date', 'TIMESTAMPTZ', 'Data fim (opcional)'
UNION ALL
SELECT 'completedAt', 'completed_at', 'TIMESTAMPTZ', 'Data conclusão (opcional)'
UNION ALL
SELECT 'createdAt', 'created_at', 'TIMESTAMPTZ', 'Data criação'
UNION ALL
SELECT 'updatedAt', 'updated_at', 'TIMESTAMPTZ', 'Data atualização';

-- 4. VERIFICAR COMPATIBILIDADE COM workout_records
SELECT 
    '🏋️ TIPOS DE EXERCÍCIO EM workout_records' AS diagnostico,
    workout_type,
    COUNT(*) as quantidade
FROM public.workout_records 
WHERE workout_type IS NOT NULL
GROUP BY workout_type
ORDER BY quantidade DESC
LIMIT 10;

-- 5. VERIFICAR FUNÇÕES NECESSÁRIAS
SELECT 
    '⚙️ FUNÇÕES DO SISTEMA' AS diagnostico,
    routine_name,
    routine_type
FROM information_schema.routines 
WHERE routine_name IN (
    'update_goals_from_workout',
    'register_goal_checkin'
) AND routine_schema = 'public';

-- 6. VERIFICAR TRIGGERS
SELECT 
    '🔄 TRIGGERS ATIVOS' AS diagnostico,
    trigger_name,
    event_manipulation,
    action_timing
FROM information_schema.triggers 
WHERE trigger_name LIKE '%goal%' 
   OR trigger_name LIKE '%workout%';

-- 7. TESTE DE INSERÇÃO COM ESTRUTURA CORRETA
-- Primeiro, garantir que temos todas as colunas necessárias
DO $$
BEGIN
    -- Adicionar colunas se não existirem
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'user_goals' AND column_name = 'measurement_type'
    ) THEN
        ALTER TABLE public.user_goals ADD COLUMN measurement_type TEXT DEFAULT 'minutes';
        RAISE NOTICE '✅ Adicionada coluna measurement_type';
    END IF;
    
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'user_goals' AND column_name = 'category'
    ) THEN
        ALTER TABLE public.user_goals ADD COLUMN category TEXT;
        RAISE NOTICE '✅ Adicionada coluna category';
    END IF;
END $$;

-- 8. ESTRUTURA FINAL APÓS CORREÇÕES
SELECT 
    '📋 ESTRUTURA FINAL APÓS CORREÇÕES' AS diagnostico,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'user_goals' 
  AND table_schema = 'public'
ORDER BY ordinal_position;

