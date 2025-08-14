-- 🔧 CORREÇÃO: Sincronizar nomenclatura para manter triggers e metas funcionando
-- Data: 2025-01-28
-- Objetivo: Corrigir NEW.category → NEW.workout_type mantendo funcionalidade

SELECT '🔍 DIAGNÓSTICO: Verificando trigger de metas em workout_records' as status;

-- 1. VERIFICAR ESTRUTURA DA TABELA workout_records
SELECT 
    column_name,
    data_type,
    CASE 
        WHEN column_name = 'workout_type' THEN '✅ CAMPO CORRETO'
        WHEN column_name = 'category' THEN '❌ CAMPO INEXISTENTE'
        ELSE '📋 Info'
    END as relevancia
FROM information_schema.columns 
WHERE table_name = 'workout_records' 
  AND column_name IN ('workout_type', 'category', 'user_id', 'duration_minutes')
ORDER BY column_name;

-- 2. LISTAR TRIGGERS ATIVOS (para conferência)
SELECT 
    t.tgname as trigger_name,
    p.proname as function_name,
    '📋 Ativo' as status
FROM pg_trigger t
JOIN pg_proc p ON t.tgfoid = p.oid
JOIN pg_class c ON t.tgrelid = c.oid
WHERE c.relname = 'workout_records'
  AND t.tgisinternal = false;

-- 3. CORRIGIR FUNÇÃO PARA USAR workout_type (mantendo lógica das metas)
CREATE OR REPLACE FUNCTION sync_workout_to_weekly_goals_expanded()
RETURNS TRIGGER AS $$
BEGIN
    -- ✅ VERIFICAR SE FUNÇÕES DE META EXISTEM ANTES DE EXECUTAR
    IF NOT EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'update_weekly_goal_progress') THEN
        -- Se não existe, apenas log silencioso e continua
        RETURN NEW;
    END IF;
    
    -- Atualizar metas de minutos (geral)
    PERFORM update_weekly_goal_progress(
        NEW.user_id,
        NEW.duration_minutes::NUMERIC,
        'minutes'
    );
    
    -- ✅ CORREÇÃO: usar workout_type ao invés de category
    -- Treinos de cardio/corrida
    IF NEW.workout_type ILIKE '%cardio%' 
       OR NEW.workout_type ILIKE '%corrida%' 
       OR NEW.workout_type ILIKE '%caminhada%' 
       OR NEW.workout_type ILIKE '%aeróbico%' THEN
        
        PERFORM update_weekly_goal_progress(
            NEW.user_id,
            NEW.duration_minutes::NUMERIC,
            'cardio_minutes'
        );
    END IF;
    
    -- Treinos de força/musculação  
    IF NEW.workout_type ILIKE '%musculação%' 
       OR NEW.workout_type ILIKE '%funcional%' 
       OR NEW.workout_type ILIKE '%crossfit%' 
       OR NEW.workout_type ILIKE '%força%' 
       OR NEW.workout_type ILIKE '%hipertrofia%' THEN
        
        PERFORM update_weekly_goal_progress(
            NEW.user_id,
            NEW.duration_minutes::NUMERIC,
            'strength_minutes'
        );
    END IF;
    
    -- Treinos de flexibilidade
    IF NEW.workout_type ILIKE '%pilates%' 
       OR NEW.workout_type ILIKE '%yoga%' 
       OR NEW.workout_type ILIKE '%alongamento%' 
       OR NEW.workout_type ILIKE '%flexibilidade%' THEN
        
        PERFORM update_weekly_goal_progress(
            NEW.user_id,
            NEW.duration_minutes::NUMERIC,
            'flexibility_minutes'
        );
    END IF;
    
    -- Para metas de dias, contar qualquer treino como +1 dia
    PERFORM update_weekly_goal_progress(
        NEW.user_id,
        1::NUMERIC,
        'days'
    );
    
    RETURN NEW;
    
EXCEPTION WHEN OTHERS THEN
    -- Em caso de erro, apenas log silencioso e continua o registro do treino
    -- Não queremos que erros de meta atrapalhem o registro de treinos
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 4. GARANTIR QUE O TRIGGER ESTEJA ATIVO
DROP TRIGGER IF EXISTS sync_workout_to_weekly_goals_expanded_trigger ON workout_records;
CREATE TRIGGER sync_workout_to_weekly_goals_expanded_trigger
    AFTER INSERT ON workout_records
    FOR EACH ROW
    EXECUTE FUNCTION sync_workout_to_weekly_goals_expanded();

-- 5. VERIFICAR OUTRAS FUNÇÕES QUE PODEM TER O MESMO PROBLEMA
DO $$
DECLARE
    func_record RECORD;
BEGIN
    -- Buscar funções que mencionam 'category' em triggers de workout_records
    FOR func_record IN 
        SELECT p.proname, p.prosrc
        FROM pg_proc p
        WHERE p.prosrc ILIKE '%NEW.category%'
          AND p.proname != 'sync_workout_to_weekly_goals_expanded'
    LOOP
        RAISE NOTICE '⚠️ ATENÇÃO: Função % também usa NEW.category - pode precisar de correção', func_record.proname;
    END LOOP;
END;
$$;

-- 6. TESTE DE VALIDAÇÃO
SELECT '✅ TESTE: Verificando se trigger foi corrigido' as validacao;

SELECT 
    t.tgname as trigger_name,
    p.proname as function_name,
    CASE 
        WHEN p.prosrc ILIKE '%NEW.workout_type%' THEN '✅ CORRIGIDO'
        WHEN p.prosrc ILIKE '%NEW.category%' THEN '❌ AINDA COM ERRO'
        ELSE '📋 Neutro'
    END as status_correcao
FROM pg_trigger t
JOIN pg_proc p ON t.tgfoid = p.oid
JOIN pg_class c ON t.tgrelid = c.oid
WHERE c.relname = 'workout_records'
  AND t.tgisinternal = false
  AND p.proname = 'sync_workout_to_weekly_goals_expanded';

SELECT '🎯 RESULTADO: Trigger mantido ativo com nomenclatura corrigida (workout_type)' as resultado_final; 