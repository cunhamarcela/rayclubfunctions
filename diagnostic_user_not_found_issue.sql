-- =================================================================
-- DIAGNÓSTICO DO PROBLEMA "USER_NOT_FOUND" NO REGISTRO DE TREINOS
-- =================================================================

-- Problema: Usuários não conseguem registrar treinos
-- Erro: "Usuário não encontrado ou inativo"
-- Data: $(date)

-- =============================================
-- ETAPA 1: VERIFICAR FUNÇÃO RECORD_WORKOUT_BASIC
-- =============================================

SELECT '🔍 DIAGNÓSTICO: Verificando função record_workout_basic' as etapa;

-- Verificar se a função existe
SELECT 
    'record_workout_basic' as funcao,
    COUNT(*) as versoes_encontradas,
    string_agg(
        pg_get_function_arguments(p.oid) || ' -> ' || pg_get_function_result(p.oid), 
        E'\n'
    ) as assinaturas
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE p.proname = 'record_workout_basic'
  AND n.nspname = 'public';

-- Verificar código da função atual
SELECT 
    p.proname as nome_funcao,
    pg_get_functiondef(p.oid) as codigo_funcao
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE p.proname = 'record_workout_basic'
  AND n.nspname = 'public'
LIMIT 1;

-- =============================================
-- ETAPA 2: VERIFICAR TABELA PROFILES
-- =============================================

SELECT '🔍 DIAGNÓSTICO: Verificando tabela profiles' as etapa;

-- Verificar estrutura da tabela profiles
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'profiles' 
  AND table_schema = 'public'
ORDER BY ordinal_position;

-- Contar total de usuários na tabela profiles
SELECT 
    'profiles' as tabela,
    COUNT(*) as total_usuarios,
    COUNT(CASE WHEN id IS NOT NULL THEN 1 END) as usuarios_com_id,
    COUNT(CASE WHEN email IS NOT NULL THEN 1 END) as usuarios_com_email
FROM profiles;

-- Verificar usuários recentes (últimos 7 dias)
SELECT 
    'Usuários recentes (7 dias)' as categoria,
    COUNT(*) as quantidade
FROM profiles 
WHERE created_at >= NOW() - INTERVAL '7 days';

-- =============================================
-- ETAPA 3: VERIFICAR AUTENTICAÇÃO SUPABASE
-- =============================================

SELECT '🔍 DIAGNÓSTICO: Verificando tabela auth.users' as etapa;

-- Verificar diferenças entre auth.users e profiles
SELECT 
    'Comparação auth.users vs profiles' as diagnostico,
    (SELECT COUNT(*) FROM auth.users) as auth_users_total,
    (SELECT COUNT(*) FROM profiles) as profiles_total,
    (SELECT COUNT(*) FROM auth.users au WHERE NOT EXISTS (SELECT 1 FROM profiles p WHERE p.id = au.id)) as usuarios_sem_profile,
    (SELECT COUNT(*) FROM profiles p WHERE NOT EXISTS (SELECT 1 FROM auth.users au WHERE au.id = p.id)) as profiles_sem_auth;

-- Verificar usuários que estão tentando registrar treinos (do log do erro)
-- Assumindo o ID do usuário do log: 01d4a292-1873-4af6-948b-a55eed56d6b9
DO $$
DECLARE
    test_user_id UUID := '%01d4a292-1873-4af6-948b-a55eed56d6b9%';
BEGIN
    -- Verificar se este usuário específico existe em auth.users
    IF EXISTS (SELECT 1 FROM auth.users WHERE id::text LIKE test_user_id) THEN
        RAISE NOTICE '✅ Usuário %.% encontrado em auth.users', substring(test_user_id, 1, 8), substring(test_user_id, 10, 8);
    ELSE
        RAISE NOTICE '❌ Usuário %.% NÃO encontrado em auth.users', substring(test_user_id, 1, 8), substring(test_user_id, 10, 8);
    END IF;

    -- Verificar se este usuário específico existe em profiles
    IF EXISTS (SELECT 1 FROM profiles WHERE id::text LIKE test_user_id) THEN
        RAISE NOTICE '✅ Usuário %.% encontrado em profiles', substring(test_user_id, 1, 8), substring(test_user_id, 10, 8);
    ELSE
        RAISE NOTICE '❌ Usuário %.% NÃO encontrado em profiles', substring(test_user_id, 1, 8), substring(test_user_id, 10, 8);
    END IF;
END $$;

-- =============================================
-- ETAPA 4: VERIFICAR LOGS DE ERRO
-- =============================================

SELECT '🔍 DIAGNÓSTICO: Verificando logs de erro recentes' as etapa;

-- Verificar erros recentes na tabela de logs
SELECT 
    created_at,
    user_id,
    error_message,
    error_type,
    status,
    request_data->'user_id' as user_id_from_request
FROM check_in_error_logs
WHERE error_type = 'AUTH_ERROR' 
   OR error_message ILIKE '%user not found%'
   OR error_message ILIKE '%usuário não encontrado%'
ORDER BY created_at DESC
LIMIT 10;

-- =============================================
-- ETAPA 5: TESTE DIRETO DA FUNÇÃO
-- =============================================

SELECT '🔍 DIAGNÓSTICO: Testando função com usuário válido' as etapa;

-- Pegar um usuário válido da tabela profiles para teste
DO $$
DECLARE
    test_user_id UUID;
    test_result JSONB;
BEGIN
    -- Buscar primeiro usuário válido
    SELECT id INTO test_user_id FROM profiles LIMIT 1;
    
    IF test_user_id IS NOT NULL THEN
        RAISE NOTICE '✅ Testando com usuário válido: %', test_user_id;
        
        -- Testar função record_workout_basic
        SELECT record_workout_basic(
            test_user_id,
            'Teste Diagnóstico',
            'Teste',
            30,
            NOW(),
            NULL,
            NULL,
            'Teste de diagnóstico',
            NULL
        ) INTO test_result;
        
        RAISE NOTICE '✅ Resultado do teste: %', test_result;
    ELSE
        RAISE NOTICE '❌ Nenhum usuário encontrado na tabela profiles para teste';
    END IF;
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE '❌ Erro no teste da função: %', SQLERRM;
END $$;

-- =============================================
-- ETAPA 6: VERIFICAR PERMISSÕES E POLÍTICAS RLS
-- =============================================

SELECT '🔍 DIAGNÓSTICO: Verificando políticas de segurança' as etapa;

-- Verificar se RLS está habilitado na tabela profiles
SELECT 
    schemaname,
    tablename,
    rowsecurity as rls_enabled,
    pg_class.oid
FROM pg_tables
JOIN pg_class ON pg_tables.tablename = pg_class.relname
WHERE tablename = 'profiles' AND schemaname = 'public';

-- Verificar políticas RLS da tabela profiles
SELECT 
    pol.polname as policy_name,
    pol.polcmd as command,
    pol.polroles,
    pol.polqual as policy_condition
FROM pg_policy pol
JOIN pg_class c ON pol.polrelid = c.oid
WHERE c.relname = 'profiles';

-- =============================================
-- RELATÓRIO FINAL
-- =============================================

SELECT '📊 RELATÓRIO FINAL DO DIAGNÓSTICO' as etapa;

SELECT 
    'Diagnóstico USER_NOT_FOUND' as problema,
    NOW() as data_diagnostico,
    (SELECT COUNT(*) FROM pg_proc WHERE proname = 'record_workout_basic') as funcoes_encontradas,
    (SELECT COUNT(*) FROM profiles) as total_profiles,
    (SELECT COUNT(*) FROM auth.users) as total_auth_users,
    (SELECT COUNT(*) FROM check_in_error_logs WHERE error_type = 'AUTH_ERROR' AND created_at >= NOW() - INTERVAL '1 day') as erros_auth_hoje; 