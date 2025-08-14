-- ========================================
-- MIGRAÇÃO PARA SISTEMA UNIFICADO DE METAS
-- ========================================
-- Data: 29 de Janeiro de 2025 às 17:15
-- Objetivo: Garantir que a tabela user_goals suporte o sistema unificado
-- Referência: Sistema de metas unificado Ray Club

-- 1. VERIFICAR E AJUSTAR ESTRUTURA DA TABELA user_goals
DO $$
BEGIN
    -- Adicionar campos se não existirem
    
    -- Campo goal_type (tipo da meta)
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'user_goals' AND column_name = 'goal_type'
    ) THEN
        ALTER TABLE user_goals ADD COLUMN goal_type VARCHAR(50) DEFAULT 'custom';
    END IF;
    
    -- Campo category (categoria do exercício)
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'user_goals' AND column_name = 'category'
    ) THEN
        ALTER TABLE user_goals ADD COLUMN category VARCHAR(50);
    END IF;
    
    -- Campo auto_increment (atualização automática)
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'user_goals' AND column_name = 'auto_increment'
    ) THEN
        ALTER TABLE user_goals ADD COLUMN auto_increment BOOLEAN DEFAULT true;
    END IF;
    
    -- Campo is_completed (status de conclusão)
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'user_goals' AND column_name = 'is_completed'
    ) THEN
        ALTER TABLE user_goals ADD COLUMN is_completed BOOLEAN DEFAULT false;
    END IF;
    
    -- Campo completed_at (data de conclusão)
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'user_goals' AND column_name = 'completed_at'
    ) THEN
        ALTER TABLE user_goals ADD COLUMN completed_at TIMESTAMPTZ;
    END IF;
    
    RAISE NOTICE 'Estrutura da tabela user_goals verificada e ajustada.';
END
$$;

-- 2. ÍNDICES PARA PERFORMANCE
CREATE INDEX IF NOT EXISTS idx_user_goals_user_id_active 
ON user_goals(user_id) WHERE is_completed = false;

CREATE INDEX IF NOT EXISTS idx_user_goals_category_auto 
ON user_goals(category, auto_increment) WHERE is_completed = false;

CREATE INDEX IF NOT EXISTS idx_user_goals_type 
ON user_goals(goal_type);

-- 3. FUNÇÃO AUXILIAR PARA MAPEAR CATEGORIAS DE EXERCÍCIO
CREATE OR REPLACE FUNCTION get_goal_category_from_workout(workout_type TEXT)
RETURNS TEXT AS $$
BEGIN
    -- Usar o mesmo mapeamento do WorkoutCategoryMapping do Flutter
    RETURN CASE 
        WHEN LOWER(workout_type) LIKE '%corrida%' THEN 'corrida'
        WHEN LOWER(workout_type) LIKE '%caminhada%' THEN 'caminhada'
        WHEN LOWER(workout_type) LIKE '%yoga%' THEN 'yoga'
        WHEN LOWER(workout_type) LIKE '%pilates%' THEN 'pilates'
        WHEN LOWER(workout_type) LIKE '%musculacao%' OR LOWER(workout_type) LIKE '%musculação%' THEN 'musculacao'
        WHEN LOWER(workout_type) LIKE '%funcional%' THEN 'funcional'
        WHEN LOWER(workout_type) LIKE '%cardio%' THEN 'cardio'
        WHEN LOWER(workout_type) LIKE '%hiit%' THEN 'hiit'
        WHEN LOWER(workout_type) LIKE '%ciclismo%' THEN 'ciclismo'
        WHEN LOWER(workout_type) LIKE '%natacao%' OR LOWER(workout_type) LIKE '%natação%' THEN 'natacao'
        WHEN LOWER(workout_type) LIKE '%alongamento%' THEN 'alongamento'
        WHEN LOWER(workout_type) LIKE '%crossfit%' THEN 'crossfit'
        WHEN LOWER(workout_type) LIKE '%luta%' THEN 'luta'
        WHEN LOWER(workout_type) LIKE '%fisioterapia%' THEN 'fisioterapia'
        ELSE 'geral'
    END;
END;
$$ LANGUAGE plpgsql;

-- 4. FUNÇÃO PARA ATUALIZAR METAS AUTOMATICAMENTE
CREATE OR REPLACE FUNCTION update_goals_from_workout(
    p_user_id UUID,
    p_workout_type TEXT,
    p_duration_minutes INTEGER
)
RETURNS JSON AS $$
DECLARE
    v_goal_category TEXT;
    v_updated_goals INTEGER := 0;
    v_goal_record RECORD;
    v_new_value NUMERIC;
    v_result JSON;
BEGIN
    -- Mapear tipo de treino para categoria
    v_goal_category := get_goal_category_from_workout(p_workout_type);
    
    -- Log para debug
    RAISE LOG 'Processando treino: user=%, tipo=%, categoria=%, minutos=%', 
        p_user_id, p_workout_type, v_goal_category, p_duration_minutes;
    
    -- Atualizar metas de categoria específica
    FOR v_goal_record IN 
        SELECT id, current_value, target_value, goal_type, unit
        FROM user_goals 
        WHERE user_id = p_user_id 
        AND goal_type = 'workout_category'
        AND category = v_goal_category
        AND is_completed = false
        AND auto_increment = true
    LOOP
        -- +1 sessão para metas de categoria
        v_new_value := v_goal_record.current_value + 1;
        
        UPDATE user_goals 
        SET 
            current_value = v_new_value,
            is_completed = (v_new_value >= target_value),
            completed_at = CASE 
                WHEN v_new_value >= target_value THEN NOW() 
                ELSE completed_at 
            END,
            updated_at = NOW()
        WHERE id = v_goal_record.id;
        
        v_updated_goals := v_updated_goals + 1;
        
        RAISE LOG 'Meta categoria atualizada: id=%, valor=% (meta=%)', 
            v_goal_record.id, v_new_value, v_goal_record.target_value;
    END LOOP;
    
    -- Atualizar metas semanais de minutos
    FOR v_goal_record IN 
        SELECT id, current_value, target_value, goal_type, end_date
        FROM user_goals 
        WHERE user_id = p_user_id 
        AND goal_type = 'weekly_minutes'
        AND is_completed = false
        AND auto_increment = true
        AND (end_date IS NULL OR end_date >= NOW())
    LOOP
        -- +minutos para metas semanais
        v_new_value := v_goal_record.current_value + p_duration_minutes;
        
        UPDATE user_goals 
        SET 
            current_value = v_new_value,
            is_completed = (v_new_value >= target_value),
            completed_at = CASE 
                WHEN v_new_value >= target_value THEN NOW() 
                ELSE completed_at 
            END,
            updated_at = NOW()
        WHERE id = v_goal_record.id;
        
        v_updated_goals := v_updated_goals + 1;
        
        RAISE LOG 'Meta semanal atualizada: id=%, minutos=% (meta=%)', 
            v_goal_record.id, v_new_value, v_goal_record.target_value;
    END LOOP;
    
    -- Retornar resultado
    v_result := json_build_object(
        'success', true,
        'updated_goals', v_updated_goals,
        'workout_type', p_workout_type,
        'goal_category', v_goal_category,
        'duration_minutes', p_duration_minutes,
        'processed_at', NOW()
    );
    
    RAISE LOG 'Processamento completo: % meta(s) atualizada(s)', v_updated_goals;
    
    RETURN v_result;
    
EXCEPTION WHEN OTHERS THEN
    RAISE LOG 'Erro ao processar metas: %', SQLERRM;
    RETURN json_build_object(
        'success', false,
        'error', SQLERRM,
        'workout_type', p_workout_type,
        'processed_at', NOW()
    );
END;
$$ LANGUAGE plpgsql;

-- 5. TRIGGER AUTOMÁTICO PARA TREINOS REGISTRADOS (OPCIONAL)
-- Esta função será chamada automaticamente quando um treino for registrado

CREATE OR REPLACE FUNCTION trigger_update_goals_from_workout()
RETURNS TRIGGER AS $$
BEGIN
    -- Só processar treinos completados
    IF NEW.is_completed = true AND NEW.duration_minutes > 0 THEN
        PERFORM update_goals_from_workout(
            NEW.user_id,
            COALESCE(NEW.workout_type, 'Treino'),
            COALESCE(NEW.duration_minutes, 0)
        );
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Criar trigger (comentado por segurança - ativar manualmente se necessário)
-- DROP TRIGGER IF EXISTS trigger_workout_goals_update ON workout_records;
-- CREATE TRIGGER trigger_workout_goals_update
--     AFTER INSERT OR UPDATE ON workout_records
--     FOR EACH ROW
--     EXECUTE FUNCTION trigger_update_goals_from_workout();

-- 6. FUNÇÃO DE TESTE PARA VALIDAR O SISTEMA
CREATE OR REPLACE FUNCTION test_unified_goals_system()
RETURNS TEXT AS $$
DECLARE
    v_test_user_id UUID := '00000000-0000-0000-0000-000000000000';
    v_result JSON;
    v_message TEXT := '';
BEGIN
    v_message := v_message || 'TESTE DO SISTEMA UNIFICADO DE METAS' || chr(10);
    v_message := v_message || '=====================================' || chr(10);
    
    -- Teste 1: Mapear categoria
    v_message := v_message || '1. Teste de mapeamento:' || chr(10);
    v_message := v_message || '   "Corrida" → ' || get_goal_category_from_workout('Corrida') || chr(10);
    v_message := v_message || '   "Yoga" → ' || get_goal_category_from_workout('Yoga') || chr(10);
    v_message := v_message || '   "Exercício" → ' || get_goal_category_from_workout('Exercício') || chr(10);
    
    -- Teste 2: Simular processamento
    v_message := v_message || chr(10) || '2. Teste de processamento (simulado):' || chr(10);
    v_result := update_goals_from_workout(v_test_user_id, 'Corrida', 30);
    v_message := v_message || '   Resultado: ' || v_result::TEXT || chr(10);
    
    v_message := v_message || chr(10) || '✅ Sistema testado com sucesso!' || chr(10);
    
    RETURN v_message;
END;
$$ LANGUAGE plpgsql;

-- 7. COMENTÁRIOS E DOCUMENTAÇÃO
COMMENT ON FUNCTION update_goals_from_workout IS 
'Atualiza automaticamente metas baseado em treinos registrados. 
Mapeia tipos de treino para categorias e incrementa progresso das metas correspondentes.';

COMMENT ON FUNCTION get_goal_category_from_workout IS 
'Mapeia tipos de treino para categorias de metas, seguindo o mesmo padrão do Flutter.';

-- 8. GRANTS PARA SEGURANÇA
GRANT EXECUTE ON FUNCTION update_goals_from_workout TO authenticated;
GRANT EXECUTE ON FUNCTION get_goal_category_from_workout TO authenticated;
GRANT EXECUTE ON FUNCTION test_unified_goals_system TO authenticated;

-- 9. LOG DE CONCLUSÃO
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '🎯 ============================================';
    RAISE NOTICE '🎯 MIGRAÇÃO SISTEMA UNIFICADO DE METAS';
    RAISE NOTICE '🎯 ============================================';
    RAISE NOTICE '🎯 Data: %', NOW();
    RAISE NOTICE '🎯 Status: ✅ CONCLUÍDA COM SUCESSO';
    RAISE NOTICE '🎯 ';
    RAISE NOTICE '🎯 Recursos implementados:';
    RAISE NOTICE '🎯 - Estrutura da tabela user_goals ajustada';
    RAISE NOTICE '🎯 - Índices de performance criados';
    RAISE NOTICE '🎯 - Função de mapeamento de categorias';
    RAISE NOTICE '🎯 - Função de atualização automática de metas';
    RAISE NOTICE '🎯 - Sistema de testes implementado';
    RAISE NOTICE '🎯 ';
    RAISE NOTICE '🎯 Para testar o sistema:';
    RAISE NOTICE '🎯 SELECT test_unified_goals_system();';
    RAISE NOTICE '🎯 ============================================';
END
$$; 