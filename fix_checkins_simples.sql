-- =====================================================================================
-- CORREÇÃO SIMPLES: CHECK-INS PRÉ-DESAFIO
-- Versão ultra-simples para Supabase
-- Remove check-ins inválidos e recalcula progresso
-- =====================================================================================

-- PASSO 1: Criar tabela de backup
CREATE TABLE IF NOT EXISTS challenge_check_ins_backup_pre_challenge (
    LIKE challenge_check_ins INCLUDING ALL,
    backup_timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    backup_reason TEXT DEFAULT 'pre_challenge_fix'
);

-- PASSO 2: Fazer backup dos check-ins que serão removidos
INSERT INTO challenge_check_ins_backup_pre_challenge 
(id, user_id, challenge_id, check_in_date, points, workout_id, created_at, updated_at, backup_timestamp, backup_reason)
SELECT 
    id, user_id, challenge_id, check_in_date, points, workout_id, created_at, updated_at, 
    NOW(), 'pre_challenge_fix'
FROM challenge_check_ins 
WHERE challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
AND check_in_date < '2025-05-26 00:00:00-03';

-- PASSO 3: Remover check-ins inválidos
DELETE FROM challenge_check_ins 
WHERE challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
AND check_in_date < '2025-05-26 00:00:00-03';

-- PASSO 4: Recalcular progresso dos usuários afetados
UPDATE challenge_progress 
SET 
    total_check_ins = (
        SELECT COUNT(*) 
        FROM challenge_check_ins 
        WHERE user_id = challenge_progress.user_id 
        AND challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
    ),
    total_points = (
        SELECT COALESCE(SUM(points), 0) 
        FROM challenge_check_ins 
        WHERE user_id = challenge_progress.user_id 
        AND challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
    ),
    updated_at = NOW()
WHERE challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
AND user_id IN (
    SELECT DISTINCT user_id 
    FROM challenge_check_ins_backup_pre_challenge 
    WHERE backup_reason = 'pre_challenge_fix'
);

-- PASSO 5: Verificações finais
SELECT 
    'Backup Criado' as status,
    COUNT(*) as registros_backup
FROM challenge_check_ins_backup_pre_challenge 
WHERE backup_reason = 'pre_challenge_fix';

SELECT 
    'Check-ins Restantes Inválidos' as status,
    COUNT(*) as checkins_invalidos_restantes
FROM challenge_check_ins 
WHERE challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
AND check_in_date < '2025-05-26 00:00:00-03';

SELECT 
    'Estatísticas Finais' as status,
    COUNT(DISTINCT user_id) as usuarios_participando,
    COUNT(*) as checkins_validos,
    SUM(points) as pontos_validos
FROM challenge_check_ins 
WHERE challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'; 