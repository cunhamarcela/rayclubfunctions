-- ========================================
-- CORREÇÃO RÁPIDA: GARANTIR ACESSO PARA USUÁRIOS EXPERT
-- ========================================

-- 1. VERIFICAR SEU USUÁRIO ATUAL E CORRIGIR SE NECESSÁRIO
SELECT 
    '=== VERIFICANDO SEU USUÁRIO ATUAL ===' as step;

-- Ver seus dados atuais
SELECT 
    user_id,
    current_level,
    unlocked_features,
    'workout_library' = ANY(unlocked_features) as tem_workout_library,
    level_expires_at
FROM user_progress_level 
WHERE user_id = auth.uid();

-- 2. GARANTIR QUE VOCÊ É EXPERT COM TODAS AS FEATURES
UPDATE user_progress_level 
SET 
    current_level = 'expert',
    unlocked_features = ARRAY[
        'basic_workouts', 
        'profile', 
        'basic_challenges', 
        'workout_recording',
        'enhanced_dashboard', 
        'nutrition_guide', 
        'workout_library', 
        'advanced_tracking', 
        'detailed_reports'
    ],
    level_expires_at = NULL,  -- Acesso permanente
    updated_at = NOW()
WHERE user_id = auth.uid();

-- 3. VERIFICAR SE OS VÍDEOS DOS PARCEIROS ESTÃO MARCADOS
SELECT 
    '=== MARCANDO VÍDEOS DOS PARCEIROS ===' as step;

-- Marcar vídeos dos parceiros como expert-only
UPDATE workout_videos 
SET requires_expert_access = true,
    updated_at = CURRENT_TIMESTAMP
WHERE instructor_name IN (
    'Treinos de Musculação',
    'Treinos de musculação',
    'Goya Health Club',
    'Fight Fit', 
    'Bora Assessoria',
    'The Unit'
);

-- 4. VERIFICAR SE RLS ESTÁ HABILITADO
ALTER TABLE workout_videos ENABLE ROW LEVEL SECURITY;

-- 5. VERIFICAR RESULTADO
SELECT 
    '=== VERIFICAÇÃO FINAL ===' as step;

-- Seus dados após correção
SELECT 
    user_id,
    current_level,
    unlocked_features,
    'workout_library' = ANY(unlocked_features) as tem_workout_library
FROM user_progress_level 
WHERE user_id = auth.uid();

-- Quantos vídeos você deve conseguir ver agora
SELECT 
    COUNT(*) as total_videos_visiveis
FROM workout_videos
WHERE (
    requires_expert_access = false
    OR 
    (requires_expert_access = true AND user_has_workout_library_access())
);

-- Teste da função
SELECT 
    user_has_workout_library_access() as deve_ser_true;

-- Alguns vídeos dos parceiros para testar
SELECT 
    wv.title,
    wv.instructor_name,
    wv.requires_expert_access,
    user_has_workout_library_access() as voce_tem_acesso,
    CASE 
        WHEN requires_expert_access = false THEN '✅ Público'
        WHEN requires_expert_access = true AND user_has_workout_library_access() THEN '✅ Expert - Acessível'
        ELSE '❌ Bloqueado'
    END as status
FROM workout_videos wv
WHERE wv.instructor_name IN (
    'Treinos de Musculação', 'Treinos de musculação',
    'Goya Health Club', 'Fight Fit', 
    'Bora Assessoria', 'The Unit'
)
LIMIT 5;

-- 6. COMANDOS PARA TESTAR NO APP
SELECT 
    '=== TESTE NO FLUTTER ===' as step;

/*
Agora teste no seu app Flutter:

1. Faça logout e login novamente
2. Navegue até a tela de vídeos dos parceiros
3. Os vídeos devem aparecer normalmente

Se ainda não funcionar, execute este comando no Flutter para verificar:

final videos = await supabase.from('workout_videos').select();
print('Total vídeos: ${videos.length}');

final partnerVideos = videos.where((v) => 
  ['Treinos de Musculação', 'Goya Health Club', 'Fight Fit', 'Bora Assessoria', 'The Unit']
  .contains(v['instructor_name'])
).toList();
print('Vídeos de parceiros: ${partnerVideos.length}');
*/ 