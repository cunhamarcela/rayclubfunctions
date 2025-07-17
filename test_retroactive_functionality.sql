-- ================================================================
-- SCRIPT DE TESTE PARA LANÇAMENTOS RETROATIVOS
-- ================================================================
-- Execute este script APÓS rodar o supabase_fixes_complete.sql
-- ================================================================

-- Verificar se a função foi criada corretamente
SELECT 
    routine_name,
    routine_type,
    specific_name
FROM information_schema.routines 
WHERE routine_name = 'record_challenge_check_in_v2'
AND routine_schema = 'public';

-- Diagnóstico de timezone
SELECT * FROM diagnose_timezone_issues();

-- Exemplo de teste com dados fictícios
-- SUBSTITUA pelos UUIDs reais do seu ambiente

DO $$
DECLARE
    test_user_id UUID := 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'; -- SUBSTITUA
    test_challenge_id UUID := 'yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy'; -- SUBSTITUA
    test_result JSONB;
BEGIN
    RAISE NOTICE '=== TESTE DE LANÇAMENTO RETROATIVO ===';
    
    -- Teste 1: Check-in de ontem
    RAISE NOTICE 'Testando check-in retroativo de ontem...';
    
    SELECT record_challenge_check_in_v2(
        test_challenge_id,
        (CURRENT_DATE - INTERVAL '1 day')::timestamp with time zone,
        30,
        test_user_id,
        'workout_test_yesterday',
        'Treino de Ontem (Teste)',
        'musculacao'
    ) INTO test_result;
    
    RAISE NOTICE 'Resultado do teste de ontem: %', test_result;
    
    -- Teste 2: Check-in de 3 dias atrás
    RAISE NOTICE 'Testando check-in retroativo de 3 dias atrás...';
    
    SELECT record_challenge_check_in_v2(
        test_challenge_id,
        (CURRENT_DATE - INTERVAL '3 days')::timestamp with time zone,
        45,
        test_user_id,
        'workout_test_3days',
        'Treino de 3 Dias Atrás (Teste)',
        'pilates'
    ) INTO test_result;
    
    RAISE NOTICE 'Resultado do teste de 3 dias atrás: %', test_result;
    
    -- Teste 3: Tentar check-in duplicado (deve falhar)
    RAISE NOTICE 'Testando check-in duplicado (deve falhar)...';
    
    SELECT record_challenge_check_in_v2(
        test_challenge_id,
        (CURRENT_DATE - INTERVAL '1 day')::timestamp with time zone,
        20,
        test_user_id,
        'workout_test_duplicate',
        'Treino Duplicado (Teste)',
        'funcional'
    ) INTO test_result;
    
    RAISE NOTICE 'Resultado do teste de duplicado: %', test_result;
    
END $$;

-- Verificar check-ins criados (se os UUIDs existirem)
-- DESCOMENTE E SUBSTITUA pelos UUIDs reais:

-- SELECT 
--     id,
--     workout_name,
--     check_in_date,
--     DATE(check_in_date AT TIME ZONE 'America/Sao_Paulo') as check_in_day,
--     created_at,
--     DATE(created_at AT TIME ZONE 'America/Sao_Paulo') as created_day
-- FROM challenge_check_ins 
-- WHERE user_id = 'SEU_USER_ID_AQUI'
-- ORDER BY check_in_date DESC
-- LIMIT 10; 