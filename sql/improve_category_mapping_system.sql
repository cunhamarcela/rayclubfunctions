-- ========================================
-- MELHORIA NO SISTEMA DE MAPEAMENTO DE CATEGORIAS
-- ========================================
-- Data: 2025-01-27
-- Objetivo: Garantir que todas as categorias de exercício sejam mapeadas corretamente para as metas

-- Função para normalizar e mapear categorias de exercício para metas
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
        
        -- Projeto 7 Dias variations
        WHEN exercise_type IN ('projeto', 'projeto_7_dias', 'projeto 7 dias', 'check-in', 'checkin', 'check_in', 'daily_check') THEN 'projeto_7_dias'
        
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
        
        -- Fisioterapia variations
        WHEN exercise_type IN ('fisioterapia', 'fisio', 'reabilitacao', 'reabilitação', 'terapeutico') THEN 'fisioterapia'
        
        -- Default case - manter como "outro" ou valor original se não reconhecer
        ELSE COALESCE(NULLIF(exercise_type, ''), 'outro')
    END;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Função melhorada para atualizar metas quando treino é registrado
CREATE OR REPLACE FUNCTION update_category_goals_on_workout_improved()
RETURNS TRIGGER AS $$
DECLARE
    normalized_category TEXT;
    goal_exists BOOLEAN;
BEGIN
    -- Validar se tem dados necessários
    IF NEW.user_id IS NULL OR NEW.workout_type IS NULL OR NEW.duration_minutes IS NULL THEN
        RETURN NEW;
    END IF;
    
    -- Normalizar categoria do exercício
    normalized_category := normalize_exercise_category(NEW.workout_type);
    
    -- Verificar se já existe uma meta para esta categoria na semana atual
    SELECT EXISTS(
        SELECT 1 FROM workout_category_goals 
        WHERE user_id = NEW.user_id 
        AND category = normalized_category
        AND week_start_date = date_trunc('week', CURRENT_DATE)::date
        AND is_active = TRUE
    ) INTO goal_exists;
    
    -- Se não existe meta, criar uma com valor padrão
    IF NOT goal_exists THEN
        -- Usar função existente para criar meta com valor padrão
        PERFORM get_or_create_category_goal(NEW.user_id, normalized_category);
    END IF;
    
    -- Atualizar minutos na meta existente
    PERFORM add_workout_minutes_to_category(
        NEW.user_id,
        normalized_category,
        NEW.duration_minutes
    );
    
    -- Log da operação para debug
    INSERT INTO goal_update_logs (
        user_id,
        exercise_type_original,
        exercise_type_normalized,
        duration_minutes,
        updated_at
    ) VALUES (
        NEW.user_id,
        NEW.workout_type,
        normalized_category,
        NEW.duration_minutes,
        NOW()
    ) ON CONFLICT DO NOTHING; -- Ignorar se tabela não existir
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Recriar trigger com função melhorada
DROP TRIGGER IF EXISTS update_category_goals_on_workout_trigger ON workout_records;
CREATE TRIGGER update_category_goals_on_workout_trigger
    AFTER INSERT ON workout_records
    FOR EACH ROW
    EXECUTE FUNCTION update_category_goals_on_workout_improved();

-- Tabela opcional para logs de debug (criar apenas se necessário)
CREATE TABLE IF NOT EXISTS goal_update_logs (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL,
    exercise_type_original TEXT NOT NULL,
    exercise_type_normalized TEXT NOT NULL,
    duration_minutes INTEGER NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índice para performance dos logs
CREATE INDEX IF NOT EXISTS idx_goal_update_logs_user_date 
ON goal_update_logs(user_id, updated_at DESC);

-- Função para limpar logs antigos (executar periodicamente)
CREATE OR REPLACE FUNCTION cleanup_old_goal_logs()
RETURNS void AS $$
BEGIN
    DELETE FROM goal_update_logs 
    WHERE updated_at < (CURRENT_DATE - INTERVAL '30 days');
END;
$$ LANGUAGE plpgsql;

-- ========================================
-- FUNÇÃO PARA MAPEAR CATEGORIAS EXISTENTES
-- ========================================

-- Função para migrar/normalizar categorias existentes nas metas
CREATE OR REPLACE FUNCTION normalize_existing_goal_categories()
RETURNS TABLE (
    updated_count INTEGER,
    categories_mapped TEXT[]
) AS $$
DECLARE
    update_count INTEGER := 0;
    mapped_categories TEXT[] := ARRAY[]::TEXT[];
    goal_record RECORD;
BEGIN
    -- Iterar sobre todas as metas ativas com categorias não normalizadas
    FOR goal_record IN 
        SELECT id, category, user_id
        FROM workout_category_goals 
        WHERE is_active = TRUE
    LOOP
        DECLARE
            normalized_cat TEXT;
        BEGIN
            normalized_cat := normalize_exercise_category(goal_record.category);
            
            -- Se a categoria mudou, atualizar
            IF normalized_cat != goal_record.category THEN
                UPDATE workout_category_goals 
                SET category = normalized_cat,
                    updated_at = NOW()
                WHERE id = goal_record.id;
                
                update_count := update_count + 1;
                mapped_categories := array_append(mapped_categories, 
                    goal_record.category || ' → ' || normalized_cat);
            END IF;
        END;
    END LOOP;
    
    RETURN QUERY SELECT update_count, mapped_categories;
END;
$$ LANGUAGE plpgsql;

-- ========================================
-- TESTES E VALIDAÇÃO
-- ========================================

-- Função para testar mapeamento de categorias
CREATE OR REPLACE FUNCTION test_category_mapping()
RETURNS TABLE (
    original_category TEXT,
    normalized_category TEXT,
    is_correct BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    WITH test_cases AS (
        SELECT unnest(ARRAY[
            'Musculação', 'MUSCULACAO', 'musculacao', 'força', 'Força', 'bodybuilding',
            'Funcional', 'FUNCIONAL', 'funcional', 'crossfit', 'CrossFit',
            'Yoga', 'YOGA', 'yoga', 'ioga', 'Hatha Yoga',
            'Pilates', 'PILATES', 'pilates', 'Pilates Solo',
            'Cardio', 'CARDIO', 'cardio', 'cardiovascular', 'aeróbico',
            'HIIT', 'hiit', 'Hit', 'alta intensidade', 'treino intervalado',
            'Alongamento', 'alongamento', 'stretching', 'flexibilidade',
            'Dança', 'danca', 'zumba', 'dance', 'dança fitness',
            'Corrida', 'corrida', 'running', 'jogging', 'cooper',
            'Caminhada', 'caminhada', 'walking', 'trekking'
        ]) AS original
    )
    SELECT 
        tc.original,
        normalize_exercise_category(tc.original),
        -- Verificar se o mapeamento faz sentido
        normalize_exercise_category(tc.original) IN (
            'musculacao', 'funcional', 'yoga', 'pilates', 'cardio', 
            'hiit', 'alongamento', 'danca', 'corrida', 'caminhada',
            'natacao', 'ciclismo', 'fisioterapia', 'outro'
        ) as is_correct
    FROM test_cases tc;
END;
$$ LANGUAGE plpgsql;

-- ========================================
-- COMENTÁRIOS E DOCUMENTAÇÃO
-- ========================================

COMMENT ON FUNCTION normalize_exercise_category IS 'Normaliza e mapeia categorias de exercício para categorias padrão de metas';
COMMENT ON FUNCTION update_category_goals_on_workout_improved IS 'Trigger melhorado que mapeia categorias automaticamente e cria metas se necessário';
COMMENT ON FUNCTION normalize_existing_goal_categories IS 'Migra categorias existentes para versões normalizadas';
COMMENT ON FUNCTION test_category_mapping IS 'Testa o mapeamento de categorias para validação';
COMMENT ON TABLE goal_update_logs IS 'Log de atualizações de metas para debug e auditoria'; 