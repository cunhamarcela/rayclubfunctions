-- ========================================
-- TESTE COMPLETO DO FLUXO DE METAS
-- ========================================
-- Execute passo a passo no Supabase para validar o sistema completo

-- ========================================
-- PASSO 1: VERIFICAR USUÁRIOS EXISTENTES
-- ========================================

SELECT '👥 PASSO 1: VERIFICANDO USUÁRIOS' as passo;

-- Ver primeiros usuários disponíveis
SELECT 
    id as user_id,
    email,
    created_at
FROM auth.users 
ORDER BY created_at DESC
LIMIT 3;

-- Se não houver usuários, você pode usar um UUID fictício para teste:
SELECT 'gen_random_uuid()' as gerando_uuid, gen_random_uuid() as uuid_exemplo;

-- ========================================
-- PASSO 2: TESTAR FUNÇÃO DE MAPEAMENTO
-- ========================================

SELECT '🧠 PASSO 2: TESTANDO MAPEAMENTO' as passo;

-- Função principal de mapeamento
SELECT 
    'Musculação' as original,
    normalize_exercise_category('Musculação') as normalizada;

SELECT 
    'Força' as original,
    normalize_exercise_category('Força') as normalizada;

SELECT 
    'cardio' as original,
    normalize_exercise_category('cardio') as normalizada;

-- ========================================
-- PASSO 3: CRIAR META MANUALMENTE
-- ========================================

SELECT '🎯 PASSO 3: CRIANDO META DE TESTE' as passo;

-- SUBSTITUA o UUID abaixo por um real ou use gen_random_uuid()
DO $$
DECLARE
    test_user_id UUID := gen_random_uuid(); -- ou coloque UUID real aqui
    meta_criada RECORD;
BEGIN
    -- Tentar criar meta de cardio
    SELECT * INTO meta_criada
    FROM get_or_create_category_goal(test_user_id, 'cardio');
    
    RAISE NOTICE 'Meta criada: ID=%, Categoria=%, Minutos=%/%', 
        meta_criada.id, meta_criada.category, meta_criada.current_minutes, meta_criada.goal_minutes;
END $$;

-- ========================================
-- PASSO 4: VERIFICAR METAS CRIADAS
-- ========================================

SELECT '📊 PASSO 4: VERIFICANDO METAS CRIADAS' as passo;

-- Ver todas as metas da semana atual
SELECT 
    user_id,
    category,
    goal_minutes,
    current_minutes,
    completed,
    week_start_date,
    is_active,
    created_at
FROM workout_category_goals 
WHERE week_start_date = date_trunc('week', CURRENT_DATE)::date
ORDER BY created_at DESC;

-- ========================================
-- PASSO 5: SIMULAR REGISTRO DE EXERCÍCIO
-- ========================================

SELECT '💪 PASSO 5: SIMULANDO REGISTRO DE EXERCÍCIO' as passo;

-- Verificar se tabela workout_records existe
SELECT 
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.tables 
            WHERE table_name = 'workout_records'
        ) 
        THEN '✅ Tabela workout_records existe'
        ELSE '⚠️ Tabela workout_records não existe - criar primeiro'
    END as status_tabela;

-- Estrutura esperada da tabela workout_records
SELECT 
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'workout_records'
ORDER BY ordinal_position;

-- ========================================
-- PASSO 6: TESTAR FUNÇÃO DE ADIÇÃO DE MINUTOS
-- ========================================

SELECT '⏱️ PASSO 6: TESTANDO ADIÇÃO DE MINUTOS' as passo;

-- SUBSTITUA o UUID por um que tenha meta criada
DO $$
DECLARE
    test_user_id UUID;
    meta_atualizada RECORD;
BEGIN
    -- Pegar um usuário que tenha meta
    SELECT user_id INTO test_user_id
    FROM workout_category_goals 
    WHERE is_active = true
    LIMIT 1;
    
    IF test_user_id IS NOT NULL THEN
        -- Adicionar 30 minutos de cardio
        SELECT * INTO meta_atualizada
        FROM add_workout_minutes_to_category(test_user_id, 'cardio', 30);
        
        RAISE NOTICE 'Meta atualizada: Categoria=%, Minutos=%/%, Completa=%', 
            meta_atualizada.category, 
            meta_atualizada.current_minutes, 
            meta_atualizada.goal_minutes,
            meta_atualizada.completed;
    ELSE
        RAISE NOTICE 'Nenhuma meta encontrada para teste';
    END IF;
END $$;

-- ========================================
-- PASSO 7: VERIFICAR PROGRESSO ATUALIZADO
-- ========================================

SELECT '📈 PASSO 7: VERIFICANDO PROGRESSO' as passo;

-- Ver progresso de todas as metas
SELECT 
    category,
    goal_minutes,
    current_minutes,
    ROUND((current_minutes::numeric / goal_minutes::numeric) * 100, 2) as percentual,
    completed,
    CASE 
        WHEN completed THEN '🎉 Completada'
        WHEN current_minutes::numeric / goal_minutes::numeric >= 0.8 THEN '💪 Quase lá'
        WHEN current_minutes::numeric / goal_minutes::numeric >= 0.5 THEN '🔥 Metade'
        ELSE '🌱 Começando'
    END as status_visual
FROM workout_category_goals 
WHERE is_active = true
AND week_start_date = date_trunc('week', CURRENT_DATE)::date
ORDER BY percentual DESC;

-- ========================================
-- PASSO 8: TESTAR DIFERENTES CATEGORIAS
-- ========================================

SELECT '🎨 PASSO 8: TESTANDO MÚLTIPLAS CATEGORIAS' as passo;

-- Criar metas para diferentes categorias
DO $$
DECLARE
    test_user_id UUID := gen_random_uuid();
    categorias TEXT[] := ARRAY['musculacao', 'yoga', 'funcional', 'corrida'];
    cat TEXT;
BEGIN
    FOREACH cat IN ARRAY categorias
    LOOP
        PERFORM get_or_create_category_goal(test_user_id, cat);
        RAISE NOTICE 'Meta criada para categoria: %', cat;
    END LOOP;
END $$;

-- ========================================
-- PASSO 9: SIMULAR TRIGGER COMPLETO
-- ========================================

SELECT '⚡ PASSO 9: SIMULANDO TRIGGER' as passo;

-- Verificar trigger exists
SELECT 
    trigger_name,
    event_object_table,
    action_timing,
    event_manipulation
FROM information_schema.triggers 
WHERE trigger_name = 'update_category_goals_on_workout_trigger';

-- Para testar o trigger, você precisará inserir na tabela workout_records
-- Exemplo (descomente se a tabela existir):
/*
INSERT INTO workout_records (
    user_id, 
    workout_type, 
    duration_minutes,
    created_at
) VALUES (
    (SELECT user_id FROM workout_category_goals LIMIT 1),
    'Musculação',
    45,
    NOW()
);
*/

-- ========================================
-- PASSO 10: VERIFICAR LOGS
-- ========================================

SELECT '📝 PASSO 10: VERIFICANDO LOGS' as passo;

-- Se existir tabela de logs
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'goal_update_logs')
        THEN (
            SELECT count(*)::text || ' logs encontrados' 
            FROM goal_update_logs 
            WHERE updated_at >= CURRENT_DATE
        )
        ELSE 'Tabela de logs não existe'
    END as status_logs;

-- Ver logs recentes se existir
/*
SELECT 
    exercise_type_original,
    exercise_type_normalized,
    duration_minutes,
    updated_at
FROM goal_update_logs 
ORDER BY updated_at DESC 
LIMIT 5;
*/

-- ========================================
-- RESUMO DOS RESULTADOS
-- ========================================

SELECT '📊 RESUMO FINAL' as passo;

-- Estatísticas gerais
SELECT 
    'Total de metas ativas' as metrica,
    count(*)::text as valor
FROM workout_category_goals 
WHERE is_active = true

UNION ALL

SELECT 
    'Categorias diferentes' as metrica,
    count(DISTINCT category)::text as valor
FROM workout_category_goals 
WHERE is_active = true

UNION ALL

SELECT 
    'Metas completadas' as metrica,
    count(*)::text as valor
FROM workout_category_goals 
WHERE is_active = true AND completed = true

UNION ALL

SELECT 
    'Metas desta semana' as metrica,
    count(*)::text as valor
FROM workout_category_goals 
WHERE week_start_date = date_trunc('week', CURRENT_DATE)::date;

-- ========================================
-- VALIDAÇÕES FINAIS
-- ========================================

SELECT '✅ VALIDAÇÕES FINAIS' as passo;

-- Verificar consistência dos dados
WITH validacao AS (
    SELECT 
        id,
        category,
        goal_minutes,
        current_minutes,
        completed,
        CASE 
            WHEN goal_minutes <= 0 THEN 'Erro: Meta inválida'
            WHEN current_minutes < 0 THEN 'Erro: Minutos negativos'
            WHEN completed = true AND current_minutes < goal_minutes THEN 'Erro: Marcada completa mas sem atingir meta'
            WHEN completed = false AND current_minutes >= goal_minutes THEN 'Aviso: Atingiu meta mas não marcada como completa'
            ELSE 'OK'
        END as validacao
    FROM workout_category_goals 
    WHERE is_active = true
)
SELECT 
    validacao,
    count(*) as quantidade
FROM validacao
GROUP BY validacao
ORDER BY validacao;

SELECT 'Teste completo finalizado! ✨' as resultado; 