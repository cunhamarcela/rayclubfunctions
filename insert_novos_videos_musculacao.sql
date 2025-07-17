-- =====================================================
-- SCRIPT: INSERÇÃO DE NOVOS VÍDEOS DE MUSCULAÇÃO
-- =====================================================
-- Data: Janeiro 2025
-- Descrição: Inserir 3 novos vídeos de treino de musculação
-- Vídeos: Treino E, Treino F, Treino A - Semana 02
-- =====================================================

-- Verificação inicial: quantos vídeos existem atualmente na categoria Musculação
SELECT 
    category,
    COUNT(*) as total_videos
FROM workout_videos 
WHERE category = 'Musculação'
GROUP BY category;

-- =====================================================
-- INSERÇÃO DOS NOVOS VÍDEOS
-- =====================================================

-- 1. Treino E - Musculação
INSERT INTO workout_videos (
    title,
    description,
    youtube_url,
    thumbnail_url,
    duration,
    duration_minutes,
    difficulty,
    instructor_name,
    category,
    order_index,
    is_new,
    is_popular,
    is_recommended,
    created_at,
    updated_at
) VALUES (
    'Treino E',
    'Treino completo de musculação focado em desenvolvimento muscular e força. Sequência de exercícios planejados para máxima eficiência.',
    'https://youtu.be/9DuQ5lBul3k',
    'https://img.youtube.com/vi/9DuQ5lBul3k/maxresdefault.jpg',
    '45 min',
    45,
    'Intermediário',
    'Personal Trainer',
    'Musculação',
    1,
    true,
    false,
    false,
    NOW(),
    NOW()
);

-- 2. Treino F - Musculação
INSERT INTO workout_videos (
    title,
    description,
    youtube_url,
    thumbnail_url,
    duration,
    duration_minutes,
    difficulty,
    instructor_name,
    category,
    order_index,
    is_new,
    is_popular,
    is_recommended,
    created_at,
    updated_at
) VALUES (
    'Treino F',
    'Treino avançado de musculação com exercícios específicos para ganho de massa muscular e definição corporal.',
    'https://youtu.be/IgDVKO2OUgc',
    'https://img.youtube.com/vi/IgDVKO2OUgc/maxresdefault.jpg',
    '50 min',
    50,
    'Avançado',
    'Personal Trainer',
    'Musculação',
    2,
    true,
    false,
    false,
    NOW(),
    NOW()
);

-- 3. Treino A - Semana 02 - Musculação
INSERT INTO workout_videos (
    title,
    description,
    youtube_url,
    thumbnail_url,
    duration,
    duration_minutes,
    difficulty,
    instructor_name,
    category,
    order_index,
    is_new,
    is_popular,
    is_recommended,
    created_at,
    updated_at
) VALUES (
    'Treino A - Semana 02',
    'Segunda semana do programa de treinamento A. Evolução natural do treino com progressão de cargas e intensidade.',
    'https://youtu.be/zUKHyAuXldg',
    'https://img.youtube.com/vi/zUKHyAuXldg/maxresdefault.jpg',
    '40 min',
    40,
    'Intermediário',
    'Personal Trainer',
    'Musculação',
    3,
    true,
    false,
    false,
    NOW(),
    NOW()
);

-- =====================================================
-- ATUALIZAÇÃO DA CATEGORIA
-- =====================================================

-- Atualizar contagem de vídeos na categoria Musculação
UPDATE workout_categories 
SET 
    "workoutsCount" = (
        SELECT COUNT(*) 
        FROM workout_videos 
        WHERE category = 'Musculação'
    ),
    updated_at = NOW()
WHERE name = 'Musculação';

-- =====================================================
-- VERIFICAÇÕES FINAIS
-- =====================================================

-- 1. Verificar se os vídeos foram inseridos corretamente
SELECT 
    id,
    title,
    youtube_url,
    category,
    difficulty,
    duration,
    duration_minutes,
    is_new,
    created_at
FROM workout_videos 
WHERE title IN ('Treino E', 'Treino F', 'Treino A - Semana 02')
ORDER BY created_at DESC;

-- 2. Verificar total de vídeos na categoria após inserção
SELECT 
    category,
    COUNT(*) as total_videos
FROM workout_videos 
WHERE category = 'Musculação'
GROUP BY category;

-- 3. Verificar contagem atualizada na tabela de categorias
SELECT 
    name,
    "workoutsCount",
    updated_at
FROM workout_categories 
WHERE name = 'Musculação';

-- 4. Listar todos os vídeos de Musculação (para validação visual)
SELECT 
    title,
    duration,
    difficulty,
    is_new,
    DATE(created_at) as data_criacao
FROM workout_videos 
WHERE category = 'Musculação'
ORDER BY created_at DESC;

-- =====================================================
-- NOTAS IMPORTANTES
-- =====================================================
-- ✅ Script corrigido conforme estrutura REAL do banco
-- ✅ Removido 'video_id' (coluna não existe)
-- ✅ Removido 'is_premium' (coluna não existe)
-- ✅ Adicionado 'duration_minutes' (integer)
-- ✅ Adicionado 'order_index' para organização
-- ✅ Adicionado flags: is_new=true, is_popular=false, is_recommended=false
-- ✅ URLs e thumbnails do YouTube configuradas
-- ✅ Categoria Musculação mantida consistente
-- ===================================================== 