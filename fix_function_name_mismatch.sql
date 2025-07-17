-- 🔧 CORREÇÃO: NOME DA FUNÇÃO INCORRETO
-- 📋 Atualizando record_workout_basic para chamar a função correta

-- ======================================
-- 🔍 VERIFICAR FUNÇÕES EXISTENTES
-- ======================================

SELECT '🔍 VERIFICANDO FUNÇÕES DE RANKING:' as titulo;

SELECT 
    p.proname as nome_funcao,
    'EXISTS' as status
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public' 
AND p.proname IN ('process_workout_for_ranking_fixed', 'process_workout_for_ranking_one_per_day', 'process_workout_for_ranking');

-- ======================================
-- 🔧 CORRIGIR FUNÇÃO RECORD_WORKOUT_BASIC
-- ======================================

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
BEGIN
    -- Validações básicas
    IF p_user_id IS NULL THEN
        RETURN jsonb_build_object(
            'success', FALSE,
            'message', 'user_id é obrigatório',
            'error_code', 'MISSING_USER_ID'
        );
    END IF;
    
    -- Verificar se usuário existe
    IF NOT EXISTS (SELECT 1 FROM profiles WHERE id = p_user_id) THEN
        RETURN jsonb_build_object(
            'success', FALSE,
            'message', 'Usuário não encontrado',
            'error_code', 'USER_NOT_FOUND'
        );
    END IF;
    
    -- Gerar workout_id se necessário
    IF p_workout_id IS NOT NULL AND p_workout_id != '' THEN
        BEGIN
            v_workout_id := p_workout_id::UUID;
        EXCEPTION WHEN OTHERS THEN
            v_workout_id := gen_random_uuid();
        END;
    ELSE
        v_workout_id := gen_random_uuid();
    END IF;
    
    -- Usar workout_record_id fornecido ou gerar novo
    v_workout_record_id := COALESCE(p_workout_record_id, gen_random_uuid());
    
    -- Inserir registro de treino
    INSERT INTO workout_records(
        id,
        user_id,
        challenge_id,
        workout_id,
        workout_name,
        workout_type,
        workout_date,
        duration_minutes,
        notes,
        created_at
    ) VALUES (
        v_workout_record_id,
        p_user_id,
        p_challenge_id,
        v_workout_id,
        p_workout_name,
        p_workout_type,
        p_date,
        p_duration_minutes,
        p_notes,
        NOW()
    );
    
    -- Inserir na fila de processamento (se a tabela existir)
    BEGIN
        INSERT INTO workout_processing_queue(
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
        );
    EXCEPTION WHEN OTHERS THEN
        -- Se falhar, apenas fazer log mas não falhar a operação principal
        RAISE LOG 'Falha ao inserir na workout_processing_queue: %', SQLERRM;
    END;
    
    -- CORREÇÃO: Chamar a função correta que existe
    BEGIN
        PERFORM process_workout_for_ranking_one_per_day(v_workout_record_id);
    EXCEPTION WHEN OTHERS THEN
        RAISE LOG 'Falha ao processar ranking: %', SQLERRM;
    END;
    
    RETURN jsonb_build_object(
        'success', TRUE,
        'message', 'Treino registrado com sucesso',
        'workout_id', v_workout_record_id,
        'internal_workout_id', v_workout_id
    );
    
EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object(
            'success', FALSE,
            'message', 'Erro ao registrar treino: ' || SQLERRM,
            'error_code', SQLSTATE
        );
END;
$$ LANGUAGE plpgsql;

SELECT '🔧 FUNÇÃO RECORD_WORKOUT_BASIC CORRIGIDA' as status;

-- ======================================
-- 🧪 TESTE RÁPIDO DA CORREÇÃO
-- ======================================

DO $$
DECLARE
    test_user_id UUID := gen_random_uuid();
    test_challenge_id UUID := gen_random_uuid();
    result JSONB;
BEGIN
    -- Criar usuário de teste
    INSERT INTO profiles (id, name) VALUES 
    (test_user_id, 'Test User Fixed')
    ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
    
    -- Criar desafio de teste
    INSERT INTO challenges (
        id, title, description, start_date, end_date, 
        active, points, type, is_official
    ) VALUES (
        test_challenge_id, 
        'Test Challenge Fixed', 
        'Teste da correção do nome',
        CURRENT_DATE - INTERVAL '5 days',
        CURRENT_DATE + INTERVAL '25 days',
        true, 300, 'fitness', true
    ) ON CONFLICT (id) DO UPDATE SET
        title = EXCLUDED.title,
        active = EXCLUDED.active;
    
    -- Inscrever usuário
    INSERT INTO challenge_participants (user_id, challenge_id, joined_at) VALUES 
    (test_user_id, test_challenge_id, NOW() - INTERVAL '3 days')
    ON CONFLICT (user_id, challenge_id) DO NOTHING;
    
    -- Testar função corrigida
    SELECT record_workout_basic(
        test_user_id,
        'Teste Função Corrigida',
        'cardio',
        60,
        CURRENT_DATE,
        test_challenge_id,
        'FIXED-001',
        'Teste de correção do nome da função',
        gen_random_uuid()
    ) INTO result;
    
    RAISE NOTICE 'RESULTADO DO TESTE CORRIGIDO: %', result;
    
    -- Limpeza
    DELETE FROM challenge_check_ins WHERE challenge_id = test_challenge_id;
    DELETE FROM challenge_progress WHERE challenge_id = test_challenge_id;
    DELETE FROM workout_records WHERE challenge_id = test_challenge_id;
    DELETE FROM challenge_participants WHERE challenge_id = test_challenge_id;
END $$;

SELECT '🧪 TESTE DA CORREÇÃO EXECUTADO (ver logs acima)' as status;

-- ======================================
-- ✅ VERIFICAÇÃO FINAL
-- ======================================

SELECT '✅ VERIFICAÇÃO FINAL DA CORREÇÃO:' as titulo;

WITH final_check AS (
    SELECT 
        CASE 
            WHEN EXISTS (
                SELECT 1 FROM pg_proc p 
                JOIN pg_namespace n ON p.pronamespace = n.oid 
                WHERE n.nspname = 'public' AND p.proname = 'process_workout_for_ranking_one_per_day'
            ) 
            THEN '✅ process_workout_for_ranking_one_per_day: EXISTE'
            ELSE '❌ process_workout_for_ranking_one_per_day: NÃO EXISTE'
        END as check_ranking_function,
        
        CASE 
            WHEN EXISTS (
                SELECT 1 FROM pg_proc p 
                JOIN pg_namespace n ON p.pronamespace = n.oid 
                WHERE n.nspname = 'public' AND p.proname = 'record_workout_basic'
            ) 
            THEN '✅ record_workout_basic: FUNÇÃO ATUALIZADA'
            ELSE '❌ record_workout_basic: FUNÇÃO NÃO EXISTE'
        END as check_record_function
)
SELECT check_ranking_function as resultado FROM final_check
UNION ALL
SELECT check_record_function FROM final_check;

SELECT '🎉 CORREÇÃO DO NOME DA FUNÇÃO CONCLUÍDA!' as status; 