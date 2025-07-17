-- REMOVER CHECK-INS INVÁLIDOS DO DIA 25 DE MAIO
-- O desafio começou no dia 26, não deveria ter check-ins no dia 25

-- ========================================
-- PASSO 1: VERIFICAR O PERÍODO DO DESAFIO
-- ========================================
SELECT 
    'PERÍODO DO DESAFIO' as info,
    title,
    start_date,
    end_date,
    DATE(start_date) as data_inicio,
    DATE(end_date) as data_fim
FROM challenges 
WHERE id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82';

-- ========================================
-- PASSO 2: IDENTIFICAR CHECK-INS ANTES DO INÍCIO
-- ========================================
SELECT 
    'CHECK-INS INVÁLIDOS' as tipo,
    p.name as usuario,
    DATE(cci.check_in_date AT TIME ZONE 'UTC' AT TIME ZONE 'America/Sao_Paulo') as data_brasil,
    cci.workout_name,
    cci.id as checkin_id
FROM challenge_check_ins cci
LEFT JOIN profiles p ON p.id = cci.user_id
WHERE cci.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
AND DATE(cci.check_in_date AT TIME ZONE 'UTC' AT TIME ZONE 'America/Sao_Paulo') < '2025-05-26'
ORDER BY p.name, cci.check_in_date;

-- ========================================
-- PASSO 3: DELETAR CHECK-INS DO DIA 25 (ANTES DO DESAFIO)
-- ========================================
DELETE FROM challenge_check_ins 
WHERE challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
AND DATE(check_in_date AT TIME ZONE 'UTC' AT TIME ZONE 'America/Sao_Paulo') < '2025-05-26';

-- ========================================
-- PASSO 4: RECALCULAR PROGRESSO APÓS REMOÇÃO
-- ========================================
WITH correct_progress_final AS (
    SELECT 
        cci.user_id,
        cci.challenge_id,
        COUNT(DISTINCT DATE(cci.check_in_date AT TIME ZONE 'UTC' AT TIME ZONE 'America/Sao_Paulo')) as correct_check_ins_count,
        COUNT(DISTINCT DATE(cci.check_in_date AT TIME ZONE 'UTC' AT TIME ZONE 'America/Sao_Paulo')) * 10 as total_points,
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
    check_ins_count = correct_progress_final.correct_check_ins_count,
    total_check_ins = correct_progress_final.correct_check_ins_count,
    points = correct_progress_final.total_points,
    last_check_in = correct_progress_final.last_check_in_date,
    completion_percentage = LEAST(100, (correct_progress_final.correct_check_ins_count * 100.0) / 20),
    updated_at = NOW(),
    user_name = correct_progress_final.user_name,
    user_photo_url = correct_progress_final.user_photo_url
FROM correct_progress_final
WHERE cp.user_id = correct_progress_final.user_id 
AND cp.challenge_id = correct_progress_final.challenge_id;

-- ========================================
-- PASSO 5: RECALCULAR RANKING FINAL (CRITÉRIO CORRETO)
-- ========================================
WITH challenge_workouts AS (
    -- Contar APENAS treinos deste desafio específico para desempate
    SELECT 
        user_id,
        COUNT(*) as total_workouts_this_challenge
    FROM workout_records
    WHERE challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
    GROUP BY user_id
),
ranked_users AS (
    SELECT
        cp.user_id,
        cp.challenge_id,
        DENSE_RANK() OVER (
            ORDER BY 
                cp.points DESC,                                           -- 1º: Pontos (dias com check-in)
                COALESCE(cw.total_workouts_this_challenge, 0) DESC,       -- 2º: TREINOS APENAS DESTE DESAFIO
                cp.last_check_in ASC NULLS LAST                          -- 3º: Data do último check-in (mais antigo ganha)
        ) AS new_position
    FROM challenge_progress cp
    LEFT JOIN challenge_workouts cw ON cw.user_id = cp.user_id
    WHERE cp.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
)
UPDATE challenge_progress cp
SET position = ru.new_position
FROM ranked_users ru
WHERE cp.challenge_id = ru.challenge_id 
AND cp.user_id = ru.user_id;

-- ========================================
-- PASSO 6: VERIFICAR RESULTADO FINAL CORRETO
-- ========================================

-- Ver o ranking final correto com critérios de desempate
SELECT 
    'RANKING FINAL CORRETO' as status,
    cp.position,
    COALESCE(p.name, 'Usuário') as nome,
    cp.points,
    cp.check_ins_count,
    (SELECT COUNT(*) FROM workout_records wr 
     WHERE wr.user_id = cp.user_id AND wr.challenge_id = cp.challenge_id) as treinos_neste_desafio,
    (SELECT STRING_AGG(
        DATE(cci.check_in_date AT TIME ZONE 'UTC' AT TIME ZONE 'America/Sao_Paulo')::text, 
        ', ' ORDER BY DATE(cci.check_in_date AT TIME ZONE 'UTC' AT TIME ZONE 'America/Sao_Paulo')
    ) FROM challenge_check_ins cci 
     WHERE cci.user_id = cp.user_id AND cci.challenge_id = cp.challenge_id) as datas_checkin
FROM challenge_progress cp
LEFT JOIN profiles p ON p.id = cp.user_id
WHERE cp.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
ORDER BY cp.position
LIMIT 20;

-- ========================================
-- PASSO 7: VERIFICAR ESPECIFICAMENTE AS EX-LÍDERES
-- ========================================
SELECT 
    'VERIFICAÇÃO FINAL LÍDERES' as tipo,
    p.name as usuario,
    cp.points as pontos_finais,
    cp.check_ins_count as checkins_finais,
    cp.position as posicao_final,
    (SELECT COUNT(*) FROM workout_records wr 
     WHERE wr.user_id = cp.user_id AND wr.challenge_id = cp.challenge_id) as treinos_desafio,
    (SELECT STRING_AGG(
        DATE(cci.check_in_date AT TIME ZONE 'UTC' AT TIME ZONE 'America/Sao_Paulo')::text, 
        ', ' ORDER BY DATE(cci.check_in_date AT TIME ZONE 'UTC' AT TIME ZONE 'America/Sao_Paulo')
    ) FROM challenge_check_ins cci 
     WHERE cci.user_id = cp.user_id AND cci.challenge_id = cp.challenge_id) as datas_validas
FROM challenge_progress cp
LEFT JOIN profiles p ON p.id = cp.user_id
WHERE cp.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
AND p.name IN ('Flávia Martins Vasconcelos Filiu', 'Gabriela Bacelar', 'Marcela Cunha Santana', 'Yolanda Monteiro')
ORDER BY cp.position;

-- ========================================
-- PASSO 8: ESTATÍSTICAS DO RANKING CORRIGIDO
-- ========================================
SELECT 
    'ESTATÍSTICAS RANKING' as tipo,
    cp.points,
    COUNT(*) as usuarios_com_esta_pontuacao,
    STRING_AGG(COALESCE(p.name, 'Usuário'), ', ' ORDER BY cp.position) as usuarios
FROM challenge_progress cp
LEFT JOIN profiles p ON p.id = cp.user_id
WHERE cp.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
GROUP BY cp.points
ORDER BY cp.points DESC; 