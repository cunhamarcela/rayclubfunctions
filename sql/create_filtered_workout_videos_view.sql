-- Criar view que filtra automaticamente vídeos baseado no nível do usuário
-- O Flutter pode usar esta view como se fosse uma tabela normal

-- 1. REMOVER RLS da tabela original (vai usar a view)
ALTER TABLE workout_videos DISABLE ROW LEVEL SECURITY;

-- 2. CRIAR view filtrada
CREATE OR REPLACE VIEW workout_videos_filtered AS
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
    wv.updated_at,
    -- NÃO incluir requires_expert_access para manter compatibilidade
    wv.requires_expert_access  -- Mantém para debug se necessário
FROM workout_videos wv
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

-- 3. CRIAR alias/sinônimo da view para que Flutter use normalmente
-- Isso permite que o Flutter continue usando 'workout_videos' sem mudanças
DROP VIEW IF EXISTS public.workout_videos_view;
CREATE VIEW public.workout_videos_view AS SELECT * FROM workout_videos_filtered;

-- 4. ALTERNATIVA: Renomear tabelas (mais invasivo)
-- Se quiser fazer o Flutter usar automaticamente a view:
-- ALTER TABLE workout_videos RENAME TO workout_videos_raw;
-- CREATE VIEW workout_videos AS SELECT * FROM workout_videos_filtered;

-- 5. TESTAR a view
SELECT 'TESTE DA VIEW:' as debug_step;

-- Ver quantos vídeos a view retorna (sem usuário logado)
SELECT 
    'Vídeos na view (sem auth):' as tipo,
    COUNT(*) as total
FROM workout_videos_filtered;

-- 6. INSTRUÇÕES PARA USO
SELECT 'INSTRUÇÕES PARA O FLUTTER:' as instrucoes;
SELECT 'OPÇÃO A: Mudar queries do Flutter para usar "workout_videos_filtered"' as opcao_a;
SELECT 'OPÇÃO B: Renomear tabela original e criar view com nome "workout_videos"' as opcao_b;
SELECT 'OPÇÃO C: Usar função RPC no lugar das queries diretas' as opcao_c;

-- 7. VERIFICAR se a view foi criada corretamente
SELECT 
    schemaname,
    viewname,
    definition
FROM pg_views 
WHERE viewname LIKE '%workout_videos%';

-- 8. MOSTRAR diferença entre tabela e view
SELECT 'COMPARAÇÃO:' as debug_step;

SELECT 
    'Tabela original (todos):' as fonte,
    COUNT(*) as total
FROM workout_videos;

SELECT 
    'View filtrada (sem auth):' as fonte,
    COUNT(*) as total
FROM workout_videos_filtered; 