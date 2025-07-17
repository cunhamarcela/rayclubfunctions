-- ========================================
-- DEBUG: POR QUE USUÁRIOS BASIC AINDA VEEM VÍDEOS? - CORRIGIDO
-- ========================================

-- 1. VERIFICAR SE RLS ESTÁ HABILITADO (CORRIGIDO)
SELECT 
    '=== STATUS RLS ===' as debug_step,
    schemaname,
    tablename,
    rowsecurity as rls_habilitado
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

-- 3. FORÇAR RESET COMPLETO DO RLS
-- Desabilitar temporariamente
ALTER TABLE workout_videos DISABLE ROW LEVEL SECURITY;

-- Remover TODAS as políticas existentes
DROP POLICY IF EXISTS "Auto: Apenas experts veem vídeos" ON workout_videos;
DROP POLICY IF EXISTS "RLS_STRICT: Apenas experts autenticados" ON workout_videos;
DROP POLICY IF EXISTS "Apenas experts podem ver vídeos" ON workout_videos;
DROP POLICY IF EXISTS "Controle de acesso aos vídeos dos parceiros" ON workout_videos;
DROP POLICY IF EXISTS "Usuários não autenticados veem apenas vídeos públicos" ON workout_videos;
DROP POLICY IF EXISTS "Vídeos são públicos" ON workout_videos;

-- Verificar se políticas foram removidas
SELECT 
    '=== POLÍTICAS APÓS REMOÇÃO ===' as debug_step,
    COUNT(*) as politicas_restantes
FROM pg_policies 
WHERE tablename = 'workout_videos';

-- Reabilitar RLS
ALTER TABLE workout_videos ENABLE ROW LEVEL SECURITY;

-- 4. CRIAR POLÍTICA SUPER RESTRITIVA
CREATE POLICY "SUPER_STRICT: Só experts veem vídeos" ON workout_videos
    FOR ALL USING (
        -- Condições mais restritivas
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

-- 5. VERIFICAR A NOVA POLÍTICA
SELECT 
    '=== NOVA POLÍTICA SUPER RESTRITIVA ===' as debug_step,
    policyname,
    cmd,
    qual
FROM pg_policies 
WHERE tablename = 'workout_videos';

-- 6. TESTE MANUAL DA POLÍTICA
-- Pegar um usuário basic para testar
WITH test_basic AS (
    SELECT user_id, current_level
    FROM user_progress_level 
    WHERE current_level = 'basic' 
    LIMIT 1
)
SELECT 
    '=== TESTE USUÁRIO BASIC ===' as debug_step,
    tb.user_id,
    tb.current_level,
    EXISTS (
        SELECT 1 
        FROM user_progress_level upl
        WHERE upl.user_id = tb.user_id
          AND upl.current_level = 'expert'
          AND (upl.level_expires_at IS NULL OR upl.level_expires_at > NOW())
    ) as politica_permitiria,
    'FALSE = CORRETO (basic não deve ver)' as esperado
FROM test_basic tb;

-- Pegar um usuário expert para testar
WITH test_expert AS (
    SELECT user_id, current_level
    FROM user_progress_level 
    WHERE current_level = 'expert' 
    LIMIT 1
)
SELECT 
    '=== TESTE USUÁRIO EXPERT ===' as debug_step,
    te.user_id,
    te.current_level,
    EXISTS (
        SELECT 1 
        FROM user_progress_level upl
        WHERE upl.user_id = te.user_id
          AND upl.current_level = 'expert'
          AND (upl.level_expires_at IS NULL OR upl.level_expires_at > NOW())
    ) as politica_permitiria,
    'TRUE = CORRETO (expert deve ver)' as esperado
FROM test_expert te;

-- 7. STATUS FINAL
SELECT 
    '=== STATUS FINAL ===' as debug_step,
    'RLS Habilitado' as item,
    CASE WHEN rowsecurity THEN '✅ SIM' ELSE '❌ NÃO' END as status
FROM pg_tables 
WHERE tablename = 'workout_videos'
UNION ALL
SELECT 
    '=== STATUS FINAL ===',
    'Políticas Ativas',
    COUNT(*)::text
FROM pg_policies 
WHERE tablename = 'workout_videos'
UNION ALL
SELECT 
    '=== STATUS FINAL ===',
    'Total Vídeos',
    COUNT(*)::text
FROM workout_videos;

-- 8. USER_IDS PARA TESTE NO FLUTTER
SELECT 
    '=== TESTE NO FLUTTER ===' as debug_step,
    'BASIC - Deve ver 0 vídeos' as tipo,
    user_id
FROM user_progress_level 
WHERE current_level = 'basic' 
LIMIT 2;

SELECT 
    '=== TESTE NO FLUTTER ===',
    'EXPERT - Deve ver todos os vídeos' as tipo,
    user_id
FROM user_progress_level 
WHERE current_level = 'expert' 
LIMIT 2; 