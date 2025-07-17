-- Script para verificar níveis de usuários específicos
-- Execute no SQL Editor do Supabase

-- 1. Verificar alguns usuários básicos
SELECT 
    au.email,
    upl.current_level,
    upl.level_expires_at,
    CASE 
        WHEN upl.current_level = 'expert' AND (upl.level_expires_at IS NULL OR upl.level_expires_at > now()) 
        THEN 'DEVE VER VÍDEOS' 
        ELSE 'NÃO DEVE VER VÍDEOS' 
    END as video_access
FROM auth.users au
LEFT JOIN user_progress_level upl ON upl.user_id = au.id
WHERE upl.current_level = 'basic'
LIMIT 5;

-- 2. Verificar alguns usuários expert
SELECT 
    au.email,
    upl.current_level,
    upl.level_expires_at,
    CASE 
        WHEN upl.current_level = 'expert' AND (upl.level_expires_at IS NULL OR upl.level_expires_at > now()) 
        THEN 'DEVE VER VÍDEOS' 
        ELSE 'NÃO DEVE VER VÍDEOS' 
    END as video_access
FROM auth.users au
LEFT JOIN user_progress_level upl ON upl.user_id = au.id
WHERE upl.current_level = 'expert'
LIMIT 5;

-- 3. Contar vídeos que devem ser visíveis para experts
SELECT 
    'Vídeos parceiros (expert-only)' as tipo,
    COUNT(*) as total
FROM workout_videos 
WHERE requires_expert_access = true;

SELECT 
    'Vídeos públicos' as tipo,
    COUNT(*) as total
FROM workout_videos 
WHERE requires_expert_access = false OR requires_expert_access IS NULL;

-- 4. IDs específicos para testar no Flutter:
SELECT 
    'USUÁRIO BÁSICO PARA TESTE:' as tipo,
    au.id as user_id,
    au.email
FROM auth.users au
JOIN user_progress_level upl ON upl.user_id = au.id
WHERE upl.current_level = 'basic'
LIMIT 1;

SELECT 
    'USUÁRIO EXPERT PARA TESTE:' as tipo,
    au.id as user_id,
    au.email
FROM auth.users au
JOIN user_progress_level upl ON upl.user_id = au.id
WHERE upl.current_level = 'expert'
LIMIT 1; 