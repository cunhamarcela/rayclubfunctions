-- 🔧 CORREÇÃO: TABELA WORKOUT_PROCESSING_QUEUE AUSENTE
-- 📋 Script para criar tabela e corrigir função record_workout_basic

-- ======================================
-- 🔍 VERIFICAR SE A TABELA EXISTE
-- ======================================

SELECT '🔍 VERIFICANDO TABELA WORKOUT_PROCESSING_QUEUE:' as titulo;

SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'workout_processing_queue') 
        THEN '✅ Tabela workout_processing_queue EXISTE'
        ELSE '❌ Tabela workout_processing_queue NÃO EXISTE'
    END as status_tabela;

-- ======================================
-- 📊 CRIAR TABELA SE NÃO EXISTIR
-- ======================================

CREATE TABLE IF NOT EXISTS workout_processing_queue (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workout_id UUID NOT NULL REFERENCES workout_records(id) ON DELETE CASCADE,
    user_id UUID NOT NULL,
    challenge_id UUID,
    processed_for_ranking BOOLEAN DEFAULT FALSE,
    processed_for_dashboard BOOLEAN DEFAULT FALSE,
    processing_error TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    processed_at TIMESTAMP WITH TIME ZONE,
    retry_count INTEGER DEFAULT 0,
    max_retries INTEGER DEFAULT 3,
    next_retry_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Criar índices se não existirem
CREATE INDEX IF NOT EXISTS idx_workout_queue_processing 
ON workout_processing_queue(processed_for_ranking, processed_for_dashboard);

CREATE INDEX IF NOT EXISTS idx_workout_queue_workout_id
ON workout_processing_queue(workout_id);

CREATE INDEX IF NOT EXISTS idx_workout_queue_user_id
ON workout_processing_queue(user_id);

SELECT '📊 TABELA WORKOUT_PROCESSING_QUEUE CRIADA/VERIFICADA' as status;

-- ======================================
-- 🔧 FUNÇÃO RECORD_WORKOUT_BASIC SIMPLIFICADA
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
    
    -- Chamar função de processamento se existir
    BEGIN
        PERFORM process_workout_for_ranking_fixed(v_workout_record_id);
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

SELECT '🔧 FUNÇÃO RECORD_WORKOUT_BASIC ATUALIZADA' as status;

-- ======================================
-- 🧪 TESTE RÁPIDO DA FUNÇÃO CORRIGIDA
-- ======================================

DO $$
DECLARE
    test_user_id UUID := gen_random_uuid();
    test_challenge_id UUID := gen_random_uuid();
    result JSONB;
BEGIN
    -- Criar usuário de teste
    INSERT INTO profiles (id, name) VALUES 
    (test_user_id, 'Test User Fix Queue')
    ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
    
    -- Criar desafio de teste
    INSERT INTO challenges (
        id, title, description, start_date, end_date, 
        active, points, type, is_official
    ) VALUES (
        test_challenge_id, 
        'Test Challenge Fix Queue', 
        'Teste da correção',
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
    
    -- Testar função
    SELECT record_workout_basic(
        test_user_id,
        'Teste Fix Queue',
        'cardio',
        60,
        CURRENT_DATE,
        test_challenge_id,
        'FIX-QUEUE-001',
        'Teste de correção da fila',
        gen_random_uuid()
    ) INTO result;
    
    RAISE NOTICE 'RESULTADO DO TESTE: %', result;
    
    -- Limpeza
    DELETE FROM challenge_check_ins WHERE challenge_id = test_challenge_id;
    DELETE FROM challenge_progress WHERE challenge_id = test_challenge_id;
    DELETE FROM workout_records WHERE challenge_id = test_challenge_id;
    DELETE FROM challenge_participants WHERE challenge_id = test_challenge_id;
END $$;

SELECT '🧪 TESTE DA FUNÇÃO EXECUTADO (ver logs acima)' as status;

-- ======================================
-- ✅ VERIFICAÇÃO FINAL
-- ======================================

SELECT '✅ VERIFICAÇÃO FINAL:' as titulo;

WITH final_check AS (
    SELECT 
        CASE 
            WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'workout_processing_queue') 
            THEN '✅ workout_processing_queue: EXISTE'
            ELSE '❌ workout_processing_queue: NÃO EXISTE'
        END as check_queue_table,
        
        CASE 
            WHEN EXISTS (
                SELECT 1 FROM pg_proc p 
                JOIN pg_namespace n ON p.pronamespace = n.oid 
                WHERE n.nspname = 'public' AND p.proname = 'record_workout_basic'
            ) 
            THEN '✅ record_workout_basic: FUNÇÃO EXISTE'
            ELSE '❌ record_workout_basic: FUNÇÃO NÃO EXISTE'
        END as check_function,
        
        CASE 
            WHEN EXISTS (
                SELECT 1 FROM pg_proc p 
                JOIN pg_namespace n ON p.pronamespace = n.oid 
                WHERE n.nspname = 'public' AND p.proname = 'process_workout_for_ranking_fixed'
            ) 
            THEN '✅ process_workout_for_ranking_fixed: FUNÇÃO EXISTE'
            ELSE '⚠️  process_workout_for_ranking_fixed: FUNÇÃO NÃO EXISTE'
        END as check_ranking_function
)
SELECT check_queue_table as resultado FROM final_check
UNION ALL
SELECT check_function FROM final_check
UNION ALL
SELECT check_ranking_function FROM final_check;

SELECT '🎉 CORREÇÃO CONCLUÍDA! Agora execute o teste novamente.' as status; 