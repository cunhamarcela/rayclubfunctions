-- ========================================
-- CORREÇÃO: PERMITIR MÚLTIPLAS METAS ATIVAS POR USUÁRIO
-- ========================================
-- Data: 2025-07-28
-- Objetivo: Remover constraint que impede múltiplas metas ativas por usuário na mesma semana
-- Problema: unique_active_goal_per_user_week impede múltiplas metas simultâneas

-- 1. Remover a constraint problemática
ALTER TABLE weekly_goals_expanded 
DROP CONSTRAINT IF EXISTS unique_active_goal_per_user_week;

-- 2. Criar nova constraint mais flexível que permite múltiplas metas ativas
-- mas evita duplicação da mesma meta (mesmo título e tipo)
ALTER TABLE weekly_goals_expanded 
ADD CONSTRAINT unique_goal_type_per_user_week 
UNIQUE (user_id, week_start_date, goal_type, goal_title);

-- 3. Comentário explicativo
COMMENT ON CONSTRAINT unique_goal_type_per_user_week ON weekly_goals_expanded IS 
'Permite múltiplas metas ativas por usuário na mesma semana, mas evita duplicação do mesmo tipo de meta';

-- 4. Verificar estrutura atual
SELECT constraint_name, constraint_type 
FROM information_schema.table_constraints 
WHERE table_name = 'weekly_goals_expanded' 
AND constraint_type = 'UNIQUE'; 