-- =====================================================
-- 🧪 TESTES SISTEMA DE METAS - VERSÃO CORRIGIDA
-- =====================================================
-- Data: 2025-01-30 
-- Versão: 3.0.0 - Alinhado com estrutura real do banco
-- User ID: 01d4a292-1873-4af6-948b-a55eed56d6b9
-- =====================================================

SELECT '🧹 === LIMPEZA INICIAL PARA TESTES ===' AS inicio_teste;

-- Limpar dados de teste anteriores
DELETE FROM public.user_goals WHERE title LIKE '%TESTE%';
DELETE FROM public.workout_records WHERE workout_name LIKE '%TESTE%';

-- ============== TESTE 1: VERIFICAR ESTRUTURA ==============
SELECT '🏗️  === TESTE 1: VERIFICAÇÃO DA ESTRUTURA ===' AS teste_estrutura;

-- 1.1 - Verificar colunas críticas
SELECT 
    '✅ COLUNAS CRÍTICAS' as teste,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'user_goals' 
  AND column_name IN ('category', 'measurement_type', 'type', 'target', 'progress')
ORDER BY column_name;

-- 1.2 - Verificar funções
SELECT 
    '✅ FUNÇÕES CRIADAS' as teste,
    routine_name,
    routine_type
FROM information_schema.routines 
WHERE routine_name IN ('update_goals_from_workout', 'register_goal_checkin')
  AND routine_schema = 'public';

-- 1.3 - Verificar triggers
SELECT 
    '✅ TRIGGERS CRIADOS' as teste,
    trigger_name,
    event_manipulation,
    action_timing
FROM information_schema.triggers 
WHERE trigger_name LIKE '%update_goals_from_workout%';

-- ============== TESTE 2: CRIAÇÃO DE DADOS DE TESTE ==============
SELECT '📊 === TESTE 2: CRIAÇÃO DE DADOS DE TESTE ===' AS teste_criacao;

-- 2.1 - Meta pré-definida (Funcional, medida em minutos)
-- Usar apenas as colunas que existem na tabela
INSERT INTO public.user_goals (
    id, user_id, title, type, category, 
    target, progress, unit, measurement_type,
    start_date, created_at
) VALUES (
    '11111111-1111-1111-1111-111111111111'::uuid, 
    '01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid, 
    'TESTE: Meta Funcional', 
    'workout_category', 'Funcional',
    150.0, 0.0, 'minutos', 'minutes',
    NOW(), NOW()
) ON CONFLICT (id) DO UPDATE SET
    title = EXCLUDED.title,
    target = EXCLUDED.target,
    progress = 0.0,
    updated_at = NOW();

SELECT '✅ Meta de minutos criada: 11111111-1111-1111-1111-111111111111' AS meta_minutos_criada;

-- 2.2 - Meta personalizada (medida em dias)
INSERT INTO public.user_goals (
    id, user_id, title, type,
    target, progress, unit, measurement_type,
    start_date, created_at
) VALUES (
    '22222222-2222-2222-2222-222222222222'::uuid, 
    '01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid,
    'TESTE: Meditar Diariamente', 
    'custom',
    7.0, 0.0, 'dias', 'days',
    NOW(), NOW()
) ON CONFLICT (id) DO UPDATE SET
    title = EXCLUDED.title,
    target = EXCLUDED.target,
    progress = 0.0,
    updated_at = NOW();

SELECT '✅ Meta de dias criada: 22222222-2222-2222-2222-222222222222' AS meta_dias_criada;

-- ============== TESTE 3: TRIGGER AUTOMÁTICO ==============
SELECT '⚡ === TESTE 3: TRIGGER AUTOMÁTICO ===' AS teste_trigger;

-- 3.1 - Verificar progresso antes
SELECT 
    '📊 Progresso antes do treino' AS status,
    progress AS progresso_atual,
    category,
    measurement_type
FROM public.user_goals 
WHERE id = '11111111-1111-1111-1111-111111111111'::uuid;

-- 3.2 - Registrar treino de Funcional (deve disparar trigger)
INSERT INTO public.workout_records (
    id, user_id, workout_name, workout_type,
    date, duration_minutes, is_completed, created_at
) VALUES (
    '33333333-3333-3333-3333-333333333333'::uuid, 
    '01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid,
    'TESTE: Treino Funcional', 'Funcional',
    NOW(), 45, true, NOW()
) ON CONFLICT (id) DO UPDATE SET
    workout_name = EXCLUDED.workout_name,
    duration_minutes = EXCLUDED.duration_minutes,
    updated_at = NOW();

SELECT '🏋️ Treino registrado: Funcional, 45 minutos' AS treino_registrado;

-- 3.3 - Verificar progresso depois (aguardar trigger)
SELECT 
    '📊 Progresso após treino' AS status,
    progress AS progresso_atual,
    category,
    measurement_type,
    CASE 
        WHEN progress = 45 THEN '✅ TRIGGER FUNCIONANDO: +45 minutos adicionados automaticamente!'
        WHEN progress = 0 THEN '⚠️ TRIGGER NÃO EXECUTOU: Verificar se função existe e trigger está ativo'
        ELSE '❓ PROGRESSO INESPERADO: ' || progress || ' minutos'
    END AS resultado_trigger
FROM public.user_goals 
WHERE id = '11111111-1111-1111-1111-111111111111'::uuid;

-- ============== TESTE 4: CHECK-IN MANUAL ==============
SELECT '✋ === TESTE 4: CHECK-IN MANUAL ===' AS teste_checkin;

-- 4.1 - Verificar progresso antes
SELECT 
    '📊 Progresso antes do check-in' AS status,
    progress AS progresso_atual,
    measurement_type
FROM public.user_goals 
WHERE id = '22222222-2222-2222-2222-222222222222'::uuid;

-- 4.2 - Fazer check-in manual (se a função existir)
DO $$
DECLARE
    v_checkin_result BOOLEAN;
    v_function_exists BOOLEAN;
BEGIN
    -- Verificar se a função existe
    SELECT EXISTS (
        SELECT 1 FROM information_schema.routines 
        WHERE routine_name = 'register_goal_checkin' 
          AND routine_schema = 'public'
    ) INTO v_function_exists;
    
    IF v_function_exists THEN
        SELECT register_goal_checkin(
            '22222222-2222-2222-2222-222222222222'::uuid, 
            '01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid
        ) INTO v_checkin_result;
        
        RAISE NOTICE '✅ Check-in executado com sucesso: %', v_checkin_result;
    ELSE
        RAISE NOTICE '⚠️ Função register_goal_checkin não encontrada';
    END IF;
END $$;

-- 4.3 - Verificar progresso depois
SELECT 
    '📊 Progresso após check-in' AS status,
    progress AS progresso_atual,
    CASE 
        WHEN progress = 1 THEN '✅ CHECK-IN FUNCIONANDO: +1 dia adicionado!'
        WHEN progress = 0 THEN '⚠️ CHECK-IN NÃO EXECUTOU: Verificar função register_goal_checkin'
        ELSE '❓ PROGRESSO INESPERADO: ' || progress || ' dias'
    END AS resultado_checkin
FROM public.user_goals 
WHERE id = '22222222-2222-2222-2222-222222222222'::uuid;

-- ============== TESTE 5: MÚLTIPLOS TREINOS ==============
SELECT '🔄 === TESTE 5: MÚLTIPLOS TREINOS ===' AS teste_multiplos;

-- 5.1 - Verificar progresso inicial
SELECT 
    '📊 Progresso antes dos treinos múltiplos' AS status,
    progress AS progresso_atual
FROM public.user_goals 
WHERE id = '11111111-1111-1111-1111-111111111111'::uuid;

-- 5.2 - Registrar 3 treinos de 30 minutos cada
INSERT INTO public.workout_records (
    id, user_id, workout_name, workout_type,
    date, duration_minutes, is_completed, created_at
) VALUES 
    ('44444444-4444-4444-4444-444444444444'::uuid, '01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid, 'TESTE: Treino Funcional 1', 'Funcional', NOW() + interval '1 minute', 30, true, NOW()),
    ('55555555-5555-5555-5555-555555555555'::uuid, '01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid, 'TESTE: Treino Funcional 2', 'Funcional', NOW() + interval '2 minutes', 30, true, NOW()),
    ('66666666-6666-6666-6666-666666666666'::uuid, '01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid, 'TESTE: Treino Funcional 3', 'Funcional', NOW() + interval '3 minutes', 30, true, NOW())
ON CONFLICT (id) DO UPDATE SET
    workout_name = EXCLUDED.workout_name,
    duration_minutes = EXCLUDED.duration_minutes;

SELECT '🏋️ 3 treinos registrados: 30 minutos cada' AS treinos_registrados;

-- 5.3 - Verificar progresso final
SELECT 
    '📊 Progresso após treinos múltiplos' AS status,
    progress AS progresso_atual,
    CASE 
        WHEN progress = 135 THEN '✅ ACUMULAÇÃO FUNCIONANDO: Total 135 minutos (45+30+30+30)!'
        WHEN progress = 45 THEN '⚠️ APENAS PRIMEIRO TREINO: Triggers subsequentes não funcionaram'
        ELSE '❓ PROGRESSO INESPERADO: ' || progress || ' minutos'
    END AS resultado_acumulacao
FROM public.user_goals 
WHERE id = '11111111-1111-1111-1111-111111111111'::uuid;

-- ============== TESTE 6: DIFERENTES CATEGORIAS ==============
SELECT '🏷️  === TESTE 6: DIFERENTES CATEGORIAS ===' AS teste_categorias;

-- 6.1 - Criar meta de Musculação
INSERT INTO public.user_goals (
    id, user_id, title, type, category,
    target, progress, unit, measurement_type,
    start_date, created_at
) VALUES (
    '77777777-7777-7777-7777-777777777777'::uuid, 
    '01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid,
    'TESTE: Meta Musculação', 
    'workout_category', 'Musculação',
    120.0, 0.0, 'minutos', 'minutes',
    NOW(), NOW()
) ON CONFLICT (id) DO UPDATE SET
    title = EXCLUDED.title,
    progress = 0.0;

SELECT '✅ Meta de Musculação criada' AS meta_musculacao_criada;

-- 6.2 - Registrar treino de Musculação
INSERT INTO public.workout_records (
    id, user_id, workout_name, workout_type,
    date, duration_minutes, is_completed, created_at
) VALUES (
    '88888888-8888-8888-8888-888888888888'::uuid, 
    '01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid,
    'TESTE: Treino Musculação', 'Musculação',
    NOW(), 60, true, NOW()
) ON CONFLICT (id) DO UPDATE SET
    workout_name = EXCLUDED.workout_name,
    duration_minutes = EXCLUDED.duration_minutes;

SELECT '🏋️ Treino de Musculação registrado: 60 minutos' AS treino_musculacao;

-- 6.3 - Verificar seletividade
SELECT 
    '📊 Verificação de Seletividade' AS teste,
    title,
    category,
    progress,
    CASE 
        WHEN id = '11111111-1111-1111-1111-111111111111' AND progress >= 135 THEN '✅ Meta Funcional OK'
        WHEN id = '77777777-7777-7777-7777-777777777777' AND progress = 60 THEN '✅ Meta Musculação OK'
        WHEN id = '22222222-2222-2222-2222-222222222222' AND progress >= 0 THEN '✅ Meta Dias OK'
        ELSE '❓ Progresso: ' || progress
    END AS resultado_seletividade
FROM public.user_goals 
WHERE title LIKE '%TESTE%'
ORDER BY category NULLS LAST;

-- ============== RESULTADOS FINAIS ==============
SELECT '📊 === RESULTADOS FINAIS DOS TESTES ===' AS relatorio_final;

-- Mostrar todas as metas criadas
SELECT 
    '📋 METAS CRIADAS NOS TESTES' as resultado,
    title,
    category,
    target,
    progress,
    measurement_type,
    CASE 
        WHEN target > 0 THEN ROUND((progress / target) * 100, 1)
        ELSE 0
    END as percentual_conclusao
FROM public.user_goals 
WHERE title LIKE '%TESTE%'
ORDER BY created_at;

-- Mostrar todos os treinos registrados
SELECT 
    '🏋️ TREINOS REGISTRADOS NOS TESTES' as resultado,
    workout_name,
    workout_type,
    duration_minutes,
    date
FROM public.workout_records 
WHERE workout_name LIKE '%TESTE%'
ORDER BY created_at;

-- ============== DIAGNÓSTICO FINAL ==============
SELECT '🔍 === DIAGNÓSTICO FINAL ===' AS diagnostico_final;

-- Verificar se as funções estão funcionando
SELECT 
    '⚙️ STATUS DAS FUNÇÕES' AS status,
    'update_goals_from_workout' AS funcao,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM public.user_goals 
            WHERE title LIKE '%TESTE%' 
              AND category = 'Funcional' 
              AND progress > 0
        ) THEN '✅ FUNCIONANDO'
        ELSE '❌ NÃO FUNCIONANDO'
    END AS resultado;

-- ============== LIMPEZA FINAL (OPCIONAL) ==============
SELECT '🧹 === LIMPEZA FINAL (OPCIONAL) ===' AS limpeza_info;
SELECT 'Para limpar dados de teste, execute:' AS instrucao_1;
SELECT 'DELETE FROM public.user_goals WHERE title LIKE ''%TESTE%'';' AS comando_1;
SELECT 'DELETE FROM public.workout_records WHERE workout_name LIKE ''%TESTE%'';' AS comando_2;

