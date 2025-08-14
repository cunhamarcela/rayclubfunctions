-- ========================================
-- ADIÇÃO DE NOVAS MODALIDADES DE EXERCÍCIO
-- ========================================
-- Data: 2025-01-29
-- Objetivo: Adicionar Força, Fisioterapia e Flexibilidade ao sistema de metas

-- Atualizar função de mapeamento com novas categorias
CREATE OR REPLACE FUNCTION normalize_exercise_category(exercise_type TEXT)
RETURNS TEXT AS $$
BEGIN
    -- Normalizar entrada (remover espaços, converter para minúsculas)
    exercise_type := lower(trim(exercise_type));
    
    -- Mapear variações de nomes para categorias padronizadas
    RETURN CASE
        -- Cardio variations
        WHEN exercise_type IN ('cardio', 'cardiovascular', 'aerobico', 'aeróbico') THEN 'cardio'
        
        -- Musculação variations  
        WHEN exercise_type IN ('musculacao', 'musculação', 'bodybuilding', 'strength') THEN 'musculacao'
        
        -- Força variations (separado de musculação)
        WHEN exercise_type IN ('força', 'forca', 'powerlifting', 'levantamento', 'peso livre') THEN 'forca'
        
        -- Funcional variations
        WHEN exercise_type IN ('funcional', 'functional', 'crossfit', 'cross fit') THEN 'funcional'
        
        -- Yoga variations
        WHEN exercise_type IN ('yoga', 'ioga', 'hatha yoga', 'vinyasa') THEN 'yoga'
        
        -- Pilates variations
        WHEN exercise_type IN ('pilates', 'pilates solo', 'pilates mat') THEN 'pilates'
        
        -- HIIT variations
        WHEN exercise_type IN ('hiit', 'hit', 'treino intervalado', 'intervalo', 'alta intensidade') THEN 'hiit'
        
        -- Alongamento variations
        WHEN exercise_type IN ('alongamento', 'stretching', 'mobilidade') THEN 'alongamento'
        
        -- Flexibilidade variations (separado de alongamento)
        WHEN exercise_type IN ('flexibilidade', 'flexibility', 'amplitude', 'mobilidade articular') THEN 'flexibilidade'
        
        -- Fisioterapia variations
        WHEN exercise_type IN ('fisioterapia', 'fisio', 'terapia', 'reabilitacao', 'reabilitação', 'physiotherapy') THEN 'fisioterapia'
        
        -- Dança variations
        WHEN exercise_type IN ('danca', 'dança', 'dance', 'zumba', 'danca fitness') THEN 'danca'
        
        -- Corrida variations
        WHEN exercise_type IN ('corrida', 'running', 'run', 'jogging', 'cooper') THEN 'corrida'
        
        -- Caminhada variations
        WHEN exercise_type IN ('caminhada', 'walking', 'walk', 'trekking', 'hiking') THEN 'caminhada'
        
        -- Natação variations
        WHEN exercise_type IN ('natacao', 'natação', 'swimming', 'swim') THEN 'natacao'
        
        -- Ciclismo variations
        WHEN exercise_type IN ('ciclismo', 'bike', 'bicicleta', 'cycling', 'spinning') THEN 'ciclismo'
        
        -- Se não corresponder a nenhuma categoria, usar como 'outro'
        ELSE COALESCE(NULLIF(exercise_type, ''), 'outro')
    END;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Atualizar função get_or_create_category_goal com novos valores padrão
CREATE OR REPLACE FUNCTION get_or_create_category_goal(
    p_user_id UUID,
    p_category TEXT
) RETURNS workout_category_goals AS $$
DECLARE
    v_goal_record workout_category_goals;
    v_current_week_start DATE;
    v_current_week_end DATE;
BEGIN
    -- Calcular início e fim da semana atual
    v_current_week_start := date_trunc('week', CURRENT_DATE)::date;
    v_current_week_end := v_current_week_start + interval '6 days';
    
    -- Tentar buscar meta existente para a categoria na semana atual
    SELECT wcg.* INTO v_goal_record
    FROM workout_category_goals wcg
    WHERE wcg.user_id = p_user_id
    AND wcg.category = p_category
    AND wcg.week_start_date = v_current_week_start
    AND wcg.is_active = TRUE;
    
    -- Se não existir, criar nova meta com valor padrão baseado na categoria
    IF NOT FOUND THEN
        -- Buscar última meta desta categoria para copiar o valor
        SELECT goal_minutes INTO v_goal_record.goal_minutes
        FROM workout_category_goals
        WHERE user_id = p_user_id 
        AND category = p_category
        AND is_active = TRUE
        ORDER BY week_start_date DESC
        LIMIT 1;
        
        -- Se não houver meta anterior, usar padrão baseado na categoria
        IF v_goal_record.goal_minutes IS NULL THEN
            v_goal_record.goal_minutes := CASE 
                WHEN p_category IN ('corrida', 'caminhada') THEN 120 -- 2 horas
                WHEN p_category IN ('yoga', 'alongamento') THEN 90 -- 1.5 horas  
                WHEN p_category IN ('funcional', 'crossfit') THEN 60 -- 1 hora
                WHEN p_category IN ('natacao', 'ciclismo') THEN 100 -- 1h40
                WHEN p_category = 'forca' THEN 90 -- 1.5 horas para força
                WHEN p_category = 'fisioterapia' THEN 60 -- 1 hora para fisio
                WHEN p_category = 'flexibilidade' THEN 45 -- 45 min para flexibilidade
                ELSE 90 -- Padrão geral: 1.5 horas
            END;
        END IF;
        
        -- Inserir nova meta
        INSERT INTO workout_category_goals (
            user_id, 
            category,
            goal_minutes, 
            current_minutes,
            week_start_date,
            week_end_date,
            is_active
        ) VALUES (
            p_user_id,
            p_category,
            v_goal_record.goal_minutes,
            0,
            v_current_week_start,
            v_current_week_end,
            TRUE
        ) RETURNING * INTO v_goal_record;
    END IF;
    
    RETURN v_goal_record;
END;
$$ LANGUAGE plpgsql;

-- Testar as novas categorias
SELECT 
    'Teste das novas categorias:' as titulo,
    normalize_exercise_category('Força') as forca_test,
    normalize_exercise_category('Fisioterapia') as fisio_test,
    normalize_exercise_category('Flexibilidade') as flex_test; 