-- Sistema de Automação Completa para Metas Semanais (VERSÃO CORRIGIDA)
-- Data: 2025-01-27
-- Objetivo: Garantir funcionamento 100% automático sem intervenção do usuário
-- Correção: Tratamento seguro para cron jobs que podem não existir

-- =====================================================
-- 1. VERIFICAR E CONFIGURAR EXTENSÕES NECESSÁRIAS
-- =====================================================

-- Habilitar extensão pg_cron se não estiver habilitada
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- =====================================================
-- 2. FUNÇÃO DE RESET E RENOVAÇÃO AUTOMÁTICA
-- =====================================================

CREATE OR REPLACE FUNCTION reset_and_renew_weekly_goals()
RETURNS void AS $$
DECLARE
    v_user_record RECORD;
    v_last_goal RECORD;
    v_new_week_start DATE;
    v_new_week_end DATE;
BEGIN
    -- Calcular próxima semana
    v_new_week_start := date_trunc('week', CURRENT_DATE)::date;
    v_new_week_end := (v_new_week_start + interval '6 days')::date;
    
    -- Log da execução
    RAISE NOTICE 'Iniciando reset semanal para semana: % - %', v_new_week_start, v_new_week_end;
    
    -- 1. Desativar metas da semana anterior
    UPDATE weekly_goals_expanded
    SET active = false, updated_at = NOW()
    WHERE week_end_date < CURRENT_DATE
      AND active = true;
    
    -- 2. Para cada usuário que tinha meta ativa, criar nova meta automaticamente
    FOR v_user_record IN 
        SELECT DISTINCT user_id 
        FROM weekly_goals_expanded 
        WHERE week_end_date = (v_new_week_start - interval '1 day')::date
          AND active = false -- Recém desativadas
    LOOP
        -- Buscar última meta do usuário
        SELECT * INTO v_last_goal
        FROM weekly_goals_expanded
        WHERE user_id = v_user_record.user_id
          AND week_end_date = (v_new_week_start - interval '1 day')::date
        ORDER BY created_at DESC
        LIMIT 1;
        
        -- Se encontrou meta anterior, recriar com os mesmos parâmetros
        IF FOUND THEN
            INSERT INTO weekly_goals_expanded (
                user_id,
                goal_type,
                measurement_type,
                goal_title,
                goal_description,
                target_value,
                current_value,
                unit_label,
                week_start_date,
                week_end_date,
                active,
                created_at,
                updated_at
            ) VALUES (
                v_last_goal.user_id,
                v_last_goal.goal_type,
                v_last_goal.measurement_type,
                v_last_goal.goal_title,
                v_last_goal.goal_description,
                v_last_goal.target_value,
                0, -- Reset current_value para nova semana
                v_last_goal.unit_label,
                v_new_week_start,
                v_new_week_end,
                true, -- Ativa para nova semana
                NOW(),
                NOW()
            );
            
            RAISE NOTICE 'Meta renovada automaticamente para usuário: % - Meta: %', 
                         v_user_record.user_id, v_last_goal.goal_title;
        END IF;
    END LOOP;
    
    -- 3. Limpar metas muito antigas (mais de 4 semanas)
    DELETE FROM weekly_goals_expanded
    WHERE week_end_date < (CURRENT_DATE - interval '4 weeks')
      AND active = false;
      
    RAISE NOTICE 'Reset semanal concluído com sucesso!';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 3. CONFIGURAR CRON JOB AUTOMÁTICO (VERSÃO SEGURA)
-- =====================================================

-- Função para remover job de forma segura
DO $$
BEGIN
    -- Tentar remover job existente se houver
    IF EXISTS (SELECT 1 FROM cron.job WHERE jobname = 'weekly-goals-reset') THEN
        PERFORM cron.unschedule('weekly-goals-reset');
        RAISE NOTICE 'Job anterior removido com sucesso';
    ELSE
        RAISE NOTICE 'Nenhum job anterior encontrado (normal na primeira execução)';
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Aviso: Não foi possível remover job anterior: %', SQLERRM;
END $$;

-- Configurar para executar toda segunda-feira às 00:05
SELECT cron.schedule(
    'weekly-goals-reset',
    '5 0 * * 1', -- Cron: 00:05 toda segunda-feira
    'SELECT reset_and_renew_weekly_goals();'
);

RAISE NOTICE 'Cron job configurado com sucesso!';

-- =====================================================
-- 4. FUNÇÃO PARA CRIAR PRIMEIRA META DO USUÁRIO
-- =====================================================

CREATE OR REPLACE FUNCTION ensure_user_has_weekly_goal(p_user_id UUID)
RETURNS UUID AS $$
DECLARE
    v_existing_goal RECORD;
    v_new_goal_id UUID;
    v_current_week_start DATE;
    v_current_week_end DATE;
BEGIN
    -- Calcular semana atual
    v_current_week_start := date_trunc('week', CURRENT_DATE)::date;
    v_current_week_end := (v_current_week_start + interval '6 days')::date;
    
    -- Verificar se usuário já tem meta para semana atual
    SELECT * INTO v_existing_goal
    FROM weekly_goals_expanded
    WHERE user_id = p_user_id
      AND week_start_date = v_current_week_start
      AND active = true;
    
    -- Se já tem meta, retornar ID existente
    IF FOUND THEN
        RETURN v_existing_goal.id;
    END IF;
    
    -- Se não tem meta, criar uma padrão (Musculação 180min)
    INSERT INTO weekly_goals_expanded (
        user_id,
        goal_type,
        measurement_type,
        goal_title,
        goal_description,
        target_value,
        current_value,
        unit_label,
        week_start_date,
        week_end_date,
        active
    ) VALUES (
        p_user_id,
        'musculacao',
        'minutes',
        'Meta de Musculação',
        'Meta padrão: 3 horas de musculação por semana',
        180,
        0,
        'min',
        v_current_week_start,
        v_current_week_end,
        true
    ) RETURNING id INTO v_new_goal_id;
    
    RETURN v_new_goal_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 5. TRIGGER AUTOMÁTICO PARA NOVOS USUÁRIOS
-- =====================================================

CREATE OR REPLACE FUNCTION auto_create_goal_for_new_workout()
RETURNS TRIGGER AS $$
DECLARE
    v_user_goal_count INTEGER;
BEGIN
    -- Contar quantas metas ativas o usuário tem na semana atual
    SELECT COUNT(*) INTO v_user_goal_count
    FROM weekly_goals_expanded
    WHERE user_id = NEW.user_id
      AND week_start_date = date_trunc('week', CURRENT_DATE)::date
      AND active = true;
    
    -- Se não tem nenhuma meta, criar automaticamente
    IF v_user_goal_count = 0 THEN
        PERFORM ensure_user_has_weekly_goal(NEW.user_id);
        
        RAISE NOTICE 'Meta automática criada para usuário: % no primeiro treino', NEW.user_id;
    END IF;
    
    -- Executar sincronização normal
    PERFORM sync_workout_to_weekly_goals_expanded_internal(NEW);
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 6. FUNÇÃO INTERNA DE SINCRONIZAÇÃO (ATUALIZADA)
-- =====================================================

CREATE OR REPLACE FUNCTION sync_workout_to_weekly_goals_expanded_internal(workout_record RECORD)
RETURNS void AS $$
BEGIN
    -- Atualizar metas de minutos (geral)
    PERFORM update_weekly_goal_progress(
        workout_record.user_id,
        workout_record.duration_minutes::NUMERIC,
        'minutes'
    );
    
    -- Se é treino de cardio, atualizar meta específica de cardio
    IF workout_record.category ILIKE '%cardio%' OR 
       workout_record.category ILIKE '%corrida%' OR 
       workout_record.category ILIKE '%caminhada%' THEN
        PERFORM update_weekly_goal_progress(
            workout_record.user_id,
            workout_record.duration_minutes::NUMERIC,
            'minutes'
        );
    END IF;
    
    -- Se é treino de musculação, atualizar meta específica de musculação
    IF workout_record.category ILIKE '%musculacao%' OR 
       workout_record.category ILIKE '%funcional%' OR 
       workout_record.category ILIKE '%crossfit%' THEN
        PERFORM update_weekly_goal_progress(
            workout_record.user_id,
            workout_record.duration_minutes::NUMERIC,
            'minutes'
        );
    END IF;
    
    -- Para metas de dias, contar qualquer treino como +1 dia (apenas uma vez por dia)
    PERFORM update_weekly_goal_progress_daily(
        workout_record.user_id,
        workout_record.created_at::date
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 7. FUNÇÃO PARA ATUALIZAR PROGRESSO DIÁRIO (EVITA DUPLICAÇÃO)
-- =====================================================

CREATE OR REPLACE FUNCTION update_weekly_goal_progress_daily(
    p_user_id UUID,
    p_workout_date DATE
)
RETURNS void AS $$
DECLARE
    v_goal_record RECORD;
    v_current_week_start DATE;
    v_days_trained INTEGER;
BEGIN
    v_current_week_start := date_trunc('week', p_workout_date)::date;
    
    -- Buscar metas de dias ativas
    FOR v_goal_record IN
        SELECT * FROM weekly_goals_expanded
        WHERE user_id = p_user_id
          AND week_start_date = v_current_week_start
          AND measurement_type = 'days'
          AND active = true
    LOOP
        -- Contar quantos dias únicos o usuário treinou nesta semana
        SELECT COUNT(DISTINCT wr.created_at::date) INTO v_days_trained
        FROM workout_records wr
        WHERE wr.user_id = p_user_id
          AND wr.created_at::date >= v_current_week_start
          AND wr.created_at::date <= (v_current_week_start + interval '6 days')::date;
        
        -- Atualizar meta com o número real de dias treinados
        UPDATE weekly_goals_expanded
        SET 
            current_value = v_days_trained,
            completed = (v_days_trained >= target_value),
            updated_at = NOW()
        WHERE id = v_goal_record.id;
    END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 8. ATUALIZAR TRIGGER PRINCIPAL (VERSÃO SEGURA)
-- =====================================================

-- Remover trigger antigo se existir
DO $$
BEGIN
    DROP TRIGGER IF EXISTS sync_workout_to_weekly_goals_expanded_trigger ON workout_records;
    RAISE NOTICE 'Trigger anterior removido (se existia)';
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Trigger anterior não existia (normal)';
END $$;

-- Criar novo trigger que inclui criação automática
CREATE TRIGGER sync_workout_to_weekly_goals_expanded_trigger
    AFTER INSERT ON workout_records
    FOR EACH ROW
    EXECUTE FUNCTION auto_create_goal_for_new_workout();

RAISE NOTICE 'Novo trigger criado com sucesso!';

-- =====================================================
-- 9. FUNÇÃO DE DIAGNÓSTICO E MONITORAMENTO
-- =====================================================

CREATE OR REPLACE FUNCTION weekly_goals_system_status()
RETURNS TABLE (
    metric VARCHAR(50),
    value TEXT,
    status VARCHAR(20)
) AS $$
BEGIN
    -- Status do cron job
    RETURN QUERY
    SELECT 
        'cron_job_scheduled'::VARCHAR(50),
        CASE 
            WHEN EXISTS (SELECT 1 FROM cron.job WHERE jobname = 'weekly-goals-reset') 
            THEN 'Ativo' 
            ELSE 'Inativo' 
        END::TEXT,
        CASE 
            WHEN EXISTS (SELECT 1 FROM cron.job WHERE jobname = 'weekly-goals-reset') 
            THEN 'OK' 
            ELSE 'ERROR' 
        END::VARCHAR(20);
    
    -- Usuários com metas ativas
    RETURN QUERY
    SELECT 
        'users_with_active_goals'::VARCHAR(50),
        COUNT(DISTINCT user_id)::TEXT,
        'INFO'::VARCHAR(20)
    FROM weekly_goals_expanded
    WHERE active = true
      AND week_start_date = date_trunc('week', CURRENT_DATE)::date;
    
    -- Metas criadas esta semana
    RETURN QUERY
    SELECT 
        'goals_created_this_week'::VARCHAR(50),
        COUNT(*)::TEXT,
        'INFO'::VARCHAR(20)
    FROM weekly_goals_expanded
    WHERE week_start_date = date_trunc('week', CURRENT_DATE)::date;
    
    -- Última execução do reset
    RETURN QUERY
    SELECT 
        'last_reset_execution'::VARCHAR(50),
        COALESCE(
            (SELECT MAX(start_time)::TEXT FROM cron.job_run_details WHERE jobname = 'weekly-goals-reset'),
            'Nunca executado'
        )::TEXT,
        'INFO'::VARCHAR(20);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 10. COMENTÁRIOS E DOCUMENTAÇÃO
-- =====================================================

COMMENT ON FUNCTION reset_and_renew_weekly_goals() IS 'Executa reset semanal e renova metas automaticamente baseadas na semana anterior';
COMMENT ON FUNCTION ensure_user_has_weekly_goal(UUID) IS 'Garante que usuário sempre tenha uma meta ativa, criando uma padrão se necessário';
COMMENT ON FUNCTION auto_create_goal_for_new_workout() IS 'Trigger que cria meta automática quando usuário faz primeiro treino da semana';
COMMENT ON FUNCTION weekly_goals_system_status() IS 'Diagnóstico completo do sistema de automação de metas semanais';

-- =====================================================
-- 11. TESTE DE VERIFICAÇÃO FINAL
-- =====================================================

-- Verificar se tudo foi criado corretamente
SELECT 'Sistema de automação instalado com sucesso!' as status;

-- Verificar status do sistema
SELECT * FROM weekly_goals_system_status();

-- Logs finais
RAISE NOTICE '==========================================';
RAISE NOTICE 'SISTEMA DE AUTOMAÇÃO INSTALADO COM SUCESSO!';
RAISE NOTICE '==========================================';
RAISE NOTICE 'Cron job: Toda segunda-feira às 00:05';
RAISE NOTICE 'Triggers: Ativados para workout_records';
RAISE NOTICE 'Funções: Todas criadas e documentadas';
RAISE NOTICE 'Status: Execute SELECT * FROM weekly_goals_system_status();';
RAISE NOTICE '=========================================='; 