-- ========================================
-- TESTES COM UUID REAL DO USUÁRIO
-- ========================================
-- UUID: 01d4a292-1873-4af6-948b-a55eed56d6b9

-- ========================================
-- 1. VERIFICAR O USUÁRIO
-- ========================================

SELECT '👤 VERIFICANDO USUÁRIO ESPECÍFICO' as teste;

SELECT 
    id,
    email,
    created_at,
    '✅ Usuário encontrado' as status
FROM auth.users 
WHERE id = '01d4a292-1873-4af6-948b-a55eed56d6b9';

-- ========================================
-- 2. CRIAR METAS PARA DIFERENTES CATEGORIAS
-- ========================================

SELECT '🎯 CRIANDO METAS PARA O USUÁRIO' as teste;

-- Criar meta de Cardio
SELECT 
    'cardio' as categoria,
    get_or_create_category_goal(
        '01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid,
        'cardio'
    );

-- Criar meta de Musculação  
SELECT 
    'musculacao' as categoria,
    get_or_create_category_goal(
        '01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid,
        'musculacao'
    );

-- Criar meta de Yoga
SELECT 
    'yoga' as categoria,
    get_or_create_category_goal(
        '01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid,
        'yoga'
    );

-- Criar meta de Funcional
SELECT 
    'funcional' as categoria,
    get_or_create_category_goal(
        '01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid,
        'funcional'
    );

-- Criar meta de Corrida
SELECT 
    'corrida' as categoria,
    get_or_create_category_goal(
        '01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid,
        'corrida'
    );

-- ========================================
-- 3. VERIFICAR METAS CRIADAS
-- ========================================

SELECT '📊 VERIFICANDO METAS CRIADAS' as teste;

SELECT 
    category as categoria,
    goal_minutes as meta_minutos,
    current_minutes as progresso_atual,
    completed as completada,
    is_active as ativa,
    week_start_date as inicio_semana,
    created_at as criada_em
FROM workout_category_goals 
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'
AND is_active = true
ORDER BY created_at DESC;

-- ========================================
-- 4. TESTAR ADIÇÃO DE PROGRESSO
-- ========================================

SELECT '⏱️ ADICIONANDO PROGRESSO NAS METAS' as teste;

-- Adicionar 45 minutos de cardio
SELECT 
    'Adicionando 45min de cardio' as acao,
    add_workout_minutes_to_category(
        '01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid,
        'cardio',
        45
    );

-- Adicionar 60 minutos de musculação
SELECT 
    'Adicionando 60min de musculacao' as acao,
    add_workout_minutes_to_category(
        '01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid,
        'musculacao',
        60
    );

-- Adicionar 30 minutos de yoga
SELECT 
    'Adicionando 30min de yoga' as acao,
    add_workout_minutes_to_category(
        '01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid,
        'yoga',
        30
    );

-- ========================================
-- 5. VER PROGRESSO ATUALIZADO
-- ========================================

SELECT '📈 PROGRESSO ATUALIZADO' as teste;

SELECT 
    category as categoria,
    current_minutes || '/' || goal_minutes || ' min' as progresso,
    ROUND((current_minutes::numeric / goal_minutes::numeric) * 100, 2) || '%' as percentual,
    completed as completada,
    CASE 
        WHEN completed THEN '🎉 Completada!'
        WHEN current_minutes::numeric / goal_minutes::numeric >= 0.8 THEN '💪 Quase lá!'
        WHEN current_minutes::numeric / goal_minutes::numeric >= 0.5 THEN '🔥 Metade feita!'
        WHEN current_minutes::numeric / goal_minutes::numeric >= 0.25 THEN '✨ Bom começo!'
        ELSE '🌱 Começando...'
    END as status_visual
FROM workout_category_goals 
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'
AND is_active = true
ORDER BY (current_minutes::numeric / goal_minutes::numeric) DESC;

-- ========================================
-- 6. TESTAR MAPEAMENTO COM VARIAÇÕES
-- ========================================

SELECT '🔄 TESTANDO MAPEAMENTO AUTOMÁTICO' as teste;

-- Simular que o usuário registrou "Força" (deve virar musculacao)
SELECT 
    'Registrando exercício de Força' as acao,
    add_workout_minutes_to_category(
        '01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid,
        normalize_exercise_category('Força'),
        30
    );

-- Simular que o usuário registrou "running" (deve virar corrida)
SELECT 
    'Registrando exercício de running' as acao,
    add_workout_minutes_to_category(
        '01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid,
        normalize_exercise_category('running'),
        25
    );

-- ========================================
-- 7. VERIFICAR RESULTADO FINAL
-- ========================================

SELECT '🏆 RESULTADO FINAL' as teste;

-- Dashboard completo do usuário
SELECT 
    category as categoria,
    goal_minutes as meta,
    current_minutes as progresso,
    ROUND((current_minutes::numeric / goal_minutes::numeric) * 100, 2) as percentual,
    completed as completada,
    week_start_date as semana,
    CASE 
        WHEN completed THEN '🎉'
        WHEN current_minutes::numeric / goal_minutes::numeric >= 0.8 THEN '💪'
        WHEN current_minutes::numeric / goal_minutes::numeric >= 0.5 THEN '🔥'
        WHEN current_minutes::numeric / goal_minutes::numeric >= 0.25 THEN '✨'
        ELSE '🌱'
    END as emoji,
    created_at as criada_em
FROM workout_category_goals 
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'
AND is_active = true
ORDER BY percentual DESC;

-- ========================================
-- 8. TESTAR CRIAÇÃO AUTOMÁTICA
-- ========================================

SELECT '🤖 TESTANDO CRIAÇÃO AUTOMÁTICA' as teste;

-- Tentar adicionar progresso para categoria que não tem meta ainda
SELECT 
    'Adicionando 20min de pilates (sem meta existente)' as acao,
    add_workout_minutes_to_category(
        '01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid,
        'pilates',
        20
    );

-- Verificar se meta foi criada automaticamente
SELECT 
    'Meta de pilates criada automaticamente?' as pergunta,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM workout_category_goals 
            WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'
            AND category = 'pilates'
            AND is_active = true
        ) 
        THEN '✅ SIM! Meta criada automaticamente'
        ELSE '❌ Não, meta não foi criada'
    END as resultado;

-- ========================================
-- 9. COMPLETAR UMA META
-- ========================================

SELECT '🎯 COMPLETANDO UMA META' as teste;

-- Vamos completar a meta de yoga (adicionar minutos suficientes)
SELECT 
    goal_minutes - current_minutes as minutos_restantes_yoga
FROM workout_category_goals 
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'
AND category = 'yoga'
AND is_active = true;

-- Adicionar minutos suficientes para completar yoga (assumindo que precisa de mais 60)
SELECT 
    'Completando meta de yoga' as acao,
    add_workout_minutes_to_category(
        '01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid,
        'yoga',
        70  -- Deve ser suficiente para completar
    );

-- ========================================
-- 10. RESUMO FINAL
-- ========================================

SELECT '📊 RESUMO FINAL DO USUÁRIO' as teste;

-- Estatísticas completas
SELECT 
    'Total de metas ativas' as metrica,
    count(*)::text as valor
FROM workout_category_goals 
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'
AND is_active = true

UNION ALL

SELECT 
    'Metas completadas' as metrica,
    count(*)::text as valor
FROM workout_category_goals 
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'
AND is_active = true 
AND completed = true

UNION ALL

SELECT 
    'Total de minutos registrados' as metrica,
    sum(current_minutes)::text as valor
FROM workout_category_goals 
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'
AND is_active = true

UNION ALL

SELECT 
    'Progresso médio' as metrica,
    ROUND(avg(current_minutes::numeric / goal_minutes::numeric) * 100, 2)::text || '%' as valor
FROM workout_category_goals 
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'
AND is_active = true;

-- Dashboard final visual
SELECT 
    '🏆 DASHBOARD FINAL' as titulo,
    category || ' ' || 
    CASE 
        WHEN completed THEN '🎉'
        WHEN current_minutes::numeric / goal_minutes::numeric >= 0.8 THEN '💪'
        WHEN current_minutes::numeric / goal_minutes::numeric >= 0.5 THEN '🔥'
        WHEN current_minutes::numeric / goal_minutes::numeric >= 0.25 THEN '✨'
        ELSE '🌱'
    END || ' ' ||
    current_minutes || '/' || goal_minutes || ' min (' ||
    ROUND((current_minutes::numeric / goal_minutes::numeric) * 100, 2) || '%)'
    as meta_visual
FROM workout_category_goals 
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'
AND is_active = true
ORDER BY (current_minutes::numeric / goal_minutes::numeric) DESC; 