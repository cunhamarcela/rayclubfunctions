-- Script SQL para resolver problemas comuns de login
-- Execute no Supabase SQL Editor após identificar o problema

-- SUBSTITUA O EMAIL AQUI:
\set user_email 'EMAIL_DO_USUARIO@exemplo.com'

-- ========== SOLUÇÕES PARA PROBLEMAS COMUNS ==========

-- 1. CRIAR PERFIL AUSENTE
-- Use se o diagnóstico mostrou "PERFIL AUSENTE"
DO $$
DECLARE
    user_id uuid;
    user_name text;
    user_exists boolean;
BEGIN
    -- Verificar se o usuário existe em auth.users
    SELECT EXISTS(SELECT 1 FROM auth.users WHERE email = 'EMAIL_DO_USUARIO@exemplo.com') INTO user_exists;
    
    IF NOT user_exists THEN
        RAISE NOTICE '❌ Usuário não existe em auth.users. Não é possível criar perfil.';
        RETURN;
    END IF;
    
    -- Buscar dados do usuário
    SELECT id, COALESCE(raw_user_meta_data->>'name', raw_user_meta_data->>'full_name', split_part(email, '@', 1))
    INTO user_id, user_name
    FROM auth.users 
    WHERE email = 'EMAIL_DO_USUARIO@exemplo.com';
    
    -- Verificar se já existe perfil
    IF EXISTS(SELECT 1 FROM profiles WHERE id = user_id) THEN
        RAISE NOTICE '⚠️ Perfil já existe para este usuário';
        RETURN;
    END IF;
    
    -- Criar perfil
    INSERT INTO profiles (
        id,
        email,
        name,
        level,
        status,
        created_at,
        updated_at
    ) VALUES (
        user_id,
        'EMAIL_DO_USUARIO@exemplo.com',
        COALESCE(user_name, 'Usuário'),
        'basic',
        'active',
        NOW(),
        NOW()
    );
    
    RAISE NOTICE '✅ Perfil criado com sucesso para %', 'EMAIL_DO_USUARIO@exemplo.com';
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE '❌ Erro ao criar perfil: %', SQLERRM;
END $$;

-- 2. REENVIAR EMAIL DE CONFIRMAÇÃO
-- Use se o diagnóstico mostrou "EMAIL NÃO CONFIRMADO"
-- NOTA: Isso deve ser feito via app ou Supabase Dashboard, não SQL
SELECT 
    'Para reenviar email de confirmação:' as instrucao,
    '1. Vá para Supabase Dashboard > Authentication > Users' as passo_1,
    '2. Encontre o usuário e clique em "Send confirmation email"' as passo_2,
    'OU use a função auth.resetPasswordForEmail() via API' as alternativa;

-- 3. VERIFICAR/CORRIGIR DADOS DO USUÁRIO
-- Mostra os dados atuais e permite verificar inconsistências
WITH user_data AS (
    SELECT 
        au.id,
        au.email,
        au.email_confirmed_at,
        au.raw_app_meta_data->>'provider' as provider,
        au.raw_user_meta_data->>'name' as auth_name,
        au.created_at as auth_created,
        p.name as profile_name,
        p.level as profile_level,
        p.status as profile_status,
        p.created_at as profile_created
    FROM auth.users au
    LEFT JOIN profiles p ON au.id = p.id
    WHERE au.email = 'EMAIL_DO_USUARIO@exemplo.com'
)
SELECT 
    'DADOS_ATUAIS' as categoria,
    json_build_object(
        'user_id', id,
        'email', email,
        'email_confirmed', (email_confirmed_at IS NOT NULL),
        'provider', provider,
        'auth_name', auth_name,
        'profile_name', profile_name,
        'profile_level', profile_level,
        'profile_status', profile_status,
        'auth_created', auth_created,
        'profile_created', profile_created
    ) as dados_completos
FROM user_data;

-- 4. SCRIPT PARA CASOS OAUTH (Google/Apple)
-- Verifica se usuário está tentando usar senha em conta OAuth
WITH oauth_check AS (
    SELECT 
        email,
        raw_app_meta_data->>'provider' as provider,
        CASE 
            WHEN raw_app_meta_data->>'provider' IN ('google', 'apple') THEN true
            ELSE false
        END as is_oauth_account
    FROM auth.users
    WHERE email = 'EMAIL_DO_USUARIO@exemplo.com'
)
SELECT 
    CASE 
        WHEN is_oauth_account THEN '⚠️ ESTA É UMA CONTA ' || UPPER(provider)
        ELSE '✅ Esta é uma conta de email/senha normal'
    END as tipo_conta,
    CASE 
        WHEN is_oauth_account THEN 'Usuário deve usar o botão "Entrar com ' || provider || '"'
        ELSE 'Usuário pode usar email e senha'
    END as instrucoes_para_usuario
FROM oauth_check;

-- 5. SCRIPT DE LIMPEZA (USE COM CUIDADO!)
-- Apenas se você quiser remover completamente a conta para recriação
/*
ATENÇÃO: Este script remove PERMANENTEMENTE a conta do usuário!
Use apenas se outras soluções falharam e você tem certeza.

Para executar, descomente as linhas abaixo:

DELETE FROM profiles WHERE email = 'EMAIL_DO_USUARIO@exemplo.com';
-- NOTA: Não é possível deletar de auth.users via SQL por segurança
-- Para deletar auth.users, use o Supabase Dashboard > Authentication > Users
*/

-- 6. VERIFICAÇÃO FINAL
-- Execute após aplicar qualquer correção
SELECT 
    'VERIFICAÇÃO_FINAL' as etapa,
    CASE 
        WHEN au.id IS NULL THEN '❌ Usuário não existe em auth.users'
        WHEN au.email_confirmed_at IS NULL THEN '⚠️ Email ainda não confirmado'
        WHEN p.id IS NULL THEN '⚠️ Perfil ainda ausente'
        WHEN au.raw_app_meta_data->>'provider' IN ('google', 'apple') THEN 
            '✅ Conta OAuth - instruir uso do botão ' || (au.raw_app_meta_data->>'provider')
        ELSE '✅ Conta está configurada corretamente'
    END as status_final,
    COALESCE(
        'Auth: ' || au.id::text || ' | Profile: ' || COALESCE(p.id::text, 'NULL') || 
        ' | Provider: ' || COALESCE(au.raw_app_meta_data->>'provider', 'email'),
        'Usuário não encontrado'
    ) as detalhes
FROM auth.users au
LEFT JOIN profiles p ON au.id = p.id
WHERE au.email = 'EMAIL_DO_USUARIO@exemplo.com';

-- ========== INSTRUÇÕES DE USO ==========

/*
COMO USAR ESTE SCRIPT:

1. Primeiro execute o diagnóstico (quick_login_diagnosis.sql)
2. Identifique o problema específico
3. Substitua 'EMAIL_DO_USUARIO@exemplo.com' pelo email real
4. Execute a seção apropriada deste script:

   - Para PERFIL AUSENTE: Execute a seção 1
   - Para EMAIL NÃO CONFIRMADO: Siga instruções da seção 2
   - Para CONTA OAUTH: Informe o usuário conforme seção 4

5. Execute a VERIFICAÇÃO FINAL (seção 6) para confirmar a correção

CASOS ESPECÍFICOS:

A) Usuário existe em auth.users mas não tem perfil:
   → Execute seção 1 (CRIAR PERFIL AUSENTE)

B) Usuário tem conta Google/Apple mas tenta usar senha:
   → Instrua para usar o botão correto (seção 4)

C) Email não foi confirmado:
   → Reenvie confirmação via Dashboard (seção 2)

D) Usuário não existe em auth.users:
   → Não há como corrigir via SQL, usuário deve se cadastrar novamente

E) Tudo parece OK mas ainda não funciona:
   → Verificar logs do app, pode ser problema de código/configuração
*/ 