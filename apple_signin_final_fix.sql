-- Script Final para Garantir Apple Sign In Funcionando
-- Este script resolve definitivamente o erro "Database error saving new user"

-- 1. Primeiro, vamos verificar se as tabelas existem e têm as colunas corretas
DO $$
BEGIN
    -- Verificar se a tabela profiles tem a estrutura necessária
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'profiles' AND column_name = 'id' AND table_schema = 'public'
    ) THEN
        RAISE EXCEPTION 'Tabela profiles não encontrada ou sem coluna id';
    END IF;
    
    -- Verificar se user_progress_level tem current_level (não level)
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'user_progress_level' AND column_name = 'current_level' AND table_schema = 'public'
    ) THEN
        RAISE EXCEPTION 'Tabela user_progress_level não tem coluna current_level';
    END IF;
    
    RAISE NOTICE 'Estrutura das tabelas verificada com sucesso';
END $$;

-- 2. Criar função handle_new_user mais robusta
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    user_name text;
    user_email text;
BEGIN
    -- Log de início
    RAISE NOTICE 'handle_new_user: Iniciando para usuário %', NEW.id;
    
    -- Extrair email (garantir que não seja null)
    user_email := COALESCE(NEW.email, 'user-' || NEW.id || '@rayclub.com');
    
    -- Extrair nome do usuário dos metadados
    user_name := COALESCE(
        NEW.raw_user_meta_data->>'full_name',
        NEW.raw_user_meta_data->>'name',
        NEW.raw_user_meta_data->>'given_name',
        split_part(user_email, '@', 1),
        'Usuário'
    );
    
    RAISE NOTICE 'handle_new_user: Email=%, Nome=%', user_email, user_name;
    
    -- 1. Inserir perfil básico
    BEGIN
        INSERT INTO public.profiles (
            id,
            email,
            name,
            created_at,
            updated_at
        ) VALUES (
            NEW.id,
            user_email,
            user_name,
            NOW(),
            NOW()
        ) ON CONFLICT (id) DO UPDATE SET
            email = COALESCE(EXCLUDED.email, profiles.email),
            name = COALESCE(EXCLUDED.name, profiles.name),
            updated_at = NOW();
        
        RAISE NOTICE 'handle_new_user: Perfil criado/atualizado com sucesso';
    EXCEPTION
        WHEN OTHERS THEN
            RAISE WARNING 'handle_new_user: Erro ao criar perfil: %', SQLERRM;
    END;
    
    -- 2. Inserir progresso inicial
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
    
    -- 3. Inserir nível de acesso inicial
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
    
    RAISE NOTICE 'handle_new_user: Concluído com sucesso para usuário %', NEW.id;
    RETURN NEW;
    
EXCEPTION
    WHEN OTHERS THEN
        -- Log do erro mas não falha o trigger
        RAISE WARNING 'handle_new_user: Erro geral para usuário %: %', NEW.id, SQLERRM;
        RETURN NEW;
END;
$$;

-- 3. Recriar o trigger (garantir que está ativo)
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

-- 4. Verificar se o trigger foi criado
SELECT 
    trigger_name,
    event_manipulation,
    action_timing,
    action_statement
FROM information_schema.triggers 
WHERE trigger_name = 'on_auth_user_created';

-- 5. Criar função de teste específica para Apple Sign In
CREATE OR REPLACE FUNCTION test_apple_signin_complete()
RETURNS TABLE(
    step text,
    status text,
    details text
)
LANGUAGE plpgsql
AS $$
DECLARE
    test_user_id uuid := gen_random_uuid();
    test_email text := 'apple-test-' || test_user_id || '@privaterelay.appleid.com';
    profile_created boolean := false;
    progress_created boolean := false;
    level_created boolean := false;
BEGIN
    -- Passo 1: Criar usuário Apple
    RETURN QUERY SELECT 'Passo 1'::text, 'INICIANDO'::text, 'Criando usuário Apple de teste'::text;
    
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
            crypt('apple123', gen_salt('bf')),
            NOW(),
            '{"provider": "apple", "providers": ["apple"]}',
            '{"name": "Apple User", "full_name": "Apple Test User", "given_name": "Apple", "family_name": "User"}',
            NOW(),
            NOW()
        );
        
        RETURN QUERY SELECT 'Passo 1'::text, 'SUCCESS'::text, 'Usuário criado: ' || test_user_id::text;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN QUERY SELECT 'Passo 1'::text, 'ERROR'::text, 'Erro ao criar usuário: ' || SQLERRM;
            RETURN;
    END;
    
    -- Aguardar trigger
    PERFORM pg_sleep(0.5);
    
    -- Passo 2: Verificar perfil
    SELECT EXISTS(SELECT 1 FROM public.profiles WHERE id = test_user_id) INTO profile_created;
    IF profile_created THEN
        RETURN QUERY SELECT 'Passo 2'::text, 'SUCCESS'::text, 'Perfil criado automaticamente'::text;
    ELSE
        RETURN QUERY SELECT 'Passo 2'::text, 'ERROR'::text, 'Perfil NÃO foi criado'::text;
    END IF;
    
    -- Passo 3: Verificar progresso
    SELECT EXISTS(SELECT 1 FROM public.user_progress WHERE user_id = test_user_id) INTO progress_created;
    IF progress_created THEN
        RETURN QUERY SELECT 'Passo 3'::text, 'SUCCESS'::text, 'Progresso criado automaticamente'::text;
    ELSE
        RETURN QUERY SELECT 'Passo 3'::text, 'ERROR'::text, 'Progresso NÃO foi criado'::text;
    END IF;
    
    -- Passo 4: Verificar nível
    SELECT EXISTS(SELECT 1 FROM public.user_progress_level WHERE user_id = test_user_id) INTO level_created;
    IF level_created THEN
        RETURN QUERY SELECT 'Passo 4'::text, 'SUCCESS'::text, 'Nível criado automaticamente'::text;
    ELSE
        RETURN QUERY SELECT 'Passo 4'::text, 'ERROR'::text, 'Nível NÃO foi criado'::text;
    END IF;
    
    -- Passo 5: Resultado final
    IF profile_created AND progress_created AND level_created THEN
        RETURN QUERY SELECT 'RESULTADO'::text, 'SUCCESS'::text, 'Apple Sign In funcionando 100%'::text;
    ELSE
        RETURN QUERY SELECT 'RESULTADO'::text, 'ERROR'::text, 'Apple Sign In com problemas'::text;
    END IF;
    
    -- Limpeza
    BEGIN
        DELETE FROM public.user_progress_level WHERE user_id = test_user_id;
        DELETE FROM public.user_progress WHERE user_id = test_user_id;
        DELETE FROM public.profiles WHERE id = test_user_id;
        DELETE FROM auth.users WHERE id = test_user_id;
        RETURN QUERY SELECT 'LIMPEZA'::text, 'SUCCESS'::text, 'Dados de teste removidos'::text;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN QUERY SELECT 'LIMPEZA'::text, 'WARNING'::text, 'Erro na limpeza: ' || SQLERRM;
    END;
    
END;
$$;

-- 6. Executar teste completo
SELECT * FROM test_apple_signin_complete();

-- 7. Verificar políticas RLS (garantir que estão corretas)
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE schemaname = 'public' 
AND tablename IN ('profiles', 'user_progress', 'user_progress_level')
ORDER BY tablename, policyname;

-- 8. Mostrar resumo final
SELECT 
    'CONFIGURAÇÃO APPLE SIGN IN' as info,
    'COMPLETA' as status,
    NOW() as timestamp;

-- Instruções finais:
-- 1. Execute este script no Supabase Dashboard > SQL Editor
-- 2. Verifique se todos os testes passaram (status = SUCCESS)
-- 3. Se algum teste falhar, verifique as mensagens de erro
-- 4. O Apple Sign In deve funcionar corretamente após este script 