-- ========================================
-- SOLUÇÃO 2: TABELA DE SUBCATEGORIAS SEPARADA
-- Mais robusta e escalável
-- ========================================

-- 1. Criar tabela de subcategorias
CREATE TABLE IF NOT EXISTS workout_subcategories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    parent_category_id UUID NOT NULL,
    icon VARCHAR(50),
    color_hex VARCHAR(7),
    order_index INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Foreign key para categoria pai
    CONSTRAINT fk_parent_category 
        FOREIGN KEY (parent_category_id) 
        REFERENCES workout_categories(id) 
        ON DELETE CASCADE,
    
    -- Unique constraint para evitar duplicatas na mesma categoria
    CONSTRAINT unique_subcategory_per_category 
        UNIQUE (parent_category_id, name)
);

-- 2. Criar índices
CREATE INDEX idx_workout_subcategories_parent ON workout_subcategories(parent_category_id);
CREATE INDEX idx_workout_subcategories_active ON workout_subcategories(is_active);
CREATE INDEX idx_workout_subcategories_order ON workout_subcategories(order_index);

-- 3. Adicionar campo subcategory_id à tabela workout_videos
ALTER TABLE workout_videos 
ADD COLUMN IF NOT EXISTS subcategory_id UUID,
ADD CONSTRAINT fk_video_subcategory 
    FOREIGN KEY (subcategory_id) 
    REFERENCES workout_subcategories(id) 
    ON DELETE SET NULL;

-- 4. Criar índice para o novo campo
CREATE INDEX idx_workout_videos_subcategory_id ON workout_videos(subcategory_id);

-- 5. Inserir subcategorias de fisioterapia
INSERT INTO workout_subcategories (
    name, 
    description, 
    parent_category_id, 
    icon, 
    color_hex, 
    order_index
) VALUES 
(
    'Testes', 
    'Avaliações e diagnósticos funcionais',
    'da178dba-ae94-425a-aaed-133af7b1bb0f', -- ID da categoria Fisioterapia
    'assignment',
    '#3498DB',
    1
),
(
    'Mobilidade', 
    'Exercícios para melhorar amplitude de movimento',
    'da178dba-ae94-425a-aaed-133af7b1bb0f', -- ID da categoria Fisioterapia
    'accessibility_new',
    '#2ECC71',
    2
),
(
    'Fortalecimento', 
    'Prevenção de lesões e fortalecimento muscular',
    'da178dba-ae94-425a-aaed-133af7b1bb0f', -- ID da categoria Fisioterapia
    'fitness_center',
    '#E74C3C',
    3
);

-- 6. Atualizar vídeos de fisioterapia com as subcategorias

-- Subcategoria: Testes
UPDATE workout_videos 
SET subcategory_id = (
    SELECT id FROM workout_subcategories 
    WHERE name = 'Testes' 
    AND parent_category_id = 'da178dba-ae94-425a-aaed-133af7b1bb0f'
)
WHERE category = 'da178dba-ae94-425a-aaed-133af7b1bb0f' -- Fisioterapia
  AND (
    LOWER(title) LIKE '%apresentação%' OR
    LOWER(title) LIKE '%teste%' OR
    LOWER(title) LIKE '%avaliação%' OR
    LOWER(description) LIKE '%apresentação%' OR
    LOWER(description) LIKE '%introdução%'
  );

-- Subcategoria: Mobilidade
UPDATE workout_videos 
SET subcategory_id = (
    SELECT id FROM workout_subcategories 
    WHERE name = 'Mobilidade' 
    AND parent_category_id = 'da178dba-ae94-425a-aaed-133af7b1bb0f'
)
WHERE category = 'da178dba-ae94-425a-aaed-133af7b1bb0f' -- Fisioterapia
  AND (
    LOWER(title) LIKE '%mobilidade%' OR
    LOWER(description) LIKE '%mobilidade%' OR
    LOWER(description) LIKE '%amplitude%'
  );

-- Subcategoria: Fortalecimento
UPDATE workout_videos 
SET subcategory_id = (
    SELECT id FROM workout_subcategories 
    WHERE name = 'Fortalecimento' 
    AND parent_category_id = 'da178dba-ae94-425a-aaed-133af7b1bb0f'
)
WHERE category = 'da178dba-ae94-425a-aaed-133af7b1bb0f' -- Fisioterapia
  AND (
    LOWER(title) LIKE '%prevenção%' OR
    LOWER(title) LIKE '%lesões%' OR
    LOWER(title) LIKE '%joelho%' OR
    LOWER(title) LIKE '%coluna%' OR
    LOWER(title) LIKE '%fortalecimento%' OR
    LOWER(description) LIKE '%prevenção%' OR
    LOWER(description) LIKE '%fortaleça%'
  );

-- 7. Verificar resultado da migração
SELECT 
    '=== SUBCATEGORIAS CRIADAS ===' as info;

SELECT 
    ws.name as subcategoria,
    ws.description,
    ws.color_hex,
    wc.name as categoria_pai
FROM workout_subcategories ws
JOIN workout_categories wc ON ws.parent_category_id = wc.id
ORDER BY ws.order_index;

-- 8. Ver vídeos classificados por subcategoria
SELECT 
    '=== VÍDEOS POR SUBCATEGORIA ===' as info;

SELECT 
    ws.name as subcategoria,
    COUNT(wv.id) as quantidade_videos,
    STRING_AGG(wv.title, ', ' ORDER BY wv.title) as videos
FROM workout_subcategories ws
LEFT JOIN workout_videos wv ON wv.subcategory_id = ws.id
WHERE ws.parent_category_id = 'da178dba-ae94-425a-aaed-133af7b1bb0f'
GROUP BY ws.id, ws.name, ws.order_index
ORDER BY ws.order_index;

-- 9. Vídeos de fisioterapia não classificados
SELECT 
    '=== VÍDEOS NÃO CLASSIFICADOS ===' as info;

SELECT 
    title,
    description,
    instructor_name
FROM workout_videos 
WHERE category = 'da178dba-ae94-425a-aaed-133af7b1bb0f' -- Fisioterapia
  AND subcategory_id IS NULL;

-- 10. Habilitar RLS na nova tabela
ALTER TABLE workout_subcategories ENABLE ROW LEVEL SECURITY;

-- 11. Criar política para subcategorias (públicas para leitura)
CREATE POLICY "Subcategorias são públicas" ON workout_subcategories
    FOR SELECT USING (is_active = true);

-- 12. Função para buscar vídeos por subcategoria
CREATE OR REPLACE FUNCTION get_videos_by_subcategory(subcategory_name TEXT, category_id UUID)
RETURNS TABLE(
    video_id UUID,
    title TEXT,
    duration TEXT,
    difficulty TEXT,
    youtube_url TEXT,
    instructor_name TEXT,
    description TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        wv.id,
        wv.title,
        wv.duration,
        wv.difficulty,
        wv.youtube_url,
        wv.instructor_name,
        wv.description
    FROM workout_videos wv
    JOIN workout_subcategories ws ON wv.subcategory_id = ws.id
    WHERE ws.name = subcategory_name
      AND ws.parent_category_id = category_id
      AND ws.is_active = true
    ORDER BY wv.order_index, wv.created_at;
END;
$$ LANGUAGE plpgsql; 