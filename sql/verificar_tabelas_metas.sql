-- ========================================
-- VERIFICAR TABELAS DE METAS EXISTENTES
-- ========================================
-- Data: 2025-07-28
-- Objetivo: Identificar qual sistema de metas está funcionando

-- 1. Verificar se as tabelas existem
DO $$
BEGIN
    -- Verificar weekly_goals (sistema antigo)
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'weekly_goals') THEN
        RAISE NOTICE '✅ TABELA weekly_goals existe';
        EXECUTE 'SELECT COUNT(*) as total_weekly_goals FROM weekly_goals';
    ELSE
        RAISE NOTICE '❌ TABELA weekly_goals NÃO existe';
    END IF;

    -- Verificar weekly_goals_expanded (sistema expandido)
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'weekly_goals_expanded') THEN
        RAISE NOTICE '✅ TABELA weekly_goals_expanded existe';
        EXECUTE 'SELECT COUNT(*) as total_weekly_goals_expanded FROM weekly_goals_expanded';
    ELSE
        RAISE NOTICE '❌ TABELA weekly_goals_expanded NÃO existe';
    END IF;

    -- Verificar personalized_weekly_goals (sistema personalizado)
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'personalized_weekly_goals') THEN
        RAISE NOTICE '✅ TABELA personalized_weekly_goals existe';
        EXECUTE 'SELECT COUNT(*) as total_personalized_weekly_goals FROM personalized_weekly_goals';
    ELSE
        RAISE NOTICE '❌ TABELA personalized_weekly_goals NÃO existe';
    END IF;
END $$;

-- 2. Mostrar dados das tabelas que existem
-- Sistema antigo
SELECT 'SISTEMA ANTIGO - weekly_goals' as sistema, COUNT(*) as total_registros 
FROM weekly_goals 
WHERE TRUE = (SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'weekly_goals'))
UNION ALL
-- Sistema expandido  
SELECT 'SISTEMA EXPANDIDO - weekly_goals_expanded' as sistema, COUNT(*) as total_registros
FROM weekly_goals_expanded
WHERE TRUE = (SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'weekly_goals_expanded'))
UNION ALL
-- Sistema personalizado
SELECT 'SISTEMA PERSONALIZADO - personalized_weekly_goals' as sistema, COUNT(*) as total_registros  
FROM personalized_weekly_goals
WHERE TRUE = (SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'personalized_weekly_goals'));

-- 3. Se weekly_goals existir, mostrar suas metas
DO $$
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'weekly_goals') THEN
        RAISE NOTICE '🔍 DADOS em weekly_goals:';
    END IF;
END $$;

SELECT 
    'weekly_goals' as tabela,
    id,
    user_id,
    goal_title,
    target_value,
    current_value,
    active,
    week_start_date,
    created_at
FROM weekly_goals 
WHERE TRUE = (SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'weekly_goals'))
ORDER BY created_at DESC
LIMIT 5;

-- 4. Se weekly_goals_expanded existir, mostrar suas metas  
SELECT 
    'weekly_goals_expanded' as tabela,
    id,
    user_id,
    goal_title,
    target_value,
    current_value,
    active,
    week_start_date,
    created_at
FROM weekly_goals_expanded
WHERE TRUE = (SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'weekly_goals_expanded'))
ORDER BY created_at DESC  
LIMIT 5;

-- 5. Se personalized_weekly_goals existir, mostrar suas metas
SELECT 
    'personalized_weekly_goals' as tabela,
    id,
    user_id,
    goal_title,
    target_value,
    current_progress,
    active,
    week_start_date,
    created_at
FROM personalized_weekly_goals
WHERE TRUE = (SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'personalized_weekly_goals'))
ORDER BY created_at DESC
LIMIT 5; 