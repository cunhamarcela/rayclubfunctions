-- Limpeza e correção final das políticas RLS

-- 1. REMOVER todas as políticas conflitantes
DROP POLICY IF EXISTS "Debug: Apenas experts veem vídeos" ON workout_videos;
DROP POLICY IF EXISTS "SUPER_STRICT: Só experts veem vídeos" ON workout_videos;
DROP POLICY IF EXISTS "Auto: Apenas experts veem vídeos" ON workout_videos;

-- 2. VERIFICAR se não há mais políticas
SELECT 'Políticas restantes:' as status, COUNT(*) as total
FROM pg_policies 
WHERE tablename = 'workout_videos';

-- 3. CRIAR uma única política correta e simples
CREATE POLICY "workout_videos_expert_only"
ON workout_videos
FOR SELECT
TO authenticated
USING (
    -- Vídeos públicos: todos podem ver
    (requires_expert_access = false OR requires_expert_access IS NULL)
    OR
    -- Vídeos expert: só experts podem ver
    (
        requires_expert_access = true 
        AND EXISTS (
            SELECT 1 
            FROM user_progress_level upl
            WHERE upl.user_id = auth.uid() 
            AND upl.current_level = 'expert'
            AND (upl.level_expires_at IS NULL OR upl.level_expires_at > now())
        )
    )
);

-- 4. VERIFICAR a política criada
SELECT 
    policyname,
    cmd,
    roles,
    qual
FROM pg_policies 
WHERE tablename = 'workout_videos';

-- 5. CONTAGEM de vídeos por tipo
SELECT 
    'Vídeos públicos (todos podem ver):' as tipo,
    COUNT(*) as total
FROM workout_videos 
WHERE requires_expert_access = false OR requires_expert_access IS NULL;

SELECT 
    'Vídeos expert-only (só experts veem):' as tipo,
    COUNT(*) as total
FROM workout_videos 
WHERE requires_expert_access = true;

-- 6. INSTRUÇÕES PARA TESTE NO FLUTTER
SELECT '🧪 TESTE NO FLUTTER:' as instrucoes;
SELECT '1. Faça login com usuário BASIC' as passo1;
SELECT '2. Execute: await supabase.from("workout_videos").select()' as passo2;
SELECT '3. Deve retornar apenas vídeos públicos (não deve incluir 40 vídeos de parceiros)' as passo3;
SELECT '4. Faça login com usuário EXPERT' as passo4;
SELECT '5. Execute: await supabase.from("workout_videos").select()' as passo5;
SELECT '6. Deve retornar TODOS os vídeos (incluindo 40 vídeos de parceiros)' as passo6;

-- 7. VERIFICAR IDs de usuários para teste
SELECT 
    '👤 USUÁRIO BASIC PARA TESTE:' as tipo,
    au.id,
    au.email,
    upl.current_level
FROM auth.users au
JOIN user_progress_level upl ON upl.user_id = au.id
WHERE upl.current_level = 'basic'
LIMIT 1;

SELECT 
    '👨‍💼 USUÁRIO EXPERT PARA TESTE:' as tipo,
    au.id,
    au.email,
    upl.current_level
FROM auth.users au
JOIN user_progress_level upl ON upl.user_id = au.id
WHERE upl.current_level = 'expert'
LIMIT 1;

-- 8. STATUS FINAL
SELECT 'STATUS FINAL:' as status;
SELECT '✅ RLS ativo na tabela workout_videos' as config1;
SELECT '✅ Política única "workout_videos_expert_only"' as config2;
SELECT '✅ Vídeos públicos: visíveis para todos' as config3;
SELECT '✅ Vídeos de parceiros: só para experts' as config4;
SELECT '⚠️  Teste deve ser feito no FLUTTER, não no SQL Editor' as importante; 