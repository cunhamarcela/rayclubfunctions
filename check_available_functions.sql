-- ============================================================================
-- VERIFICAR FUNÇÕES DISPONÍVEIS E SUAS ASSINATURAS
-- ============================================================================

-- Listar todas as funções relacionadas a workout e ranking
SELECT 
    '🔧 FUNÇÕES RELACIONADAS A WORKOUT E RANKING:' as titulo;

SELECT 
    proname as function_name,
    pg_get_function_arguments(oid) as arguments,
    pg_get_function_result(oid) as return_type,
    CASE 
        WHEN proname LIKE '%record_workout%' THEN '📝 REGISTRO'
        WHEN proname LIKE '%process%ranking%' THEN '🏆 RANKING'
        WHEN proname LIKE '%challenge_check_in%' THEN '✅ CHECK-IN'
        ELSE '📋 OUTRO'
    END as category
FROM pg_proc 
WHERE proname ILIKE ANY(ARRAY[
    '%workout%',
    '%ranking%', 
    '%check_in%',
    '%checkin%'
])
AND pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public')
ORDER BY category, proname;

-- Verificar especificamente as funções mencionadas
SELECT '🎯 FUNÇÕES ESPECÍFICAS MENCIONADAS:' as titulo;

SELECT 
    function_name,
    CASE 
        WHEN EXISTS (SELECT 1 FROM pg_proc WHERE proname = function_name)
        THEN '✅ EXISTE'
        ELSE '❌ NÃO EXISTE'
    END as status
FROM (VALUES 
    ('record_workout_basic'),
    ('process_workout_for_ranking'),
    ('process_workout_for_ranking_fixed'),
    ('record_challenge_check_in_v2')
) AS funcs(function_name);

-- Buscar funções similares com variações no nome
SELECT '🔍 BUSCA POR VARIAÇÕES:' as titulo;

SELECT 
    proname as function_name,
    pg_get_function_arguments(oid) as arguments
FROM pg_proc 
WHERE (
    proname ILIKE '%process%workout%' OR
    proname ILIKE '%workout%ranking%' OR
    proname ILIKE '%ranking%'
)
AND pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public')
ORDER BY proname;

-- Verificar se existe alguma função que aceita UUID como parâmetro para ranking
SELECT '🔍 FUNÇÕES QUE ACEITAM UUID PARA RANKING:' as titulo;

SELECT 
    proname as function_name,
    pg_get_function_arguments(oid) as arguments,
    pg_get_function_result(oid) as return_type
FROM pg_proc 
WHERE proname ILIKE '%ranking%'
AND pg_get_function_arguments(oid) ILIKE '%uuid%'
AND pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public')
ORDER BY proname; 