-- Debug: Por que usuário basic ainda vê todos os vídeos?

-- 1. VERIFICAR se a view foi criada corretamente
SELECT 
    'VERIFICAÇÃO DA VIEW:' as debug_step;

SELECT 
    table_name,
    table_type
FROM information_schema.tables 
WHERE table_name IN ('workout_videos', 'workout_videos_raw')
ORDER BY table_name;

-- 2. VERIFICAR se há dados na view (sem autenticação)
SELECT 
    'Contagem na view (sem auth):' as teste,
    COUNT(*) as total
FROM workout_videos;

-- 3. VERIFICAR se há dados na tabela raw
SELECT 
    'Contagem na tabela raw:' as teste,
    COUNT(*) as total
FROM workout_videos_raw;

-- 4. TESTAR a lógica de filtragem manualmente
SELECT 
    'TESTE DE FILTRAGEM MANUAL:' as debug_step;

-- Simular usuário sem autenticação (auth.uid() = NULL)
SELECT 
    'Vídeos que usuário SEM AUTH deveria ver:' as teste,
    COUNT(*) as total
FROM workout_videos_raw wv
WHERE 
    -- Só vídeos públicos quando não há autenticação
    (wv.requires_expert_access = false OR wv.requires_expert_access IS NULL);

-- 5. VERIFICAR se todos os vídeos são expert-only
SELECT 
    'ANÁLISE DOS VÍDEOS:' as debug_step;

SELECT 
    requires_expert_access,
    COUNT(*) as total_videos
FROM workout_videos_raw
GROUP BY requires_expert_access;

-- 6. PROBLEMA PROVÁVEL: Se todos os vídeos são expert-only E auth.uid() não funciona
SELECT 
    'DIAGNÓSTICO:' as debug_step;

SELECT 
    CASE 
        WHEN (SELECT COUNT(*) FROM workout_videos_raw WHERE requires_expert_access = false OR requires_expert_access IS NULL) = 0 
        THEN '❌ PROBLEMA: Todos os vídeos são expert-only, mas auth.uid() não funciona no Flutter'
        ELSE '✅ Há vídeos públicos disponíveis'
    END as diagnostico;






-- 8. CRIAR teste para simular usuário basic específico
CREATE OR REPLACE FUNCTION test_view_with_user(test_user_id UUID)
RETURNS TABLE(
    video_count BIGINT,
    user_level TEXT,
    should_see_videos TEXT
) AS $$
BEGIN
    -- Verificar nível do usuário
    RETURN QUERY
    SELECT 
        (SELECT COUNT(*) FROM workout_videos_raw wv
         WHERE 
             (wv.requires_expert_access = false OR wv.requires_expert_access IS NULL)
             OR
             (wv.requires_expert_access = true AND EXISTS (
                 SELECT 1 FROM user_progress_level upl
                 WHERE upl.user_id = test_user_id
                 AND upl.current_level = 'expert'
                 AND (upl.level_expires_at IS NULL OR upl.level_expires_at > now())
             ))
        ) as video_count,
        COALESCE(upl.current_level, 'SEM NÍVEL') as user_level,
        CASE 
            WHEN upl.current_level = 'expert' THEN 'DEVERIA VER TODOS'
            WHEN upl.current_level = 'basic' THEN 'DEVERIA VER 0 (só expert-only existem)'
            ELSE 'USUÁRIO INVÁLIDO'
        END as should_see_videos
    FROM user_progress_level upl
    WHERE upl.user_id = test_user_id;
END;
$$ LANGUAGE plpgsql;

-- 9. BUSCAR ID de usuário basic para teste
SELECT 
    'USUÁRIO BASIC PARA TESTE:' as debug_step,
    au.id,
    au.email
FROM auth.users au
JOIN user_progress_level upl ON upl.user_id = au.id
WHERE upl.current_level = 'basic'
LIMIT 1;

-- 10. INSTRUÇÕES PARA INVESTIGAR NO FLUTTER
SELECT 'INVESTIGAÇÃO NO FLUTTER:' as instrucoes;
SELECT 'Cole este código no Flutter (logado como basic) e me mostre o resultado:' as passo;

SELECT '
// TESTE 1: Verificar auth.uid()
print("Auth UID: ${supabase.auth.currentUser?.id}");

// TESTE 2: Verificar se view está sendo usada
final rawQuery = await supabase
  .from("workout_videos_raw")
  .select()
  .count();
print("Tabela raw: ${rawQuery.count} vídeos");

// TESTE 3: Verificar view filtrada
final viewQuery = await supabase
  .from("workout_videos")
  .select()
  .count();
print("View filtrada: ${viewQuery.count} vídeos");

// TESTE 4: Verificar nível do usuário
final userLevel = await supabase
  .from("user_progress_level")
  .select("current_level")
  .eq("user_id", supabase.auth.currentUser!.id)
  .single();
print("Nível do usuário: ${userLevel}");
' as codigo_teste; 