-- =====================================================
-- SCRIPT: INSERÇÃO DE NOVOS VÍDEOS FIGHT FIT E GOYA
-- =====================================================
-- Data: Janeiro 2025
-- Descrição: Inserir 7 novos vídeos do YouTube
-- Instrutores: Fight Fit e Goya Health Club
-- =====================================================

-- Verificar as categorias existentes
SELECT 
    id,
    name,
    description,
    "workoutsCount"
FROM workout_categories 
WHERE id IN (
    '43eb2044-38cf-4193-848c-da46fd7e9cb4', -- Fight Fit
    'fe034f6d-aa79-436c-b0b7-7aea572f08c1'  -- Goya Health Club
);

-- =====================================================
-- INSERÇÃO DOS NOVOS VÍDEOS
-- =====================================================

-- 1. FightFit - Fullbody
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
    'FightFit - Fullbody',
    'Treino completo de corpo inteiro com elementos de luta e exercícios funcionais para um condicionamento físico total.',
    'https://youtu.be/PcSBjmE5p_4',
    'https://img.youtube.com/vi/PcSBjmE5p_4/maxresdefault.jpg',
    '45 min',
    45,
    'Intermediário',
    'Fight Fit',
    '43eb2044-38cf-4193-848c-da46fd7e9cb4',
    10,
    true,
    true,
    true,
    NOW(),
    NOW()
);

-- 2. Pilates Goyá - Fullbody Miniband - Foco em Core
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
    'Pilates Goyá - Fullbody Miniband - Foco em Core',
    'Treino completo de Pilates utilizando miniband com foco específico no fortalecimento do core e estabilização.',
    'https://youtu.be/nmw1S-MgZB8',
    'https://img.youtube.com/vi/nmw1S-MgZB8/maxresdefault.jpg',
    '40 min',
    40,
    'Intermediário',
    'Goya Health Club',
    'fe034f6d-aa79-436c-b0b7-7aea572f08c1',
    10,
    true,
    true,
    true,
    NOW(),
    NOW()
);

-- 3. Pilates Goyá - Fullbody com caneleira - foco em inferiores
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
    'Pilates Goyá - Fullbody com caneleira - foco em inferiores',
    'Treino de Pilates corpo inteiro utilizando caneleiras com foco específico no fortalecimento dos membros inferiores.',
    'https://youtu.be/yf6ZrEdmrww',
    'https://img.youtube.com/vi/yf6ZrEdmrww/maxresdefault.jpg',
    '45 min',
    45,
    'Intermediário',
    'Goya Health Club',
    'fe034f6d-aa79-436c-b0b7-7aea572f08c1',
    11,
    true,
    true,
    true,
    NOW(),
    NOW()
);

-- 4. Pilates Goyá - Mat Pilates
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
    'Pilates Goyá - Mat Pilates',
    'Treino clássico de Mat Pilates no solo, focando nos princípios fundamentais do método com exercícios tradicionais.',
    'https://youtu.be/LwhNjhgWVxg',
    'https://img.youtube.com/vi/LwhNjhgWVxg/maxresdefault.jpg',
    '35 min',
    35,
    'Iniciante',
    'Goya Health Club',
    'fe034f6d-aa79-436c-b0b7-7aea572f08c1',
    12,
    true,
    true,
    true,
    NOW(),
    NOW()
);

-- 5. Pilates Goyá - Restaurativa
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
    'Pilates Goyá - Restaurativa',
    'Sessão restaurativa de Pilates com exercícios suaves e relaxantes para recuperação muscular e bem-estar.',
    'https://youtu.be/GuReZ7sCgEk',
    'https://img.youtube.com/vi/GuReZ7sCgEk/maxresdefault.jpg',
    '30 min',
    30,
    'Iniciante',
    'Goya Health Club',
    'fe034f6d-aa79-436c-b0b7-7aea572f08c1',
    13,
    true,
    false,
    true,
    NOW(),
    NOW()
);

-- 6. FightFit - Inferiores A
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
    'FightFit - Inferiores A',
    'Treino FightFit focado especificamente no fortalecimento dos membros inferiores com exercícios de alta intensidade.',
    'https://youtu.be/7HGN94JMd4k',
    'https://img.youtube.com/vi/7HGN94JMd4k/maxresdefault.jpg',
    '35 min',
    35,
    'Intermediário',
    'Fight Fit',
    '43eb2044-38cf-4193-848c-da46fd7e9cb4',
    11,
    true,
    true,
    true,
    NOW(),
    NOW()
);

-- 7. FightFit - Superiores + Cardio
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
    'FightFit - Superiores + Cardio',
    'Treino FightFit combinando exercícios para membros superiores com intervalos cardiovasculares de alta intensidade.',
    'https://youtu.be/XRl2edEW4Gs',
    'https://img.youtube.com/vi/XRl2edEW4Gs/maxresdefault.jpg',
    '40 min',
    40,
    'Avançado',
    'Fight Fit',
    '43eb2044-38cf-4193-848c-da46fd7e9cb4',
    12,
    true,
    true,
    true,
    NOW(),
    NOW()
);

-- =====================================================
-- ATUALIZAÇÃO DAS CATEGORIAS
-- =====================================================

-- Atualizar contagem de vídeos nas categorias
UPDATE workout_categories 
SET 
    "workoutsCount" = (
        SELECT COUNT(*) 
        FROM workout_videos 
        WHERE category = '43eb2044-38cf-4193-848c-da46fd7e9cb4'
    ),
    updated_at = NOW()
WHERE id = '43eb2044-38cf-4193-848c-da46fd7e9cb4';

UPDATE workout_categories 
SET 
    "workoutsCount" = (
        SELECT COUNT(*) 
        FROM workout_videos 
        WHERE category = 'fe034f6d-aa79-436c-b0b7-7aea572f08c1'
    ),
    updated_at = NOW()
WHERE id = 'fe034f6d-aa79-436c-b0b7-7aea572f08c1';

-- =====================================================
-- VERIFICAÇÃO FINAL
-- =====================================================

-- Verificar se os vídeos foram inseridos corretamente
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
JOIN workout_categories wc ON wv.category::uuid = wc.id
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

-- Verificar contagem atualizada das categorias
SELECT 
    name,
    "workoutsCount",
    description
FROM workout_categories 
WHERE id IN (
    '43eb2044-38cf-4193-848c-da46fd7e9cb4',
    'fe034f6d-aa79-436c-b0b7-7aea572f08c1'
)
ORDER BY name; 