-- TESTE ESPECÍFICO PARA O CASO DO USUÁRIO
-- Cenário: Criar treino, excluir, verificar se o progresso é recalculado corretamente

-- =====================================================
-- 1. VERIFICAR ESTADO ATUAL DO SEU PROGRESSO
-- =====================================================

-- Substitua 'SEU_USER_ID' pelo seu ID de usuário real
-- Substitua 'CHALLENGE_ID' pelo ID do desafio em questão

-- Para encontrar seu user_id se você não souber:
SELECT 
    'Encontrar seu user_id' as status,
    id as user_id,
    name,
    email
FROM auth.users 
WHERE email ILIKE '%seu_email_aqui%'  -- Substitua pelo seu email
LIMIT 5;

-- Para encontrar o challenge_id do desafio ativo:
SELECT 
    'Desafios ativos' as status,
    id as challenge_id,
    name,
    start_date,
    end_date,
    points as points_per_checkin
FROM challenges 
WHERE NOW() BETWEEN start_date AND end_date
ORDER BY start_date DESC;

-- =====================================================
-- 2. VERIFICAR SEU PROGRESSO ATUAL
-- =====================================================

-- Substitua os IDs pelos valores corretos:
DO $$ 
DECLARE
    user_id_param UUID := '00000000-0000-0000-0000-000000000000'; -- SUBSTITUA pelo seu user_id
    challenge_id_param UUID := '00000000-0000-0000-0000-000000000000'; -- SUBSTITUA pelo challenge_id
BEGIN
    -- Mostrar progresso atual
    RAISE NOTICE '=== PROGRESSO ATUAL ===';
    
    PERFORM (
        SELECT RAISE(NOTICE, 'Pontos no challenge_progress: %', points)
        FROM challenge_progress 
        WHERE user_id = user_id_param AND challenge_id = challenge_id_param
    );
    
    PERFORM (
        SELECT RAISE(NOTICE, 'Check-ins no challenge_progress: %', check_ins_count)
        FROM challenge_progress 
        WHERE user_id = user_id_param AND challenge_id = challenge_id_param
    );
    
    -- Mostrar check-ins reais
    PERFORM (
        SELECT RAISE(NOTICE, 'Check-ins reais na tabela: %', COUNT(*))
        FROM challenge_check_ins 
        WHERE user_id = user_id_param AND challenge_id = challenge_id_param
    );
    
    -- Mostrar treinos relacionados
    PERFORM (
        SELECT RAISE(NOTICE, 'Treinos relacionados: %', COUNT(*))
        FROM workout_records 
        WHERE user_id = user_id_param AND challenge_id = challenge_id_param
    );
    
    -- Mostrar check-ins órfãos (sem treino correspondente)
    PERFORM (
        SELECT RAISE(NOTICE, 'Check-ins órfãos: %', COUNT(*))
        FROM challenge_check_ins cci
        WHERE cci.user_id = user_id_param 
          AND cci.challenge_id = challenge_id_param
          AND cci.workout_id IS NOT NULL
          AND NOT EXISTS (
              SELECT 1 FROM workout_records wr 
              WHERE wr.id = cci.workout_id::uuid
          )
    );
END $$;

-- =====================================================
-- 3. FUNÇÃO PARA RECALCULAR SEU PROGRESSO MANUALMENTE
-- =====================================================

CREATE OR REPLACE FUNCTION fix_my_progress(
    p_user_id UUID,
    p_challenge_id UUID
)
RETURNS TABLE(
    status TEXT,
    old_points INTEGER,
    new_points INTEGER,
    old_checkins INTEGER,
    new_checkins INTEGER,
    orphan_checkins_removed INTEGER
) AS $$
DECLARE
    old_points INTEGER := 0;
    old_checkins INTEGER := 0;
    orphan_count INTEGER := 0;
    recalc_result JSONB;
BEGIN
    -- Capturar valores antigos
    SELECT COALESCE(points, 0), COALESCE(check_ins_count, 0)
    INTO old_points, old_checkins
    FROM challenge_progress
    WHERE user_id = p_user_id AND challenge_id = p_challenge_id;
    
    -- Contar e remover check-ins órfãos
    WITH orphan_checkins AS (
        DELETE FROM challenge_check_ins cci
        WHERE cci.user_id = p_user_id 
          AND cci.challenge_id = p_challenge_id
          AND cci.workout_id IS NOT NULL
          AND NOT EXISTS (
              SELECT 1 FROM workout_records wr 
              WHERE wr.id = cci.workout_id::uuid
          )
        RETURNING id
    )
    SELECT COUNT(*) INTO orphan_count FROM orphan_checkins;
    
    -- Recalcular usando a função melhorada
    SELECT recalculate_challenge_progress_complete(p_user_id, p_challenge_id) INTO recalc_result;
    
    -- Retornar comparação
    RETURN QUERY
    SELECT 
        'Progresso corrigido'::TEXT,
        old_points,
        (recalc_result->>'points')::INTEGER,
        old_checkins,
        (recalc_result->>'check_ins')::INTEGER,
        orphan_count;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 4. EXECUTAR CORREÇÃO PARA SEU CASO
-- =====================================================

-- IMPORTANTE: Substitua pelos seus IDs reais antes de executar:
/*
SELECT * FROM fix_my_progress(
    '00000000-0000-0000-0000-000000000000'::UUID,  -- SEU USER_ID
    '00000000-0000-0000-0000-000000000000'::UUID   -- CHALLENGE_ID
);
*/

-- =====================================================
-- 5. VERIFICAR RESULTADO
-- =====================================================

-- Após executar a correção, execute novamente para verificar:
/*
DO $$ 
DECLARE
    user_id_param UUID := '00000000-0000-0000-0000-000000000000'; -- SEU USER_ID
    challenge_id_param UUID := '00000000-0000-0000-0000-000000000000'; -- CHALLENGE_ID
BEGIN
    RAISE NOTICE '=== PROGRESSO APÓS CORREÇÃO ===';
    
    PERFORM (
        SELECT RAISE(NOTICE, 'Pontos atualizados: %', points)
        FROM challenge_progress 
        WHERE user_id = user_id_param AND challenge_id = challenge_id_param
    );
    
    PERFORM (
        SELECT RAISE(NOTICE, 'Check-ins atualizados: %', check_ins_count)
        FROM challenge_progress 
        WHERE user_id = user_id_param AND challenge_id = challenge_id_param
    );
END $$;
*/

-- =====================================================
-- 6. PARA PREVENIR PROBLEMAS FUTUROS
-- =====================================================

-- Esta função pode ser chamada sempre que você suspeitar de inconsistências
CREATE OR REPLACE FUNCTION check_my_progress_health(
    p_user_id UUID,
    p_challenge_id UUID
)
RETURNS TABLE(
    metric TEXT,
    value INTEGER,
    status TEXT
) AS $$
BEGIN
    RETURN QUERY
    WITH metrics AS (
        SELECT 
            'Points in progress table' as metric,
            COALESCE((SELECT points FROM challenge_progress WHERE user_id = p_user_id AND challenge_id = p_challenge_id), 0) as value,
            'info' as status
        UNION ALL
        SELECT 
            'Check-ins in progress table' as metric,
            COALESCE((SELECT check_ins_count FROM challenge_progress WHERE user_id = p_user_id AND challenge_id = p_challenge_id), 0) as value,
            'info' as status
        UNION ALL
        SELECT 
            'Actual check-ins in table' as metric,
            (SELECT COUNT(*)::INTEGER FROM challenge_check_ins WHERE user_id = p_user_id AND challenge_id = p_challenge_id) as value,
            'info' as status
        UNION ALL
        SELECT 
            'Orphan check-ins (no workout)' as metric,
            (SELECT COUNT(*)::INTEGER 
             FROM challenge_check_ins cci
             WHERE cci.user_id = p_user_id 
               AND cci.challenge_id = p_challenge_id
               AND cci.workout_id IS NOT NULL
               AND NOT EXISTS (
                   SELECT 1 FROM workout_records wr 
                   WHERE wr.id = cci.workout_id::uuid
               )) as value,
            CASE 
                WHEN (SELECT COUNT(*) 
                      FROM challenge_check_ins cci
                      WHERE cci.user_id = p_user_id 
                        AND cci.challenge_id = p_challenge_id
                        AND cci.workout_id IS NOT NULL
                        AND NOT EXISTS (
                            SELECT 1 FROM workout_records wr 
                            WHERE wr.id = cci.workout_id::uuid
                        )) > 0 
                THEN 'warning' 
                ELSE 'ok' 
            END as status
    )
    SELECT * FROM metrics;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 7. INSTRUÇÕES DE USO
-- =====================================================

/*
INSTRUÇÕES:

1. Primeiro, encontre seus IDs executando as consultas na seção 1
2. Substitua os IDs nos scripts das seções 2 e 4
3. Execute a correção com fix_my_progress()
4. Verifique o resultado na seção 5
5. Use check_my_progress_health() sempre que quiser verificar a saúde do seu progresso

EXEMPLO DE USO:
SELECT * FROM fix_my_progress(
    'abc12345-1234-5678-9abc-123456789abc'::UUID,  -- Seu user_id
    'def67890-5678-9012-3def-456789012345'::UUID   -- Challenge_id do desafio Ray
);
*/ 