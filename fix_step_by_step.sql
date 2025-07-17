-- SCRIPT PASSO A PASSO PARA CORRIGIR DUPLICAÇÃO DE CHECK-INS
-- Execute cada seção separadamente

-- ========================================
-- PASSO 1: VERIFICAR SITUAÇÃO ATUAL
-- ========================================

-- Ver quantas duplicatas existem
SELECT 
    'Duplicatas por data' as tipo,
    COUNT(*) as quantidade
FROM (
    SELECT user_id, challenge_id, DATE(check_in_date)
    FROM challenge_check_ins
    GROUP BY user_id, challenge_id, DATE(check_in_date)
    HAVING COUNT(*) > 1
) duplicates;

-- ========================================
-- PASSO 2: LIMPAR DUPLICATAS EXISTENTES
-- ========================================

-- Remover check-ins duplicados (manter o mais recente)
WITH duplicates AS (
    SELECT 
        id,
        ROW_NUMBER() OVER (
            PARTITION BY user_id, challenge_id, DATE(check_in_date) 
            ORDER BY created_at DESC
        ) as rn
    FROM challenge_check_ins
)
DELETE FROM challenge_check_ins 
WHERE id IN (
    SELECT id FROM duplicates WHERE rn > 1
);

-- ========================================
-- PASSO 3: RECALCULAR CHALLENGE_PROGRESS
-- ========================================

-- Atualizar contagens corretas
WITH correct_counts AS (
    SELECT 
        cci.challenge_id,
        cci.user_id,
        COUNT(*) as real_check_ins,
        COUNT(*) * 10 as real_points,
        MAX(cci.check_in_date) as last_check_in
    FROM challenge_check_ins cci
    GROUP BY cci.challenge_id, cci.user_id
)
UPDATE challenge_progress cp
SET 
    points = cc.real_points,
    check_ins_count = cc.real_check_ins,
    total_check_ins = cc.real_check_ins,
    last_check_in = cc.last_check_in,
    updated_at = NOW()
FROM correct_counts cc
WHERE cp.challenge_id = cc.challenge_id 
  AND cp.user_id = cc.user_id;

-- ========================================
-- PASSO 4: ADICIONAR CONSTRAINT (OPCIONAL)
-- ========================================

-- Tentar adicionar constraint para prevenir duplicatas futuras
-- Se der erro, pode pular este passo
DO $$
BEGIN
    ALTER TABLE challenge_check_ins 
    ADD CONSTRAINT unique_user_challenge_workout_checkin 
    UNIQUE (user_id, challenge_id, workout_id);
    RAISE NOTICE 'Constraint adicionada com sucesso';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Constraint já existe ou erro: %', SQLERRM;
END $$;

-- ========================================
-- PASSO 5: VERIFICAR RESULTADO
-- ========================================

-- Verificar se ainda há duplicatas
SELECT 
    'Duplicatas restantes' as status,
    COUNT(*) as quantidade
FROM (
    SELECT user_id, challenge_id, DATE(check_in_date)
    FROM challenge_check_ins
    GROUP BY user_id, challenge_id, DATE(check_in_date)
    HAVING COUNT(*) > 1
) duplicates;

-- Ver estatísticas gerais
SELECT 
    'Total de check-ins' as tipo,
    COUNT(*) as quantidade
FROM challenge_check_ins
UNION ALL
SELECT 
    'Total de usuários com progresso' as tipo,
    COUNT(*) as quantidade
FROM challenge_progress;

-- ========================================
-- PASSO 6: RESOLVER DUPLICATAS RESTANTES
-- ========================================

-- ========================================
-- PASSO 1: IDENTIFICAR OS USUÁRIOS PROBLEMÁTICOS
-- ========================================
SELECT 
    'USUÁRIOS PROBLEMÁTICOS' as tipo,
    cci.user_id,
    COALESCE(p.name, 'SEM NOME') as nome_usuario,
    DATE(cci.check_in_date) as data,
    COUNT(*) as quantidade_checkins,
    STRING_AGG(cci.id::text, ', ') as ids_checkins
FROM challenge_check_ins cci
LEFT JOIN profiles p ON p.id = cci.user_id
WHERE cci.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
GROUP BY cci.user_id, p.name, DATE(cci.check_in_date)
HAVING COUNT(*) > 1
ORDER BY cci.user_id, DATE(cci.check_in_date);

-- ========================================
-- PASSO 2: DELETAR DUPLICATAS BASEADO NO USER_ID (NÃO NO NAME)
-- ========================================
WITH checkins_to_keep AS (
    SELECT 
        cci.id,
        cci.user_id,
        DATE(cci.check_in_date) as check_date,
        ROW_NUMBER() OVER (
            PARTITION BY cci.user_id, DATE(cci.check_in_date) 
            ORDER BY cci.created_at ASC
        ) as rn
    FROM challenge_check_ins cci
    WHERE cci.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
)
DELETE FROM challenge_check_ins 
WHERE challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
AND id NOT IN (
    SELECT id FROM checkins_to_keep WHERE rn = 1
);

-- ========================================
-- PASSO 3: VERIFICAR SE AINDA EXISTEM DUPLICATAS
-- ========================================
SELECT 
    'VERIFICAÇÃO PÓS LIMPEZA' as tipo,
    cci.user_id,
    COALESCE(p.name, 'SEM NOME') as nome_usuario,
    DATE(cci.check_in_date) as data,
    COUNT(*) as quantidade_checkins
FROM challenge_check_ins cci
LEFT JOIN profiles p ON p.id = cci.user_id
WHERE cci.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
GROUP BY cci.user_id, p.name, DATE(cci.check_in_date)
HAVING COUNT(*) > 1
ORDER BY cci.user_id, DATE(cci.check_in_date);

-- ========================================
-- PASSO 4: RECALCULAR PROGRESSO CORRETAMENTE
-- ========================================
WITH correct_progress AS (
    SELECT 
        cci.user_id,
        cci.challenge_id,
        COUNT(DISTINCT DATE(cci.check_in_date)) as correct_check_ins_count,
        COUNT(DISTINCT DATE(cci.check_in_date)) * 10 as total_points,
        MAX(cci.check_in_date) as last_check_in_date,
        COALESCE(p.name, 'Usuário') as user_name,
        p.photo_url as user_photo_url
    FROM challenge_check_ins cci
    LEFT JOIN profiles p ON p.id = cci.user_id
    WHERE cci.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
    GROUP BY cci.user_id, cci.challenge_id, p.name, p.photo_url
)
UPDATE challenge_progress cp
SET 
    check_ins_count = correct_progress.correct_check_ins_count,
    total_check_ins = correct_progress.correct_check_ins_count,
    points = correct_progress.total_points,
    last_check_in = correct_progress.last_check_in_date,
    completion_percentage = LEAST(100, (correct_progress.correct_check_ins_count * 100.0) / 20), -- 20 dias no desafio
    updated_at = NOW(),
    user_name = correct_progress.user_name,
    user_photo_url = correct_progress.user_photo_url
FROM correct_progress
WHERE cp.user_id = correct_progress.user_id 
AND cp.challenge_id = correct_progress.challenge_id;

-- ========================================
-- PASSO 5: RECALCULAR RANKING
-- ========================================
WITH user_total_workouts AS (
    SELECT 
        user_id,
        COUNT(*) as total_workouts_ever
    FROM workout_records
    GROUP BY user_id
),
ranked_users AS (
    SELECT
        cp.user_id,
        cp.challenge_id,
        DENSE_RANK() OVER (
            ORDER BY 
                cp.points DESC,
                COALESCE(utw.total_workouts_ever, 0) DESC,
                cp.last_check_in ASC NULLS LAST
        ) AS new_position
    FROM challenge_progress cp
    LEFT JOIN user_total_workouts utw ON utw.user_id = cp.user_id
    WHERE cp.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
)
UPDATE challenge_progress cp
SET position = ru.new_position
FROM ranked_users ru
WHERE cp.challenge_id = ru.challenge_id 
AND cp.user_id = ru.user_id;

-- ========================================
-- PASSO 6: RESULTADO FINAL
-- ========================================
SELECT 
    'RESULTADO FINAL CORRIGIDO' as status,
    cp.user_id,
    COALESCE(p.name, 'Usuário') as nome,
    cp.points,
    cp.check_ins_count,
    cp.total_check_ins,
    cp.position,
    (SELECT COUNT(DISTINCT DATE(cci.check_in_date)) 
     FROM challenge_check_ins cci 
     WHERE cci.user_id = cp.user_id AND cci.challenge_id = cp.challenge_id) as verificacao_checkins_unicos
FROM challenge_progress cp
LEFT JOIN profiles p ON p.id = cp.user_id
WHERE cp.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
ORDER BY cp.position;

-- ========================================
-- PASSO 7: ESTATÍSTICAS FINAIS
-- ========================================
SELECT 
    'ESTATÍSTICAS FINAIS' as tipo,
    COUNT(DISTINCT cp.user_id) as total_usuarios_no_desafio,
    SUM(cp.check_ins_count) as total_checkins_unicos,
    AVG(cp.check_ins_count) as media_checkins_por_usuario,
    MAX(cp.check_ins_count) as max_checkins_usuario,
    MIN(cp.check_ins_count) as min_checkins_usuario
FROM challenge_progress cp
WHERE cp.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'; 