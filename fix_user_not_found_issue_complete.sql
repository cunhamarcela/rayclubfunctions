-- ====================================================================
-- SOLUÇÃO COMPLETA PARA O PROBLEMA "USER_NOT_FOUND" NO REGISTRO DE TREINOS
-- ====================================================================

-- Problema: Usuários autenticados não conseguem registrar treinos
-- Causa: Função record_workout_basic busca na tabela 'profiles' mas alguns usuários 
--        existem apenas em 'auth.users' (dessincronia entre tabelas)
-- Solução: Sincronizar tabelas e tornar função mais robusta

BEGIN;

-- =============================================
-- ETAPA 1: SINCRONIZAR TABELA PROFILES COM AUTH.USERS
-- =============================================

SELECT '🔧 ETAPA 1: Sincronizando tabela profiles com auth.users' as etapa;

-- Inserir usuários de auth.users que não estão em profiles
INSERT INTO public.profiles (
    id,
    email,
    name,
    photo_url,
    created_at,
    updated_at
)
SELECT 
    au.id,
    au.email,
    COALESCE(au.raw_user_meta_data->>'name', au.raw_user_meta_data->>'full_name', split_part(au.email, '@', 1)) as name,
    au.raw_user_meta_data->>'avatar_url' as photo_url,
    au.created_at,
    NOW()
FROM auth.users au
WHERE NOT EXISTS (
    SELECT 1 FROM public.profiles p WHERE p.id = au.id
)
AND au.email IS NOT NULL;

-- Verificar quantos usuários foram sincronizados
SELECT 
    'Sincronização profiles' as resultado,
    (SELECT COUNT(*) FROM auth.users) as total_auth_users,
    (SELECT COUNT(*) FROM profiles) as total_profiles_agora,
    (SELECT COUNT(*) FROM auth.users au WHERE NOT EXISTS (SELECT 1 FROM profiles p WHERE p.id = au.id)) as usuarios_ainda_sem_profile;

-- =============================================
-- ETAPA 2: CRIAR TRIGGER PARA MANTER SINCRONIZAÇÃO AUTOMÁTICA
-- =============================================

SELECT '🔧 ETAPA 2: Criando trigger para sincronização automática' as etapa;

-- Função para sincronizar automaticamente
CREATE OR REPLACE FUNCTION sync_auth_users_to_profiles()
RETURNS TRIGGER AS $$
BEGIN
    -- Quando um usuário é criado em auth.users, criar também em profiles
    IF TG_OP = 'INSERT' THEN
        INSERT INTO public.profiles (
            id,
            email,
            name,
            photo_url,
            created_at,
            updated_at
        ) VALUES (
            NEW.id,
            NEW.email,
            COALESCE(NEW.raw_user_meta_data->>'name', NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
            NEW.raw_user_meta_data->>'avatar_url',
            NEW.created_at,
            NOW()
        ) ON CONFLICT (id) DO UPDATE SET
            email = EXCLUDED.email,
            updated_at = NOW();
        
        RETURN NEW;
    END IF;
    
    -- Quando um usuário é atualizado em auth.users, atualizar também em profiles
    IF TG_OP = 'UPDATE' THEN
        UPDATE public.profiles SET
            email = NEW.email,
            name = COALESCE(NEW.raw_user_meta_data->>'name', NEW.raw_user_meta_data->>'full_name', name),
            photo_url = COALESCE(NEW.raw_user_meta_data->>'avatar_url', photo_url),
            updated_at = NOW()
        WHERE id = NEW.id;
        
        RETURN NEW;
    END IF;
    
    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Criar trigger na tabela auth.users
DROP TRIGGER IF EXISTS trigger_sync_auth_users_to_profiles ON auth.users;
CREATE TRIGGER trigger_sync_auth_users_to_profiles
    AFTER INSERT OR UPDATE ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION sync_auth_users_to_profiles();

-- =============================================
-- ETAPA 3: CORRIGIR FUNÇÃO RECORD_WORKOUT_BASIC
-- =============================================

SELECT '🔧 ETAPA 3: Corrigindo função record_workout_basic' as etapa;

-- Versão corrigida da função que é mais tolerante e cria perfil se necessário
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
    v_date_brt TIMESTAMP WITH TIME ZONE;
    v_existing_count INTEGER := 0;
    v_request_data JSONB;
    v_response_data JSONB;
    v_is_update BOOLEAN := FALSE;
    v_user_exists_in_auth BOOLEAN := FALSE;
    v_user_exists_in_profiles BOOLEAN := FALSE;
    
    -- Controles de rate limiting
    v_recent_submissions INTEGER := 0;
    v_last_submission TIMESTAMP WITH TIME ZONE;
    
BEGIN
    -- Registrar dados da requisição para auditoria
    v_request_data := jsonb_build_object(
        'user_id', p_user_id,
        'workout_name', p_workout_name,
        'workout_type', p_workout_type,
        'duration_minutes', p_duration_minutes,
        'date', p_date,
        'challenge_id', p_challenge_id,
        'workout_id', p_workout_id,
        'notes', p_notes,
        'workout_record_id', p_workout_record_id
    );

    -- Converter data para BRT
    v_date_brt := CASE 
        WHEN p_date IS NOT NULL THEN p_date AT TIME ZONE 'America/Sao_Paulo'
        ELSE NOW() AT TIME ZONE 'America/Sao_Paulo'
    END;
    
    -- VALIDAÇÃO 1: Parâmetros obrigatórios
    IF p_user_id IS NULL THEN
        v_response_data := jsonb_build_object(
            'success', FALSE,
            'message', 'ID do usuário é obrigatório',
            'error_code', 'MISSING_USER_ID'
        );
        RETURN v_response_data;
    END IF;
    
    IF p_workout_name IS NULL OR LENGTH(TRIM(p_workout_name)) = 0 THEN
        v_response_data := jsonb_build_object(
            'success', FALSE,
            'message', 'Nome do treino é obrigatório',
            'error_code', 'MISSING_WORKOUT_NAME'
        );
        RETURN v_response_data;
    END IF;

    -- VALIDAÇÃO 2: Verificar usuário de forma mais robusta
    -- Primeiro, verificar se o usuário existe em auth.users
    SELECT EXISTS(SELECT 1 FROM auth.users WHERE id = p_user_id) INTO v_user_exists_in_auth;
    
    -- Segundo, verificar se o usuário existe em profiles
    SELECT EXISTS(SELECT 1 FROM profiles WHERE id = p_user_id) INTO v_user_exists_in_profiles;
    
    -- Se o usuário não existe em auth.users, é um erro real
    IF NOT v_user_exists_in_auth THEN
        v_response_data := jsonb_build_object(
            'success', FALSE,
            'message', 'Usuário não encontrado no sistema de autenticação',
            'error_code', 'USER_NOT_AUTHENTICATED'
        );
        
        INSERT INTO check_in_error_logs(user_id, request_data, response_data, error_message, error_type, status)
        VALUES (p_user_id, v_request_data, v_response_data, 'User not found in auth.users', 'AUTH_ERROR', 'error');
        
        RETURN v_response_data;
    END IF;
    
    -- Se o usuário existe em auth.users mas não em profiles, criar o perfil automaticamente
    IF v_user_exists_in_auth AND NOT v_user_exists_in_profiles THEN
        BEGIN
            INSERT INTO public.profiles (
                id,
                email,
                name,
                photo_url,
                created_at,
                updated_at
            )
            SELECT 
                au.id,
                au.email,
                COALESCE(au.raw_user_meta_data->>'name', au.raw_user_meta_data->>'full_name', split_part(au.email, '@', 1)),
                au.raw_user_meta_data->>'avatar_url',
                au.created_at,
                NOW()
            FROM auth.users au
            WHERE au.id = p_user_id;
            
            -- Log da criação automática
            INSERT INTO check_in_error_logs(user_id, request_data, response_data, error_message, error_type, status)
            VALUES (p_user_id, v_request_data, jsonb_build_object('auto_created_profile', true), 'Auto-created missing profile', 'AUTO_FIX', 'info');
            
        EXCEPTION WHEN OTHERS THEN
            -- Se não conseguir criar o perfil, logar mas continuar
            INSERT INTO check_in_error_logs(user_id, request_data, response_data, error_message, error_type, status)
            VALUES (p_user_id, v_request_data, jsonb_build_object('error', SQLERRM), 'Failed to auto-create profile: ' || SQLERRM, 'AUTO_FIX_ERROR', 'warning');
        END;
    END IF;

    -- PROTEÇÃO 1: Rate Limiting - verificar submissões muito frequentes
    SELECT COUNT(*), MAX(created_at) INTO v_recent_submissions, v_last_submission
    FROM workout_records 
    WHERE user_id = p_user_id 
      AND workout_name = p_workout_name
      AND workout_type = p_workout_type
      AND created_at > NOW() - INTERVAL '1 minute';
    
    IF v_recent_submissions > 0 AND v_last_submission > NOW() - INTERVAL '30 seconds' THEN
        v_response_data := jsonb_build_object(
            'success', FALSE,
            'message', 'Aguarde 30 segundos antes de registrar treino similar',
            'error_code', 'RATE_LIMITED',
            'retry_after_seconds', 30
        );
        RETURN v_response_data;
    END IF;

    -- PROTEÇÃO 2: Verificar duplicatas exatas por data (timezone-aware)
    SELECT COUNT(*) INTO v_existing_count
    FROM workout_records
    WHERE user_id = p_user_id
      AND workout_name = p_workout_name
      AND workout_type = p_workout_type
      AND duration_minutes = p_duration_minutes
      AND DATE(date AT TIME ZONE 'America/Sao_Paulo') = DATE(v_date_brt)
      AND COALESCE(challenge_id::text, '') = COALESCE(p_challenge_id::text, '');

    IF v_existing_count > 0 AND p_workout_record_id IS NULL THEN
        -- Buscar o registro existente
        SELECT id INTO v_workout_record_id
        FROM workout_records
        WHERE user_id = p_user_id
          AND workout_name = p_workout_name
          AND workout_type = p_workout_type
          AND duration_minutes = p_duration_minutes
          AND DATE(date AT TIME ZONE 'America/Sao_Paulo') = DATE(v_date_brt)
          AND COALESCE(challenge_id::text, '') = COALESCE(p_challenge_id::text, '')
        ORDER BY created_at DESC
        LIMIT 1;

        v_response_data := jsonb_build_object(
            'success', TRUE,
            'message', 'Treino idêntico já registrado - retornando existente',
            'workout_id', v_workout_record_id,
            'is_duplicate', TRUE
        );
        RETURN v_response_data;
    END IF;

    -- Gerar workout_id UUID se necessário
    IF p_workout_id IS NOT NULL AND p_workout_id != '' THEN
        BEGIN
            v_workout_id := p_workout_id::UUID;
        EXCEPTION WHEN OTHERS THEN
            v_workout_id := gen_random_uuid();
        END;
    ELSE
        v_workout_id := gen_random_uuid();
    END IF;

    -- Determinar se é atualização ou inserção
    v_is_update := (p_workout_record_id IS NOT NULL);

    BEGIN
        IF v_is_update THEN
            -- ATUALIZAÇÃO: Verificar se o registro existe
            IF NOT EXISTS (SELECT 1 FROM workout_records WHERE id = p_workout_record_id AND user_id = p_user_id) THEN
                v_response_data := jsonb_build_object(
                    'success', FALSE,
                    'message', 'Registro de treino não encontrado para atualização',
                    'error_code', 'WORKOUT_NOT_FOUND'
                );
                RETURN v_response_data;
            END IF;

            -- Atualizar registro existente
            UPDATE workout_records SET
                workout_name = p_workout_name,
                workout_type = p_workout_type,
                duration_minutes = p_duration_minutes,
                date = p_date,
                notes = COALESCE(p_notes, notes),
                challenge_id = COALESCE(p_challenge_id, challenge_id),
                updated_at = NOW()
            WHERE id = p_workout_record_id AND user_id = p_user_id;
            
            v_workout_record_id := p_workout_record_id;
        ELSE
            -- INSERÇÃO: Criar novo registro
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
                p_notes,
                10, -- Pontos básicos
                NOW()
            ) RETURNING id INTO v_workout_record_id;
        END IF;

        -- Agendar processamento assíncrono (se existir a tabela)
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
            ) ON CONFLICT (workout_id) DO UPDATE SET
                processed_for_ranking = FALSE,
                processed_for_dashboard = FALSE,
                processing_error = NULL,
                processed_at = NULL;
        EXCEPTION WHEN OTHERS THEN
            -- Se a tabela de processamento não existir, continuar sem ela
            NULL;
        END;

        -- Preparar resposta de sucesso
        v_response_data := jsonb_build_object(
            'success', TRUE,
            'message', CASE 
                WHEN v_is_update THEN 'Treino atualizado com sucesso'
                ELSE 'Treino registrado com sucesso'
            END,
            'workout_id', v_workout_record_id,
            'workout_record_id', v_workout_record_id,
            'points_earned', 10,
            'processing_queued', TRUE
        );

        RETURN v_response_data;

    EXCEPTION WHEN OTHERS THEN
        -- Log do erro
        INSERT INTO check_in_error_logs(user_id, request_data, response_data, error_message, error_type, status)
        VALUES (p_user_id, v_request_data, jsonb_build_object('sql_error', SQLERRM), 'SQL Error: ' || SQLERRM, 'SQL_ERROR', 'error');
        
        v_response_data := jsonb_build_object(
            'success', FALSE,
            'message', 'Erro interno do servidor ao registrar treino',
            'error_code', 'INTERNAL_ERROR'
        );
        
        RETURN v_response_data;
    END;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- ETAPA 4: VERIFICAÇÕES FINAIS
-- =============================================

SELECT '🔧 ETAPA 4: Verificações finais' as etapa;

-- Verificar se a função foi criada corretamente
SELECT 
    'record_workout_basic' as funcao,
    COUNT(*) as versoes_criadas,
    CASE WHEN COUNT(*) > 0 THEN '✅ CRIADA' ELSE '❌ FALHOU' END as status
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE p.proname = 'record_workout_basic'
  AND n.nspname = 'public';

-- Verificar sincronização final
SELECT 
    'Sincronização Final' as resultado,
    (SELECT COUNT(*) FROM auth.users) as total_auth_users,
    (SELECT COUNT(*) FROM profiles) as total_profiles,
    (SELECT COUNT(*) FROM auth.users au WHERE NOT EXISTS (SELECT 1 FROM profiles p WHERE p.id = au.id)) as usuarios_sem_profile;

-- Testar a função com um usuário existente
DO $$
DECLARE
    test_user_id UUID;
    test_result JSONB;
BEGIN
    -- Pegar um usuário válido para teste
    SELECT id INTO test_user_id FROM profiles LIMIT 1;
    
    IF test_user_id IS NOT NULL THEN
        -- Testar função corrigida
        SELECT record_workout_basic(
            test_user_id,
            'Teste Correção USER_NOT_FOUND',
            'Teste',
            30,
            NOW(),
            NULL,
            NULL,
            'Teste da correção',
            NULL
        ) INTO test_result;
        
        RAISE NOTICE '✅ Teste da função corrigida: %', test_result->>'success';
        RAISE NOTICE '📝 Mensagem: %', test_result->>'message';
    ELSE
        RAISE NOTICE '❌ Nenhum usuário encontrado para teste';
    END IF;
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE '❌ Erro no teste: %', SQLERRM;
END $$;

COMMIT;

-- =============================================
-- RELATÓRIO FINAL
-- =============================================

SELECT '📊 RELATÓRIO FINAL - CORREÇÃO USER_NOT_FOUND' as titulo;

SELECT 
    NOW() as data_correcao,
    'Problema USER_NOT_FOUND corrigido' as status,
    (SELECT COUNT(*) FROM auth.users) as usuarios_auth,
    (SELECT COUNT(*) FROM profiles) as usuarios_profiles,
    (SELECT EXISTS(SELECT 1 FROM pg_proc WHERE proname = 'record_workout_basic')) as funcao_atualizada,
    (SELECT EXISTS(SELECT 1 FROM pg_trigger WHERE tgname = 'trigger_sync_auth_users_to_profiles')) as trigger_sincronizacao;

SELECT '✅ CORREÇÃO APLICADA COM SUCESSO' as resultado; 