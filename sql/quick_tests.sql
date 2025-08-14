-- ========================================
-- TESTES RÁPIDOS NO SUPABASE
-- ========================================
-- Execute uma query por vez para validar o sistema

-- ========================================
-- 1. VERIFICAR SE SISTEMA ESTÁ INSTALADO
-- ========================================

-- Verificar se as funções existem
SELECT 
    routine_name as funcao_encontrada
FROM information_schema.routines 
WHERE routine_schema = 'public' 
AND (routine_name LIKE '%goal%' OR routine_name LIKE '%category%')
ORDER BY routine_name;

-- ========================================
-- 2. TESTAR FUNÇÃO DE MAPEAMENTO
-- ========================================

-- Testar mapeamento de categorias
SELECT 
    'Musculação' as original,
    normalize_exercise_category('Musculação') as normalizada;

SELECT 
    'Força' as original,
    normalize_exercise_category('Força') as normalizada;

SELECT 
    'Cardio' as original,
    normalize_exercise_category('Cardio') as normalizada;

SELECT 
    'categoria_inexistente' as original,
    normalize_exercise_category('categoria_inexistente') as normalizada;

-- ========================================
-- 3. VERIFICAR ESTRUTURA DA TABELA
-- ========================================

-- Ver se tabela existe e sua estrutura
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'workout_category_goals'
ORDER BY ordinal_position;

-- ========================================
-- 4. CRIAR META DE TESTE
-- ========================================

-- Primeiro, vamos ver se há usuários disponíveis
SELECT 
    id as user_id,
    email
FROM auth.users 
ORDER BY created_at DESC
LIMIT 3;

-- SUBSTITUA o UUID abaixo por um real da query acima!
SELECT 
    get_or_create_category_goal(
        'COLOQUE-UM-UUID-REAL-AQUI'::uuid,  -- ⚠️ SUBSTITUA!
        'cardio'
    );

-- Alternativa: criar com UUID gerado (para teste)
SELECT 
    get_or_create_category_goal(
        gen_random_uuid(),
        'cardio'
    );

-- ========================================
-- 5. VER METAS CRIADAS
-- ========================================

-- Ver todas as metas ativas
SELECT 
    user_id,
    category,
    goal_minutes,
    current_minutes,
    completed,
    ROUND((current_minutes::numeric / goal_minutes::numeric) * 100, 2) as percentual,
    created_at
FROM workout_category_goals 
WHERE is_active = true
ORDER BY created_at DESC;

-- ========================================
-- 6. ATUALIZAR META MANUALMENTE
-- ========================================

-- Adicionar 30 minutos para a primeira meta encontrada
SELECT 
    add_workout_minutes_to_category(
        (SELECT user_id FROM workout_category_goals WHERE is_active = true LIMIT 1),
        'cardio',
        30
    );

-- ========================================
-- 7. VER PROGRESSO ATUALIZADO
-- ========================================

-- Ver progresso com emojis
SELECT 
    category,
    current_minutes || '/' || goal_minutes || ' min' as progresso,
    ROUND((current_minutes::numeric / goal_minutes::numeric) * 100, 2) || '%' as percentual,
    CASE 
        WHEN completed THEN '🎉 Completada'
        WHEN current_minutes::numeric / goal_minutes::numeric >= 0.8 THEN '💪 Quase lá'
        WHEN current_minutes::numeric / goal_minutes::numeric >= 0.5 THEN '🔥 Metade'
        ELSE '🌱 Começando'
    END as status
FROM workout_category_goals 
WHERE is_active = true
ORDER BY (current_minutes::numeric / goal_minutes::numeric) DESC;

-- ========================================
-- 8. CRIAR MÚLTIPLAS METAS
-- ========================================

-- Criar metas para um usuário (SUBSTITUA o UUID!)
SELECT 
    get_or_create_category_goal(
        'COLOQUE-UM-UUID-REAL-AQUI'::uuid,  -- ⚠️ SUBSTITUA!
        'musculacao'
    );

SELECT 
    get_or_create_category_goal(
        'COLOQUE-UM-UUID-REAL-AQUI'::uuid,  -- ⚠️ SUBSTITUA!
        'yoga'
    );

-- ========================================
-- 9. VERIFICAR TRIGGERS
-- ========================================

-- Ver se trigger está ativo
SELECT 
    trigger_name,
    event_object_table,
    action_timing,
    event_manipulation
FROM information_schema.triggers 
WHERE trigger_name LIKE '%goal%';

-- ========================================
-- 10. ESTATÍSTICAS RÁPIDAS
-- ========================================

-- Resumo geral
SELECT 
    count(*) as total_metas,
    count(DISTINCT user_id) as usuarios_com_metas,
    count(DISTINCT category) as categorias_diferentes,
    count(*) FILTER (WHERE completed = true) as metas_completadas,
    ROUND(avg(current_minutes), 2) as media_progresso_minutos
FROM workout_category_goals 
WHERE is_active = true;

-- Metas por categoria
SELECT 
    category,
    count(*) as quantidade,
    ROUND(avg(goal_minutes), 2) as meta_media,
    ROUND(avg(current_minutes), 2) as progresso_medio
FROM workout_category_goals 
WHERE is_active = true
GROUP BY category
ORDER BY quantidade DESC;

-- ========================================
-- 11. LIMPEZA (se necessário)
-- ========================================

-- Para limpar dados de teste (CUIDADO!)
/*
DELETE FROM workout_category_goals 
WHERE user_id NOT IN (
    SELECT id FROM auth.users
);
*/

-- ========================================
-- 12. TESTE DE PERFORMANCE
-- ========================================

-- Testar se funções estão rápidas
EXPLAIN ANALYZE 
SELECT get_or_create_category_goal(gen_random_uuid(), 'cardio');

-- Ver índices da tabela
SELECT 
    indexname,
    indexdef
FROM pg_indexes 
WHERE tablename = 'workout_category_goals';

-- ========================================
-- RESULTADOS ESPERADOS
-- ========================================

/*
✅ O que você deve ver se tudo estiver funcionando:

1. Funções encontradas: normalize_exercise_category, get_or_create_category_goal, etc.
2. Mapeamento funcionando: 'Musculação' → 'musculacao'  
3. Tabela existindo com colunas corretas
4. Metas sendo criadas com valores padrão
5. Progresso sendo atualizado quando adicionar minutos
6. Triggers ativos na tabela
7. Estatísticas mostrando dados consistentes

❌ Se algo não funcionar:
- Verifique se executou o SQL de criação primeiro
- Confirme se substituiu os UUIDs pelos reais
- Verifique permissões RLS se necessário
*/ 