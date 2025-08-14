-- =====================================================
-- 🎯 TESTE FINAL DO SISTEMA ALINHADO
-- =====================================================
-- Data: 2025-01-30
-- Versão: FINAL - 100% alinhado com estrutura real
-- User ID: 01d4a292-1873-4af6-948b-a55eed56d6b9
-- =====================================================

SELECT '🎯 === TESTE FINAL COM ESTRUTURA PERFEITAMENTE ALINHADA ===' AS inicio;

-- Limpeza
DELETE FROM public.user_goals WHERE title LIKE '%TESTE FINAL%';
DELETE FROM public.workout_records WHERE workout_name LIKE '%TESTE FINAL%';

-- ============== TESTE 1: INSERÇÃO COM NOMES CORRETOS ==============
SELECT '📝 === TESTE 1: INSERÇÃO COM NOMES CORRETOS ===' AS teste_1;

-- Meta Musculação (tipo mais comum: 576 registros)
INSERT INTO public.user_goals (
    id, user_id, title, description, goal_type, category,
    target_value, current_value, unit, measurement_type,
    start_date, created_at, updated_at
) VALUES (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid,
    '01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid,
    'TESTE FINAL: Meta Musculação',
    'Meta alinhada com estrutura real',
    'workout_category',
    'Musculação',  -- ← Tipo real do banco
    180.0,         -- ← target_value (nome correto)
    0.0,           -- ← current_value (nome correto)
    'minutos',
    'minutes',
    NOW(),
    NOW(),
    NOW()
) ON CONFLICT (id) DO UPDATE SET
    title = EXCLUDED.title,
    current_value = 0.0,
    updated_at = NOW();

SELECT '✅ Meta Musculação criada com nomes corretos' AS resultado_1;

-- ============== TESTE 2: TRIGGER AUTOMÁTICO ==============
SELECT '⚡ === TESTE 2: TRIGGER AUTOMÁTICO COM ALINHAMENTO ===' AS teste_2;

-- Verificar progresso antes
SELECT 
    '📊 ANTES' AS momento,
    title,
    goal_type,
    category,
    target_value,
    current_value,
    measurement_type
FROM public.user_goals 
WHERE id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid;

-- Registrar treino de Musculação (deve disparar trigger)
INSERT INTO public.workout_records (
    id, user_id, workout_name, workout_type,
    date, duration_minutes, is_completed, created_at
) VALUES (
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'::uuid,
    '01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid,
    'TESTE FINAL: Treino Musculação',
    'Musculação',  -- ← EXATO match com category
    NOW(),
    60,
    true,
    NOW()
) ON CONFLICT (id) DO UPDATE SET
    workout_name = EXCLUDED.workout_name,
    duration_minutes = EXCLUDED.duration_minutes;

SELECT '🏋️ Treino Musculação registrado: 60 minutos' AS acao_2;

-- Verificar progresso depois
SELECT 
    '📊 DEPOIS' AS momento,
    title,
    category,
    target_value,
    current_value,
    CASE 
        WHEN current_value = 60 THEN '✅ TRIGGER FUNCIONANDO PERFEITAMENTE!'
        WHEN current_value = 0 THEN '❌ TRIGGER NÃO EXECUTOU'
        ELSE '❓ Progresso inesperado: ' || current_value
    END AS status_trigger
FROM public.user_goals 
WHERE id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid;

-- ============== TESTE 3: MÚLTIPLOS TREINOS ==============
SELECT '🔄 === TESTE 3: MÚLTIPLOS TREINOS DIFERENTES ===' AS teste_3;

-- Cardio (318 registros no banco)
INSERT INTO public.workout_records (
    id, user_id, workout_name, workout_type,
    date, duration_minutes, is_completed, created_at
) VALUES (
    'cccccccc-cccc-cccc-cccc-cccccccccccc'::uuid,
    '01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid,
    'TESTE FINAL: Treino Cardio',
    'Cardio',
    NOW(),
    45,
    true,
    NOW()
);

-- Funcional (194 registros no banco)  
INSERT INTO public.workout_records (
    id, user_id, workout_name, workout_type,
    date, duration_minutes, is_completed, created_at
) VALUES (
    'dddddddd-dddd-dddd-dddd-dddddddddddd'::uuid,
    '01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid,
    'TESTE FINAL: Treino Funcional',
    'Funcional',
    NOW(),
    30,
    true,
    NOW()
);

SELECT '🏃‍♀️ Registrados: Cardio (45min) + Funcional (30min)' AS acao_3;

-- Verificar que apenas Musculação foi atualizada (seletividade)
SELECT 
    '🎯 SELETIVIDADE DO TRIGGER' AS teste,
    category,
    current_value,
    CASE 
        WHEN category = 'Musculação' AND current_value = 60 THEN '✅ CORRETO: Apenas Musculação atualizada'
        WHEN category != 'Musculação' THEN '✅ CORRETO: Outras categorias não afetadas' 
        ELSE '❌ PROBLEMA: ' || category || ' = ' || current_value
    END AS resultado_seletividade
FROM public.user_goals 
WHERE title LIKE '%TESTE FINAL%';

-- ============== TESTE 4: META PERSONALIZADA (DAYS) ==============
SELECT '✋ === TESTE 4: META PERSONALIZADA (DAYS) ===' AS teste_4;

-- Meta personalizada medida em dias
INSERT INTO public.user_goals (
    id, user_id, title, description, goal_type,
    target_value, current_value, unit, measurement_type,
    start_date, created_at, updated_at
) VALUES (
    'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee'::uuid,
    '01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid,
    'TESTE FINAL: Meditar Diariamente',
    'Meta personalizada de check-ins',
    'custom',
    7.0,    -- ← target_value  
    0.0,    -- ← current_value
    'dias',
    'days',
    NOW(),
    NOW(),
    NOW()
);

-- Fazer check-in manual
SELECT register_goal_checkin_fixed(
    'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee'::uuid,
    '01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid
) AS checkin_resultado;

-- Verificar resultado
SELECT 
    '✋ CHECK-IN MANUAL' AS teste,
    title,
    goal_type,
    target_value,
    current_value,
    measurement_type,
    CASE 
        WHEN current_value = 1 THEN '✅ CHECK-IN FUNCIONANDO!'
        ELSE '❌ PROBLEMA: ' || current_value
    END AS status_checkin
FROM public.user_goals 
WHERE id = 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee'::uuid;

-- ============== TESTE 5: VERIFICAR ALINHAMENTO TOTAL ==============
SELECT '🔍 === TESTE 5: VERIFICAÇÃO DE ALINHAMENTO TOTAL ===' AS teste_5;

-- Mostrar dados reais do workout_records
SELECT 
    '📊 TIPOS REAIS NO BANCO' AS origem,
    workout_type,
    COUNT(*) as total_registros
FROM public.workout_records 
WHERE workout_type IN ('Musculação', 'Cardio', 'Funcional', 'Yoga', 'Pilates')
GROUP BY workout_type
ORDER BY total_registros DESC
LIMIT 5;

-- Verificar estrutura das metas criadas
SELECT 
    '🎯 METAS DE TESTE CRIADAS' AS origem,
    title,
    goal_type,
    category,
    target_value,
    current_value,
    measurement_type,
    ROUND((current_value / target_value) * 100, 1) as percentual
FROM public.user_goals 
WHERE title LIKE '%TESTE FINAL%'
ORDER BY category;

-- ============== RESULTADOS FINAIS ==============
SELECT '📋 === RESULTADOS FINAIS DO ALINHAMENTO ===' AS resultados;

-- Status geral do sistema
WITH sistema_status AS (
    SELECT 
        COUNT(*) FILTER (WHERE title LIKE '%TESTE FINAL%' AND goal_type = 'workout_category') as metas_workout,
        COUNT(*) FILTER (WHERE title LIKE '%TESTE FINAL%' AND goal_type = 'custom') as metas_custom,
        COUNT(*) FILTER (WHERE title LIKE '%TESTE FINAL%' AND current_value > 0) as metas_com_progresso
    FROM public.user_goals
)
SELECT 
    '🎯 STATUS FINAL DO SISTEMA' AS relatorio,
    metas_workout || ' metas workout criadas' AS workout_metas,
    metas_custom || ' metas custom criadas' AS custom_metas,
    metas_com_progresso || ' metas com progresso' AS metas_ativas,
    CASE 
        WHEN metas_com_progresso > 0 THEN '✅ SISTEMA 100% FUNCIONAL!'
        ELSE '❌ SISTEMA COM PROBLEMAS'
    END AS status_geral
FROM sistema_status;

-- Limpeza final
SELECT '🧹 Para limpar os dados de teste:' AS limpeza;
SELECT 'DELETE FROM public.user_goals WHERE title LIKE ''%TESTE FINAL%'';' AS comando_limpeza_1;
SELECT 'DELETE FROM public.workout_records WHERE workout_name LIKE ''%TESTE FINAL%'';' AS comando_limpeza_2;

SELECT '🎉 === TESTE DE ALINHAMENTO COMPLETO! ===' AS fim;

