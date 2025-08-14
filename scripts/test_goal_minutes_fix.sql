-- 🧪 TESTE DA CORREÇÃO: goal_minutes ambiguity
-- Data: 2025-01-21 às 17:20
-- Teste usando SELECT para ver resultados no SQL Editor

-- Configurar usuário de teste
DO $$
DECLARE
    test_user_id UUID := '01d4a292-1873-4af6-948b-a55eed56d6b9'; -- User do log de erro original
    test_result weekly_goals;
    test_category_result workout_category_goals;
BEGIN
    -- Teste 1: Função add_workout_minutes_to_goal
    SELECT add_workout_minutes_to_goal(test_user_id, 30) INTO test_result;
    
    -- Teste 2: Função add_workout_minutes_to_category  
    SELECT add_workout_minutes_to_category(test_user_id, 'funcional', 45) INTO test_category_result;
END $$;

-- 📊 RESULTADOS DOS TESTES (usando SELECT)

-- Teste 1: Verificar se a função weekly goals funciona
SELECT 
    '🧪 TESTE 1: add_workout_minutes_to_goal' as teste,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM weekly_goals 
            WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'
            AND week_start_date = date_trunc('week', CURRENT_DATE)::date
        ) THEN '✅ PASSOU - Meta semanal criada/atualizada'
        ELSE '❌ FALHOU - Meta semanal não encontrada'
    END as resultado;

-- Teste 2: Verificar se a função category goals funciona
SELECT 
    '🧪 TESTE 2: add_workout_minutes_to_category' as teste,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM workout_category_goals 
            WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'
            AND category = 'funcional'
            AND week_start_date = date_trunc('week', CURRENT_DATE)::date
        ) THEN '✅ PASSOU - Meta de categoria criada/atualizada'
        ELSE '❌ FALHOU - Meta de categoria não encontrada'
    END as resultado;

-- Teste 3: Verificar detalhes das metas criadas
SELECT 
    '📊 DETALHES DA META SEMANAL' as tipo,
    goal_minutes as meta_minutos,
    current_minutes as minutos_atuais,
    completed as completada,
    week_start_date as inicio_semana
FROM weekly_goals 
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'
AND week_start_date = date_trunc('week', CURRENT_DATE)::date;

-- Teste 4: Verificar detalhes das metas de categoria
SELECT 
    '📊 DETALHES DA META DE CATEGORIA' as tipo,
    category as categoria,
    goal_minutes as meta_minutos,
    current_minutes as minutos_atuais,
    completed as completada
FROM workout_category_goals 
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'
AND category = 'funcional'
AND week_start_date = date_trunc('week', CURRENT_DATE)::date;

-- Teste 5: Simular erro antigo (deve funcionar agora)
SELECT 
    '🔧 TESTE SIMULAÇÃO DO ERRO ORIGINAL' as teste,
    CASE 
        WHEN (
            SELECT add_workout_minutes_to_goal('01d4a292-1873-4af6-948b-a55eed56d6b9', 15)
        ) IS NOT NULL 
        THEN '✅ SUCESSO - Função executou sem erro de ambiguidade'
        ELSE '❌ ERRO - Ainda há problemas'
    END as resultado;

-- Teste 6: Status final
SELECT 
    '🎯 RESUMO DOS TESTES' as categoria,
    'Correção de goal_minutes ambiguity' as funcionalidade,
    CASE 
        WHEN EXISTS (SELECT 1 FROM weekly_goals WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9')
        AND EXISTS (SELECT 1 FROM workout_category_goals WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9')
        THEN '✅ TODAS AS FUNÇÕES FUNCIONANDO'
        ELSE '⚠️ VERIFICAR RESULTADOS ACIMA'
    END as status_final,
    NOW() as testado_em; 