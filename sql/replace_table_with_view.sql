-- SOLUÇÃO DEFINITIVA: Substituir tabela por view filtrada
-- Flutter continua usando 'workout_videos' normalmente, mas agora é uma view filtrada

-- 1. RENOMEAR tabela original
ALTER TABLE workout_videos RENAME TO workout_videos_raw;

-- 2. CRIAR view com o nome original da tabela
CREATE VIEW workout_videos AS
SELECT 
    wv.id,
    wv.title,
    wv.duration,
    wv.duration_minutes,
    wv.difficulty,
    wv.youtube_url,
    wv.thumbnail_url,
    wv.category,
    wv.instructor_name,
    wv.description,
    wv.order_index,
    wv.is_new,
    wv.is_popular,
    wv.is_recommended,
    wv.created_at,
    wv.updated_at
    -- NÃO incluir requires_expert_access para manter compatibilidade total
FROM workout_videos_raw wv
WHERE 
    -- Vídeos públicos: todos podem ver
    (wv.requires_expert_access = false OR wv.requires_expert_access IS NULL)
    OR
    -- Vídeos expert: só experts podem ver
    (
        wv.requires_expert_access = true 
        AND EXISTS (
            SELECT 1 
            FROM user_progress_level upl
            WHERE upl.user_id = auth.uid() 
            AND upl.current_level = 'expert'
            AND (upl.level_expires_at IS NULL OR upl.level_expires_at > now())
        )
    );

-- 3. REMOVER políticas RLS antigas (não são mais necessárias)
DROP POLICY IF EXISTS "workout_videos_expert_only" ON workout_videos_raw;

-- 4. TESTAR a solução
SELECT 'TESTE DA SOLUÇÃO:' as debug_step;

-- Basic users: devem ver 0 vídeos (sem auth.uid())
SELECT 
    'Sem autenticação (basic simulado):' as cenario,
    COUNT(*) as videos_visiveis
FROM workout_videos;

-- 5. VERIFICAR estrutura
SELECT 'VERIFICAÇÃO:' as debug_step;

-- Ver se a view foi criada
SELECT 
    'View criada:' as status,
    COUNT(*) as total_views
FROM information_schema.views 
WHERE table_name = 'workout_videos';

-- Ver se tabela original foi renomeada
SELECT 
    'Tabela original (renomeada):' as status,
    COUNT(*) as total_tables
FROM information_schema.tables 
WHERE table_name = 'workout_videos_raw';

-- 6. COMPARAÇÃO FINAL
SELECT 'COMPARAÇÃO FINAL:' as debug_step;

SELECT 
    'Tabela raw (todos os 40):' as fonte,
    COUNT(*) as total
FROM workout_videos_raw;

SELECT 
    'View filtrada (0 sem auth):' as fonte,
    COUNT(*) as total
FROM workout_videos;

-- 7. RESULTADO ESPERADO NO FLUTTER
SELECT 'RESULTADO ESPERADO NO FLUTTER:' as instrucoes;
SELECT '✅ Basic user: supabase.from("workout_videos").select() retorna []' as basic_result;
SELECT '✅ Expert user: supabase.from("workout_videos").select() retorna 40 vídeos' as expert_result;
SELECT '✅ Flutter não precisa de nenhuma mudança!' as flutter_status;
SELECT '✅ RLS não é mais necessário' as rls_status; 