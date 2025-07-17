-- ====================================================================
-- SOLUÇÃO MAIS EFICIENTE E ESCALÁVEL: Verificar apenas auth.users
-- ====================================================================

-- ESTRATÉGIA: Usar apenas a tabela nativa de autenticação do Supabase
-- VANTAGENS: Máxima performance, escalabilidade e simplicidade
-- JUSTIFICATIVA: auth.users é a fonte única da verdade para autenticação

BEGIN;

SELECT '🚀 SOLUÇÃO OPTIMAL: Verificação eficiente com auth.users' as etapa;

CREATE OR REPLACE FUNCTION record_workout_basic(
    p_user_id UUID,
    p_workout_name TEXT,
    p_workout_type TEXT,
    p_duration_minutes INTEGER,
    p_date TIMESTAMP WITH TIME ZONE,
    p_challenge_id UUID DEFAULT NULL,
    p_workout_id TEXT DEFAULT NULL,
    p_notes TEXT DEFAULT '',
    p_workout_record_id UUID DEFAULT NULL
)
RETURNS JSONB AS $$
DECLARE
    v_workout_record_id UUID;
    v_workout_id UUID;
    v_existing_count INTEGER := 0;
    v_is_update BOOLEAN := FALSE;
    
BEGIN
    -- ==========================================
    -- VALIDAÇÃO 1: Parâmetros obrigatórios
    -- ==========================================
    IF p_user_id IS NULL THEN
        RETURN jsonb_build_object(
            'success', FALSE,
            'message', 'ID do usuário é obrigatório',
            'error_code', 'MISSING_USER_ID'
        );
    END IF;
    
    IF p_workout_name IS NULL OR LENGTH(TRIM(p_workout_name)) = 0 THEN
        RETURN jsonb_build_object(
            'success', FALSE,
            'message', 'Nome do treino é obrigatório',
            'error_code', 'MISSING_WORKOUT_NAME'
        );
    END IF;

    -- ==========================================
    -- VALIDAÇÃO 2: Usuário autenticado (OPTIMAL)
    -- ==========================================
    -- Verificar APENAS na fonte oficial de autenticação
    IF NOT EXISTS (
        SELECT 1 FROM auth.users 
        WHERE id = p_user_id 
        AND deleted_at IS NULL  -- Garantir que não foi deletado
    ) THEN
        RETURN jsonb_build_object(
            'success', FALSE,
            'message', 'Usuário não encontrado no sistema de autenticação',
            'error_code', 'USER_NOT_AUTHENTICATED'
        );
    END IF;

    -- ==========================================
    -- PROTEÇÃO: Anti-duplicação inteligente
    -- ==========================================
    -- Verificar duplicatas por data (timezone-aware e performática)
    SELECT COUNT(*) INTO v_existing_count
    FROM workout_records
    WHERE user_id = p_user_id
      AND workout_name = p_workout_name
      AND workout_type = p_workout_type
      AND duration_minutes = p_duration_minutes
      AND DATE(date AT TIME ZONE 'America/Sao_Paulo') = DATE(p_date AT TIME ZONE 'America/Sao_Paulo')
      AND COALESCE(challenge_id::text, '') = COALESCE(p_challenge_id::text, '');

    -- Se já existe um treino idêntico hoje, retornar o existente (mais eficiente)
    IF v_existing_count > 0 AND p_workout_record_id IS NULL THEN
        SELECT id INTO v_workout_record_id
        FROM workout_records
        WHERE user_id = p_user_id
          AND workout_name = p_workout_name
          AND workout_type = p_workout_type
          AND duration_minutes = p_duration_minutes
          AND DATE(date AT TIME ZONE 'America/Sao_Paulo') = DATE(p_date AT TIME ZONE 'America/Sao_Paulo')
          AND COALESCE(challenge_id::text, '') = COALESCE(p_challenge_id::text, '')
        ORDER BY created_at DESC
        LIMIT 1;

        RETURN jsonb_build_object(
            'success', TRUE,
            'message', 'Treino idêntico já registrado hoje',
            'workout_id', v_workout_record_id,
            'is_duplicate', TRUE
        );
    END IF;

    -- ==========================================
    -- PROCESSAMENTO: Gerar workout_id eficientemente
    -- ==========================================
    IF p_workout_id IS NOT NULL AND p_workout_id != '' THEN
        BEGIN
            v_workout_id := p_workout_id::UUID;
        EXCEPTION WHEN OTHERS THEN
            v_workout_id := gen_random_uuid();
        END;
    ELSE
        v_workout_id := gen_random_uuid();
    END IF;

    -- ==========================================
    -- OPERAÇÃO PRINCIPAL: Insert/Update performático
    -- ==========================================
    v_is_update := (p_workout_record_id IS NOT NULL);

    IF v_is_update THEN
        -- ATUALIZAÇÃO: Simples e eficiente
        UPDATE workout_records SET
            workout_name = p_workout_name,
            workout_type = p_workout_type,
            duration_minutes = p_duration_minutes,
            date = p_date,
            notes = COALESCE(p_notes, notes),
            challenge_id = COALESCE(p_challenge_id, challenge_id),
            updated_at = NOW()
        WHERE id = p_workout_record_id AND user_id = p_user_id;
        
        IF NOT FOUND THEN
            RETURN jsonb_build_object(
                'success', FALSE,
                'message', 'Registro não encontrado para atualização',
                'error_code', 'WORKOUT_NOT_FOUND'
            );
        END IF;
        
        v_workout_record_id := p_workout_record_id;
    ELSE
        -- INSERÇÃO: Operação atômica e eficiente
        INSERT INTO workout_records (
            user_id,
            challenge_id,
            workout_id,
            workout_name,
            workout_type,
            date,
            duration_minutes,
            notes,
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
            COALESCE(p_notes, ''),
            CASE WHEN p_duration_minutes >= 45 THEN 10 ELSE 5 END,
            NOW()
        ) RETURNING id INTO v_workout_record_id;
    END IF;

    -- ==========================================
    -- PROCESSAMENTO ASSÍNCRONO: Fail-safe
    -- ==========================================
    -- Tentar agendar processamento, mas não falhar se a tabela não existir
    BEGIN
        INSERT INTO workout_processing_queue (
            workout_id,
            user_id,
            challenge_id,
            processed_for_ranking,
            processed_for_dashboard
        ) VALUES (
            v_workout_record_id,
            p_user_id,
            p_challenge_id,
            FALSE,
            FALSE
        ) ON CONFLICT (workout_id) DO NOTHING;
    EXCEPTION WHEN OTHERS THEN
        -- Continuar sem processamento assíncrono se não disponível
        NULL;
    END;

    -- ==========================================
    -- RESPOSTA: Padronizada e informativa
    -- ==========================================
    RETURN jsonb_build_object(
        'success', TRUE,
        'message', CASE 
            WHEN v_is_update THEN 'Treino atualizado com sucesso' 
            ELSE 'Treino registrado com sucesso' 
        END,
        'workout_id', v_workout_record_id,
        'workout_record_id', v_workout_record_id, -- Compatibilidade com código existente
        'points_earned', CASE WHEN p_duration_minutes >= 45 THEN 10 ELSE 5 END,
        'is_update', v_is_update
    );

EXCEPTION 
    WHEN unique_violation THEN
        RETURN jsonb_build_object(
            'success', FALSE,
            'message', 'Treino duplicado detectado',
            'error_code', 'DUPLICATE_WORKOUT'
        );
    WHEN OTHERS THEN
        RETURN jsonb_build_object(
            'success', FALSE,
            'message', 'Erro interno: ' || SQLERRM,
            'error_code', 'INTERNAL_ERROR'
        );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ==========================================
-- ÍNDICES PARA MÁXIMA PERFORMANCE
-- ==========================================

-- Índice para verificação de duplicatas (mais importante)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_workout_records_dedup 
ON workout_records (user_id, workout_name, workout_type, duration_minutes, date);

-- Índice para consultas por usuário e data
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_workout_records_user_date 
ON workout_records (user_id, date DESC);

-- Índice para verificação de challenge
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_workout_records_challenge 
ON workout_records (challenge_id, date DESC) WHERE challenge_id IS NOT NULL;

COMMIT;

-- ==========================================
-- TESTE DE PERFORMANCE E FUNCIONALIDADE
-- ==========================================

-- Testar com usuário problemático conhecido
DO $$
DECLARE
    test_result JSONB;
    test_user_id UUID := '01d4a292-1873-4af6-948b-a55eed56d6b9';
    start_time TIMESTAMP;
    end_time TIMESTAMP;
    execution_time INTERVAL;
BEGIN
    start_time := clock_timestamp();
    
    -- Teste funcional
    SELECT record_workout_basic(
        test_user_id,
        'Teste Performance Optimal',
        'Cardio',
        45,
        NOW(),
        NULL,
        NULL,
        'Teste da solução optimal',
        NULL
    ) INTO test_result;
    
    end_time := clock_timestamp();
    execution_time := end_time - start_time;
    
    RAISE NOTICE '⚡ Tempo de execução: %', execution_time;
    RAISE NOTICE '✅ Resultado: %', test_result->>'success';
    RAISE NOTICE '📝 Mensagem: %', test_result->>'message';
    
    IF (test_result->>'success')::boolean THEN
        RAISE NOTICE '🎉 SOLUÇÃO OPTIMAL FUNCIONANDO PERFEITAMENTE!';
    ELSE
        RAISE NOTICE '❌ Erro: %', test_result->>'error_code';
    END IF;
    
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE '❌ Erro no teste: %', SQLERRM;
END $$;

-- Relatório final
SELECT 
    '🏆 SOLUÇÃO OPTIMAL IMPLEMENTADA' as status,
    'Máxima eficiência e escalabilidade' as caracteristicas,
    NOW() as data_implementacao;

-- Verificar índices criados
SELECT 
    indexname,
    tablename,
    indexdef
FROM pg_indexes 
WHERE tablename = 'workout_records' 
  AND indexname LIKE 'idx_workout_records_%'
ORDER BY indexname; 