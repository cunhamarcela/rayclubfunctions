-- ================================================================
-- VERIFICAR FUNÇÕES REALMENTE USADAS PELO APP
-- ================================================================
-- Este script verifica as funções que o Flutter está chamando:
-- 1. record_workout_basic (registrar treino)
-- 2. process_workout_for_ranking (alimentar ranking)
-- 3. update_workout_and_refresh (atualizar treino)
-- 4. delete_workout_and_refresh (deletar treino)
-- ================================================================

-- 1. Verificar se as funções existem
SELECT 
    '=== FUNÇÕES REALMENTE USADAS PELO APP ===' as section,
    p.proname as function_name,
    pg_get_function_arguments(p.oid) as arguments,
    pg_get_function_result(p.oid) as return_type,
    obj_description(p.oid, 'pg_proc') as description
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public' 
AND p.proname IN (
    'record_workout_basic',
    'process_workout_for_ranking', 
    'update_workout_and_refresh',
    'delete_workout_and_refresh'
)
ORDER BY p.proname;

-- 2. Verificar definição da função record_workout_basic
SELECT 
    '=== DEFINIÇÃO record_workout_basic ===' as section,
    pg_get_functiondef(p.oid) as function_definition
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public' 
AND p.proname = 'record_workout_basic';

-- 3. Verificar definição da função process_workout_for_ranking
SELECT 
    '=== DEFINIÇÃO process_workout_for_ranking ===' as section,
    pg_get_functiondef(p.oid) as function_definition
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public' 
AND p.proname = 'process_workout_for_ranking';

-- 4. Testar record_workout_basic com dados retroativos
DO $$
DECLARE
    test_result jsonb;
    test_user_id uuid := 'bc0bfc71-f0cb-4636-a998-026b9e2b5b55';
    test_challenge_id uuid := '29c91ea0-7dc1-486f-8e4a-86686cbf5f82';
BEGIN
    RAISE NOTICE '=== TESTANDO FUNÇÕES REAIS ===';
    
    -- Teste: Check-in retroativo usando record_workout_basic
    SELECT record_workout_basic(
        p_user_id := test_user_id,
        p_workout_name := 'Teste Retroativo - Função Real',
        p_workout_type := 'teste',
        p_duration_minutes := 30,
        p_date := '2025-06-01 09:00:00-03',
        p_challenge_id := test_challenge_id,
        p_notes := 'Teste de lançamento retroativo'
    ) INTO test_result;
    
    RAISE NOTICE 'Resultado teste retroativo: %', test_result;
    
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE '❌ Erro no teste: %', SQLERRM;
END $$;

-- 5. Verificar como a função trata datas retroativas
SELECT 
    '=== ANÁLISE DE DATAS EM WORKOUT_RECORDS ===' as section,
    COUNT(*) as total_records,
    COUNT(CASE WHEN DATE(date) != DATE(created_at) THEN 1 END) as records_with_different_dates,
    ROUND(
        COUNT(CASE WHEN DATE(date) != DATE(created_at) THEN 1 END) * 100.0 / COUNT(*), 
        2
    ) as percentage_retroactive
FROM workout_records
WHERE created_at >= CURRENT_DATE - INTERVAL '30 days';

-- 6. Verificar últimos registros para entender o padrão
SELECT 
    '=== ÚLTIMOS 10 REGISTROS ===' as section,
    id,
    user_id,
    challenge_id,
    workout_name,
    date,
    created_at,
    CASE 
        WHEN DATE(date) = DATE(created_at) THEN 'MESMO_DIA'
        ELSE 'RETROATIVO'
    END as tipo_lancamento
FROM workout_records
ORDER BY created_at DESC
LIMIT 10; 