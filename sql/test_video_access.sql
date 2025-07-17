-- Script para testar controle de acesso aos vídeos
-- Execute no SQL Editor após executar fix_video_access_control.sql

-- 1. Verificar se RLS foi desabilitado
SELECT 
    'Status RLS:' as check_type,
    tablename,
    rowsecurity as rls_ativo
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename = 'workout_videos';

-- 2. Verificar se todos os vídeos são visíveis agora
SELECT 
    'Total vídeos visíveis:' as check_type,
    COUNT(*) as total
FROM workout_videos;

-- 3. Verificar divisão expert vs público
SELECT 
    CASE 
        WHEN requires_expert_access = true THEN 'Vídeos Expert-only'
        ELSE 'Vídeos Públicos'
    END as tipo_video,
    COUNT(*) as quantidade
FROM workout_videos
GROUP BY requires_expert_access
ORDER BY requires_expert_access DESC;

-- 4. Testar função de verificação de acesso (sem auth)
-- Essa consulta simula o comportamento para diferentes tipos de vídeo
SELECT 
    'Simulação de acesso:' as teste,
    id,
    title,
    requires_expert_access,
    CASE 
        WHEN requires_expert_access = true THEN 'Precisa ser expert'
        ELSE 'Todos podem acessar'
    END as regra_acesso
FROM workout_videos
ORDER BY requires_expert_access DESC, title
LIMIT 10;

-- 5. Verificar se as funções foram criadas
SELECT 
    'Funções criadas:' as check_type,
    proname as function_name
FROM pg_proc 
WHERE proname IN ('can_access_video_link', 'get_videos_with_access_info');

-- 6. Listar vídeos de parceiros (que requerem expert)
SELECT 
    'Vídeos de Parceiros (Expert-only):' as tipo,
    instructor_name,
    COUNT(*) as quantidade
FROM workout_videos
WHERE requires_expert_access = true
GROUP BY instructor_name
ORDER BY quantidade DESC;

SELECT 'RESULTADO ESPERADO:' as resultado;
SELECT '✅ Todos os usuários veem TODOS os vídeos na lista' as expectativa1;
SELECT '✅ Usuários BASIC não conseguem acessar links de vídeos expert' as expectativa2;
SELECT '✅ Usuários EXPERT conseguem acessar todos os links' as expectativa3; 