-- 🚀 CORREÇÃO RÁPIDA: Resolver erro "workout_record has no field category"
-- Execute este arquivo no Supabase SQL Editor agora mesmo!

-- ✅ CORRIGIR FUNÇÃO PRINCIPAL (trocar category por workout_type)
CREATE OR REPLACE FUNCTION sync_workout_to_weekly_goals_expanded()
RETURNS TRIGGER AS $$
BEGIN
    -- Verificar se função de metas existe
    IF NOT EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'update_weekly_goal_progress') THEN
        RETURN NEW; -- Se não existe, só continua sem erro
    END IF;
    
    -- Atualizar metas usando workout_type (não category)
    PERFORM update_weekly_goal_progress(NEW.user_id, NEW.duration_minutes::NUMERIC, 'minutes');
    
    -- Cardio
    IF NEW.workout_type ILIKE '%cardio%' OR NEW.workout_type ILIKE '%corrida%' THEN
        PERFORM update_weekly_goal_progress(NEW.user_id, NEW.duration_minutes::NUMERIC, 'cardio_minutes');
    END IF;
    
    -- Força  
    IF NEW.workout_type ILIKE '%funcional%' OR NEW.workout_type ILIKE '%musculação%' THEN
        PERFORM update_weekly_goal_progress(NEW.user_id, NEW.duration_minutes::NUMERIC, 'strength_minutes');
    END IF;
    
    -- Dias
    PERFORM update_weekly_goal_progress(NEW.user_id, 1::NUMERIC, 'days');
    
    RETURN NEW;
    
EXCEPTION WHEN OTHERS THEN
    RETURN NEW; -- Em caso de erro, não quebrar o registro de treino
END;
$$ LANGUAGE plpgsql;

-- ✅ GARANTIR QUE O TRIGGER ESTEJA ATIVO
DROP TRIGGER IF EXISTS sync_workout_to_weekly_goals_expanded_trigger ON workout_records;
CREATE TRIGGER sync_workout_to_weekly_goals_expanded_trigger
    AFTER INSERT ON workout_records
    FOR EACH ROW
    EXECUTE FUNCTION sync_workout_to_weekly_goals_expanded();

SELECT '🎯 PRONTO! Agora teste o registro de treinos no app - deve funcionar!' as resultado; 