-- ========================================
-- DEBUG: POR QUE USUÁRIOS BASIC AINDA VEEM VÍDEOS?
-- ========================================

-- 1. VERIFICAR SE RLS ESTÁ HABILITADO
SELECT 
    '=== STATUS RLS ===' as debug_step,
    schemaname,
    tablename,
    rowsecurity as rls_habilitado,
    forcerowsecurity as rls_forcado
FROM pg_tables 
WHERE tablename = 'workout_videos';

-- 2. VERIFICAR POLÍTICAS ATIVAS
SELECT 
    '=== POLÍTICAS ATIVAS ===' as debug_step,
    policyname,
    permissive,
    cmd,
    qual
FROM pg_policies 
WHERE tablename = 'workout_videos';

-- 3. TESTAR A POLÍTICA MANUALMENTE
SELECT 
    '=== TESTE MANUAL DA POLÍTICA ===' as debug_step;

-- Simular a condição da política para usuários basic
WITH test_basic AS (
    SELECT user_id 
    FROM user_progress_level 
    WHERE current_level = 'basic' 
    LIMIT 1
)
SELECT 
    tb.user_id,
    'basic' as nivel,
    EXISTS (
        SELECT 1 
        FROM user_progress_level upl
        WHERE upl.user_id = tb.user_id
          AND upl.current_level = 'expert'
          AND (upl.level_expires_at IS NULL OR upl.level_expires_at > NOW())
    ) as politica_permite,
    'Deveria ser FALSE para usuários basic' as esperado
FROM test_basic tb;

-- Simular a condição da política para usuários expert
WITH test_expert AS (
    SELECT user_id 
    FROM user_progress_level 
    WHERE current_level = 'expert' 
    LIMIT 1
)
SELECT 
    te.user_id,
    'expert' as nivel,
    EXISTS (
        SELECT 1 
        FROM user_progress_level upl
        WHERE upl.user_id = te.user_id
          AND upl.current_level = 'expert'
          AND (upl.level_expires_at IS NULL OR upl.level_expires_at > NOW())
    ) as politica_permite,
    'Deveria ser TRUE para usuários expert' as esperado
FROM test_expert te;

-- 4. VERIFICAR SE HÁ OUTRAS POLÍTICAS CONFLITANTES
SELECT 
    '=== BUSCAR POLÍTICAS CONFLITANTES ===' as debug_step;

-- Verificar se há políticas em outras tabelas que podem afetar
SELECT 
    schemaname,
    tablename,
    policyname,
    cmd
FROM pg_policies 
WHERE schemaname = 'public'
  AND (policyname ILIKE '%video%' OR tablename ILIKE '%video%')
ORDER BY tablename, policyname;

-- 5. FORÇAR DESABILITAÇÃO E REABILITAÇÃO DO RLS
SELECT 
    '=== RESETANDO RLS ===' as debug_step;

-- Desabilitar temporariamente
ALTER TABLE workout_videos DISABLE ROW LEVEL SECURITY;

-- Remover todas as políticas
DROP POLICY IF EXISTS "Auto: Apenas experts veem vídeos" ON workout_videos;
DROP POLICY IF EXISTS "Apenas experts podem ver vídeos" ON workout_videos;
DROP POLICY IF EXISTS "Controle de acesso aos vídeos dos parceiros" ON workout_videos;
DROP POLICY IF EXISTS "Usuários não autenticados veem apenas vídeos públicos" ON workout_videos;
DROP POLICY IF EXISTS "Vídeos são públicos" ON workout_videos;

-- Reabilitar RLS
ALTER TABLE workout_videos ENABLE ROW LEVEL SECURITY;

-- 6. CRIAR POLÍTICA MAIS RESTRITIVA
CREATE POLICY "RLS_STRICT: Apenas experts autenticados" ON workout_videos
    FOR SELECT USING (
        -- Usuário deve estar autenticado E ser expert
        auth.uid() IS NOT NULL
        AND 
        EXISTS (
            SELECT 1 
            FROM user_progress_level upl
            WHERE upl.user_id = auth.uid()
              AND upl.current_level = 'expert'
              AND (upl.level_expires_at IS NULL OR upl.level_expires_at > NOW())
        )
    );

-- 7. VERIFICAR A NOVA POLÍTICA
SELECT 
    '=== NOVA POLÍTICA CRIADA ===' as debug_step,
    policyname,
    cmd,
    qual
FROM pg_policies 
WHERE tablename = 'workout_videos';

-- 8. TESTE FINAL COM FUNÇÃO
CREATE OR REPLACE FUNCTION test_final_rls(test_user_id UUID)
RETURNS JSON AS $$
DECLARE
    result JSON;
    user_level TEXT;
    expires_at TIMESTAMP;
    policy_would_allow BOOLEAN;
BEGIN
    -- Buscar dados do usuário
    SELECT current_level, level_expires_at
    INTO user_level, expires_at
    FROM user_progress_level
    WHERE user_id = test_user_id;
    
    -- Simular a nova política
    policy_would_allow := (
        test_user_id IS NOT NULL
        AND 
        EXISTS (
            SELECT 1 
            FROM user_progress_level upl
            WHERE upl.user_id = test_user_id
              AND upl.current_level = 'expert'
              AND (upl.level_expires_at IS NULL OR upl.level_expires_at > NOW())
        )
    );
    
    result := json_build_object(
        'user_id', test_user_id,
        'user_level', COALESCE(user_level, 'not_found'),
        'level_expires_at', expires_at,
        'policy_allows', policy_would_allow,
        'expected_result', CASE 
            WHEN user_level = 'expert' AND (expires_at IS NULL OR expires_at > NOW()) THEN 'DEVE VER VÍDEOS'
            ELSE 'NÃO DEVE VER VÍDEOS'
        END,
        'is_correct', CASE 
            WHEN user_level = 'expert' AND (expires_at IS NULL OR expires_at > NOW()) AND policy_would_allow THEN '✅ CORRETO'
            WHEN user_level != 'expert' AND NOT policy_would_allow THEN '✅ CORRETO'
            ELSE '❌ ERRO - POLÍTICA NÃO ESTÁ FUNCIONANDO'
        END
    );
    
    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 9. TESTAR COM USUÁRIOS REAIS
SELECT 
    '=== TESTE FINAL - USUÁRIOS EXPERT ===' as debug_step;

SELECT test_final_rls(user_id) as resultado
FROM user_progress_level 
WHERE current_level = 'expert' 
LIMIT 2;

SELECT 
    '=== TESTE FINAL - USUÁRIOS BASIC ===' as debug_step;

SELECT test_final_rls(user_id) as resultado
FROM user_progress_level 
WHERE current_level = 'basic' 
LIMIT 2;

-- 10. COMANDO PARA TESTE NO FLUTTER
SELECT 
    '=== INSTRUÇÕES PARA TESTE ===' as debug_step;

/*
AGORA TESTE NO FLUTTER:

1. Faça logout e login como usuário BASIC
2. Execute: 
   final videos = await supabase.from('workout_videos').select();
   print('Basic user videos: ${videos.length}'); // Deve ser 0

3. Faça logout e login como usuário EXPERT  
4. Execute:
   final videos = await supabase.from('workout_videos').select();
   print('Expert user videos: ${videos.length}'); // Deve ser 40

Se ainda não funcionar, há um problema mais profundo que precisamos investigar.
*/

-- 11. VERIFICAÇÃO DE SEGURANÇA FINAL
SELECT 
    '=== STATUS FINAL DO SISTEMA ===' as debug_step;

SELECT 
    'RLS Status' as check_item,
    CASE WHEN rowsecurity THEN '✅ HABILITADO' ELSE '❌ DESABILITADO' END as status
FROM pg_tables 
WHERE tablename = 'workout_videos'
UNION ALL
SELECT 
    'Políticas Ativas',
    COUNT(*)::text || ' política(s)'
FROM pg_policies 
WHERE tablename = 'workout_videos'
UNION ALL
SELECT 
    'Total de Vídeos',
    COUNT(*)::text
FROM workout_videos; 