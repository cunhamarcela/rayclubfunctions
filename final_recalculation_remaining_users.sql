-- 🔧 RECÁLCULO FINAL DOS 6 USUÁRIOS RESTANTES
-- Data: 2025-01-11
-- Objetivo: Recalcular progresso dos usuários sem progresso no challenge 61cf61f4-0325-476e-8ab2-481bf84fd8a4

SET timezone = 'America/Sao_Paulo';

-- 🎯 IDENTIFICAR OS USUÁRIOS RESTANTES
SELECT 
    '🎯 USUÁRIOS PARA RECÁLCULO' as status,
    user_id,
    'Challenge: 61cf61f4-0325-476e-8ab2-481bf84fd8a4' as challenge_info
FROM (
    VALUES 
    ('01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid),
    ('13185d42-ef08-4842-96d9-5845f58bf4f1'::uuid),
    ('2f4ae97d-fafa-4e3a-ba31-eedac1fe9b20'::uuid),
    ('4604cac6-2b8e-4ff4-9ad6-8b58dbb8cacc'::uuid),
    ('a934cab8-f52b-42ff-920c-42c1faadefd5'::uuid),
    ('bbea26ca-f34c-499f-ad3a-48646a614cd3'::uuid)
) AS usuarios_restantes(user_id);

-- 🔍 VERIFICAR CHECK-INS EXISTENTES PARA ESSES USUÁRIOS
SELECT 
    '🔍 CHECK-INS EXISTENTES' as status,
    cci.user_id,
    COALESCE(u.name, 'Nome não encontrado') as nome_usuario,
    COUNT(*) as total_checkins,
    SUM(cci.points) as total_pontos,
    MIN(cci.check_in_date) as primeiro_checkin,
    MAX(cci.check_in_date) as ultimo_checkin
FROM challenge_check_ins cci
LEFT JOIN users u ON cci.user_id = u.id
WHERE cci.challenge_id = '61cf61f4-0325-476e-8ab2-481bf84fd8a4'
    AND cci.user_id IN (
        '01d4a292-1873-4af6-948b-a55eed56d6b9',
        '13185d42-ef08-4842-96d9-5845f58bf4f1',
        '2f4ae97d-fafa-4e3a-ba31-eedac1fe9b20',
        '4604cac6-2b8e-4ff4-9ad6-8b58dbb8cacc',
        'a934cab8-f52b-42ff-920c-42c1faadefd5',
        'bbea26ca-f34c-499f-ad3a-48646a614cd3'
    )
GROUP BY cci.user_id, u.name
ORDER BY total_checkins DESC;

-- 🔧 EXECUTAR RECÁLCULO PARA CADA USUÁRIO
DO $$
DECLARE
    user_ids uuid[] := ARRAY[
        '01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid,
        '13185d42-ef08-4842-96d9-5845f58bf4f1'::uuid,
        '2f4ae97d-fafa-4e3a-ba31-eedac1fe9b20'::uuid,
        '4604cac6-2b8e-4ff4-9ad6-8b58dbb8cacc'::uuid,
        'a934cab8-f52b-42ff-920c-42c1faadefd5'::uuid,
        'bbea26ca-f34c-499f-ad3a-48646a614cd3'::uuid
    ];
    challenge_id uuid := '61cf61f4-0325-476e-8ab2-481bf84fd8a4';
    user_id uuid;
    checkins_count integer;
    total_points integer;
    progress_exists boolean;
BEGIN
    RAISE NOTICE '🔧 INICIANDO RECÁLCULO DOS 6 USUÁRIOS RESTANTES';
    
    FOREACH user_id IN ARRAY user_ids LOOP
        -- Verificar se há check-ins para este usuário
        SELECT COUNT(*), COALESCE(SUM(points), 0)
        INTO checkins_count, total_points
        FROM challenge_check_ins
        WHERE user_id = user_id AND challenge_id = challenge_id;
        
        -- Verificar se já existe progresso
        SELECT EXISTS(
            SELECT 1 FROM challenge_progress 
            WHERE user_id = user_id AND challenge_id = challenge_id
        ) INTO progress_exists;
        
        RAISE NOTICE '👤 Usuário: % | Check-ins: % | Pontos: % | Progresso existe: %', 
            user_id, checkins_count, total_points, progress_exists;
        
        IF checkins_count > 0 THEN
            -- Deletar progresso existente se houver
            DELETE FROM challenge_progress 
            WHERE user_id = user_id AND challenge_id = challenge_id;
            
            -- Inserir novo progresso
            INSERT INTO challenge_progress (
                user_id, 
                challenge_id, 
                check_ins, 
                points, 
                created_at, 
                updated_at
            ) VALUES (
                user_id,
                challenge_id,
                checkins_count,
                total_points,
                NOW(),
                NOW()
            );
            
            RAISE NOTICE '✅ Progresso recalculado: % check-ins, % pontos', checkins_count, total_points;
        ELSE
            RAISE NOTICE '⚠️ Usuário sem check-ins válidos';
        END IF;
    END LOOP;
    
    RAISE NOTICE '🎉 RECÁLCULO CONCLUÍDO PARA TODOS OS 6 USUÁRIOS';
END $$;

-- ✅ VERIFICAÇÃO FINAL
SELECT 
    '✅ VERIFICAÇÃO PÓS-RECÁLCULO' as status,
    cp.user_id,
    COALESCE(u.name, 'Nome não encontrado') as nome_usuario,
    cp.check_ins as checkins_progresso,
    cp.points as pontos_progresso,
    cp.updated_at as atualizado_em,
    -- Verificar consistência com check-ins reais
    (SELECT COUNT(*) FROM challenge_check_ins cci 
     WHERE cci.user_id = cp.user_id AND cci.challenge_id = cp.challenge_id) as checkins_reais,
    (SELECT COALESCE(SUM(points), 0) FROM challenge_check_ins cci 
     WHERE cci.user_id = cp.user_id AND cci.challenge_id = cp.challenge_id) as pontos_reais,
    CASE 
        WHEN cp.check_ins = (SELECT COUNT(*) FROM challenge_check_ins cci 
                            WHERE cci.user_id = cp.user_id AND cci.challenge_id = cp.challenge_id)
        AND cp.points = (SELECT COALESCE(SUM(points), 0) FROM challenge_check_ins cci 
                        WHERE cci.user_id = cp.user_id AND cci.challenge_id = cp.challenge_id)
        THEN '✅ CONSISTENTE'
        ELSE '❌ INCONSISTENTE'
    END as status_consistencia
FROM challenge_progress cp
LEFT JOIN users u ON cp.user_id = u.id
WHERE cp.challenge_id = '61cf61f4-0325-476e-8ab2-481bf84fd8a4'
    AND cp.user_id IN (
        '01d4a292-1873-4af6-948b-a55eed56d6b9',
        '13185d42-ef08-4842-96d9-5845f58bf4f1',
        '2f4ae97d-fafa-4e3a-ba31-eedac1fe9b20',
        '4604cac6-2b8e-4ff4-9ad6-8b58dbb8cacc',
        'a934cab8-f52b-42ff-920c-42c1faadefd5',
        'bbea26ca-f34c-499f-ad3a-48646a614cd3'
    )
ORDER BY cp.points DESC;

-- 📊 ESTATÍSTICAS FINAIS ATUALIZADAS
WITH stats_finais AS (
    SELECT 
        COUNT(DISTINCT cci.user_id) as usuarios_com_checkins,
        COUNT(*) as total_checkins,
        SUM(cci.points) as total_pontos,
        (SELECT COUNT(DISTINCT user_id) FROM challenge_progress WHERE challenge_id = '61cf61f4-0325-476e-8ab2-481bf84fd8a4') as usuarios_com_progresso
    FROM challenge_check_ins cci
    WHERE cci.challenge_id = '61cf61f4-0325-476e-8ab2-481bf84fd8a4'
)
SELECT 
    '📊 ESTATÍSTICAS FINAIS ATUALIZADAS' as status,
    sf.usuarios_com_checkins,
    sf.usuarios_com_progresso,
    sf.total_checkins,
    sf.total_pontos,
    CASE 
        WHEN sf.usuarios_com_checkins = sf.usuarios_com_progresso THEN '✅ COBERTURA COMPLETA'
        ELSE '⚠️ COBERTURA INCOMPLETA: ' || (sf.usuarios_com_checkins - sf.usuarios_com_progresso)::text || ' usuários restantes'
    END as status_cobertura
FROM stats_finais sf; 