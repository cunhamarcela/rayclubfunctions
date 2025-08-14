-- =====================================================
-- 🔧 CORREÇÃO COMPLETA DE ALINHAMENTO
-- =====================================================
-- Data: 2025-01-30
-- Objetivo: Alinhar PERFEITAMENTE código Flutter ↔ Supabase
-- Status: Correção baseada no diagnóstico real
-- =====================================================

-- 1. ADICIONAR COLUNAS FALTANTES
SELECT '🔧 === ADICIONANDO COLUNAS FALTANTES ===' AS etapa_1;

-- Adicionar description
ALTER TABLE public.user_goals ADD COLUMN IF NOT EXISTS description TEXT;

-- Adicionar completed_at  
ALTER TABLE public.user_goals ADD COLUMN IF NOT EXISTS completed_at TIMESTAMPTZ;

-- Criar aliases/views para compatibilidade com código Flutter
-- (Manter nomes do banco, mas criar getters no código)

SELECT '✅ Colunas adicionadas com sucesso' AS resultado_1;

-- 2. VERIFICAR MAPEAMENTO DE COLUNAS ATUAL
SELECT '📋 === MAPEAMENTO FINAL DE COLUNAS ===' AS etapa_2;

SELECT 
    '🔗 MAPEAMENTO CORRETO' AS info,
    'Flutter: targetValue' AS flutter_field,
    'Supabase: target_value' AS supabase_column,
    'USAR: data[''target_value'']' AS codigo_correto
UNION ALL
SELECT 
    '🔗 MAPEAMENTO CORRETO',
    'Flutter: currentValue',
    'Supabase: current_value', 
    'USAR: data[''current_value'']'
UNION ALL
SELECT 
    '🔗 MAPEAMENTO CORRETO',
    'Flutter: type.value',
    'Supabase: goal_type',
    'USAR: data[''goal_type'']'
UNION ALL
SELECT 
    '🔗 MAPEAMENTO CORRETO',
    'Flutter: endDate',
    'Supabase: target_date',
    'USAR: data[''target_date'']';

-- 3. ATUALIZAR CATEGORIAS PARA ALINHAR COM workout_records
SELECT '🏷️ === ALINHANDO CATEGORIAS DE EXERCÍCIO ===' AS etapa_3;

-- Mostrar tipos existentes no banco
SELECT 
    '📊 TIPOS EXISTENTES EM workout_records' AS info,
    workout_type,
    COUNT(*) as quantidade
FROM public.workout_records 
WHERE workout_type IS NOT NULL
GROUP BY workout_type
ORDER BY quantidade DESC;

-- 4. CRIAR FUNÇÃO DE CONVERSÃO FLUTTER ↔ SUPABASE
CREATE OR REPLACE FUNCTION map_flutter_to_supabase_goal(
    p_id UUID,
    p_user_id UUID,
    p_title TEXT,
    p_description TEXT,
    p_type TEXT,
    p_category TEXT,
    p_target_value NUMERIC,
    p_current_value NUMERIC,
    p_unit TEXT,
    p_measurement_type TEXT,
    p_start_date TIMESTAMPTZ,
    p_end_date TIMESTAMPTZ,
    p_completed_at TIMESTAMPTZ
) RETURNS UUID AS $$
DECLARE
    v_goal_id UUID;
BEGIN
    INSERT INTO public.user_goals (
        id, user_id, title, description, goal_type, category,
        target_value, current_value, unit, measurement_type,
        start_date, target_date, completed_at, created_at, updated_at
    ) VALUES (
        p_id, p_user_id, p_title, p_description, p_type, p_category,
        p_target_value, p_current_value, p_unit, p_measurement_type,
        p_start_date, p_end_date, p_completed_at, NOW(), NOW()
    ) 
    ON CONFLICT (id) DO UPDATE SET
        title = EXCLUDED.title,
        description = EXCLUDED.description,
        goal_type = EXCLUDED.goal_type,
        category = EXCLUDED.category,
        target_value = EXCLUDED.target_value,
        current_value = EXCLUDED.current_value,
        unit = EXCLUDED.unit,
        measurement_type = EXCLUDED.measurement_type,
        start_date = EXCLUDED.start_date,
        target_date = EXCLUDED.target_date,
        completed_at = EXCLUDED.completed_at,
        updated_at = NOW()
    RETURNING id INTO v_goal_id;
    
    RETURN v_goal_id;
END;
$$ LANGUAGE plpgsql;

SELECT '✅ Função de mapeamento criada' AS resultado_4;

-- 5. ATUALIZAR TRIGGER PARA USAR NOMES CORRETOS
CREATE OR REPLACE FUNCTION update_goals_from_workout_fixed()
RETURNS TRIGGER AS $$
BEGIN
    -- Atualizar metas que coincidem com o tipo de treino
    UPDATE public.user_goals 
    SET 
        current_value = current_value + NEW.duration_minutes,  -- NOME CORRETO
        updated_at = NOW()
    WHERE 
        user_id = NEW.user_id
        AND category = NEW.workout_type
        AND measurement_type = 'minutes'
        AND completed_at IS NULL;
    
    -- Log da operação
    RAISE NOTICE 'Meta atualizada: usuário %, +% minutos de %', 
        NEW.user_id, NEW.duration_minutes, NEW.workout_type;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Recriar trigger com função corrigida
DROP TRIGGER IF EXISTS trigger_update_goals_from_workout ON public.workout_records;
CREATE TRIGGER trigger_update_goals_from_workout
    AFTER INSERT OR UPDATE ON public.workout_records
    FOR EACH ROW
    WHEN (NEW.is_completed = true)
    EXECUTE FUNCTION update_goals_from_workout_fixed();

SELECT '✅ Trigger atualizado com nomes corretos' AS resultado_5;

-- 6. FUNÇÃO CORRIGIDA PARA CHECK-IN MANUAL
CREATE OR REPLACE FUNCTION register_goal_checkin_fixed(
    p_goal_id UUID,
    p_user_id UUID
) RETURNS BOOLEAN AS $$
DECLARE
    v_goal_exists BOOLEAN;
    v_rows_updated INTEGER;
BEGIN
    -- Verificar se a meta existe e pertence ao usuário
    SELECT EXISTS (
        SELECT 1 FROM public.user_goals 
        WHERE id = p_goal_id 
          AND user_id = p_user_id
          AND measurement_type = 'days'
          AND completed_at IS NULL
    ) INTO v_goal_exists;
    
    IF NOT v_goal_exists THEN
        RAISE NOTICE '❌ Meta não encontrada ou não é do tipo days: %', p_goal_id;
        RETURN FALSE;
    END IF;
    
    -- Incrementar progresso da meta
    UPDATE public.user_goals 
    SET 
        current_value = current_value + 1,  -- NOME CORRETO
        updated_at = NOW()
    WHERE id = p_goal_id 
      AND user_id = p_user_id;
    
    GET DIAGNOSTICS v_rows_updated = ROW_COUNT;
    
    IF v_rows_updated > 0 THEN
        RAISE NOTICE '✅ Check-in registrado para meta: %', p_goal_id;
        RETURN TRUE;
    ELSE
        RAISE NOTICE '❌ Falha ao registrar check-in para meta: %', p_goal_id;
        RETURN FALSE;
    END IF;
END;
$$ LANGUAGE plpgsql;

SELECT '✅ Função de check-in corrigida' AS resultado_6;

-- 7. TESTE RÁPIDO COM ESTRUTURA CORRETA
SELECT '🧪 === TESTE RÁPIDO COM ESTRUTURA CORRETA ===' AS etapa_7;

-- Inserir meta de teste usando nomes corretos
SELECT map_flutter_to_supabase_goal(
    '99999999-9999-9999-9999-999999999999'::uuid,
    '01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid,
    'TESTE: Meta Alinhada',
    'Teste com estrutura correta',
    'workout_category',
    'Funcional',
    120.0,  -- target_value
    0.0,    -- current_value
    'minutos',
    'minutes',
    NOW(),
    NULL,
    NULL
) AS meta_teste_criada;

-- Verificar se foi inserida corretamente
SELECT 
    '✅ VERIFICAÇÃO DA META TESTE' AS resultado,
    title,
    goal_type,
    category,
    target_value,
    current_value,
    measurement_type
FROM public.user_goals 
WHERE id = '99999999-9999-9999-9999-999999999999'::uuid;

-- 8. ESTRUTURA FINAL ALINHADA
SELECT '📋 === ESTRUTURA FINAL ALINHADA ===' AS etapa_8;

SELECT 
    '📊 ESTRUTURA FINAL DA TABELA' AS info,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'user_goals' 
  AND table_schema = 'public'
ORDER BY ordinal_position;

-- LIMPEZA
DELETE FROM public.user_goals WHERE id = '99999999-9999-9999-9999-999999999999'::uuid;

SELECT '🎯 === ALINHAMENTO COMPLETO FINALIZADO! ===' AS conclusao;

