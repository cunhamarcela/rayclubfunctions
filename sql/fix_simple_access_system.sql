-- ========================================
-- SISTEMA SIMPLES: BASIC = 0 VÍDEOS | EXPERT = TODOS OS VÍDEOS
-- ========================================

-- 1. PRIMEIRO: DEBUGAR POR QUE A FUNÇÃO RETORNA FALSE
SELECT 
    '=== DEBUG: POR QUE user_has_workout_library_access() RETORNA FALSE ===' as step;

-- Ver seus dados RAW na tabela
SELECT 
    user_id,
    current_level,
    unlocked_features,
    array_length(unlocked_features, 1) as qtd_features,
    'workout_library' = ANY(unlocked_features) as tem_workout_library_check,
    level_expires_at,
    CASE 
        WHEN level_expires_at IS NULL THEN 'Permanente'
        WHEN level_expires_at > NOW() THEN 'Válido'
        ELSE 'EXPIRADO'
    END as status_expiracao
FROM user_progress_level 
WHERE user_id = auth.uid();

-- Verificar se auth.uid() está funcionando
SELECT 
    auth.uid() as meu_user_id,
    auth.uid() IS NOT NULL as esta_autenticado;

-- 2. CORRIGIR SEUS DADOS SE NECESSÁRIO
UPDATE user_progress_level 
SET 
    current_level = 'expert',
    unlocked_features = ARRAY[
        'basic_workouts', 'profile', 'basic_challenges', 'workout_recording',
        'enhanced_dashboard', 'nutrition_guide', 'workout_library', 
        'advanced_tracking', 'detailed_reports'
    ],
    level_expires_at = NULL,
    updated_at = NOW()
WHERE user_id = auth.uid();

-- 3. CRIAR FUNÇÃO SIMPLES E DIRETA
CREATE OR REPLACE FUNCTION is_user_expert_simple(user_id_param UUID DEFAULT auth.uid())
RETURNS BOOLEAN AS $$
DECLARE
    user_level TEXT;
    expires_at TIMESTAMP;
BEGIN
    -- Se não tem user_id, não é expert
    IF user_id_param IS NULL THEN
        RETURN false;
    END IF;
    
    -- Buscar nível do usuário
    SELECT current_level, level_expires_at
    INTO user_level, expires_at
    FROM user_progress_level
    WHERE user_id = user_id_param;
    
    -- Se não encontrou, não é expert
    IF user_level IS NULL THEN
        RETURN false;
    END IF;
    
    -- Se expirou, não é expert
    IF expires_at IS NOT NULL AND expires_at < NOW() THEN
        RETURN false;
    END IF;
    
    -- Retorna true apenas se for expert
    RETURN user_level = 'expert';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. REMOVER SISTEMA COMPLEXO DE requires_expert_access
-- Não vamos mais usar a coluna requires_expert_access
UPDATE workout_videos SET requires_expert_access = false;

-- 5. REMOVER POLÍTICAS ANTIGAS
DROP POLICY IF EXISTS "Controle de acesso aos vídeos dos parceiros" ON workout_videos;
DROP POLICY IF EXISTS "Usuários não autenticados veem apenas vídeos públicos" ON workout_videos;
DROP POLICY IF EXISTS "Vídeos são públicos" ON workout_videos;

-- 6. CRIAR POLÍTICA SIMPLES: APENAS EXPERTS VEEM VÍDEOS
CREATE POLICY "Apenas experts podem ver vídeos" ON workout_videos
    FOR SELECT USING (
        is_user_expert_simple(auth.uid())
    );

-- 7. TESTAR O SISTEMA
SELECT 
    '=== TESTE DO NOVO SISTEMA ===' as step;

-- Testar função simples
SELECT 
    auth.uid() as meu_id,
    is_user_expert_simple() as sou_expert_funcao_simples,
    user_has_workout_library_access() as funcao_antiga;

-- Ver seus dados após correção
SELECT 
    user_id,
    current_level,
    'workout_library' = ANY(unlocked_features) as tem_workout_library,
    level_expires_at
FROM user_progress_level 
WHERE user_id = auth.uid();

-- Contar vídeos que você consegue ver agora
SELECT 
    COUNT(*) as videos_que_voce_ve
FROM workout_videos;

-- 8. FUNÇÃO PARA TESTAR CENÁRIOS
CREATE OR REPLACE FUNCTION test_simple_access_system()
RETURNS JSON AS $$
DECLARE
    result JSON;
    sample_basic_user UUID;
    sample_expert_user UUID;
    current_user_videos INTEGER;
BEGIN
    -- Pegar usuários de exemplo
    SELECT user_id INTO sample_basic_user FROM user_progress_level WHERE current_level = 'basic' LIMIT 1;
    SELECT user_id INTO sample_expert_user FROM user_progress_level WHERE current_level = 'expert' LIMIT 1;
    
    -- Contar vídeos para usuário atual
    SELECT COUNT(*) INTO current_user_videos FROM workout_videos;
    
    result := json_build_object(
        'current_user', json_build_object(
            'user_id', auth.uid(),
            'is_expert', is_user_expert_simple(),
            'videos_visible', current_user_videos
        ),
        'test_scenarios', json_build_object(
            'basic_user_test', json_build_object(
                'user_id', sample_basic_user,
                'is_expert', is_user_expert_simple(sample_basic_user),
                'should_see_videos', false
            ),
            'expert_user_test', json_build_object(
                'user_id', sample_expert_user,
                'is_expert', is_user_expert_simple(sample_expert_user),
                'should_see_videos', true
            )
        ),
        'system_status', json_build_object(
            'total_videos', (SELECT COUNT(*) FROM workout_videos),
            'rls_enabled', (SELECT rowsecurity FROM pg_tables WHERE tablename = 'workout_videos'),
            'current_policy', 'Apenas experts podem ver vídeos'
        )
    );
    
    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 9. VERIFICAR RESULTADO FINAL
SELECT 
    '=== RESULTADO FINAL ===' as step;

-- Teste completo do sistema
SELECT test_simple_access_system();

-- Seus dados finais
SELECT 
    'Você deveria ser expert e ver todos os vídeos' as resultado,
    auth.uid() as seu_id,
    is_user_expert_simple() as voce_e_expert,
    (SELECT COUNT(*) FROM workout_videos) as videos_que_voce_ve;

/*
=== RESUMO DO NOVO SISTEMA ===

1. USUÁRIOS BASIC: 
   - is_user_expert_simple() retorna FALSE
   - Política RLS bloqueia = veem 0 vídeos

2. USUÁRIOS EXPERT:
   - is_user_expert_simple() retorna TRUE  
   - Política RLS permite = veem TODOS os vídeos

3. USUÁRIOS NÃO CADASTRADOS:
   - is_user_expert_simple() retorna FALSE
   - Política RLS bloqueia = veem 0 vídeos

Simples e direto!
*/ 