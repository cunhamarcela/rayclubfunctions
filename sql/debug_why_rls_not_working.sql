-- Diagnóstico: Por que usuários basic ainda veem vídeos com RLS ativo?

-- 1. REATIVAR RLS primeiro
ALTER TABLE workout_videos ENABLE ROW LEVEL SECURITY;

-- 2. RECRIAR a política restritiva
CREATE POLICY "Debug: Apenas experts veem vídeos"
ON workout_videos
FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 
        FROM user_progress_level upl
        WHERE upl.user_id = auth.uid() 
        AND upl.current_level = 'expert'
        AND (upl.level_expires_at IS NULL OR upl.level_expires_at > now())
    )
);

-- 3. VERIFICAR se RLS está realmente ativo
SELECT 
    schemaname,
    tablename,
    rowsecurity as rls_ativo,
    pg_get_userbyid(relowner) as table_owner
FROM pg_tables pt
JOIN pg_class pc ON pc.relname = pt.tablename
WHERE schemaname = 'public' 
AND tablename = 'workout_videos';

-- 4. VERIFICAR todas as políticas ativas
SELECT 
    schemaname,
    tablename,
    policyname,
    cmd,
    permissive,
    roles,
    qual
FROM pg_policies 
WHERE tablename = 'workout_videos';

-- 5. TESTAR função auth.uid() - pode estar retornando NULL
SELECT 
    'Teste auth.uid():' as teste,
    auth.uid() as user_id,
    CASE 
        WHEN auth.uid() IS NULL THEN 'PROBLEMA: auth.uid() é NULL!'
        ELSE 'OK: auth.uid() funciona'
    END as status;

-- 6. VERIFICAR se existem usuários na tabela user_progress_level
SELECT 
    'Total usuários com nível:' as info,
    COUNT(*) as total
FROM user_progress_level;

SELECT 
    'Usuários por nível:' as info,
    current_level,
    COUNT(*) as total
FROM user_progress_level
GROUP BY current_level;

-- 7. TESTAR a lógica da política manualmente
-- Se auth.uid() funcionar, isso deve retornar true/false
SELECT 
    'Teste lógica da política:' as teste,
    EXISTS (
        SELECT 1 
        FROM user_progress_level upl
        WHERE upl.user_id = auth.uid() 
        AND upl.current_level = 'expert'
        AND (upl.level_expires_at IS NULL OR upl.level_expires_at > now())
    ) as usuario_eh_expert;

-- 8. VERIFICAR se há roles/permissions que podem estar causando bypass
SELECT 
    'Current user:' as info,
    current_user as user_name,
    session_user as session_user;

-- 9. VERIFICAR configurações específicas do Supabase
SELECT 
    'Supabase auth settings:' as info,
    rolname,
    rolsuper,
    rolcreaterole,
    rolcreatedb
FROM pg_roles 
WHERE rolname IN ('authenticated', 'anon', 'service_role');

-- 10. CRIAR função de teste que simula o Flutter
CREATE OR REPLACE FUNCTION test_video_access_from_flutter()
RETURNS TABLE(
    scenario TEXT,
    auth_user_id UUID,
    user_level TEXT,
    video_count BIGINT,
    should_see_videos TEXT
) AS $$
BEGIN
    -- Teste só funciona se auth.uid() retornar algo
    IF auth.uid() IS NULL THEN
        RETURN QUERY SELECT 
            'ERRO: auth.uid() é NULL'::TEXT,
            NULL::UUID,
            'N/A'::TEXT,
            0::BIGINT,
            'Requisição não autenticada'::TEXT;
        RETURN;
    END IF;
    
    -- Buscar dados do usuário atual
    RETURN QUERY
    SELECT 
        'Usuário atual'::TEXT as scenario,
        auth.uid() as auth_user_id,
        COALESCE(upl.current_level, 'SEM NÍVEL') as user_level,
        (SELECT COUNT(*) FROM workout_videos) as video_count,
        CASE 
            WHEN upl.current_level = 'expert' THEN 'SIM - deve ver todos'
            WHEN upl.current_level = 'basic' THEN 'NÃO - deve ver 0 com RLS'
            ELSE 'INDEFINIDO'
        END as should_see_videos
    FROM user_progress_level upl
    WHERE upl.user_id = auth.uid();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 11. EXECUTAR teste (só funciona com usuário autenticado)
SELECT * FROM test_video_access_from_flutter();

-- 12. INSTRUÇÕES para teste no Flutter
SELECT 'PRÓXIMOS PASSOS:' as instrucoes;
SELECT '1. Execute este script no Supabase SQL Editor' as passo1;
SELECT '2. Faça login no Flutter com usuário BASIC' as passo2;
SELECT '3. Chame: supabase.from("workout_videos").select().count()' as passo3;
SELECT '4. Se retornar > 0, RLS não está funcionando' as passo4;
SELECT '5. Se retornar 0, RLS está funcionando corretamente' as passo5; 