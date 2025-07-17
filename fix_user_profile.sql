-- Script para corrigir perfil ausente
-- Substitua EMAIL_AQUI pelo email do usuário

-- 1. Verificar se usuário existe em auth.users mas não tem perfil
WITH user_check AS (
    SELECT 
        au.id,
        au.email,
        au.raw_user_meta_data->>'name' as user_name,
        p.id as profile_exists
    FROM auth.users au
    LEFT JOIN profiles p ON au.id = p.id
    WHERE au.email = 'EMAIL_AQUI'
)
SELECT 
    CASE 
        WHEN id IS NULL THEN '❌ USUÁRIO NÃO EXISTE'
        WHEN profile_exists IS NOT NULL THEN '✅ PERFIL JÁ EXISTE'
        ELSE '⚠️ PERFIL AUSENTE - EXECUTE SCRIPT DE CORREÇÃO'
    END as status
FROM user_check;

-- 2. Script para criar perfil ausente
-- Execute APENAS se o status acima foi "PERFIL AUSENTE"
INSERT INTO profiles (
    id,
    email,
    name,
    level,
    status,
    created_at,
    updated_at
)
SELECT 
    au.id,
    au.email,
    COALESCE(
        au.raw_user_meta_data->>'name', 
        au.raw_user_meta_data->>'full_name',
        split_part(au.email, '@', 1)
    ) as name,
    'basic' as level,
    'active' as status,
    NOW() as created_at,
    NOW() as updated_at
FROM auth.users au
WHERE au.email = 'EMAIL_AQUI'
AND NOT EXISTS (
    SELECT 1 FROM profiles p WHERE p.id = au.id
);

-- 3. Verificação final
SELECT 
    'VERIFICAÇÃO FINAL' as etapa,
    au.email,
    au.id as auth_id,
    p.id as profile_id,
    p.name as profile_name,
    CASE 
        WHEN p.id IS NOT NULL THEN '✅ PERFIL CRIADO COM SUCESSO'
        ELSE '❌ FALHA NA CRIAÇÃO DO PERFIL'
    END as resultado
FROM auth.users au
LEFT JOIN profiles p ON au.id = p.id
WHERE au.email = 'EMAIL_AQUI'; 