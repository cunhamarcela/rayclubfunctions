-- =====================================================
-- 🧪 TESTES COMPLETOS DO SISTEMA DE METAS
-- =====================================================
-- Data: 2025-01-30
-- Objetivo: Testar todas as funcionalidades do sistema
-- Versão: 2.0.0 - Com SELECT em vez de RAISE NOTICE
-- User ID: 01d4a292-1873-4af6-948b-a55eed56d6b9
-- =====================================================

-- ============== LIMPEZA INICIAL ==============
SELECT '🧹 === LIMPEZA INICIAL PARA TESTES ===' AS inicio_teste;

-- Limpar dados de teste (cuidado em produção!)
DELETE FROM public.user_goals WHERE title LIKE '%TESTE%';
DELETE FROM public.workout_records WHERE workout_name LIKE '%TESTE%';

-- ============== TESTE 1: VERIFICAR ESTRUTURA ==============
SELECT '🏗️  === TESTE 1: VERIFICAÇÃO DA ESTRUTURA ===' AS teste_estrutura;

-- 1.1 - Verificar se as colunas foram criadas
SELECT 
    '✅ ESTRUTURA DA TABELA' as teste,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'user_goals' 
  AND column_name IN ('category', 'measurement_type')
ORDER BY column_name;

-- 1.2 - Verificar se as funções existem
SELECT 
    '✅ FUNÇÕES CRIADAS' as teste,
    routine_name,
    routine_type
FROM information_schema.routines 
WHERE routine_name IN ('update_goals_from_workout', 'register_goal_checkin')
  AND routine_schema = 'public';

-- 1.3 - Verificar se o trigger existe
SELECT 
    '✅ TRIGGERS CRIADOS' as teste,
    trigger_name,
    event_manipulation,
    action_timing
FROM information_schema.triggers 
WHERE trigger_name = 'trigger_update_goals_from_workout';

-- ============== TESTE 2: CRIAÇÃO DE DADOS DE TESTE ==============
SELECT '📊 === TESTE 2: CRIAÇÃO DE DADOS DE TESTE ===' AS teste_criacao;

-- Definir o user_id específico
WITH test_user AS (
    SELECT '01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid AS user_id
)
SELECT '👤 Usando user_id: ' || user_id AS usuario_teste 
FROM test_user;
-- 2.1 - Criar meta pré-definida (Funcional, medida em minutos)
INSERT INTO public.user_goals (
    id, user_id, title, description, type, category, 
    target, progress, unit, measurement_type,
    start_date, created_at
) VALUES (
    '11111111-1111-1111-1111-111111111111'::uuid, '01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid, 
    'TESTE: Meta Funcional', 'Meta automática de funcional',
    'workout_category', 'Funcional',
    150.0, 0.0, 'minutos', 'minutes',
    NOW(), NOW()
);

SELECT '✅ Meta de minutos criada: 11111111-1111-1111-1111-111111111111' AS meta_minutos_criada;

-- 2.2 - Criar meta personalizada (medida em dias)
INSERT INTO public.user_goals (
    id, user_id, title, description, type, category,
    target, progress, unit, measurement_type,
    start_date, created_at
) VALUES (
    '22222222-2222-2222-2222-222222222222'::uuid, '01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid,
    'TESTE: Meditar Diariamente', 'Meta personalizada de meditação',
    'custom', NULL,
    7.0, 0.0, 'dias', 'days',
    NOW(), NOW()
);

SELECT '✅ Meta de dias criada: 22222222-2222-2222-2222-222222222222' AS meta_dias_criada;

-- ============== TESTE 3: TRIGGER AUTOMÁTICO ==============
SELECT '⚡ === TESTE 3: TRIGGER AUTOMÁTICO ===' AS teste_trigger;

-- 3.1 - Verificar progresso antes
SELECT 
    '📊 Progresso antes do treino' AS status,
    progress AS progresso_atual
FROM public.user_goals 
WHERE id = '11111111-1111-1111-1111-111111111111'::uuid;

-- 3.2 - Registrar treino de Funcional (deve disparar trigger)
INSERT INTO public.workout_records (
    id, user_id, workout_name, workout_type,
    date, duration_minutes, is_completed, created_at
) VALUES (
    '33333333-3333-3333-3333-333333333333'::uuid, '01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid,
    'TESTE: Treino Funcional', 'Funcional',
    NOW(), 45, true, NOW()
);

SELECT '🏋️ Treino registrado: Funcional, 45 minutos' AS treino_registrado;

-- 3.3 - Verificar progresso depois (aguardar trigger)
SELECT 
    '📊 Progresso após treino' AS status,
    progress AS progresso_atual,
    CASE 
        WHEN progress = 45 THEN '✅ TRIGGER FUNCIONANDO: +45 minutos adicionados automaticamente!'
        ELSE '❌ TRIGGER COM PROBLEMA: Progresso = ' || progress || ' (esperado 45)'
    END AS resultado_trigger
FROM public.user_goals 
WHERE id = '11111111-1111-1111-1111-111111111111'::uuid;

-- ============== TESTE 4: CHECK-IN MANUAL ==============
SELECT '✋ === TESTE 4: CHECK-IN MANUAL ===' AS teste_checkin;

-- 4.1 - Verificar progresso antes
SELECT 
    '📊 Progresso antes do check-in' AS status,
    progress AS progresso_atual
FROM public.user_goals 
WHERE id = '22222222-2222-2222-2222-222222222222'::uuid;

-- 4.2 - Fazer check-in manual
SELECT 
    '✋ Executando check-in manual...' AS status,
    register_goal_checkin(
        '22222222-2222-2222-2222-222222222222'::uuid, 
        '01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid
    ) AS checkin_resultado;

-- 4.3 - Verificar progresso depois
SELECT 
    '📊 Progresso após check-in' AS status,
    progress AS progresso_atual,
    CASE 
        WHEN progress = 1 THEN '✅ CHECK-IN FUNCIONANDO: +1 dia adicionado!'
        ELSE '❌ CHECK-IN COM PROBLEMA: Progresso = ' || progress || ' (esperado 1)'
    END AS resultado_checkin
FROM public.user_goals 
WHERE id = '22222222-2222-2222-2222-222222222222'::uuid;

-- ============== TESTE 5: MÚLTIPLOS TREINOS ==============
SELECT '🔄 === TESTE 5: MÚLTIPLOS TREINOS ===' AS teste_multiplos;

-- 5.1 - Verificar progresso inicial (após o primeiro treino de 45min)
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
    ('66666666-6666-6666-6666-666666666666'::uuid, '01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid, 'TESTE: Treino Funcional 3', 'Funcional', NOW() + interval '3 minutes', 30, true, NOW());

SELECT '🏋️ 3 treinos registrados: 30 minutos cada' AS treinos_registrados;

-- 5.3 - Verificar progresso final
SELECT 
    '📊 Progresso após treinos múltiplos' AS status,
    progress AS progresso_atual,
    CASE 
        WHEN progress = 135 THEN '✅ ACUMULAÇÃO FUNCIONANDO: Total 135 minutos (45+30+30+30)!'
        ELSE '❌ ACUMULAÇÃO COM PROBLEMA: Progresso = ' || progress || ' (esperado 135)'
    END AS resultado_acumulacao
FROM public.user_goals 
WHERE id = '11111111-1111-1111-1111-111111111111'::uuid;

-- ============== TESTE 6: DIFERENTES CATEGORIAS ==============
SELECT '🏷️  === TESTE 6: DIFERENTES CATEGORIAS ===' AS teste_categorias;

-- 6.1 - Criar meta de Musculação
INSERT INTO public.user_goals (
    id, user_id, title, description, type, category,
    target, progress, unit, measurement_type,
    start_date, created_at
) VALUES (
    '77777777-7777-7777-7777-777777777777'::uuid, '01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid,
    'TESTE: Meta Musculação', 'Meta automática de musculação',
    'workout_category', 'Musculação',
    120.0, 0.0, 'minutos', 'minutes',
    NOW(), NOW()
);

SELECT '✅ Meta de Musculação criada' AS meta_musculacao_criada;

-- 6.2 - Registrar treino de Musculação
INSERT INTO public.workout_records (
    id, user_id, workout_name, workout_type,
    date, duration_minutes, is_completed, created_at
) VALUES (
    '88888888-8888-8888-8888-888888888888'::uuid, '01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid,
    'TESTE: Treino Musculação', 'Musculação',
    NOW(), 60, true, NOW()
);

SELECT '🏋️ Treino de Musculação registrado: 60 minutos' AS treino_musculacao;

-- 6.3 - Verificar seletividade (cada meta deve ser atualizada apenas com sua categoria)
SELECT 
    '📊 Verificação de Seletividade' AS teste,
    title,
    category,
    progress,
    CASE 
        WHEN id = '11111111-1111-1111-1111-111111111111' AND progress = 135 THEN '✅ Meta Funcional OK'
        WHEN id = '77777777-7777-7777-7777-777777777777' AND progress = 60 THEN '✅ Meta Musculação OK'
        WHEN id = '22222222-2222-2222-2222-222222222222' AND progress = 1 THEN '✅ Meta Dias OK'
        ELSE '❌ Progresso incorreto: ' || progress
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
    ROUND((progress / target) * 100, 1) as percentual_conclusao
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

-- ============== LIMPEZA FINAL (OPCIONAL) ==============
SELECT '🧹 === LIMPEZA FINAL (OPCIONAL) ===' AS limpeza_info;
SELECT 'Para limpar dados de teste, execute:' AS instrucao_1;
SELECT 'DELETE FROM public.user_goals WHERE title LIKE ''%TESTE%'';' AS comando_1;
SELECT 'DELETE FROM public.workout_records WHERE workout_name LIKE ''%TESTE%'';' AS comando_2;
