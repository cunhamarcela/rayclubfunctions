-- Script SQL para diagnóstico rápido de problemas de login
-- Execute no Supabase SQL Editor substituindo 'EMAIL_DO_USUARIO' pelo email real

-- SUBSTITUA O EMAIL AQUI:
\set user_email 'EMAIL_DO_USUARIO@exemplo.com'

-- ========== DIAGNÓSTICO RÁPIDO ==========

-- 1. Verificar se existe na tabela auth.users
SELECT 
    'AUTH.USERS' as tabela,
    CASE 
        WHEN COUNT(*) > 0 THEN '✅ EXISTE'
        ELSE '❌ NÃO EXISTE'
    END as status,
    COALESCE(string_agg(
        'ID: ' || id::text || 
        ' | Email: ' || email || 
        ' | Confirmado: ' || COALESCE(email_confirmed_at::text, 'NÃO') ||
        ' | Provider: ' || COALESCE(raw_app_meta_data->>'provider', 'email') ||
        ' | Criado: ' || created_at::text
    , '; '), 'Nenhum registro encontrado') as detalhes
FROM auth.users 
WHERE email = :'user_email';

-- 2. Verificar se existe na tabela profiles
SELECT 
    'PROFILES' as tabela,
    CASE 
        WHEN COUNT(*) > 0 THEN '✅ EXISTE'
        ELSE '❌ NÃO EXISTE'
    END as status,
    COALESCE(string_agg(
        'ID: ' || id::text || 
        ' | Nome: ' || COALESCE(name, 'NULL') || 
        ' | Level: ' || COALESCE(level, 'NULL') ||
        ' | Status: ' || COALESCE(status, 'NULL') ||
        ' | Criado: ' || created_at::text
    , '; '), 'Nenhum registro encontrado') as detalhes
FROM profiles 
WHERE email = :'user_email';

-- 3. Verificar problemas comuns
WITH user_analysis AS (
    SELECT 
        au.email,
        au.id as auth_id,
        au.email_confirmed_at,
        au.raw_app_meta_data->>'provider' as provider,
        p.id as profile_id,
        p.name as profile_name,
        p.level as profile_level
    FROM auth.users au
    LEFT JOIN profiles p ON au.email = p.email
    WHERE au.email = :'user_email'
)
SELECT 
    'DIAGNÓSTICO' as categoria,
    CASE 
        WHEN auth_id IS NULL THEN '❌ USUÁRIO NÃO EXISTE NO AUTH'
        WHEN email_confirmed_at IS NULL THEN '⚠️ EMAIL NÃO CONFIRMADO'
        WHEN profile_id IS NULL THEN '⚠️ PERFIL AUSENTE'
        WHEN provider IN ('google', 'apple') THEN '⚠️ CONTA OAUTH - USE BOTÃO GOOGLE/APPLE'
        ELSE '✅ CONTA APARENTA ESTAR OK'
    END as problema_identificado,
    CASE 
        WHEN auth_id IS NULL THEN 'Usuário deve se cadastrar novamente'
        WHEN email_confirmed_at IS NULL THEN 'Reenviar email de confirmação'
        WHEN profile_id IS NULL THEN 'Criar perfil manualmente'
        WHEN provider IN ('google', 'apple') THEN 'Instruir usuário a usar login com ' || provider
        ELSE 'Verificar se a senha está correta'
    END as solucao_recomendada,
    COALESCE(
        'Auth ID: ' || auth_id::text || 
        ' | Profile ID: ' || COALESCE(profile_id::text, 'NULL') ||
        ' | Provider: ' || COALESCE(provider, 'email') ||
        ' | Confirmado: ' || COALESCE(email_confirmed_at::text, 'NÃO')
    , 'Nenhum dado encontrado') as detalhes_tecnicos
FROM user_analysis;

-- 4. Query para casos específicos - Usuários OAuth tentando login com senha
SELECT 
    'CONFLITO_OAUTH' as tipo_problema,
    COUNT(*) as quantidade_casos,
    string_agg(
        email || ' (Provider: ' || (raw_app_meta_data->>'provider') || ')'
    , '; ') as usuarios_afetados
FROM auth.users 
WHERE email = :'user_email'
AND raw_app_meta_data->>'provider' IN ('google', 'apple');

-- 5. Últimas tentativas de login (se houver logs)
SELECT 
    'HISTÓRICO_LOGIN' as categoria,
    'Último login: ' || COALESCE(last_sign_in_at::text, 'NUNCA') ||
    ' | Confirm. sent: ' || COALESCE(confirmation_sent_at::text, 'NUNCA') ||
    ' | Recovery sent: ' || COALESCE(recovery_sent_at::text, 'NUNCA') as informacoes
FROM auth.users 
WHERE email = :'user_email';

-- ========== INSTRUÇÕES DE USO ==========

/*
COMO USAR ESTE SCRIPT:

1. Substitua 'EMAIL_DO_USUARIO@exemplo.com' na linha 5 pelo email real do usuário
2. Execute todo o script no Supabase SQL Editor
3. Analise os resultados:

   - AUTH.USERS: Se "NÃO EXISTE", o usuário deve se cadastrar novamente
   - PROFILES: Se "NÃO EXISTE" mas AUTH.USERS existe, criar perfil manualmente
   - DIAGNÓSTICO: Mostra o problema principal e a solução recomendada
   - CONFLITO_OAUTH: Se retornar dados, usuário deve usar botão Google/Apple
   - HISTÓRICO_LOGIN: Mostra quando foi o último acesso

PROBLEMAS MAIS COMUNS:

1. "USUÁRIO NÃO EXISTE NO AUTH"
   → Solução: Usuário deve se cadastrar novamente

2. "EMAIL NÃO CONFIRMADO"
   → Solução: Reenviar email de confirmação

3. "PERFIL AUSENTE"
   → Solução: Executar script para criar perfil manualmente

4. "CONTA OAUTH - USE BOTÃO GOOGLE/APPLE"
   → Solução: Instruir usuário a usar o botão correto

5. Se tudo estiver OK mas ainda não consegue entrar:
   → Verificar se a senha está correta
   → Verificar se há problemas de RLS/permissões
   → Verificar logs do app para erros específicos
*/ 