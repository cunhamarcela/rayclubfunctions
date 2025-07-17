-- =====================================================
-- SCRIPT: CORREÇÃO DE TIPOS DE DADOS NO JOIN
-- =====================================================
-- Erro: operator does not exist: character varying = uuid
-- Solução: Fazer cast explícito dos tipos
-- =====================================================

-- CORREÇÃO DA CONSULTA DE VERIFICAÇÃO
-- Verificar se os vídeos foram inseridos corretamente (com cast)
SELECT 
    wv.title,
    wv.duration,
    wv.youtube_url,
    wv.instructor_name,
    wc.name as categoria_nome,
    wv.is_new,
    wv.is_popular,
    wv.is_recommended
FROM workout_videos wv
JOIN workout_categories wc ON wv.category::uuid = wc.id  -- CAST para uuid
WHERE wv.youtube_url IN (
    'https://youtu.be/PcSBjmE5p_4',
    'https://youtu.be/nmw1S-MgZB8',
    'https://youtu.be/yf6ZrEdmrww',
    'https://youtu.be/LwhNjhgWVxg',
    'https://youtu.be/GuReZ7sCgEk',
    'https://youtu.be/7HGN94JMd4k',
    'https://youtu.be/XRl2edEW4Gs'
)
ORDER BY wc.name, wv.order_index;

-- =====================================================
-- VERIFICAR ESTRUTURA DAS TABELAS
-- =====================================================

-- Verificar tipo da coluna category em workout_videos
SELECT 
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'workout_videos' 
AND column_name = 'category';

-- Verificar tipo da coluna id em workout_categories  
SELECT 
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'workout_categories' 
AND column_name = 'id';

-- =====================================================
-- OPÇÃO 1: ALTERAR TIPO DA COLUNA CATEGORY PARA UUID
-- =====================================================
/*
-- CUIDADO: Execute apenas se necessário e após backup
-- Isso pode quebrar dados existentes se não forem UUIDs válidos

-- Primeiro, verificar se todos os valores são UUIDs válidos
SELECT category, 
       CASE 
           WHEN category ~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$' 
           THEN 'UUID válido'
           ELSE 'UUID inválido'
       END as status
FROM workout_videos 
WHERE category IS NOT NULL;

-- Se todos forem válidos, alterar o tipo:
ALTER TABLE workout_videos 
ALTER COLUMN category TYPE uuid USING category::uuid;
*/

-- =====================================================
-- OPÇÃO 2: CONSULTAS COM CAST (RECOMENDADO)
-- =====================================================

-- Para consultas futuras, sempre usar cast:
-- JOIN workout_categories wc ON wv.category::uuid = wc.id

-- =====================================================
-- VERIFICAÇÃO CORRIGIDA PARA OS VÍDEOS ADICIONAIS
-- =====================================================

-- Verificar vídeos adicionais (Musculação + Bora Assessoria)
SELECT 
    wv.title,
    wv.duration,
    wv.youtube_url,
    wv.instructor_name,
    wc.name as categoria_nome,
    wv.is_new,
    wv.is_popular,
    wv.is_recommended
FROM workout_videos wv
JOIN workout_categories wc ON wv.category::uuid = wc.id  -- CAST para uuid
WHERE wv.youtube_url IN (
    'https://youtu.be/3yY_1SqWVs0',
    'https://youtu.be/3zXH9PE6mBs',
    'https://youtu.be/L5uFJCUfPqY',
    'https://youtu.be/q5Sdb78aKIU',
    'https://youtu.be/UMDV7_wxhw4',
    'https://youtu.be/tl3Fimu0gpQ',
    'https://youtu.be/6yJKVsP20aQ',
    'https://youtu.be/GOPI_6NDy4U',
    'https://youtu.be/801tkezxy6A',
    'https://youtu.be/QbVlhi8WFps',
    'https://youtu.be/rCofCuN-GKQ',
    'https://youtu.be/oAsp-YevYl8'
)
ORDER BY wc.name, wv.order_index;

-- =====================================================
-- VERIFICAR CONTAGEM CORRIGIDA DAS CATEGORIAS
-- =====================================================

SELECT 
    wc.name,
    wc."workoutsCount",
    wc.description,
    COUNT(wv.id) as videos_reais
FROM workout_categories wc
LEFT JOIN workout_videos wv ON wv.category::uuid = wc.id  -- CAST para uuid
WHERE wc.id IN (
    '43eb2044-38cf-4193-848c-da46fd7e9cb4',
    'fe034f6d-aa79-436c-b0b7-7aea572f08c1',
    'd2d2a9b8-d861-47c7-9d26-283539beda24',
    '07754890-b092-4386-be56-bb088a2a96f1'
)
GROUP BY wc.id, wc.name, wc."workoutsCount", wc.description
ORDER BY wc.name; 