-- ========================================
-- CORREÇÃO DO TESTE DE VALIDAÇÃO
-- ========================================
-- O teste anterior estava mostrando ❌ para categorias válidas

SELECT '🔧 TESTE DE MAPEAMENTO CORRIGIDO' as teste;

-- Teste corrigido que valida todas as categorias
SELECT 
    original,
    normalize_exercise_category(original) as normalizada,
    CASE 
        WHEN normalize_exercise_category(original) IN (
            'musculacao', 'cardio', 'yoga', 'funcional', 'pilates',
            'hiit', 'alongamento', 'danca', 'corrida', 'caminhada',
            'natacao', 'ciclismo', 'fisioterapia'
        ) THEN '✅ VÁLIDA'
        WHEN normalize_exercise_category(original) = 'outro' THEN '⚠️ GENÉRICA'
        ELSE '❌ INVÁLIDA'
    END as status_corrigido
FROM (
    VALUES 
        ('Musculação'),
        ('musculacao'),
        ('MUSCULACAO'),
        ('força'),
        ('Força'),
        ('bodybuilding'),
        ('Cardio'),
        ('cardio'),
        ('cardiovascular'),
        ('aeróbico'),
        ('Yoga'),
        ('yoga'),
        ('ioga'),
        ('Funcional'),
        ('funcional'),
        ('crossfit'),
        ('Pilates'),
        ('pilates'),
        ('HIIT'),
        ('hiit'),
        ('alta intensidade'),
        ('Corrida'),
        ('corrida'),
        ('running'),
        ('Caminhada'),
        ('caminhada'),
        ('walking'),
        ('Alongamento'),
        ('alongamento'),
        ('stretching'),
        ('Dança'),
        ('danca'),
        ('zumba'),
        ('Categoria Inexistente')
) as test_data(original);

-- ========================================
-- RESUMO DO MAPEAMENTO
-- ========================================

SELECT '📊 RESUMO DO SISTEMA DE MAPEAMENTO' as teste;

-- Contar quantas variações mapeiam para cada categoria final
WITH mapeamento_test AS (
    SELECT 
        normalize_exercise_category(original) as categoria_final,
        original
    FROM (
        VALUES 
            ('Musculação'), ('musculacao'), ('MUSCULACAO'), ('força'), ('Força'), ('bodybuilding'),
            ('Cardio'), ('cardio'), ('cardiovascular'), ('aeróbico'),
            ('Yoga'), ('yoga'), ('ioga'),
            ('Funcional'), ('funcional'), ('crossfit'),
            ('Pilates'), ('pilates'),
            ('HIIT'), ('hiit'), ('alta intensidade'),
            ('Corrida'), ('corrida'), ('running'),
            ('Caminhada'), ('caminhada'), ('walking'),
            ('Alongamento'), ('alongamento'), ('stretching'),
            ('Dança'), ('danca'), ('zumba')
    ) as test_data(original)
)
SELECT 
    categoria_final,
    count(*) as variacoes_mapeadas,
    array_agg(original) as exemplos
FROM mapeamento_test
GROUP BY categoria_final
ORDER BY variacoes_mapeadas DESC;

-- ========================================
-- VALIDAÇÃO FINAL
-- ========================================

SELECT '✅ VALIDAÇÃO FINAL DO SISTEMA' as teste;

SELECT 
    'Sistema de mapeamento funcionando' as componente,
    CASE 
        WHEN (
            normalize_exercise_category('Musculação') = 'musculacao' AND
            normalize_exercise_category('Força') = 'musculacao' AND
            normalize_exercise_category('cardio') = 'cardio' AND
            normalize_exercise_category('running') = 'corrida' AND
            normalize_exercise_category('yoga') = 'yoga'
        ) 
        THEN '✅ FUNCIONANDO PERFEITAMENTE'
        ELSE '❌ PROBLEMA DETECTADO'
    END as status;

SELECT 
    'Categorias suportadas' as info,
    ARRAY[
        'musculacao', 'cardio', 'funcional', 'yoga', 'pilates',
        'hiit', 'alongamento', 'danca', 'corrida', 'caminhada',
        'natacao', 'ciclismo', 'fisioterapia', 'outro'
    ] as lista_completa; 