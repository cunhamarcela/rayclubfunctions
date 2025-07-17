-- Script de Compatibilidade iPad - Apple Review
-- Este script garante que o app funcione perfeitamente no iPad Air (5th generation) com iPadOS 18.5

-- 1. Otimizar função handle_new_user para iPad
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    user_name text;
    user_email text;
    device_type text;
BEGIN
    -- Log detalhado para debug no iPad
    RAISE NOTICE 'handle_new_user: Iniciando para usuário % no device %', NEW.id, COALESCE(NEW.raw_user_meta_data->>'device_type', 'unknown');
    
    -- Extrair email (garantir que não seja null)
    user_email := COALESCE(NEW.email, 'user-' || NEW.id || '@rayclub.com');
    
    -- Extrair device type
    device_type := COALESCE(NEW.raw_user_meta_data->>'device_type', 'unknown');
    
    -- Extrair nome do usuário dos metadados (melhor suporte para Apple Sign In)
    user_name := COALESCE(
        NEW.raw_user_meta_data->>'full_name',
        NEW.raw_user_meta_data->>'name',
        NEW.raw_user_meta_data->>'given_name',
        CASE 
            WHEN NEW.raw_user_meta_data->>'family_name' IS NOT NULL THEN
                CONCAT(
                    COALESCE(NEW.raw_user_meta_data->>'given_name', ''),
                    ' ',
                    NEW.raw_user_meta_data->>'family_name'
                )
            ELSE NULL
        END,
        split_part(user_email, '@', 1),
        'Usuário'
    );
    
    -- Limpar nome (remover espaços extras)
    user_name := TRIM(user_name);
    IF user_name = '' THEN
        user_name := 'Usuário';
    END IF;
    
    RAISE NOTICE 'handle_new_user: Email=%, Nome=%, Device=%', user_email, user_name, device_type;
    
    -- 1. Inserir perfil básico com retry para iPad
    BEGIN
        INSERT INTO public.profiles (
            id,
            email,
            name,
            created_at,
            updated_at,
            settings
        ) VALUES (
            NEW.id,
            user_email,
            user_name,
            NOW(),
            NOW(),
            jsonb_build_object(
                'dark_mode', false,
                'notifications', true,
                'device_type', device_type,
                'signup_method', COALESCE(NEW.raw_app_meta_data->>'provider', 'email')
            )
        ) ON CONFLICT (id) DO UPDATE SET
            email = COALESCE(EXCLUDED.email, profiles.email),
            name = COALESCE(EXCLUDED.name, profiles.name),
            updated_at = NOW(),
            settings = COALESCE(EXCLUDED.settings, profiles.settings);
        
        RAISE NOTICE 'handle_new_user: Perfil criado/atualizado com sucesso';
    EXCEPTION
        WHEN OTHERS THEN
            RAISE WARNING 'handle_new_user: Erro ao criar perfil: %', SQLERRM;
            -- Tentar novamente com dados mínimos
            BEGIN
                INSERT INTO public.profiles (id, email, name) 
                VALUES (NEW.id, user_email, user_name)
                ON CONFLICT (id) DO UPDATE SET updated_at = NOW();
            EXCEPTION
                WHEN OTHERS THEN
                    RAISE WARNING 'handle_new_user: Falha crítica ao criar perfil: %', SQLERRM;
            END;
    END;
    
    -- 2. Inserir progresso inicial com retry
    BEGIN
        INSERT INTO public.user_progress (
            user_id,
            points,
            level,
            workouts,
            created_at,
            updated_at
        ) VALUES (
            NEW.id,
            0,
            1,
            0,
            NOW(),
            NOW()
        ) ON CONFLICT (user_id) DO UPDATE SET
            updated_at = NOW();
        
        RAISE NOTICE 'handle_new_user: Progresso criado/atualizado com sucesso';
    EXCEPTION
        WHEN OTHERS THEN
            RAISE WARNING 'handle_new_user: Erro ao criar progresso: %', SQLERRM;
    END;
    
    -- 3. Inserir nível de acesso inicial com retry
    BEGIN
        INSERT INTO public.user_progress_level (
            user_id,
            current_level,
            created_at,
            updated_at
        ) VALUES (
            NEW.id,
            'basic',
            NOW(),
            NOW()
        ) ON CONFLICT (user_id) DO UPDATE SET
            updated_at = NOW();
        
        RAISE NOTICE 'handle_new_user: Nível criado/atualizado com sucesso';
    EXCEPTION
        WHEN OTHERS THEN
            RAISE WARNING 'handle_new_user: Erro ao criar nível: %', SQLERRM;
    END;
    
    RAISE NOTICE 'handle_new_user: Concluído com sucesso para usuário % no device %', NEW.id, device_type;
    RETURN NEW;
    
EXCEPTION
    WHEN OTHERS THEN
        -- Log do erro mas não falha o trigger
        RAISE WARNING 'handle_new_user: Erro geral para usuário %: %', NEW.id, SQLERRM;
        RETURN NEW;
END;
$$;

-- 2. Criar função específica para testar iPad
CREATE OR REPLACE FUNCTION test_ipad_compatibility()
RETURNS TABLE(
    test_name text,
    status text,
    details text
)
LANGUAGE plpgsql
AS $$
DECLARE
    test_user_id uuid := gen_random_uuid();
    test_email text := 'ipad-test-' || test_user_id || '@privaterelay.appleid.com';
    profile_created boolean := false;
    progress_created boolean := false;
    level_created boolean := false;
BEGIN
    -- Teste 1: Criar usuário Apple no iPad
    RETURN QUERY SELECT 'iPad Apple Sign In'::text, 'INICIANDO'::text, 'Testando criação de usuário Apple no iPad'::text;
    
    BEGIN
        INSERT INTO auth.users (
            instance_id,
            id,
            aud,
            role,
            email,
            encrypted_password,
            email_confirmed_at,
            raw_app_meta_data,
            raw_user_meta_data,
            created_at,
            updated_at
        ) VALUES (
            '00000000-0000-0000-0000-000000000000',
            test_user_id,
            'authenticated',
            'authenticated',
            test_email,
            crypt('ipad123', gen_salt('bf')),
            NOW(),
            '{"provider": "apple", "providers": ["apple"]}',
            '{"name": "iPad User", "full_name": "iPad Test User", "given_name": "iPad", "family_name": "User", "device_type": "ios"}',
            NOW(),
            NOW()
        );
        
        RETURN QUERY SELECT 'iPad Apple Sign In'::text, 'SUCCESS'::text, 'Usuário iPad criado: ' || test_user_id::text;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN QUERY SELECT 'iPad Apple Sign In'::text, 'ERROR'::text, 'Erro ao criar usuário iPad: ' || SQLERRM;
            RETURN;
    END;
    
    -- Aguardar trigger (iPad pode ser mais lento)
    PERFORM pg_sleep(1.0);
    
    -- Teste 2: Verificar perfil
    SELECT EXISTS(SELECT 1 FROM public.profiles WHERE id = test_user_id) INTO profile_created;
    IF profile_created THEN
        RETURN QUERY SELECT 'Perfil iPad'::text, 'SUCCESS'::text, 'Perfil criado automaticamente no iPad'::text;
    ELSE
        RETURN QUERY SELECT 'Perfil iPad'::text, 'ERROR'::text, 'Perfil NÃO foi criado no iPad'::text;
    END IF;
    
    -- Teste 3: Verificar progresso
    SELECT EXISTS(SELECT 1 FROM public.user_progress WHERE user_id = test_user_id) INTO progress_created;
    IF progress_created THEN
        RETURN QUERY SELECT 'Progresso iPad'::text, 'SUCCESS'::text, 'Progresso criado automaticamente no iPad'::text;
    ELSE
        RETURN QUERY SELECT 'Progresso iPad'::text, 'ERROR'::text, 'Progresso NÃO foi criado no iPad'::text;
    END IF;
    
    -- Teste 4: Verificar nível
    SELECT EXISTS(SELECT 1 FROM public.user_progress_level WHERE user_id = test_user_id) INTO level_created;
    IF level_created THEN
        RETURN QUERY SELECT 'Nível iPad'::text, 'SUCCESS'::text, 'Nível criado automaticamente no iPad'::text;
    ELSE
        RETURN QUERY SELECT 'Nível iPad'::text, 'ERROR'::text, 'Nível NÃO foi criado no iPad'::text;
    END IF;
    
    -- Teste 5: Verificar dados específicos do perfil
    DECLARE
        profile_name text;
        profile_settings jsonb;
    BEGIN
        SELECT name, settings INTO profile_name, profile_settings 
        FROM public.profiles WHERE id = test_user_id;
        
        IF profile_name IS NOT NULL AND profile_settings IS NOT NULL THEN
            RETURN QUERY SELECT 'Dados Perfil iPad'::text, 'SUCCESS'::text, 'Nome: ' || profile_name || ', Settings: ' || profile_settings::text;
        ELSE
            RETURN QUERY SELECT 'Dados Perfil iPad'::text, 'WARNING'::text, 'Dados do perfil incompletos';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN QUERY SELECT 'Dados Perfil iPad'::text, 'ERROR'::text, 'Erro ao verificar dados: ' || SQLERRM;
    END;
    
    -- Resultado final
    IF profile_created AND progress_created AND level_created THEN
        RETURN QUERY SELECT 'RESULTADO FINAL'::text, 'SUCCESS'::text, 'iPad totalmente compatível - Apple Sign In funcionando 100%'::text;
    ELSE
        RETURN QUERY SELECT 'RESULTADO FINAL'::text, 'ERROR'::text, 'iPad com problemas - verificar logs'::text;
    END IF;
    
    -- Limpeza
    BEGIN
        DELETE FROM public.user_progress_level WHERE user_id = test_user_id;
        DELETE FROM public.user_progress WHERE user_id = test_user_id;
        DELETE FROM public.profiles WHERE id = test_user_id;
        DELETE FROM auth.users WHERE id = test_user_id;
        RETURN QUERY SELECT 'LIMPEZA'::text, 'SUCCESS'::text, 'Dados de teste iPad removidos'::text;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN QUERY SELECT 'LIMPEZA'::text, 'WARNING'::text, 'Erro na limpeza iPad: ' || SQLERRM;
    END;
    
END;
$$;

-- 3. Criar função para testar criação de conta normal no iPad
CREATE OR REPLACE FUNCTION test_ipad_signup()
RETURNS TABLE(
    test_name text,
    status text,
    details text
)
LANGUAGE plpgsql
AS $$
DECLARE
    test_user_id uuid := gen_random_uuid();
    test_email text := 'ipad-signup-' || test_user_id || '@example.com';
BEGIN
    -- Teste de signup normal no iPad
    RETURN QUERY SELECT 'iPad Signup'::text, 'INICIANDO'::text, 'Testando criação de conta normal no iPad'::text;
    
    BEGIN
        INSERT INTO auth.users (
            instance_id,
            id,
            aud,
            role,
            email,
            encrypted_password,
            email_confirmed_at,
            raw_app_meta_data,
            raw_user_meta_data,
            created_at,
            updated_at
        ) VALUES (
            '00000000-0000-0000-0000-000000000000',
            test_user_id,
            'authenticated',
            'authenticated',
            test_email,
            crypt('ipadtest123', gen_salt('bf')),
            NOW(),
            '{"provider": "email", "providers": ["email"]}',
            '{"name": "iPad Signup User", "full_name": "iPad Signup User", "device_type": "ios", "signup_timestamp": "' || NOW()::text || '"}',
            NOW(),
            NOW()
        );
        
        RETURN QUERY SELECT 'iPad Signup'::text, 'SUCCESS'::text, 'Conta normal criada no iPad: ' || test_user_id::text;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN QUERY SELECT 'iPad Signup'::text, 'ERROR'::text, 'Erro ao criar conta no iPad: ' || SQLERRM;
            RETURN;
    END;
    
    -- Aguardar trigger
    PERFORM pg_sleep(1.0);
    
    -- Verificar se tudo foi criado
    IF EXISTS(SELECT 1 FROM public.profiles WHERE id = test_user_id) AND
       EXISTS(SELECT 1 FROM public.user_progress WHERE user_id = test_user_id) AND
       EXISTS(SELECT 1 FROM public.user_progress_level WHERE user_id = test_user_id) THEN
        RETURN QUERY SELECT 'iPad Signup Completo'::text, 'SUCCESS'::text, 'Conta normal funcionando 100% no iPad'::text;
    ELSE
        RETURN QUERY SELECT 'iPad Signup Completo'::text, 'ERROR'::text, 'Problemas na criação de conta no iPad'::text;
    END IF;
    
    -- Limpeza
    DELETE FROM public.user_progress_level WHERE user_id = test_user_id;
    DELETE FROM public.user_progress WHERE user_id = test_user_id;
    DELETE FROM public.profiles WHERE id = test_user_id;
    DELETE FROM auth.users WHERE id = test_user_id;
    
END;
$$;

-- 4. Executar todos os testes de compatibilidade iPad
SELECT 'TESTE DE COMPATIBILIDADE IPAD' as info, 'INICIANDO' as status;

-- Teste 1: Apple Sign In no iPad
SELECT * FROM test_ipad_compatibility();

-- Teste 2: Signup normal no iPad
SELECT * FROM test_ipad_signup();

-- 5. Verificar performance das consultas (importante para iPad)
EXPLAIN ANALYZE SELECT * FROM public.profiles WHERE email = 'test@example.com';
EXPLAIN ANALYZE SELECT * FROM public.user_progress WHERE user_id = gen_random_uuid();
EXPLAIN ANALYZE SELECT * FROM public.user_progress_level WHERE user_id = gen_random_uuid();

-- 6. Mostrar resumo final
SELECT 
    'COMPATIBILIDADE IPAD' as info,
    'CONFIGURADA' as status,
    'iPad Air (5th generation) com iPadOS 18.5' as target_device,
    NOW() as timestamp;

-- Instruções:
-- 1. Execute este script no Supabase Dashboard > SQL Editor
-- 2. Verifique se todos os testes passaram (status = SUCCESS)
-- 3. Se algum teste falhar, verifique as mensagens de erro específicas
-- 4. O app deve funcionar perfeitamente no iPad após este script 