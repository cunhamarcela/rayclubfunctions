-- Funções SQL para diagnóstico de problemas de login
-- Execute estas funções no Supabase SQL Editor

-- 1. Função para verificar usuário na tabela auth.users
CREATE OR REPLACE FUNCTION check_auth_user(user_email text)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    user_data json;
BEGIN
    SELECT to_json(au.*) INTO user_data
    FROM auth.users au
    WHERE au.email = user_email;
    
    RETURN user_data;
END;
$$;

-- 2. Função para verificar políticas RLS
CREATE OR REPLACE FUNCTION check_rls_policies()
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    policies json;
BEGIN
    SELECT json_agg(
        json_build_object(
            'table_name', schemaname || '.' || tablename,
            'policy_name', policyname,
            'permissive', permissive,
            'roles', roles,
            'cmd', cmd,
            'qual', qual
        )
    ) INTO policies
    FROM pg_policies
    WHERE schemaname = 'public'
    AND tablename IN ('profiles', 'challenges', 'challenge_check_ins');
    
    RETURN policies;
END;
$$;

-- 3. Função para verificar providers de autenticação
CREATE OR REPLACE FUNCTION check_user_providers(user_email text)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    providers json;
BEGIN
    SELECT json_agg(
        json_build_object(
            'provider', (raw_app_meta_data->>'provider'),
            'provider_id', (raw_app_meta_data->>'provider_id'),
            'providers', (raw_app_meta_data->>'providers')
        )
    ) INTO providers
    FROM auth.users
    WHERE email = user_email;
    
    RETURN providers;
END;
$$;

-- 4. Função para verificar confirmação de email
CREATE OR REPLACE FUNCTION check_email_confirmation(user_email text)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    confirmation_data json;
BEGIN
    SELECT json_build_object(
        'email', email,
        'email_confirmed_at', email_confirmed_at,
        'email_change', email_change,
        'email_change_confirmed_at', email_change_confirmed_at,
        'confirmation_sent_at', confirmation_sent_at,
        'recovery_sent_at', recovery_sent_at
    ) INTO confirmation_data
    FROM auth.users
    WHERE email = user_email;
    
    RETURN confirmation_data;
END;
$$;

-- 5. Função para diagnóstico completo de usuário
CREATE OR REPLACE FUNCTION diagnose_user_login(user_email text)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    result json;
    auth_user json;
    profile_data json;
    providers_data json;
    confirmation_data json;
BEGIN
    -- Verificar auth.users
    SELECT check_auth_user(user_email) INTO auth_user;
    
    -- Verificar profiles
    SELECT to_json(p.*) INTO profile_data
    FROM profiles p
    WHERE p.email = user_email;
    
    -- Verificar providers
    SELECT check_user_providers(user_email) INTO providers_data;
    
    -- Verificar confirmação
    SELECT check_email_confirmation(user_email) INTO confirmation_data;
    
    -- Compilar resultado
    SELECT json_build_object(
        'email', user_email,
        'timestamp', now(),
        'auth_user', auth_user,
        'profile', profile_data,
        'providers', providers_data,
        'confirmation', confirmation_data,
        'exists_in_auth', (auth_user IS NOT NULL),
        'exists_in_profiles', (profile_data IS NOT NULL),
        'email_confirmed', (
            SELECT email_confirmed_at IS NOT NULL
            FROM auth.users
            WHERE email = user_email
        )
    ) INTO result;
    
    RETURN result;
END;
$$;

-- 6. Função para verificar problemas comuns
CREATE OR REPLACE FUNCTION check_common_login_issues(user_email text)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    issues json;
    auth_exists boolean := false;
    profile_exists boolean := false;
    email_confirmed boolean := false;
    has_oauth_provider boolean := false;
    provider_name text;
BEGIN
    -- Verificar se existe em auth.users
    SELECT EXISTS(
        SELECT 1 FROM auth.users WHERE email = user_email
    ) INTO auth_exists;
    
    -- Verificar se existe em profiles
    SELECT EXISTS(
        SELECT 1 FROM profiles WHERE email = user_email
    ) INTO profile_exists;
    
    -- Verificar se email foi confirmado
    SELECT email_confirmed_at IS NOT NULL INTO email_confirmed
    FROM auth.users WHERE email = user_email;
    
    -- Verificar se tem provider OAuth
    SELECT 
        (raw_app_meta_data->>'provider') IN ('google', 'apple'),
        (raw_app_meta_data->>'provider')
    INTO has_oauth_provider, provider_name
    FROM auth.users WHERE email = user_email;
    
    -- Compilar diagnóstico
    SELECT json_build_object(
        'email', user_email,
        'diagnosis', json_build_object(
            'user_exists_in_auth', auth_exists,
            'user_exists_in_profiles', profile_exists,
            'email_confirmed', email_confirmed,
            'has_oauth_provider', has_oauth_provider,
            'oauth_provider', provider_name
        ),
        'issues', json_build_array(
            CASE WHEN NOT auth_exists THEN 'USER_NOT_EXISTS_IN_AUTH' END,
            CASE WHEN auth_exists AND NOT profile_exists THEN 'PROFILE_MISSING' END,
            CASE WHEN auth_exists AND NOT email_confirmed THEN 'EMAIL_NOT_CONFIRMED' END,
            CASE WHEN has_oauth_provider THEN 'USING_OAUTH_PROVIDER' END
        ),
        'recommendations', json_build_array(
            CASE WHEN NOT auth_exists THEN 'Usuário deve se cadastrar novamente' END,
            CASE WHEN auth_exists AND NOT profile_exists THEN 'Criar perfil manualmente' END,
            CASE WHEN auth_exists AND NOT email_confirmed THEN 'Reenviar email de confirmação' END,
            CASE WHEN has_oauth_provider THEN 'Usar login com ' || provider_name END
        )
    ) INTO issues;
    
    RETURN issues;
END;
$$;

-- Conceder permissões para as funções
GRANT EXECUTE ON FUNCTION check_auth_user(text) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION check_rls_policies() TO anon, authenticated;
GRANT EXECUTE ON FUNCTION check_user_providers(text) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION check_email_confirmation(text) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION diagnose_user_login(text) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION check_common_login_issues(text) TO anon, authenticated;

-- Comentários sobre as funções
COMMENT ON FUNCTION check_auth_user(text) IS 'Verifica se usuário existe na tabela auth.users';
COMMENT ON FUNCTION check_rls_policies() IS 'Lista políticas RLS ativas';
COMMENT ON FUNCTION check_user_providers(text) IS 'Verifica providers de autenticação do usuário';
COMMENT ON FUNCTION check_email_confirmation(text) IS 'Verifica status de confirmação do email';
COMMENT ON FUNCTION diagnose_user_login(text) IS 'Diagnóstico completo de problemas de login';
COMMENT ON FUNCTION check_common_login_issues(text) IS 'Verifica problemas comuns de login e sugere soluções'; 