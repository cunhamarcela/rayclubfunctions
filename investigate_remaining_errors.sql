-- ====================================================================
-- INVESTIGAÇÃO DE ERROS USER_NOT_FOUND RESIDUAIS
-- ====================================================================

-- Investigar usuários que ainda estão falhando após a correção

SELECT '🔍 INVESTIGANDO ERROS RESIDUAIS' as titulo;

-- 1. Erros recentes por usuário
SELECT 
    '📊 Erros por usuário (últimas 2h)' as categoria,
    user_id,
    COUNT(*) as total_erros,
    MAX(created_at) as ultimo_erro,
    error_details
FROM check_in_error_logs 
WHERE error_type = 'AUTH_ERROR' 
  AND created_at >= NOW() - INTERVAL '2 hours'
GROUP BY user_id, error_details
ORDER BY total_erros DESC;

-- 2. Verificar se estes usuários existem em auth.users
WITH error_users AS (
    SELECT DISTINCT user_id
    FROM check_in_error_logs 
    WHERE error_type = 'AUTH_ERROR' 
      AND created_at >= NOW() - INTERVAL '2 hours'
)
SELECT 
    '🔍 Análise usuários com erro' as categoria,
    eu.user_id,
    CASE 
        WHEN au.id IS NOT NULL THEN '✅ Existe em auth.users'
        ELSE '❌ NÃO existe em auth.users'
    END as status_auth,
    CASE 
        WHEN p.id IS NOT NULL THEN '✅ Existe em profiles'
        ELSE '❌ NÃO existe em profiles'
    END as status_profiles,
    au.email,
    au.created_at as user_created_at
FROM error_users eu
LEFT JOIN auth.users au ON eu.user_id = au.id
LEFT JOIN profiles p ON eu.user_id = p.id
ORDER BY au.created_at DESC;

-- 3. Testar função com usuários problemáticos atuais
DO $$
DECLARE
    problematic_users UUID[];
    test_user_id UUID;
    test_result JSONB;
    success_count INTEGER := 0;
    total_count INTEGER := 0;
BEGIN
    -- Pegar os 3 usuários com mais erros recentes
    SELECT ARRAY_AGG(user_id) INTO problematic_users
    FROM (
        SELECT user_id
        FROM check_in_error_logs 
        WHERE error_type = 'AUTH_ERROR' 
          AND created_at >= NOW() - INTERVAL '2 hours'
        GROUP BY user_id
        ORDER BY COUNT(*) DESC
        LIMIT 3
    ) t;
    
    -- Testar cada usuário
    IF problematic_users IS NOT NULL THEN
        FOREACH test_user_id IN ARRAY problematic_users LOOP
            total_count := total_count + 1;
            
            SELECT record_workout_basic(
                test_user_id,
                'Teste Usuário Problemático',
                'Investigação',
                30,
                NOW(),
                NULL, NULL,
                'Teste de usuário com erros recentes',
                NULL
            ) INTO test_result;
            
            IF (test_result->>'success')::boolean THEN
                success_count := success_count + 1;
            END IF;
        END LOOP;
    END IF;
    
    -- Criar tabela para resultados
    CREATE TEMP TABLE IF NOT EXISTS temp_investigation_results (
        categoria TEXT,
        resultado TEXT,
        detalhes TEXT
    );
    
    INSERT INTO temp_investigation_results VALUES (
        'TESTE USUÁRIOS PROBLEMÁTICOS ATUAIS',
        success_count || '/' || total_count || ' sucessos',
        'Testados os 3 usuários com mais erros nas últimas 2h'
    );
END $$;

-- 4. Verificar se há problema na nossa correção
SELECT 
    '🔧 Verificação da correção' as categoria,
    COUNT(*) as total_funcoes,
    MAX(pg_get_functiondef(oid)) LIKE '%auth.users%' as usa_auth_users,
    MAX(pg_get_functiondef(oid)) LIKE '%profiles%' as ainda_usa_profiles
FROM pg_proc 
WHERE proname = 'record_workout_basic';

-- 5. Comparar auth.users vs profiles (atualizado)
WITH auth_data AS (
    SELECT COUNT(*) as total_auth_users FROM auth.users
),
profile_data AS (
    SELECT COUNT(*) as total_profiles FROM profiles
)
SELECT 
    '📊 Sincronização atual' as categoria,
    ad.total_auth_users,
    pd.total_profiles,
    (ad.total_auth_users - pd.total_profiles) as diferenca,
    CASE 
        WHEN ad.total_auth_users = pd.total_profiles THEN '✅ SINCRONIZADO'
        ELSE '⚠️ DESSINCRONIZADO'
    END as status
FROM auth_data ad, profile_data pd;

-- Mostrar resultados da investigação
SELECT * FROM temp_investigation_results WHERE categoria IS NOT NULL;

SELECT '🎯 PRÓXIMOS PASSOS' as titulo;
SELECT 'Se ainda há erros, pode ser necessário:
1. Verificar se a função foi realmente atualizada
2. Sincronizar auth.users e profiles
3. Identificar novos usuários problemáticos
4. Aplicar correção mais abrangente' as recomendacoes; 