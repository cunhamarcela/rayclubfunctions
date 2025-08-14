-- =========================================
-- ATUALIZAÇÃO: CATEGORIA PROJETO 7 DIAS
-- =========================================
-- Data: 2025-01-29
-- Objetivo: Integrar "Projeto 7 Dias" ao sistema workoutCategoryGoalsProvider

-- 1. Atualizar função de mapeamento de categorias
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
        WHEN exercise_type IN ('pilates', 'reformer', 'mat pilates') THEN 'pilates'
        
        -- HIIT variations
        WHEN exercise_type IN ('hiit', 'alta intensidade', 'interval training', 'tabata') THEN 'hiit'
        
        -- Corrida variations
        WHEN exercise_type IN ('corrida', 'running', 'cooper', 'sprint') THEN 'corrida'
        
        -- Caminhada variations
        WHEN exercise_type IN ('caminhada', 'walking', 'walk', 'trekking') THEN 'caminhada'
        
        -- Natação variations
        WHEN exercise_type IN ('natacao', 'natação', 'swimming', 'nado') THEN 'natacao'
        
        -- Ciclismo variations
        WHEN exercise_type IN ('ciclismo', 'bike', 'bicicleta', 'cycling', 'spinning') THEN 'ciclismo'
        
        -- Alongamento variations
        WHEN exercise_type IN ('alongamento', 'stretching', 'mobilidade') THEN 'alongamento'
        
        -- Flexibilidade variations (separado de alongamento)
        WHEN exercise_type IN ('flexibilidade', 'flexibility', 'amplitude', 'mobilidade articular') THEN 'flexibilidade'
        
        -- Fisioterapia variations
        WHEN exercise_type IN ('fisioterapia', 'fisio', 'terapia', 'reabilitacao', 'reabilitação', 'physiotherapy') THEN 'fisioterapia'
        
        -- Projeto 7 Dias variations *** NOVA CATEGORIA ***
        WHEN exercise_type IN ('projeto', 'projeto_7_dias', 'projeto 7 dias', 'check-in', 'checkin', 'check_in', 'daily_check') THEN 'projeto_7_dias'
        
        -- Dança variations
        WHEN exercise_type IN ('danca', 'dança', 'dance', 'zumba', 'ritmos') THEN 'danca'
        
        -- Valores padrão
        ELSE lower(trim(exercise_type))
    END;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- 2. Atualizar função de valores padrão
-- Esta atualização é feita inline na função get_or_create_category_goal
-- Adicionar suporte para projeto_7_dias = 210 minutos (7 dias × 30 min)

-- 3. Teste da nova categoria
SELECT 'Testando normalização da nova categoria...' as status;

-- Teste 1: Variações de "projeto"
SELECT 
    'projeto' as original,
    normalize_exercise_category('projeto') as normalizada;
    
SELECT 
    'Projeto 7 Dias' as original,
    normalize_exercise_category('Projeto 7 Dias') as normalizada;
    
SELECT 
    'check-in' as original,
    normalize_exercise_category('check-in') as normalizada;

-- 4. Script para aplicar no Supabase
/*
INSTRUÇÕES PARA APLICAR:

1. Acesse o Supabase SQL Editor
2. Execute este script completo
3. Teste criando uma meta de "Projeto 7 Dias" no app
4. Verifique se aparece no dashboard

RESULTADO ESPERADO:
- projeto_7_dias mapeada corretamente
- Meta padrão de 210 minutos
- Aparece no workoutCategoryGoalsProvider
- Integrada ao dashboard
*/

SELECT 'Script concluído! Nova categoria projeto_7_dias integrada.' as resultado; 