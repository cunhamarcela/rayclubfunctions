-- ========================================
-- DEBUG: PROBLEMA DE ACESSO AOS VÍDEOS DOS PARCEIROS
-- ========================================

-- 1. VERIFICAR SE O SCRIPT FOI EXECUTADO
SELECT 
    '=== VERIFICAR SE COLUNAS E FUNÇÕES EXISTEM ===' as debug_step;

-- Verificar se a coluna requires_expert_access existe
SELECT 
    column_name,
    data_type,
    column_default
FROM information_schema.columns 
WHERE table_name = 'workout_videos' 
  AND column_name = 'requires_expert_access';

-- Verificar se as funções foram criadas
SELECT 
    routine_name,
    routine_type
FROM information_schema.routines 
WHERE routine_name IN (
    'user_has_workout_library_access',
    'test_access_scenarios',
    'get_video_access_stats'
);

-- 2. VERIFICAR SE OS VÍDEOS FORAM MARCADOS
SELECT 
    '=== VERIFICAR VÍDEOS MARCADOS COMO EXPERT-ONLY ===' as debug_step;

SELECT 
    COUNT(*) as total_videos,
    COUNT(*) FILTER (WHERE requires_expert_access = true) as expert_only_videos,
    COUNT(*) FILTER (WHERE requires_expert_access = false) as public_videos
FROM workout_videos;

-- Ver quais instrutores foram marcados
SELECT 
    instructor_name,
    COUNT(*) as total_videos,
    COUNT(*) FILTER (WHERE requires_expert_access = true) as expert_only,
    COUNT(*) FILTER (WHERE requires_expert_access = false) as public
FROM workout_videos
WHERE instructor_name IN (
    'Treinos de Musculação', 'Treinos de musculação',
    'Goya Health Club', 'Fight Fit', 
    'Bora Assessoria', 'The Unit'
)
GROUP BY instructor_name;

-- 3. VERIFICAR POLÍTICAS RLS
SELECT 
    '=== VERIFICAR POLÍTICAS RLS ===' as debug_step;

-- Ver se RLS está habilitado
SELECT 
    schemaname,
    tablename,
    rowsecurity as rls_enabled
FROM pg_tables 
WHERE tablename = 'workout_videos';

-- Ver políticas atuais
SELECT 
    policyname,
    permissive,
    cmd,
    qual
FROM pg_policies 
WHERE tablename = 'workout_videos';

-- 4. TESTAR FUNÇÃO DE ACESSO (SEM PARÂMETRO - USUÁRIO ATUAL)
SELECT 
    '=== TESTAR FUNÇÃO PARA USUÁRIO ATUAL ===' as debug_step;

-- Testar a função com o usuário atual
SELECT 
    auth.uid() as current_user_id,
    user_has_workout_library_access() as has_access_no_param,
    user_has_workout_library_access(auth.uid()) as has_access_with_param;

-- 5. VERIFICAR DADOS DO USUÁRIO ATUAL
SELECT 
    '=== DADOS DO USUÁRIO ATUAL ===' as debug_step;

SELECT 
    upl.user_id,
    upl.current_level,
    upl.unlocked_features,
    upl.level_expires_at,
    CASE 
        WHEN upl.level_expires_at IS NULL THEN 'Permanente'
        WHEN upl.level_expires_at > NOW() THEN 'Ativo'
        ELSE 'Expirado'
    END as status_acesso,
    'workout_library' = ANY(upl.unlocked_features) as tem_workout_library
FROM user_progress_level upl
WHERE upl.user_id = auth.uid();

-- 6. TESTAR CONSULTA REAL DE VÍDEOS
SELECT 
    '=== TESTAR CONSULTA REAL DE VÍDEOS ===' as debug_step;

-- Contar vídeos que o usuário atual consegue ver
SELECT 
    'Vídeos acessíveis ao usuário atual' as info,
    COUNT(*) as quantidade
FROM workout_videos
WHERE (
    requires_expert_access = false
    OR 
    (requires_expert_access = true AND user_has_workout_library_access())
);

-- Ver alguns vídeos específicos dos parceiros
SELECT 
    wv.id,
    wv.title,
    wv.instructor_name,
    wc.name as category_name,
    wv.requires_expert_access,
    user_has_workout_library_access() as user_has_access,
    CASE 
        WHEN requires_expert_access = false THEN 'Público - Acessível'
        WHEN requires_expert_access = true AND user_has_workout_library_access() THEN 'Expert - Acessível'
        ELSE 'Expert - BLOQUEADO'
    END as status_acesso
FROM workout_videos wv
LEFT JOIN workout_categories wc ON wv.category = wc.id
WHERE wv.instructor_name IN (
    'Treinos de Musculação', 'Treinos de musculação',
    'Goya Health Club', 'Fight Fit', 
    'Bora Assessoria', 'The Unit'
)
LIMIT 10;

-- 7. VERIFICAR SE HÁ CONFLITOS DE POLÍTICA
SELECT 
    '=== TESTAR ACESSO DIRETO (SEM RLS) ===' as debug_step;

-- Desabilitar RLS temporariamente para ver todos os vídeos
SET row_security = off;
SELECT COUNT(*) as total_videos_sem_rls FROM workout_videos;
SET row_security = on;

-- 8. DIAGNÓSTICO COMPLETO
SELECT 
    '=== DIAGNÓSTICO COMPLETO ===' as debug_step;

WITH user_info AS (
    SELECT 
        auth.uid() as user_id,
        current_level,
        unlocked_features,
        level_expires_at,
        'workout_library' = ANY(unlocked_features) as has_workout_library
    FROM user_progress_level 
    WHERE user_id = auth.uid()
),
video_stats AS (
    SELECT 
        COUNT(*) as total_videos,
        COUNT(*) FILTER (WHERE requires_expert_access = true) as expert_videos,
        COUNT(*) FILTER (WHERE requires_expert_access = false) as public_videos
    FROM workout_videos
)
SELECT 
    ui.user_id,
    ui.current_level,
    ui.has_workout_library,
    ui.level_expires_at,
    vs.total_videos,
    vs.expert_videos,
    vs.public_videos,
    user_has_workout_library_access() as function_result,
    CASE 
        WHEN ui.user_id IS NULL THEN 'PROBLEMA: Usuário não está autenticado'
        WHEN ui.current_level IS NULL THEN 'PROBLEMA: Usuário não existe na tabela user_progress_level'
        WHEN ui.current_level != 'expert' THEN 'PROBLEMA: Usuário não é expert (atual: ' || ui.current_level || ')'
        WHEN NOT ui.has_workout_library THEN 'PROBLEMA: Usuário não tem feature workout_library'
        WHEN ui.level_expires_at IS NOT NULL AND ui.level_expires_at <= NOW() THEN 'PROBLEMA: Acesso expert expirado'
        WHEN vs.expert_videos = 0 THEN 'PROBLEMA: Nenhum vídeo foi marcado como expert-only'
        ELSE 'OK: Usuário deveria ter acesso'
    END as diagnostico
FROM user_info ui, video_stats vs;

-- 9. COMANDOS PARA CORRIGIR PROBLEMAS COMUNS
SELECT 
    '=== COMANDOS PARA CORREÇÃO ===' as debug_step;

/*
-- Se o usuário não tem a feature workout_library:
UPDATE user_progress_level 
SET unlocked_features = ARRAY[
    'basic_workouts', 'profile', 'basic_challenges', 'workout_recording',
    'enhanced_dashboard', 'nutrition_guide', 'workout_library', 
    'advanced_tracking', 'detailed_reports'
]
WHERE user_id = auth.uid() AND current_level = 'expert';

-- Se o usuário não é expert:
UPDATE user_progress_level 
SET current_level = 'expert'
WHERE user_id = auth.uid();

-- Se os vídeos não foram marcados, execute novamente:
UPDATE workout_videos 
SET requires_expert_access = true
WHERE instructor_name IN (
    'Treinos de Musculação', 'Treinos de musculação',
    'Goya Health Club', 'Fight Fit', 
    'Bora Assessoria', 'The Unit'
);

-- Se RLS não está habilitado:
ALTER TABLE workout_videos ENABLE ROW LEVEL SECURITY;
*/ 