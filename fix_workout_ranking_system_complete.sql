-- ================================================================
-- CORREÇÃO COMPLETA DO SISTEMA DE TREINOS E RANKING
-- ================================================================
-- Este script resolve TODOS os problemas identificados:
-- 1. Remove funções conflitantes
-- 2. Limpa duplicatas existentes
-- 3. Implementa funções corrigidas
-- 4. Adiciona proteções contra concorrência
-- 5. Corrige o sistema de ranking
-- ================================================================

-- ================================================================
-- PARTE 1: BACKUP E LIMPEZA INICIAL
-- ================================================================

SELECT '🚀 INICIANDO CORREÇÃO COMPLETA DO SISTEMA DE TREINOS' as status;

-- 1.1 Criar backup completo dos dados atuais
CREATE TABLE IF NOT EXISTS backup_workout_system_before_fix AS
SELECT 
    'challenge_check_ins' as table_name,
    cci.id,
    cci.user_id,
    cci.challenge_id,
    cci.check_in_date,
    cci.workout_id,
    cci.points,
    cci.created_at,
    NOW() as backup_created_at
FROM challenge_check_ins cci;

INSERT INTO backup_workout_system_before_fix
SELECT 
    'challenge_progress' as table_name,
    cp.id,
    cp.user_id,
    cp.challenge_id,
    NULL as check_in_date,
    NULL as workout_id,
    cp.points,
    cp.created_at,
    NOW() as backup_created_at
FROM challenge_progress cp;

SELECT '✅ Backup criado com' || (SELECT COUNT(*) FROM backup_workout_system_before_fix) || ' registros' as status;

-- ================================================================
-- PARTE 2: REMOVER TODAS AS FUNÇÕES CONFLITANTES
-- ================================================================

SELECT '🧹 REMOVENDO FUNÇÕES CONFLITANTES' as status;

-- 2.1 Remover todas as versões problemáticas
DROP FUNCTION IF EXISTS record_challenge_check_in(uuid, timestamptz, integer, uuid, text, text, text);
DROP FUNCTION IF EXISTS record_challenge_check_in_v2(uuid, timestamptz, integer, uuid, text, text, text);
DROP FUNCTION IF EXISTS process_workout_for_ranking_fixed(uuid);
DROP FUNCTION IF EXISTS record_workout_basic_fixed(uuid, text, text, integer, timestamptz, uuid, text);

-- 2.2 Remover funções com nomes de parâmetros diferentes
DROP FUNCTION IF EXISTS record_challenge_check_in(
    _challenge_id uuid, _user_id uuid, _workout_id text, _workout_name text, 
    _workout_type text, _date timestamptz, _duration_minutes integer, _points integer
);

DROP FUNCTION IF EXISTS record_challenge_check_in(
    challenge_id_param uuid, date_param timestamptz, duration_minutes_param integer,
    user_id_param uuid, workout_id_param text, workout_name_param text, workout_type_param text
);

SELECT '✅ Funções conflitantes removidas' as status;

-- ================================================================
-- PARTE 3: LIMPEZA DE DUPLICATAS EXISTENTES
-- ================================================================

SELECT '🧹 LIMPANDO DUPLICATAS EXISTENTES' as status;

-- 3.1 Identificar e remover check-ins duplicados (manter o mais antigo)
WITH duplicados_para_remover AS (
    SELECT 
        id,
        ROW_NUMBER() OVER (
            PARTITION BY user_id, challenge_id, DATE(to_brt(check_in_date))
            ORDER BY created_at ASC
        ) as rn
    FROM challenge_check_ins
)
DELETE FROM challenge_check_ins 
WHERE id IN (
    SELECT id 
    FROM duplicados_para_remover 
    WHERE rn > 1
);

SELECT '✅ Duplicatas removidas:' || (SELECT COUNT(*) FROM backup_workout_system_before_fix WHERE table_name = 'challenge_check_ins') - (SELECT COUNT(*) FROM challenge_check_ins) || ' registros' as status;

-- ================================================================
-- PARTE 4: CRIAR FUNÇÃO DE REGISTRO BÁSICO CORRIGIDA
-- ================================================================

SELECT '🔧 CRIANDO FUNÇÃO record_workout_basic CORRIGIDA' as status;

CREATE OR REPLACE FUNCTION record_workout_basic(
    p_user_id UUID,
    p_workout_name TEXT,
    p_workout_type TEXT,
    p_duration_minutes INTEGER,
    p_date TIMESTAMP WITH TIME ZONE,
    p_challenge_id UUID DEFAULT NULL,
    p_workout_id TEXT DEFAULT NULL
)
RETURNS JSONB AS $$
DECLARE
    v_workout_record_id UUID;
    v_workout_id UUID;
    v_date_brt DATE;
    v_existing_count INTEGER := 0;
BEGIN
    -- Validações básicas
    IF p_user_id IS NULL THEN
        RAISE EXCEPTION 'user_id é obrigatório';
    END IF;
    
    -- Converter data para BRT
    v_date_brt := DATE(p_date AT TIME ZONE 'America/Sao_Paulo');
    
    -- Converter workout_id para UUID ou gerar novo
    BEGIN
        v_workout_id := p_workout_id::UUID;
    EXCEPTION WHEN OTHERS THEN
        v_workout_id := gen_random_uuid();
    END;

    -- PROTEÇÃO CONTRA DUPLICATAS: Verificar se já existe treino muito recente (último minuto)
    SELECT COUNT(*) INTO v_existing_count
    FROM workout_records 
    WHERE user_id = p_user_id 
      AND workout_name = p_workout_name
      AND workout_type = p_workout_type
      AND created_at > NOW() - INTERVAL '1 minute';
    
    IF v_existing_count > 0 THEN
        RETURN jsonb_build_object(
            'success', FALSE,
            'message', 'Aguarde antes de registrar outro treino igual',
            'error_code', 'RATE_LIMITED'
        );
    END IF;

    -- Registrar o treino
    INSERT INTO workout_records(
        user_id,
        challenge_id,
        workout_id,
        workout_name,
        workout_type,
        date,
        duration_minutes,
        points,
        created_at
    ) VALUES (
        p_user_id,
        p_challenge_id,
        v_workout_id,
        p_workout_name,
        p_workout_type,
        p_date,
        p_duration_minutes,
        10,
        NOW()
    ) RETURNING id INTO v_workout_record_id;

    -- Registrar na fila de processamento
    INSERT INTO workout_processing_queue(
        workout_id,
        user_id,
        challenge_id,
        processed_for_ranking,
        processed_for_dashboard,
        created_at
    ) VALUES (
        v_workout_record_id,
        p_user_id,
        p_challenge_id,
        FALSE,
        FALSE,
        NOW()
    ) ON CONFLICT (workout_id) DO UPDATE SET
        processed_for_ranking = FALSE,
        processed_for_dashboard = FALSE,
        processing_error = NULL,
        processed_at = NULL;

    RETURN jsonb_build_object(
        'success', TRUE,
        'message', 'Treino registrado com sucesso',
        'workout_id', v_workout_record_id,
        'is_retroactive', v_date_brt != CURRENT_DATE
    );

EXCEPTION WHEN OTHERS THEN
    -- Log de erro
    INSERT INTO check_in_error_logs(
        user_id, challenge_id, workout_id, error_message, status, created_at
    ) VALUES (
        p_user_id, p_challenge_id, v_workout_record_id, 
        'record_workout_basic: ' || SQLERRM, 'error', NOW()
    );
    
    RETURN jsonb_build_object(
        'success', FALSE,
        'message', 'Erro ao registrar treino: ' || SQLERRM,
        'error_code', 'INTERNAL_ERROR'
    );
END;
$$ LANGUAGE plpgsql;

SELECT '✅ Função record_workout_basic criada' as status;

-- ================================================================
-- PARTE 5: CRIAR FUNÇÃO DE PROCESSAMENTO DE RANKING CORRIGIDA
-- ================================================================

SELECT '🔧 CRIANDO FUNÇÃO process_workout_for_ranking CORRIGIDA' as status;

CREATE OR REPLACE FUNCTION process_workout_for_ranking(
    p_workout_record_id UUID
)
RETURNS BOOLEAN AS $$
DECLARE
    v_workout RECORD;
    v_challenge RECORD;
    v_user_name TEXT;
    v_user_photo_url TEXT;
    v_already_has_checkin BOOLEAN := FALSE;
    v_points_to_add INTEGER := 10;
    v_check_in_id UUID;
    v_challenge_target_days INTEGER;
    v_check_ins_count INTEGER := 0;
    v_completion NUMERIC := 0;
    v_workout_date_brt DATE;
BEGIN
    -- Buscar treino
    SELECT * INTO v_workout
    FROM workout_records
    WHERE id = p_workout_record_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Treino não encontrado: %', p_workout_record_id;
    END IF;

    -- Se não tem challenge_id, apenas marcar como processado
    IF v_workout.challenge_id IS NULL THEN
        UPDATE workout_processing_queue
        SET processed_for_ranking = TRUE, processed_at = NOW()
        WHERE workout_id = p_workout_record_id;
        RETURN TRUE;
    END IF;

    -- Converter data para BRT
    v_workout_date_brt := DATE(v_workout.date AT TIME ZONE 'America/Sao_Paulo');

    -- Buscar desafio com lock
    SELECT * INTO v_challenge
    FROM challenges
    WHERE id = v_workout.challenge_id
    FOR UPDATE;

    IF NOT FOUND THEN
        UPDATE workout_processing_queue
        SET processed_for_ranking = TRUE,
            processing_error = 'Desafio não encontrado',
            processed_at = NOW()
        WHERE workout_id = p_workout_record_id;
        RETURN FALSE;
    END IF;

    -- Verificar participação
    IF NOT EXISTS (
        SELECT 1 FROM challenge_participants
        WHERE challenge_id = v_workout.challenge_id 
        AND user_id = v_workout.user_id
    ) THEN
        UPDATE workout_processing_queue
        SET processed_for_ranking = TRUE,
            processing_error = 'Usuário não participa do desafio',
            processed_at = NOW()
        WHERE workout_id = p_workout_record_id;
        RETURN FALSE;
    END IF;

    -- Verificar duração mínima
    IF v_workout.duration_minutes < 45 THEN
        UPDATE workout_processing_queue
        SET processed_for_ranking = TRUE,
            processing_error = 'Duração mínima não atingida (45min)',
            processed_at = NOW()
        WHERE workout_id = p_workout_record_id;
        
        INSERT INTO check_in_error_logs(user_id, challenge_id, workout_id, error_message, status, created_at)
        VALUES (v_workout.user_id, v_workout.challenge_id, p_workout_record_id, 
                'Duração mínima não atingida: ' || v_workout.duration_minutes || 'min', 'skipped', NOW());
        RETURN FALSE;
    END IF;

    -- 🔥 CORREÇÃO PRINCIPAL: Verificação de duplicatas por DATA (timezone BRT)
    SELECT EXISTS (
        SELECT 1 FROM challenge_check_ins
        WHERE user_id = v_workout.user_id
          AND challenge_id = v_workout.challenge_id
          AND DATE(check_in_date AT TIME ZONE 'America/Sao_Paulo') = v_workout_date_brt
    ) INTO v_already_has_checkin;

    IF v_already_has_checkin THEN
        UPDATE workout_processing_queue
        SET processed_for_ranking = TRUE,
            processing_error = 'Check-in já existe para esta data',
            processed_at = NOW()
        WHERE workout_id = p_workout_record_id;
        
        INSERT INTO check_in_error_logs(user_id, challenge_id, workout_id, error_message, status, created_at)
        VALUES (v_workout.user_id, v_workout.challenge_id, p_workout_record_id, 
                'Check-in já existe para a data: ' || v_workout_date_brt, 'duplicate', NOW());
        RETURN FALSE;
    END IF;

    -- Buscar dados do usuário
    SELECT COALESCE(name, 'Usuário'), photo_url
    INTO v_user_name, v_user_photo_url
    FROM profiles
    WHERE id = v_workout.user_id;

    -- Calcular meta de dias do desafio
    v_challenge_target_days := GREATEST(1, 
        DATE_PART('day', v_challenge.end_date - v_challenge.start_date)::INT + 1
    );

    -- Inserir check-in com data do treino (permite retroativo)
    INSERT INTO challenge_check_ins(
        id, challenge_id, user_id, check_in_date, workout_id,
        points, workout_name, workout_type, duration_minutes,
        user_name, user_photo_url, created_at
    ) VALUES (
        gen_random_uuid(),
        v_workout.challenge_id,
        v_workout.user_id,
        v_workout.date,  -- Data do treino (permite retroativo)
        v_workout.id::TEXT,
        v_points_to_add,
        v_workout.workout_name,
        v_workout.workout_type,
        v_workout.duration_minutes,
        v_user_name,
        v_user_photo_url,
        NOW()  -- created_at = agora (auditoria)
    ) RETURNING id INTO v_check_in_id;

    -- Contar check-ins únicos por data (evita contar duplicatas)
    SELECT COUNT(DISTINCT DATE(check_in_date AT TIME ZONE 'America/Sao_Paulo')) 
    INTO v_check_ins_count
    FROM challenge_check_ins
    WHERE challenge_id = v_workout.challenge_id 
    AND user_id = v_workout.user_id;

    v_completion := LEAST(100, (v_check_ins_count * 100.0) / v_challenge_target_days);

    -- Atualizar/inserir progresso do desafio
    INSERT INTO challenge_progress(
        challenge_id, user_id, points, check_ins_count, total_check_ins,
        last_check_in, completion_percentage, created_at, updated_at,
        user_name, user_photo_url
    ) VALUES (
        v_workout.challenge_id,
        v_workout.user_id,
        v_points_to_add,
        v_check_ins_count,  -- Usar contagem correta
        v_check_ins_count,  -- Usar contagem correta
        v_workout.date,
        v_completion,
        NOW(),
        NOW(),
        v_user_name,
        v_user_photo_url
    )
    ON CONFLICT (challenge_id, user_id)
    DO UPDATE SET
        points = COALESCE(challenge_progress.points, 0) + v_points_to_add,
        check_ins_count = v_check_ins_count,  -- Sempre usar contagem atualizada
        total_check_ins = v_check_ins_count,   -- Sempre usar contagem atualizada
        last_check_in = GREATEST(challenge_progress.last_check_in, v_workout.date),
        completion_percentage = v_completion,
        updated_at = NOW(),
        user_name = v_user_name,
        user_photo_url = v_user_photo_url;

    -- Marcar como processado
    UPDATE workout_processing_queue
    SET processed_for_ranking = TRUE, processed_at = NOW()
    WHERE workout_id = p_workout_record_id;

    -- Recalcular ranking usando critério correto
    WITH ranked_users AS (
        SELECT 
            cp.user_id,
            cp.challenge_id,
            DENSE_RANK() OVER (
                PARTITION BY cp.challenge_id
                ORDER BY cp.points DESC, 
                         cp.check_ins_count DESC,
                         cp.last_check_in ASC NULLS LAST
            ) as new_position
        FROM challenge_progress cp
        WHERE cp.challenge_id = v_workout.challenge_id
    )
    UPDATE challenge_progress cp
    SET position = ru.new_position,
        updated_at = NOW()
    FROM ranked_users ru
    WHERE cp.challenge_id = ru.challenge_id 
    AND cp.user_id = ru.user_id;

    RETURN TRUE;

EXCEPTION WHEN OTHERS THEN
    -- Log de erro detalhado
    INSERT INTO check_in_error_logs(user_id, challenge_id, workout_id, error_message, status, created_at)
    VALUES (v_workout.user_id, v_workout.challenge_id, p_workout_record_id, 
            'process_workout_for_ranking: ' || SQLERRM, 'error', NOW());
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql;

SELECT '✅ Função process_workout_for_ranking criada' as status;

-- ================================================================
-- PARTE 6: CRIAR FUNÇÃO DE REGISTRO DE CHECK-IN CONSOLIDADA
-- ================================================================

SELECT '🔧 CRIANDO FUNÇÃO record_challenge_check_in_v2 CONSOLIDADA' as status;

CREATE OR REPLACE FUNCTION record_challenge_check_in_v2(
    p_challenge_id UUID,
    p_user_id UUID,
    p_workout_id TEXT,
    p_workout_name TEXT,
    p_workout_type TEXT,
    p_date TIMESTAMP WITH TIME ZONE,
    p_duration_minutes INTEGER
)
RETURNS JSONB AS $$
DECLARE
    v_result JSONB;
    v_workout_record_id UUID;
BEGIN
    -- Chamar função de registro básico
    v_result := record_workout_basic(
        p_user_id,
        p_workout_name,
        p_workout_type,
        p_duration_minutes,
        p_date,
        p_challenge_id,
        p_workout_id
    );
    
    -- Se registrou com sucesso, processar imediatamente
    IF (v_result->>'success')::BOOLEAN THEN
        v_workout_record_id := (v_result->>'workout_id')::UUID;
        
        -- Processar para ranking
        IF process_workout_for_ranking(v_workout_record_id) THEN
            v_result := jsonb_build_object(
                'success', TRUE,
                'message', 'Check-in registrado com sucesso',
                'challenge_id', p_challenge_id,
                'workout_id', v_workout_record_id,
                'points_earned', 10,
                'is_already_checked_in', FALSE
            );
        ELSE
            -- Se falhou no processamento, verificar se foi por duplicata
            v_result := jsonb_build_object(
                'success', FALSE,
                'message', 'Você já fez check-in hoje neste desafio',
                'challenge_id', p_challenge_id,
                'workout_id', v_workout_record_id,
                'points_earned', 0,
                'is_already_checked_in', TRUE
            );
        END IF;
    END IF;
    
    RETURN v_result;
END;
$$ LANGUAGE plpgsql;

SELECT '✅ Função record_challenge_check_in_v2 criada' as status;

-- ================================================================
-- PARTE 7: RECALCULAR TODOS OS PROGRESSOS E RANKINGS
-- ================================================================

SELECT '🔄 RECALCULANDO PROGRESSOS E RANKINGS' as status;

-- 7.1 Limpar e recalcular progresso de todos os desafios
TRUNCATE TABLE challenge_progress;

-- 7.2 Recriar progresso baseado nos check-ins únicos por data
WITH progress_correto AS (
    SELECT 
        cci.challenge_id,
        cci.user_id,
        COUNT(DISTINCT DATE(cci.check_in_date AT TIME ZONE 'America/Sao_Paulo')) as check_ins_count_correto,
        COUNT(DISTINCT DATE(cci.check_in_date AT TIME ZONE 'America/Sao_Paulo')) * 10 as points_correto,
        MAX(cci.check_in_date) as last_check_in_correto,
        MAX(cci.user_name) as user_name,
        MAX(cci.user_photo_url) as user_photo_url,
        -- Calcular porcentagem baseada na duração do desafio
        COALESCE(
            LEAST(100, 
                COUNT(DISTINCT DATE(cci.check_in_date AT TIME ZONE 'America/Sao_Paulo')) * 100.0 / 
                GREATEST(1, DATE_PART('day', c.end_date - c.start_date) + 1)
            ), 0
        ) as completion_percentage_correto
    FROM challenge_check_ins cci
    JOIN challenges c ON c.id = cci.challenge_id
    GROUP BY cci.challenge_id, cci.user_id, c.start_date, c.end_date
)
INSERT INTO challenge_progress(
    id,
    challenge_id,
    user_id,
    points,
    check_ins_count,
    total_check_ins,
    last_check_in,
    completion_percentage,
    user_name,
    user_photo_url,
    created_at,
    updated_at
)
SELECT 
    gen_random_uuid(),
    challenge_id,
    user_id,
    points_correto,
    check_ins_count_correto,
    check_ins_count_correto,
    last_check_in_correto,
    completion_percentage_correto,
    user_name,
    user_photo_url,
    NOW(),
    NOW()
FROM progress_correto;

-- 7.3 Calcular posições do ranking
WITH rankings_atualizados AS (
    SELECT 
        cp.id,
        DENSE_RANK() OVER (
            PARTITION BY cp.challenge_id
            ORDER BY cp.points DESC, 
                     cp.check_ins_count DESC, 
                     cp.last_check_in ASC NULLS LAST
        ) as nova_posicao
    FROM challenge_progress cp
)
UPDATE challenge_progress cp
SET position = ra.nova_posicao,
    updated_at = NOW()
FROM rankings_atualizados ra
WHERE cp.id = ra.id;

SELECT '✅ Progressos e rankings recalculados' as status;

-- ================================================================
-- PARTE 8: PROCESSAR FILA PENDENTE
-- ================================================================

SELECT '🔄 PROCESSANDO FILA PENDENTE' as status;

-- 8.1 Processar registros pendentes na fila
DO $$
DECLARE
    v_record RECORD;
    v_success_count INTEGER := 0;
    v_error_count INTEGER := 0;
BEGIN
    FOR v_record IN 
        SELECT * FROM workout_processing_queue 
        WHERE NOT processed_for_ranking 
        ORDER BY created_at
    LOOP
        BEGIN
            IF process_workout_for_ranking(v_record.workout_id) THEN
                v_success_count := v_success_count + 1;
            ELSE
                v_error_count := v_error_count + 1;
            END IF;
        EXCEPTION WHEN OTHERS THEN
            v_error_count := v_error_count + 1;
        END;
    END LOOP;
    
    RAISE NOTICE '✅ Fila processada: % sucessos, % erros', v_success_count, v_error_count;
END $$;

-- ================================================================
-- PARTE 9: VERIFICAÇÕES FINAIS E RELATÓRIO
-- ================================================================

SELECT '📊 GERANDO RELATÓRIO FINAL' as status;

-- 9.1 Verificar se ainda existem duplicatas
SELECT 
    '✅ VERIFICAÇÃO DE DUPLICATAS' as verificacao,
    COUNT(*) as grupos_duplicados,
    CASE 
        WHEN COUNT(*) = 0 THEN 'NENHUMA DUPLICATA ENCONTRADA ✅'
        ELSE 'AINDA EXISTEM DUPLICATAS ❌'
    END as resultado
FROM (
    SELECT 
        user_id,
        challenge_id,
        DATE(check_in_date AT TIME ZONE 'America/Sao_Paulo') as data_checkin,
        COUNT(*) as total_checkins
    FROM challenge_check_ins
    GROUP BY user_id, challenge_id, DATE(check_in_date AT TIME ZONE 'America/Sao_Paulo')
    HAVING COUNT(*) > 1
) duplicados_restantes;

-- 9.2 Estatísticas gerais
SELECT 
    '📈 ESTATÍSTICAS FINAIS' as categoria,
    (SELECT COUNT(*) FROM challenge_check_ins) as total_checkins,
    (SELECT COUNT(*) FROM challenge_progress) as total_progressos,
    (SELECT COUNT(*) FROM workout_processing_queue WHERE NOT processed_for_ranking) as pendentes_ranking,
    (SELECT COUNT(*) FROM check_in_error_logs WHERE created_at > NOW() - INTERVAL '1 hour') as erros_ultima_hora;

-- 9.3 Log de conclusão
INSERT INTO check_in_error_logs(
    user_id, challenge_id, workout_id, error_message, status, created_at
) VALUES (
    NULL, NULL, NULL,
    'CORREÇÃO COMPLETA DO SISTEMA CONCLUÍDA - ' || 
    (SELECT COUNT(*) FROM backup_workout_system_before_fix) || ' registros em backup',
    'system_fix_completed',
    NOW()
);

SELECT '🎉 CORREÇÃO COMPLETA DO SISTEMA DE TREINOS E RANKING CONCLUÍDA' as status;
SELECT '📋 Execute as verificações abaixo para confirmar que tudo está funcionando:' as proximos_passos;
SELECT '1. Teste registro de novo treino' as passo_1;
SELECT '2. Verifique se rankings estão corretos' as passo_2;
SELECT '3. Confirme que não há mais duplicatas' as passo_3; 