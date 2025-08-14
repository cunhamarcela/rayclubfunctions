-- ========================================
-- CORREÇÃO V2: REMOVER DUPLICATAS E PERMITIR MÚLTIPLAS METAS
-- ========================================
-- Data: 2025-07-28
-- Problema: Existem metas duplicadas impedindo a criação da nova constraint

BEGIN;

-- 1. PRIMEIRO: Identificar e remover duplicatas mantendo apenas a mais recente
WITH duplicates AS (
    SELECT 
        id,
        user_id,
        week_start_date,
        goal_type,
        goal_title,
        created_at,
        ROW_NUMBER() OVER (
            PARTITION BY user_id, week_start_date, goal_type, goal_title 
            ORDER BY created_at DESC
        ) as rn
    FROM weekly_goals_expanded
    WHERE active = true
)
DELETE FROM weekly_goals_expanded 
WHERE id IN (
    SELECT id FROM duplicates WHERE rn > 1
);

-- 2. Remover a constraint problemática
ALTER TABLE weekly_goals_expanded 
DROP CONSTRAINT IF EXISTS unique_active_goal_per_user_week;

-- 3. Criar nova constraint mais flexível (OPCIONAL - permite duplicatas controladas)
-- Comentado para permitir total liberdade na criação de metas
-- ALTER TABLE weekly_goals_expanded 
-- ADD CONSTRAINT unique_goal_type_per_user_week 
-- UNIQUE (user_id, week_start_date, goal_type, goal_title);

-- 4. Verificar que as duplicatas foram removidas
SELECT 
    user_id,
    week_start_date,
    goal_type,
    goal_title,
    COUNT(*) as total_metas
FROM weekly_goals_expanded 
WHERE active = true
GROUP BY user_id, week_start_date, goal_type, goal_title
HAVING COUNT(*) > 1;

-- 5. Mostrar constraint atuais
SELECT constraint_name, constraint_type 
FROM information_schema.table_constraints 
WHERE table_name = 'weekly_goals_expanded' 
AND constraint_type = 'UNIQUE';

COMMIT;

-- 6. Comentário final
COMMENT ON TABLE weekly_goals_expanded IS 
'Tabela de metas semanais expandidas - permite múltiplas metas ativas por usuário sem restrições de duplicação'; 