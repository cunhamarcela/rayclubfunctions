-- Script para diagnosticar e corrigir o erro de login com Apple
-- Erro: {"code":"unexpected_failure","message":"Database error saving new user"}

-- 1. Verificar se existe a função handle_new_user
SELECT 
    p.proname as function_name,
    pg_get_functiondef(p.oid) as function_definition
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public' 
AND p.proname LIKE '%user%'
AND p.proname LIKE '%new%';

-- 2. Verificar triggers na tabela auth.users
SELECT 
    trigger_name,
    event_manipulation,
    event_object_table,
    action_statement
FROM information_schema.triggers
WHERE event_object_schema = 'auth'
AND event_object_table = 'users';

-- 3. Criar ou atualizar a função handle_new_user
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
    -- Inserir na tabela profiles se não existir
    INSERT INTO public.profiles (
        id,
        email,
        name,
        created_at,
        updated_at
    )
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name', split_part(NEW.email, '@', 1)),
        NOW(),
        NOW()
    )
    ON CONFLICT (id) DO UPDATE
    SET 
        email = EXCLUDED.email,
        name = COALESCE(EXCLUDED.name, profiles.name),
        updated_at = NOW();

    -- Inserir na tabela user_progress se não existir
    INSERT INTO public.user_progress (
        user_id,
        points,
        level,
        workouts,
        created_at,
        updated_at
    )
    VALUES (
        NEW.id,
        0,
        1,
        0,
        NOW(),
        NOW()
    )
    ON CONFLICT (user_id) DO NOTHING;

    RETURN NEW;
EXCEPTION
    WHEN OTHERS THEN
        -- Log do erro para debug
        RAISE WARNING 'Erro ao criar usuário: %', SQLERRM;
        -- Ainda assim retorna NEW para não bloquear a criação
        RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. Criar trigger se não existir
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

-- 5. Verificar estrutura da tabela profiles
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public'
AND table_name = 'profiles'
ORDER BY ordinal_position;

-- 6. Verificar se há constraints que podem estar causando o erro
SELECT
    tc.constraint_name,
    tc.constraint_type,
    tc.table_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
    AND ccu.table_schema = tc.table_schema
WHERE tc.table_schema = 'public'
AND tc.table_name = 'profiles';

-- 7. Criar usuário de teste para a Apple
-- Primeiro, verificar se já existe
SELECT id, email FROM auth.users WHERE email = 'review@rayclub.com';

-- Se não existir, criar
-- NOTA: Execute este comando apenas se o usuário não existir
/*
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
    updated_at,
    confirmation_token,
    email_change,
    email_change_token_new,
    recovery_token
) VALUES (
    '00000000-0000-0000-0000-000000000000',
    gen_random_uuid(),
    'authenticated',
    'authenticated',
    'review@rayclub.com',
    crypt('Test1234!', gen_salt('bf')),
    NOW(),
    '{"provider": "email", "providers": ["email"]}',
    '{"name": "Apple Review User"}',
    NOW(),
    NOW(),
    '',
    '',
    '',
    ''
);
*/

-- 8. Verificar políticas RLS que podem estar bloqueando
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
WHERE tablename IN ('profiles', 'user_progress')
ORDER BY tablename, policyname; 