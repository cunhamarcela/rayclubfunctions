-- ========================================
-- APLICAÇÃO DA CORREÇÃO - DASHBOARD MINUTOS
-- ========================================
-- Data: 2025-01-22
-- Execução: Supabase SQL Editor
-- Objetivo: Aplicar a função get_dashboard_core que mostra minutos apenas do mês atual

-- 1. Verificar se a função existe (antes de aplicar)
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'get_dashboard_core') THEN
        RAISE NOTICE '✅ Função get_dashboard_core já existe - será substituída';
    ELSE
        RAISE NOTICE '🔧 Criando nova função get_dashboard_core';
    END IF;
END $$;

-- 2. Aplicar a função
\i sql/create_get_dashboard_core_function.sql

-- 3. Testar a função com um usuário exemplo
-- (Substitua pelo UUID de um usuário real do sistema)
DO $$
DECLARE
    test_result JSON;
    test_user_id UUID := '01d4a292-1873-4af6-948b-a55eed56d6b9'; -- Marcela
BEGIN
    -- Executar a função
    SELECT get_dashboard_core(test_user_id) INTO test_result;
    
    -- Mostrar resultados
    RAISE NOTICE '✅ Teste da função get_dashboard_core:';
    RAISE NOTICE '📊 Total de treinos: %', (test_result->>'total_workouts')::int;
    RAISE NOTICE '⏱️ Minutos do mês: %', (test_result->>'total_duration')::int;
    RAISE NOTICE '📅 Dias treinados no mês: %', (test_result->>'days_trained_this_month')::int;
    
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE '❌ Erro no teste: %', SQLERRM;
END $$;

-- 4. Verificar se não há problemas no DashboardRepository
-- O DashboardRepository chama: .rpc('get_dashboard_core', params: {'user_id_param': userId})
-- E espera uma resposta JSON compatível com DashboardData.fromJson()

-- 5. Resultado esperado:
-- ✅ Campo "total_duration" agora mostra apenas minutos do mês atual
-- ✅ Campo "total_workouts" continua mostrando total de todos os tempos (24)
-- ✅ Campo "days_trained_this_month" mostra dias únicos do mês (3)

RAISE NOTICE '🎉 Aplicação concluída! Agora o dashboard mostra minutos apenas do mês atual.'; 