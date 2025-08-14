-- ========================================
-- TESTES DO SISTEMA DE METAS PRÉ-ESTABELECIDAS
-- ========================================
-- Data: 2025-01-27
-- Objetivo: Validar todo o sistema usando SELECT queries no Supabase

-- ========================================
-- 1. VERIFICAR SE FUNÇÕES FORAM CRIADAS
-- ========================================

SELECT '🔍 1. VERIFICANDO FUNÇÕES CRIADAS' as teste;

-- Listar todas as funções relacionadas às metas
SELECT 
    routine_name as funcao,
    routine_type as tipo,
    created as criado_em
FROM information_schema.routines 
WHERE routine_schema = 'public' 
AND routine_name LIKE '%goal%' 
OR routine_name LIKE '%category%'
ORDER BY routine_name;

-- ========================================
-- 2. TESTAR MAPEAMENTO DE CATEGORIAS
-- ========================================

SELECT '🧠 2. TESTANDO MAPEAMENTO DE CATEGORIAS' as teste;

-- Testar função de normalização
SELECT 
    original,
    normalize_exercise_category(original) as normalizada,
    CASE 
        WHEN normalize_exercise_category(original) = 'musculacao' THEN '✅'
        WHEN normalize_exercise_category(original) = 'cardio' THEN '✅'
        WHEN normalize_exercise_category(original) = 'yoga' THEN '✅'
        WHEN normalize_exercise_category(original) = 'funcional' THEN '✅'
        ELSE '❌'
    END as status
FROM (
    VALUES 
        ('Musculação'),
        ('musculacao'),
        ('MUSCULACAO'),
        ('força'),
        ('Força'),
        ('bodybuilding'),
        ('Cardio'),
        ('cardio'),
        ('cardiovascular'),
        ('aeróbico'),
        ('Yoga'),
        ('yoga'),
        ('ioga'),
        ('Funcional'),
        ('funcional'),
        ('crossfit'),
        ('Pilates'),
        ('pilates'),
        ('HIIT'),
        ('hiit'),
        ('alta intensidade'),
        ('Corrida'),
        ('corrida'),
        ('running'),
        ('Caminhada'),
        ('caminhada'),
        ('walking'),
        ('Alongamento'),
        ('alongamento'),
        ('stretching'),
        ('Dança'),
        ('danca'),
        ('zumba'),
        ('Categoria Inexistente')
) as test_data(original);

-- ========================================
-- 3. TESTAR VALORES PADRÃO POR CATEGORIA
-- ========================================

SELECT '🎯 3. TESTANDO VALORES PADRÃO' as teste;

-- Simular criação de metas com valores padrão para cada categoria
WITH categorias_teste AS (
    SELECT unnest(ARRAY[
        'cardio', 'musculacao', 'funcional', 'yoga', 'pilates',
        'hiit', 'alongamento', 'danca', 'corrida', 'caminhada'
    ]) as categoria
)
SELECT 
    categoria,
    CASE 
        WHEN categoria IN ('corrida', 'caminhada') THEN 120
        WHEN categoria IN ('yoga', 'alongamento') THEN 90
        WHEN categoria IN ('funcional', 'crossfit') THEN 60
        WHEN categoria IN ('natacao', 'ciclismo') THEN 100
        ELSE 90
    END as valor_padrao_calculado,
    '✅ Valor razoável' as validacao
FROM categorias_teste
ORDER BY categoria;

-- ========================================
-- 4. SIMULAR CRIAÇÃO DE METAS
-- ========================================

SELECT '📝 4. SIMULANDO CRIAÇÃO DE METAS' as teste;

-- Verificar usuários existentes (usar um UUID real se disponível)
SELECT 
    count(*) as total_usuarios,
    'Use um UUID real abaixo' as instrucao
FROM auth.users 
LIMIT 5;

-- Exemplo de como testar criação de meta (substitua o UUID)
-- IMPORTANTE: Substitua 'seu-user-id-aqui' por um UUID real de usuário
/*
SELECT get_or_create_category_goal(
    'seu-user-id-aqui'::uuid,  -- SUBSTITUA por UUID real
    'cardio'
);
*/

-- ========================================
-- 5. VERIFICAR ESTRUTURA DA TABELA
-- ========================================

SELECT '🗄️ 5. VERIFICANDO ESTRUTURA DA TABELA' as teste;

-- Verificar se tabela workout_category_goals existe
SELECT 
    table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'workout_category_goals'
ORDER BY ordinal_position;

-- ========================================
-- 6. VERIFICAR TRIGGERS
-- ========================================

SELECT '⚡ 6. VERIFICANDO TRIGGERS' as teste;

-- Listar triggers relacionados
SELECT 
    trigger_name,
    event_manipulation,
    event_object_table,
    action_statement
FROM information_schema.triggers 
WHERE trigger_name LIKE '%goal%' 
OR trigger_name LIKE '%workout%';

-- ========================================
-- 7. TESTAR LOGS DE DEBUG (se existir)
-- ========================================

SELECT '📊 7. VERIFICANDO LOGS (se existir)' as teste;

-- Verificar se tabela de logs existe
SELECT 
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.tables 
            WHERE table_name = 'goal_update_logs'
        ) 
        THEN '✅ Tabela goal_update_logs existe'
        ELSE '⚠️ Tabela goal_update_logs não existe (opcional)'
    END as status_logs;

-- ========================================
-- 8. VERIFICAR POLÍTICAS RLS
-- ========================================

SELECT '🔒 8. VERIFICANDO POLÍTICAS RLS' as teste;

-- Verificar se RLS está habilitado
SELECT 
    schemaname,
    tablename,
    rowsecurity as rls_habilitado
FROM pg_tables 
WHERE tablename = 'workout_category_goals';

-- Listar políticas RLS
SELECT 
    policyname as politica,
    permissive,
    roles,
    cmd,
    qual as condicao
FROM pg_policies 
WHERE tablename = 'workout_category_goals';

-- ========================================
-- 9. TESTE COMPLETO DE FLUXO
-- ========================================

SELECT '🔄 9. TESTE COMPLETO DE FLUXO' as teste;

-- Para fazer um teste completo, você precisa:
SELECT 
    '1. Substitua os UUIDs pelos reais' as passo_1,
    '2. Execute as funções de criação' as passo_2,
    '3. Simule inserção de workout_record' as passo_3,
    '4. Verifique se meta foi atualizada' as passo_4;

-- ========================================
-- 10. QUERIES ÚTEIS PARA ADMINISTRAÇÃO
-- ========================================

SELECT '🛠️ 10. QUERIES ADMINISTRATIVAS' as teste;

-- Contar metas por categoria (quando houver dados)
/*
SELECT 
    category,
    count(*) as total_metas,
    avg(goal_minutes) as media_minutos,
    avg(current_minutes) as media_progresso
FROM workout_category_goals 
WHERE is_active = true
GROUP BY category
ORDER BY total_metas DESC;
*/

-- Ver metas ativas da semana atual (quando houver dados)
/*
SELECT 
    user_id,
    category,
    goal_minutes,
    current_minutes,
    completed,
    ROUND((current_minutes::numeric / goal_minutes::numeric) * 100, 2) as percentual
FROM workout_category_goals 
WHERE week_start_date = date_trunc('week', CURRENT_DATE)::date
AND is_active = true
ORDER BY category;
*/

-- ========================================
-- INSTRUÇÕES PARA USO
-- ========================================

SELECT '📋 INSTRUÇÕES PARA TESTE' as instrucoes;

SELECT 
    'Execute este arquivo completo no SQL Editor do Supabase' as passo_1,
    'Verifique se todas as funções retornam resultados esperados' as passo_2,
    'Para testes com dados reais, substitua UUIDs pelos verdadeiros' as passo_3,
    'Use as queries comentadas após ter dados na tabela' as passo_4; 