-- ================================================================
-- SISTEMA SIMPLES DE RANKING BASEADO EM CHECK-INS DIÁRIOS
-- Foco: apenas check-ins diários e streaks simples
-- ================================================================

\echo '✅ IMPLEMENTANDO SISTEMA SIMPLES DE CHECK-INS DIÁRIOS'
\echo '====================================================='

-- ================================================================
-- 1. TABELA DE CHECK-INS DIÁRIOS
-- ================================================================

\echo ''
\echo '📅 1. CRIANDO ESTRUTURA DE CHECK-INS DIÁRIOS'

-- Tabela principal de check-ins diários
CREATE TABLE IF NOT EXISTS daily_check_ins (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    check_in_date DATE NOT NULL DEFAULT CURRENT_DATE,
    
    -- Check-in simples (treinou hoje sim/não)
    has_workout BOOLEAN DEFAULT TRUE,
    
    -- Metadados
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraint: um check-in por usuário por dia
    UNIQUE(user_id, check_in_date)
);

-- Tabela de ranking diário simples
CREATE TABLE IF NOT EXISTS daily_simple_rankings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    ranking_date DATE NOT NULL DEFAULT CURRENT_DATE,
    
    -- Métricas simples
    current_streak INTEGER DEFAULT 0,    -- dias consecutivos atuais
    total_check_ins INTEGER DEFAULT 0,   -- total de check-ins no período
    
    -- Ranking positions
    daily_rank INTEGER,
    weekly_rank INTEGER,
    monthly_rank INTEGER,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(user_id, ranking_date)
);

-- Índices simples
CREATE INDEX IF NOT EXISTS idx_daily_checkins_user_date 
ON daily_check_ins(user_id, check_in_date DESC);

CREATE INDEX IF NOT EXISTS idx_daily_checkins_date 
ON daily_check_ins(check_in_date DESC);

CREATE INDEX IF NOT EXISTS idx_simple_rankings_date 
ON daily_simple_rankings(ranking_date DESC);

CREATE INDEX IF NOT EXISTS idx_simple_rankings_streak 
ON daily_simple_rankings(current_streak DESC, ranking_date DESC);

SELECT '✅ Estrutura de check-ins criada' as resultado;

-- ================================================================
-- 2. FUNÇÃO PARA REGISTRAR CHECK-IN DIÁRIO
-- ================================================================

\echo ''
\echo '✅ 2. IMPLEMENTANDO REGISTRO DE CHECK-IN'

CREATE OR REPLACE FUNCTION register_daily_checkin(p_user_id UUID, p_date DATE DEFAULT CURRENT_DATE)
RETURNS JSONB AS $$
DECLARE
    v_already_exists BOOLEAN;
    v_new_checkin_id UUID;
BEGIN
    -- Verificar se já existe check-in para este dia
    SELECT EXISTS(
        SELECT 1 FROM daily_check_ins 
        WHERE user_id = p_user_id AND check_in_date = p_date
    ) INTO v_already_exists;
    
    IF v_already_exists THEN
        RETURN jsonb_build_object(
            'success', TRUE,
            'message', 'Check-in já registrado para este dia',
            'already_exists', TRUE,
            'date', p_date
        );
    END IF;
    
    -- Registrar novo check-in
    INSERT INTO daily_check_ins (user_id, check_in_date, has_workout)
    VALUES (p_user_id, p_date, TRUE)
    RETURNING id INTO v_new_checkin_id;
    
    -- Atualizar ranking
    PERFORM update_simple_ranking(p_user_id, p_date);
    
    RETURN jsonb_build_object(
        'success', TRUE,
        'message', 'Check-in registrado com sucesso',
        'checkin_id', v_new_checkin_id,
        'date', p_date
    );
END;
$$ LANGUAGE plpgsql;

SELECT '✅ Função de registro de check-in implementada' as resultado;

-- ================================================================
-- 3. FUNÇÃO PARA CALCULAR STREAK SIMPLES
-- ================================================================

\echo ''
\echo '🔥 3. IMPLEMENTANDO CÁLCULO DE STREAK SIMPLES'

CREATE OR REPLACE FUNCTION calculate_simple_streak(p_user_id UUID, p_end_date DATE DEFAULT CURRENT_DATE)
RETURNS INTEGER AS $$
DECLARE
    v_streak_count INTEGER := 0;
    v_check_date DATE;
    v_has_checkin BOOLEAN;
BEGIN
    v_check_date := p_end_date;
    
    -- Contar dias consecutivos voltando no tempo
    LOOP
        -- Verificar se tem check-in neste dia
        SELECT EXISTS(
            SELECT 1 FROM daily_check_ins 
            WHERE user_id = p_user_id 
              AND check_in_date = v_check_date
              AND has_workout = TRUE
        ) INTO v_has_checkin;
        
        -- Se não tem check-in, parar a contagem
        IF NOT v_has_checkin THEN
            EXIT;
        END IF;
        
        -- Incrementar streak
        v_streak_count := v_streak_count + 1;
        v_check_date := v_check_date - INTERVAL '1 day';
        
        -- Limite de segurança
        IF v_streak_count >= 1000 THEN
            EXIT;
        END IF;
    END LOOP;
    
    RETURN v_streak_count;
END;
$$ LANGUAGE plpgsql;

SELECT '✅ Função de cálculo de streak implementada' as resultado;

-- ================================================================
-- 4. FUNÇÃO PARA ATUALIZAR RANKING SIMPLES
-- ================================================================

\echo ''
\echo '📊 4. IMPLEMENTANDO ATUALIZAÇÃO DE RANKING'

CREATE OR REPLACE FUNCTION update_simple_ranking(p_user_id UUID, p_date DATE DEFAULT CURRENT_DATE)
RETURNS TEXT AS $$
DECLARE
    v_current_streak INTEGER;
    v_weekly_checkins INTEGER;
    v_monthly_checkins INTEGER;
BEGIN
    -- Calcular streak atual
    v_current_streak := calculate_simple_streak(p_user_id, p_date);
    
    -- Calcular check-ins da semana (últimos 7 dias)
    SELECT COUNT(*) INTO v_weekly_checkins
    FROM daily_check_ins 
    WHERE user_id = p_user_id
      AND check_in_date BETWEEN (p_date - INTERVAL '6 days') AND p_date
      AND has_workout = TRUE;
    
    -- Calcular check-ins do mês (últimos 30 dias)
    SELECT COUNT(*) INTO v_monthly_checkins
    FROM daily_check_ins 
    WHERE user_id = p_user_id
      AND check_in_date BETWEEN (p_date - INTERVAL '29 days') AND p_date
      AND has_workout = TRUE;
    
    -- Inserir/atualizar ranking
    INSERT INTO daily_simple_rankings (
        user_id,
        ranking_date,
        current_streak,
        total_check_ins,
        updated_at
    ) VALUES (
        p_user_id,
        p_date,
        v_current_streak,
        v_monthly_checkins,  -- usando contagem mensal como total
        NOW()
    )
    ON CONFLICT (user_id, ranking_date) 
    DO UPDATE SET
        current_streak = EXCLUDED.current_streak,
        total_check_ins = EXCLUDED.total_check_ins,
        updated_at = NOW();
    
    RETURN 'Ranking atualizado para usuário ' || p_user_id || ' na data ' || p_date;
END;
$$ LANGUAGE plpgsql;

SELECT '✅ Função de atualização de ranking implementada' as resultado;

-- ================================================================
-- 5. FUNÇÃO PARA CALCULAR RANKINGS GLOBAIS
-- ================================================================

\echo ''
\echo '🏆 5. IMPLEMENTANDO CÁLCULO DE RANKINGS GLOBAIS'

CREATE OR REPLACE FUNCTION calculate_global_rankings(p_date DATE DEFAULT CURRENT_DATE)
RETURNS TEXT AS $$
DECLARE
    v_users_processed INTEGER := 0;
BEGIN
    -- Atualizar todos os usuários que fizeram check-in na data
    INSERT INTO daily_simple_rankings (user_id, ranking_date, current_streak, total_check_ins)
    SELECT 
        dci.user_id,
        p_date,
        calculate_simple_streak(dci.user_id, p_date),
        (SELECT COUNT(*) FROM daily_check_ins 
         WHERE user_id = dci.user_id 
           AND check_in_date BETWEEN (p_date - INTERVAL '29 days') AND p_date
           AND has_workout = TRUE)
    FROM daily_check_ins dci
    WHERE dci.check_in_date = p_date
      AND dci.has_workout = TRUE
    ON CONFLICT (user_id, ranking_date) 
    DO UPDATE SET
        current_streak = EXCLUDED.current_streak,
        total_check_ins = EXCLUDED.total_check_ins,
        updated_at = NOW();
    
    GET DIAGNOSTICS v_users_processed = ROW_COUNT;
    
    -- Calcular ranking diário (por streak atual)
    WITH daily_ranks AS (
        SELECT 
            user_id,
            ROW_NUMBER() OVER (ORDER BY current_streak DESC, total_check_ins DESC) as rank
        FROM daily_simple_rankings 
        WHERE ranking_date = p_date
    )
    UPDATE daily_simple_rankings dsr
    SET daily_rank = dr.rank
    FROM daily_ranks dr
    WHERE dsr.user_id = dr.user_id 
      AND dsr.ranking_date = p_date;
    
    -- Ranking semanal (soma de check-ins dos últimos 7 dias)
    WITH weekly_ranks AS (
        SELECT 
            user_id,
            ROW_NUMBER() OVER (ORDER BY 
                COUNT(*) DESC,  -- total de check-ins na semana
                MAX(current_streak) DESC  -- streak máximo como desempate
            ) as rank
        FROM daily_check_ins
        WHERE check_in_date BETWEEN (p_date - INTERVAL '6 days') AND p_date
          AND has_workout = TRUE
        GROUP BY user_id
    )
    UPDATE daily_simple_rankings dsr
    SET weekly_rank = wr.rank
    FROM weekly_ranks wr
    WHERE dsr.user_id = wr.user_id 
      AND dsr.ranking_date = p_date;
    
    -- Ranking mensal (soma de check-ins dos últimos 30 dias)
    WITH monthly_ranks AS (
        SELECT 
            user_id,
            ROW_NUMBER() OVER (ORDER BY 
                COUNT(*) DESC,  -- total de check-ins no mês
                MAX(current_streak) DESC  -- streak máximo como desempate
            ) as rank
        FROM daily_check_ins
        WHERE check_in_date BETWEEN (p_date - INTERVAL '29 days') AND p_date
          AND has_workout = TRUE
        GROUP BY user_id
    )
    UPDATE daily_simple_rankings dsr
    SET monthly_rank = mr.rank
    FROM monthly_ranks mr
    WHERE dsr.user_id = mr.user_id 
      AND dsr.ranking_date = p_date;
    
    RETURN 'Rankings calculados para ' || p_date || '. Usuários processados: ' || v_users_processed;
END;
$$ LANGUAGE plpgsql;

SELECT '✅ Função de cálculo global implementada' as resultado;

-- ================================================================
-- 6. FUNÇÕES DE CONSULTA SIMPLES
-- ================================================================

\echo ''
\echo '📋 6. IMPLEMENTANDO CONSULTAS DE RANKING'

-- Top rankings do dia por streak
CREATE OR REPLACE FUNCTION get_top_streaks(p_date DATE DEFAULT CURRENT_DATE, p_limit INTEGER DEFAULT 10)
RETURNS TABLE(
    rank INTEGER,
    user_id UUID,
    current_streak INTEGER,
    total_check_ins INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        dsr.daily_rank as rank,
        dsr.user_id,
        dsr.current_streak,
        dsr.total_check_ins
    FROM daily_simple_rankings dsr
    WHERE dsr.ranking_date = p_date
      AND dsr.daily_rank IS NOT NULL
    ORDER BY dsr.daily_rank
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- Informações de um usuário específico
CREATE OR REPLACE FUNCTION get_user_checkin_info(p_user_id UUID, p_date DATE DEFAULT CURRENT_DATE)
RETURNS TABLE(
    current_streak INTEGER,
    daily_rank INTEGER,
    weekly_rank INTEGER,
    monthly_rank INTEGER,
    total_check_ins INTEGER,
    checked_in_today BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        dsr.current_streak,
        dsr.daily_rank,
        dsr.weekly_rank,
        dsr.monthly_rank,
        dsr.total_check_ins,
        EXISTS(SELECT 1 FROM daily_check_ins WHERE user_id = p_user_id AND check_in_date = p_date) as checked_in_today
    FROM daily_simple_rankings dsr
    WHERE dsr.user_id = p_user_id
      AND dsr.ranking_date = p_date;
END;
$$ LANGUAGE plpgsql;

-- Histórico de check-ins de um usuário
CREATE OR REPLACE FUNCTION get_user_checkin_history(p_user_id UUID, p_days INTEGER DEFAULT 30)
RETURNS TABLE(
    check_in_date DATE,
    has_workout BOOLEAN,
    created_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        dci.check_in_date,
        dci.has_workout,
        dci.created_at
    FROM daily_check_ins dci
    WHERE dci.user_id = p_user_id
      AND dci.check_in_date >= (CURRENT_DATE - p_days)
    ORDER BY dci.check_in_date DESC;
END;
$$ LANGUAGE plpgsql;

SELECT '✅ Funções de consulta implementadas' as resultado;

-- ================================================================
-- 7. TRIGGER PARA ATUALIZAÇÃO AUTOMÁTICA
-- ================================================================

\echo ''
\echo '⚡ 7. IMPLEMENTANDO TRIGGER AUTOMÁTICO'

CREATE OR REPLACE FUNCTION trigger_update_checkin_ranking()
RETURNS TRIGGER AS $$
DECLARE
    v_workout_date DATE;
    v_user_id UUID;
BEGIN
    -- Determinar data e usuário
    IF TG_OP = 'DELETE' THEN
        v_workout_date := OLD.check_in_date;
        v_user_id := OLD.user_id;
    ELSE
        v_workout_date := NEW.check_in_date;
        v_user_id := NEW.user_id;
    END IF;
    
    -- Atualizar ranking do usuário
    PERFORM update_simple_ranking(v_user_id, v_workout_date);
    
    -- Recalcular rankings globais
    PERFORM calculate_global_rankings(v_workout_date);
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Criar trigger
DROP TRIGGER IF EXISTS trigger_checkin_ranking ON daily_check_ins;
CREATE TRIGGER trigger_checkin_ranking
    AFTER INSERT OR UPDATE OR DELETE ON daily_check_ins
    FOR EACH ROW
    EXECUTE FUNCTION trigger_update_checkin_ranking();

SELECT '✅ Trigger automático implementado' as resultado;

-- ================================================================
-- 8. MIGRAR CHECK-INS EXISTENTES DOS WORKOUT_RECORDS
-- ================================================================

\echo ''
\echo '🔄 8. MIGRANDO CHECK-INS EXISTENTES'

-- Criar check-ins baseados nos workout_records existentes
INSERT INTO daily_check_ins (user_id, check_in_date, has_workout, created_at)
SELECT DISTINCT
    wr.user_id,
    DATE(wr.date AT TIME ZONE 'America/Sao_Paulo') as check_in_date,
    TRUE as has_workout,
    MIN(wr.created_at) as created_at
FROM workout_records wr
WHERE wr.duration_minutes >= 45  -- Apenas treinos válidos
GROUP BY wr.user_id, DATE(wr.date AT TIME ZONE 'America/Sao_Paulo')
ON CONFLICT (user_id, check_in_date) DO NOTHING;

-- Calcular rankings para hoje e ontem
SELECT calculate_global_rankings(CURRENT_DATE) as ranking_hoje;
SELECT calculate_global_rankings(CURRENT_DATE - INTERVAL '1 day') as ranking_ontem;

\echo ''
\echo '✅ SISTEMA SIMPLES DE CHECK-INS IMPLEMENTADO COM SUCESSO!'
\echo ''
\echo '📊 COMANDOS ÚTEIS:'
\echo '-- Registrar check-in:'
\echo 'SELECT register_daily_checkin(''user-uuid-here'');'
\echo ''
\echo '-- Ver top streaks:'
\echo 'SELECT * FROM get_top_streaks();'
\echo ''
\echo '-- Ver info de usuário:'
\echo 'SELECT * FROM get_user_checkin_info(''user-uuid-here'');'
\echo ''
\echo '-- Ver histórico:'
\echo 'SELECT * FROM get_user_checkin_history(''user-uuid-here'', 30);'
\echo ''
\echo '-- Recalcular rankings:'
\echo 'SELECT calculate_global_rankings(CURRENT_DATE);' 