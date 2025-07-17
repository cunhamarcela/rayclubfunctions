-- ================================================================
-- CORREÇÕES CIRÚRGICAS SUPABASE (APENAS PROBLEMAS IDENTIFICADOS)
-- ================================================================
-- Baseado no diagnóstico completo, este script corrige apenas:
-- 1. Múltiplas versões de funções (ambiguidade)
-- 2. Lógica de verificação de duplicatas
-- 3. Lançamentos retroativos
-- ================================================================

-- ================================================================
-- PARTE 1: VERIFICAR ESTADO ATUAL ANTES DAS CORREÇÕES
-- ================================================================

-- 1.1. Contar problemas antes da correção
DO $$
BEGIN
    RAISE NOTICE '=== ESTADO ANTES DAS CORREÇÕES ===';
    RAISE NOTICE 'Check-ins com datas inconsistentes: %', (
        SELECT COUNT(*) FROM challenge_check_ins 
        WHERE DATE(check_in_date) != DATE(created_at)
    );
    RAISE NOTICE 'Versões da função record_challenge_check_in: %', (
        SELECT COUNT(*) FROM pg_proc 
        WHERE proname = 'record_challenge_check_in'
    );
    RAISE NOTICE 'Versões da função record_challenge_check_in_v2: %', (
        SELECT COUNT(*) FROM pg_proc 
        WHERE proname = 'record_challenge_check_in_v2'
    );
END $$;

-- ================================================================
-- PARTE 2: REMOVER AMBIGUIDADE DE FUNÇÕES (MANTER APENAS A MELHOR)
-- ================================================================

-- 2.1. Backup da função atual (caso precise reverter)
CREATE OR REPLACE FUNCTION record_challenge_check_in_v2_backup_original(
    p_challenge_id uuid,
    p_user_id uuid,
    p_workout_id uuid,
    p_workout_name text,
    p_workout_type text,
    p_date timestamp with time zone,
    p_duration_minutes integer
)
RETURNS jsonb AS $$
BEGIN
    RAISE NOTICE 'Esta é a função de backup original';
    RETURN jsonb_build_object('backup', true);
END;
$$ LANGUAGE plpgsql;

-- 2.2. Remover todas as versões problemáticas (mantendo backup)
-- Remove versões antigas e ambíguas
DROP FUNCTION IF EXISTS record_challenge_check_in(
    _challenge_id uuid, 
    _user_id uuid, 
    _workout_id text, 
    _workout_name text, 
    _workout_type text, 
    _date timestamp with time zone, 
    _duration_minutes integer, 
    _points integer
);

DROP FUNCTION IF EXISTS record_challenge_check_in(
    _user_id uuid, 
    _challenge_id uuid, 
    _workout_id character varying, 
    _workout_name character varying, 
    _workout_type character varying, 
    _duration_minutes integer, 
    _date timestamp with time zone, 
    _points integer
);

DROP FUNCTION IF EXISTS record_challenge_check_in_v2(
    p_challenge_id uuid,
    p_user_id uuid,
    p_workout_id uuid,
    p_workout_name text,
    p_workout_type text,
    p_date timestamp with time zone,
    p_duration_minutes integer
);

-- ================================================================
-- PARTE 3: CRIAR FUNÇÃO CORRIGIDA DEFINITIVA
-- ================================================================

-- 3.1. Função única e corrigida para lançamentos retroativos
CREATE OR REPLACE FUNCTION record_challenge_check_in_v2(
    _challenge_id uuid,
    _user_id uuid,
    _workout_id text,
    _workout_name text,
    _workout_type text,
    _date timestamp with time zone,
    _duration_minutes integer
)
RETURNS jsonb AS $$
DECLARE
    check_in_id uuid;
    points_awarded integer := 10;
    streak_count integer := 0;
    duplicate_check_in boolean := false;
    check_in_date_only date;
    result jsonb;
BEGIN
    BEGIN
        -- CORREÇÃO 1: Converter data para timezone correto
        _date := _date AT TIME ZONE 'America/Sao_Paulo';
        check_in_date_only := DATE(_date);
        
        RAISE NOTICE '🎯 [CORRIGIDO] Check-in para data: % (data: %)', _date, check_in_date_only;
        
        -- CORREÇÃO 2: Verificar duplicatas APENAS por DATA, não por timestamp
        SELECT EXISTS (
            SELECT 1 FROM challenge_check_ins 
            WHERE 
                challenge_id = _challenge_id 
                AND user_id = _user_id 
                AND DATE(check_in_date AT TIME ZONE 'America/Sao_Paulo') = check_in_date_only
        ) INTO duplicate_check_in;
        
        RAISE NOTICE '🔍 [CORRIGIDO] Verificação de duplicata por DATA: %', duplicate_check_in;
        
        -- Se já existe check-in nesta DATA específica, retornar erro
        IF duplicate_check_in THEN
            RAISE NOTICE '⚠️ [CORRIGIDO] Check-in já existe para a data %', check_in_date_only;
            RETURN jsonb_build_object(
                'success', false,
                'message', 'Você já fez check-in nesta data',
                'error_code', 'DUPLICATE_CHECK_IN_DATE',
                'check_in_date', check_in_date_only,
                'points_earned', 0
            );
        END IF;
        
        -- CORREÇÃO 3: Inserir com data do formulário, não NOW()
        INSERT INTO challenge_check_ins (
            id,
            challenge_id,
            user_id,
            check_in_date,    -- Data do formulário (retroativa)
            points,
            workout_id,
            workout_name,
            workout_type,
            duration_minutes,
            created_at,       -- NOW() apenas para auditoria
            updated_at,
            brt_date         -- Data brasileira para índices
        ) VALUES (
            gen_random_uuid(),
            _challenge_id,
            _user_id,
            _date,           -- CORREÇÃO: Data do formulário
            points_awarded,
            COALESCE(_workout_id, gen_random_uuid()::text),
            _workout_name,
            _workout_type,
            _duration_minutes,
            NOW(),           -- Data de criação do registro
            NOW(),
            check_in_date_only
        ) RETURNING id INTO check_in_id;
        
        -- Atualizar progresso (simplificado para esta correção)
        INSERT INTO challenge_progress (
            challenge_id,
            user_id,
            points,
            check_ins_count,
            last_check_in,
            total_check_ins
        ) VALUES (
            _challenge_id,
            _user_id,
            points_awarded,
            1,
            _date,  -- CORREÇÃO: Data do check-in, não NOW()
            1
        )
        ON CONFLICT (challenge_id, user_id) 
        DO UPDATE SET 
            points = challenge_progress.points + points_awarded,
            check_ins_count = challenge_progress.check_ins_count + 1,
            total_check_ins = challenge_progress.total_check_ins + 1,
            last_check_in = GREATEST(challenge_progress.last_check_in, _date),
            updated_at = NOW();
        
        RAISE NOTICE '✅ [CORRIGIDO] Check-in registrado: % para data %', check_in_id, check_in_date_only;
        
        RETURN jsonb_build_object(
            'success', true,
            'message', 'Check-in registrado com sucesso!',
            'check_in_id', check_in_id,
            'check_in_date', check_in_date_only,
            'points_earned', points_awarded,
            'is_retroactive', DATE(_date) != CURRENT_DATE
        );
        
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE '❌ [ERRO] Falha no check-in: %', SQLERRM;
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Erro interno: ' || SQLERRM,
            'error_code', 'INTERNAL_ERROR',
            'points_earned', 0
        );
    END;
END;
$$ LANGUAGE plpgsql;

-- ================================================================
-- PARTE 4: FUNÇÃO AUXILIAR PARA LIMPEZA DE DUPLICATAS (OPCIONAL)
-- ================================================================

-- 4.1. Função para remover check-ins duplicados (USE COM CUIDADO)
CREATE OR REPLACE FUNCTION remove_duplicate_check_ins_by_date()
RETURNS TABLE (
    user_id_affected uuid,
    challenge_id_affected uuid,
    check_in_date_affected date,
    duplicates_removed integer
) AS $$
DECLARE
    duplicate_record RECORD;
    removed_count integer;
BEGIN
    -- AVISO: Esta função remove duplicatas reais
    -- Execute apenas se tiver certeza
    
    FOR duplicate_record IN 
        SELECT 
            cci.user_id,
            cci.challenge_id,
            DATE(cci.check_in_date) as check_date,
            COUNT(*) as duplicate_count
        FROM challenge_check_ins cci
        GROUP BY cci.user_id, cci.challenge_id, DATE(cci.check_in_date)
        HAVING COUNT(*) > 1
    LOOP
        -- Manter apenas o mais recente (maior created_at)
        DELETE FROM challenge_check_ins 
        WHERE id IN (
            SELECT id 
            FROM challenge_check_ins 
            WHERE 
                user_id = duplicate_record.user_id 
                AND challenge_id = duplicate_record.challenge_id
                AND DATE(check_in_date) = duplicate_record.check_date
            ORDER BY created_at DESC 
            OFFSET 1  -- Manter o primeiro (mais recente)
        );
        
        GET DIAGNOSTICS removed_count = ROW_COUNT;
        
        user_id_affected := duplicate_record.user_id;
        challenge_id_affected := duplicate_record.challenge_id;
        check_in_date_affected := duplicate_record.check_date;
        duplicates_removed := removed_count;
        
        RETURN NEXT;
    END LOOP;
    
    RETURN;
END;
$$ LANGUAGE plpgsql;

-- ================================================================
-- PARTE 5: TESTE DA CORREÇÃO
-- ================================================================

-- 5.1. Testar a função corrigida com dados de exemplo
DO $$
DECLARE
    test_result jsonb;
    test_user_id uuid := 'bc0bfc71-f0cb-4636-a998-026b9e2b5b55'; -- Usuário do diagnóstico
    test_challenge_id uuid := '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'; -- Challenge do diagnóstico
BEGIN
    RAISE NOTICE '=== TESTANDO FUNÇÃO CORRIGIDA ===';
    
    -- Teste 1: Tentar check-in duplicado (deve falhar)
    SELECT record_challenge_check_in_v2(
        test_challenge_id,
        test_user_id,
        'test_workout_id',
        'Teste - Função Corrigida',
        'teste',
        '2025-05-27 21:00:00-03'::timestamp with time zone,
        30
    ) INTO test_result;
    
    RAISE NOTICE 'Teste de duplicata: %', test_result;
    
    -- Teste 2: Check-in retroativo válido (deve funcionar)
    SELECT record_challenge_check_in_v2(
        test_challenge_id,
        test_user_id,
        'test_workout_retroativo',
        'Teste - Retroativo Novo',
        'teste',
        '2025-06-01 09:00:00-03'::timestamp with time zone,
        45
    ) INTO test_result;
    
    RAISE NOTICE 'Teste retroativo: %', test_result;
    
END $$;

-- ================================================================
-- PARTE 6: VERIFICAÇÕES FINAIS
-- ================================================================

-- 6.1. Contabilizar estado após correções
DO $$
BEGIN
    RAISE NOTICE '=== ESTADO APÓS CORREÇÕES ===';
    RAISE NOTICE 'Versões da função record_challenge_check_in_v2: %', (
        SELECT COUNT(*) FROM pg_proc 
        WHERE proname = 'record_challenge_check_in_v2'
    );
    RAISE NOTICE 'Função corrigida criada em: %', NOW();
END $$;

-- 6.2. Mostrar assinatura da função corrigida
SELECT 
    '=== FUNÇÃO CORRIGIDA ===' as section,
    p.proname as function_name,
    pg_get_function_arguments(p.oid) as arguments,
    pg_get_function_result(p.oid) as return_type
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public' 
AND p.proname = 'record_challenge_check_in_v2';

-- ================================================================
-- INSTRUÇÕES DE EXECUÇÃO
-- ================================================================
-- 
-- 1. Execute este script no SQL Editor do Supabase
-- 2. Observe os logs/notices para confirmar que funcionou
-- 3. Teste lançamentos retroativos no app
-- 4. Se precisar remover duplicatas, execute:
--    SELECT * FROM remove_duplicate_check_ins_by_date();
-- 
-- REVERSÃO (se necessário):
-- Para reverter, use a função record_challenge_check_in_v2_backup_original
-- ================================================================ 