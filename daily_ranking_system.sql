-- ================================================================
-- SISTEMA COMPLETO DE RANKING BASEADO EM CHECK-INS DIÁRIOS
-- Calcula rankings baseados em consistência, frequência e qualidade
-- ================================================================

\echo '🏆 IMPLEMENTANDO SISTEMA DE RANKING DIÁRIO'
\echo '=========================================='

-- ================================================================
-- 1. TABELA DE RANKINGS DIÁRIOS
-- ================================================================

\echo ''
\echo '📊 1. CRIANDO ESTRUTURA DE RANKINGS'

-- Tabela principal de rankings
CREATE TABLE IF NOT EXISTS daily_user_rankings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    ranking_date DATE NOT NULL DEFAULT CURRENT_DATE,
    
    -- Métricas básicas
    daily_workouts INTEGER DEFAULT 0,
    total_minutes INTEGER DEFAULT 0,
    valid_workouts INTEGER DEFAULT 0,  -- workouts >= 45 min
    
    -- Métricas de consistência (últimos períodos)
    streak_days INTEGER DEFAULT 0,      -- dias consecutivos
    weekly_frequency INTEGER DEFAULT 0, -- workouts últimos 7 dias
    monthly_frequency INTEGER DEFAULT 0, -- workouts últimos 30 dias
    
    -- Pontuações calculadas
    daily_points INTEGER DEFAULT 0,
    consistency_bonus INTEGER DEFAULT 0,
    quality_bonus INTEGER DEFAULT 0,
    total_score INTEGER DEFAULT 0,
    
    -- Posições no ranking
    daily_rank INTEGER,
    weekly_rank INTEGER,
    monthly_rank INTEGER,
    
    -- Metadados
    last_workout_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraints
    UNIQUE(user_id, ranking_date)
);

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_daily_rankings_date 
ON daily_user_rankings(ranking_date DESC);

CREATE INDEX IF NOT EXISTS idx_daily_rankings_user_date 
ON daily_user_rankings(user_id, ranking_date DESC);

CREATE INDEX IF NOT EXISTS idx_daily_rankings_score 
ON daily_user_rankings(total_score DESC, ranking_date DESC);

-- Tabela de histórico de streaks
CREATE TABLE IF NOT EXISTS user_workout_streaks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    days_count INTEGER DEFAULT 1,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(user_id, start_date)
);

CREATE INDEX IF NOT EXISTS idx_streaks_user_active 
ON user_workout_streaks(user_id, is_active, days_count DESC);

SELECT '✅ Estrutura de rankings criada' as resultado;

-- ================================================================
-- 2. FUNÇÃO PARA CALCULAR STREAK DE USUÁRIO
-- ================================================================

\echo ''
\echo '🔥 2. IMPLEMENTANDO CÁLCULO DE STREAKS'

CREATE OR REPLACE FUNCTION calculate_user_streak(p_user_id UUID, p_date DATE DEFAULT CURRENT_DATE)
RETURNS INTEGER AS $$
DECLARE
    v_streak_days INTEGER := 0;
    v_check_date DATE;
    v_has_workout BOOLEAN;
BEGIN
    -- Começar da data especificada e ir voltando
    v_check_date := p_date;
    
    -- Verificar cada dia consecutivo
    LOOP
        -- Verificar se há treino válido neste dia
        SELECT EXISTS(
            SELECT 1 FROM workout_records 
            WHERE user_id = p_user_id 
              AND DATE(date AT TIME ZONE 'America/Sao_Paulo') = v_check_date
              AND duration_minutes >= 45  -- Só treinos válidos contam
        ) INTO v_has_workout;
        
        -- Se não tem treino, parar a contagem
        IF NOT v_has_workout THEN
            EXIT;
        END IF;
        
        -- Incrementar streak e ir para dia anterior
        v_streak_days := v_streak_days + 1;
        v_check_date := v_check_date - INTERVAL '1 day';
        
        -- Limite de segurança (máximo 365 dias)
        IF v_streak_days >= 365 THEN
            EXIT;
        END IF;
    END LOOP;
    
    RETURN v_streak_days;
END;
$$ LANGUAGE plpgsql;

SELECT '✅ Função de cálculo de streak implementada' as resultado;

-- ================================================================
-- 3. FUNÇÃO PRINCIPAL DE CÁLCULO DE RANKING DIÁRIO
-- ================================================================

\echo ''
\echo '🎯 3. IMPLEMENTANDO CÁLCULO DE RANKING DIÁRIO'

CREATE OR REPLACE FUNCTION calculate_daily_ranking(p_target_date DATE DEFAULT CURRENT_DATE)
RETURNS TEXT AS $$
DECLARE
    v_user_record RECORD;
    v_streak_days INTEGER;
    v_weekly_count INTEGER;
    v_monthly_count INTEGER;
    v_daily_points INTEGER;
    v_consistency_bonus INTEGER;
    v_quality_bonus INTEGER;
    v_total_score INTEGER;
    v_users_processed INTEGER := 0;
BEGIN
    -- Processar cada usuário ativo
    FOR v_user_record IN 
        SELECT DISTINCT 
            wr.user_id,
            COUNT(*) as daily_workouts,
            SUM(wr.duration_minutes) as total_minutes,
            COUNT(*) FILTER (WHERE wr.duration_minutes >= 45) as valid_workouts,
            MAX(wr.created_at) as last_workout_at
        FROM workout_records wr
        WHERE DATE(wr.date AT TIME ZONE 'America/Sao_Paulo') = p_target_date
        GROUP BY wr.user_id
    LOOP
        -- 1. CALCULAR STREAK
        v_streak_days := calculate_user_streak(v_user_record.user_id, p_target_date);
        
        -- 2. CALCULAR FREQUÊNCIA SEMANAL (últimos 7 dias)
        SELECT COUNT(*) INTO v_weekly_count
        FROM workout_records 
        WHERE user_id = v_user_record.user_id
          AND DATE(date AT TIME ZONE 'America/Sao_Paulo') BETWEEN (p_target_date - INTERVAL '6 days') AND p_target_date
          AND duration_minutes >= 45;
        
        -- 3. CALCULAR FREQUÊNCIA MENSAL (últimos 30 dias)
        SELECT COUNT(*) INTO v_monthly_count
        FROM workout_records 
        WHERE user_id = v_user_record.user_id
          AND DATE(date AT TIME ZONE 'America/Sao_Paulo') BETWEEN (p_target_date - INTERVAL '29 days') AND p_target_date
          AND duration_minutes >= 45;
        
        -- 4. CALCULAR PONTUAÇÕES
        -- Pontos básicos diários (treinos válidos * 10)
        v_daily_points := v_user_record.valid_workouts * 10;
        
        -- Bônus de consistência (baseado em streak)
        v_consistency_bonus := CASE 
            WHEN v_streak_days >= 30 THEN 50  -- 1 mês = 50 pontos
            WHEN v_streak_days >= 14 THEN 30  -- 2 semanas = 30 pontos
            WHEN v_streak_days >= 7 THEN 15   -- 1 semana = 15 pontos
            WHEN v_streak_days >= 3 THEN 5    -- 3 dias = 5 pontos
            ELSE 0
        END;
        
        -- Bônus de qualidade (baseado em duração média)
        v_quality_bonus := CASE 
            WHEN v_user_record.total_minutes >= 120 THEN 20  -- 2h+ = 20 pontos
            WHEN v_user_record.total_minutes >= 90 THEN 15   -- 1.5h+ = 15 pontos
            WHEN v_user_record.total_minutes >= 60 THEN 10   -- 1h+ = 10 pontos
            ELSE 0
        END;
        
        -- Score total
        v_total_score := v_daily_points + v_consistency_bonus + v_quality_bonus;
        
        -- 5. INSERIR/ATUALIZAR RANKING
        INSERT INTO daily_user_rankings (
            user_id,
            ranking_date,
            daily_workouts,
            total_minutes,
            valid_workouts,
            streak_days,
            weekly_frequency,
            monthly_frequency,
            daily_points,
            consistency_bonus,
            quality_bonus,
            total_score,
            last_workout_at,
            updated_at
        ) VALUES (
            v_user_record.user_id,
            p_target_date,
            v_user_record.daily_workouts,
            v_user_record.total_minutes,
            v_user_record.valid_workouts,
            v_streak_days,
            v_weekly_count,
            v_monthly_count,
            v_daily_points,
            v_consistency_bonus,
            v_quality_bonus,
            v_total_score,
            v_user_record.last_workout_at,
            NOW()
        )
        ON CONFLICT (user_id, ranking_date) 
        DO UPDATE SET
            daily_workouts = EXCLUDED.daily_workouts,
            total_minutes = EXCLUDED.total_minutes,
            valid_workouts = EXCLUDED.valid_workouts,
            streak_days = EXCLUDED.streak_days,
            weekly_frequency = EXCLUDED.weekly_frequency,
            monthly_frequency = EXCLUDED.monthly_frequency,
            daily_points = EXCLUDED.daily_points,
            consistency_bonus = EXCLUDED.consistency_bonus,
            quality_bonus = EXCLUDED.quality_bonus,
            total_score = EXCLUDED.total_score,
            last_workout_at = EXCLUDED.last_workout_at,
            updated_at = NOW();
            
        v_users_processed := v_users_processed + 1;
    END LOOP;
    
    -- 6. CALCULAR POSIÇÕES NO RANKING
    -- Ranking diário
    WITH daily_ranks AS (
        SELECT 
            user_id,
            ROW_NUMBER() OVER (ORDER BY total_score DESC, valid_workouts DESC, total_minutes DESC) as rank
        FROM daily_user_rankings 
        WHERE ranking_date = p_target_date
    )
    UPDATE daily_user_rankings dur
    SET daily_rank = dr.rank
    FROM daily_ranks dr
    WHERE dur.user_id = dr.user_id 
      AND dur.ranking_date = p_target_date;
    
    -- Ranking semanal (soma dos últimos 7 dias)
    WITH weekly_ranks AS (
        SELECT 
            user_id,
            ROW_NUMBER() OVER (ORDER BY SUM(total_score) DESC, SUM(valid_workouts) DESC) as rank
        FROM daily_user_rankings 
        WHERE ranking_date BETWEEN (p_target_date - INTERVAL '6 days') AND p_target_date
        GROUP BY user_id
    )
    UPDATE daily_user_rankings dur
    SET weekly_rank = wr.rank
    FROM weekly_ranks wr
    WHERE dur.user_id = wr.user_id 
      AND dur.ranking_date = p_target_date;
    
    -- Ranking mensal (soma dos últimos 30 dias)
    WITH monthly_ranks AS (
        SELECT 
            user_id,
            ROW_NUMBER() OVER (ORDER BY SUM(total_score) DESC, SUM(valid_workouts) DESC) as rank
        FROM daily_user_rankings 
        WHERE ranking_date BETWEEN (p_target_date - INTERVAL '29 days') AND p_target_date
        GROUP BY user_id
    )
    UPDATE daily_user_rankings dur
    SET monthly_rank = mr.rank
    FROM monthly_ranks mr
    WHERE dur.user_id = mr.user_id 
      AND dur.ranking_date = p_target_date;
    
    RETURN 'Ranking calculado para ' || p_target_date || '. Usuários processados: ' || v_users_processed;
END;
$$ LANGUAGE plpgsql;

SELECT '✅ Função de cálculo de ranking implementada' as resultado;

-- ================================================================
-- 4. FUNÇÕES DE CONSULTA DE RANKINGS
-- ================================================================

\echo ''
\echo '📋 4. IMPLEMENTANDO CONSULTAS DE RANKING'

-- Função para obter top rankings do dia
CREATE OR REPLACE FUNCTION get_daily_top_rankings(p_date DATE DEFAULT CURRENT_DATE, p_limit INTEGER DEFAULT 10)
RETURNS TABLE(
    rank INTEGER,
    user_id UUID,
    daily_workouts INTEGER,
    total_minutes INTEGER,
    streak_days INTEGER,
    total_score INTEGER,
    consistency_bonus INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        dur.daily_rank as rank,
        dur.user_id,
        dur.daily_workouts,
        dur.total_minutes,
        dur.streak_days,
        dur.total_score,
        dur.consistency_bonus
    FROM daily_user_rankings dur
    WHERE dur.ranking_date = p_date
      AND dur.daily_rank IS NOT NULL
    ORDER BY dur.daily_rank
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- Função para obter ranking de um usuário específico
CREATE OR REPLACE FUNCTION get_user_ranking_info(p_user_id UUID, p_date DATE DEFAULT CURRENT_DATE)
RETURNS TABLE(
    ranking_date DATE,
    daily_rank INTEGER,
    weekly_rank INTEGER,
    monthly_rank INTEGER,
    total_score INTEGER,
    streak_days INTEGER,
    weekly_frequency INTEGER,
    monthly_frequency INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        dur.ranking_date,
        dur.daily_rank,
        dur.weekly_rank,
        dur.monthly_rank,
        dur.total_score,
        dur.streak_days,
        dur.weekly_frequency,
        dur.monthly_frequency
    FROM daily_user_rankings dur
    WHERE dur.user_id = p_user_id
      AND dur.ranking_date = p_date;
END;
$$ LANGUAGE plpgsql;

-- Função para obter evolução de ranking de um usuário
CREATE OR REPLACE FUNCTION get_user_ranking_evolution(p_user_id UUID, p_days INTEGER DEFAULT 30)
RETURNS TABLE(
    ranking_date DATE,
    daily_rank INTEGER,
    total_score INTEGER,
    streak_days INTEGER,
    daily_workouts INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        dur.ranking_date,
        dur.daily_rank,
        dur.total_score,
        dur.streak_days,
        dur.daily_workouts
    FROM daily_user_rankings dur
    WHERE dur.user_id = p_user_id
      AND dur.ranking_date >= (CURRENT_DATE - p_days)
    ORDER BY dur.ranking_date DESC;
END;
$$ LANGUAGE plpgsql;

SELECT '✅ Funções de consulta implementadas' as resultado;

-- ================================================================
-- 5. TRIGGER AUTOMÁTICO PARA ATUALIZAR RANKING
-- ================================================================

\echo ''
\echo '⚡ 5. IMPLEMENTANDO TRIGGER AUTOMÁTICO'

-- Função trigger para atualizar ranking automaticamente
CREATE OR REPLACE FUNCTION trigger_update_daily_ranking()
RETURNS TRIGGER AS $$
DECLARE
    v_workout_date DATE;
BEGIN
    -- Determinar a data do treino
    IF TG_OP = 'DELETE' THEN
        v_workout_date := DATE(OLD.date AT TIME ZONE 'America/Sao_Paulo');
    ELSE
        v_workout_date := DATE(NEW.date AT TIME ZONE 'America/Sao_Paulo');
    END IF;
    
    -- Agendar recálculo do ranking para esta data (via background job)
    INSERT INTO workout_processing_queue (
        workout_id,
        user_id,
        challenge_id,
        processed_for_ranking,
        processed_for_dashboard,
        processing_error,
        created_at
    ) VALUES (
        COALESCE(NEW.id, OLD.id),
        COALESCE(NEW.user_id, OLD.user_id),
        COALESCE(NEW.challenge_id, OLD.challenge_id),
        FALSE,  -- Precisa processar ranking
        TRUE,   -- Dashboard pode estar OK
        NULL,
        NOW()
    )
    ON CONFLICT (workout_id) DO UPDATE SET
        processed_for_ranking = FALSE,
        created_at = NOW();
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Criar trigger se não existir
DROP TRIGGER IF EXISTS trigger_update_ranking ON workout_records;
CREATE TRIGGER trigger_update_ranking
    AFTER INSERT OR UPDATE OR DELETE ON workout_records
    FOR EACH ROW
    EXECUTE FUNCTION trigger_update_daily_ranking();

SELECT '✅ Trigger automático implementado' as resultado;

-- ================================================================
-- 6. FUNÇÃO PARA PROCESSAR FILA DE RANKING
-- ================================================================

\echo ''
\echo '🔄 6. IMPLEMENTANDO PROCESSAMENTO DA FILA'

CREATE OR REPLACE FUNCTION process_ranking_queue()
RETURNS TEXT AS $$
DECLARE
    v_queue_item RECORD;
    v_workout_date DATE;
    v_processed_count INTEGER := 0;
    v_error_count INTEGER := 0;
BEGIN
    -- Processar itens pendentes de ranking
    FOR v_queue_item IN 
        SELECT DISTINCT 
            wpq.id,
            wpq.user_id,
            wr.date,
            wr.id as workout_id
        FROM workout_processing_queue wpq
        JOIN workout_records wr ON wr.id = wpq.workout_id
        WHERE wpq.processed_for_ranking = FALSE
          AND (wpq.next_retry_at IS NULL OR wpq.next_retry_at <= NOW())
          AND wpq.retry_count < wpq.max_retries
        ORDER BY wpq.created_at
        LIMIT 100  -- Processar até 100 por vez
    LOOP
        BEGIN
            -- Obter data do treino
            v_workout_date := DATE(v_queue_item.date AT TIME ZONE 'America/Sao_Paulo');
            
            -- Recalcular ranking para esta data
            PERFORM calculate_daily_ranking(v_workout_date);
            
            -- Marcar como processado
            UPDATE workout_processing_queue 
            SET 
                processed_for_ranking = TRUE,
                processed_at = NOW(),
                processing_error = NULL
            WHERE id = v_queue_item.id;
            
            v_processed_count := v_processed_count + 1;
            
        EXCEPTION WHEN OTHERS THEN
            -- Em caso de erro, incrementar retry
            UPDATE workout_processing_queue 
            SET 
                retry_count = retry_count + 1,
                processing_error = SQLERRM,
                next_retry_at = NOW() + (INTERVAL '1 minute' * POWER(2, retry_count + 1))
            WHERE id = v_queue_item.id;
            
            v_error_count := v_error_count + 1;
        END;
    END LOOP;
    
    RETURN 'Processamento concluído. Sucessos: ' || v_processed_count || ', Erros: ' || v_error_count;
END;
$$ LANGUAGE plpgsql;

SELECT '✅ Processamento da fila implementado' as resultado;

-- ================================================================
-- 7. EXECUTAR CÁLCULO INICIAL
-- ================================================================

\echo ''
\echo '🚀 7. EXECUTANDO CÁLCULO INICIAL DE RANKING'

-- Calcular ranking para hoje
SELECT calculate_daily_ranking(CURRENT_DATE) as resultado_hoje;

-- Calcular ranking para ontem (se houver dados)
SELECT calculate_daily_ranking(CURRENT_DATE - INTERVAL '1 day') as resultado_ontem;

-- Processar fila pendente
SELECT process_ranking_queue() as processamento_fila;

\echo ''
\echo '✅ SISTEMA DE RANKING DIÁRIO IMPLEMENTADO COM SUCESSO!'
\echo ''
\echo '📊 COMANDOS ÚTEIS:'
\echo '-- Ver top 10 do dia:'
\echo 'SELECT * FROM get_daily_top_rankings();'
\echo ''
\echo '-- Ver ranking de um usuário:'
\echo 'SELECT * FROM get_user_ranking_info(''user-uuid-here'');'
\echo ''
\echo '-- Recalcular ranking manual:'
\echo 'SELECT calculate_daily_ranking(CURRENT_DATE);'
\echo ''
\echo '-- Processar fila pendente:'
\echo 'SELECT process_ranking_queue();' 