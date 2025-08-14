-- ========================================
-- INSERIR VÍDEOS COMPLETOS DE FISIOTERAPIA
-- Data: 2025-01-21
-- Baseado na tabela de subcategorias fornecida
-- ========================================

-- Verificar estrutura atual da fisioterapia
SELECT 
    '=== ESTRUTURA ATUAL DA FISIOTERAPIA ===' as info;

SELECT 
    COALESCE(subcategory, '(sem subcategoria)') as subcategoria,
    COUNT(*) as quantidade_videos,
    STRING_AGG(title, ', ' ORDER BY title) as videos
FROM workout_videos 
WHERE category = 'da178dba-ae94-425a-aaed-133af7b1bb0f' -- Fisioterapia
GROUP BY subcategory
ORDER BY subcategory;

-- ========================================
-- INSERÇÃO DOS VÍDEOS POR SUBCATEGORIA
-- ========================================

-- 🏋️ SUBCATEGORIA: ESTABILIDADE (11 vídeos)
-- Exercícios de fortalecimento e prevenção de lesões

-- 1. Estabilidade Prancha (Core)
INSERT INTO workout_videos (
    title, description, youtube_url, thumbnail_url, duration, duration_minutes,
    difficulty, instructor_name, category, subcategory, order_index,
    is_new, is_popular, is_recommended, created_at, updated_at
) VALUES (
    'Estabilidade Prancha',
    'Exercício fundamental de estabilidade de core utilizando a prancha ventral para fortalecimento da musculatura profunda do abdômen.',
    'https://youtu.be/Vj3IcFJrM_Y',
    'https://img.youtube.com/vi/Vj3IcFJrM_Y/maxresdefault.jpg',
    '8 min', 8, 'Iniciante', 'The Unit',
    'da178dba-ae94-425a-aaed-133af7b1bb0f', 'estabilidade', 1,
    true, true, true, NOW(), NOW()
);

-- 2. Estabilidade Prancha Lateral (Core)
INSERT INTO workout_videos (
    title, description, youtube_url, thumbnail_url, duration, duration_minutes,
    difficulty, instructor_name, category, subcategory, order_index,
    is_new, is_popular, is_recommended, created_at, updated_at
) VALUES (
    'Estabilidade Prancha Lateral',
    'Variação da prancha para trabalhar estabilidade lateral do core, fortalecendo músculos oblíquos e estabilizadores laterais.',
    'https://youtu.be/kHmTmi-hXH4',
    'https://img.youtube.com/vi/kHmTmi-hXH4/maxresdefault.jpg',
    '7 min', 7, 'Intermediário', 'The Unit',
    'da178dba-ae94-425a-aaed-133af7b1bb0f', 'estabilidade', 2,
    true, true, true, NOW(), NOW()
);

-- 3. Estabilidade Ombro 1
INSERT INTO workout_videos (
    title, description, youtube_url, thumbnail_url, duration, duration_minutes,
    difficulty, instructor_name, category, subcategory, order_index,
    is_new, is_popular, is_recommended, created_at, updated_at
) VALUES (
    'Estabilidade Ombro 1',
    'Primeira série de exercícios para estabilização do complexo do ombro, fortalecendo rotadores e estabilizadores escapulares.',
    'https://youtu.be/A0FY8CAwLIU',
    'https://img.youtube.com/vi/A0FY8CAwLIU/maxresdefault.jpg',
    '10 min', 10, 'Iniciante', 'The Unit',
    'da178dba-ae94-425a-aaed-133af7b1bb0f', 'estabilidade', 3,
    true, true, true, NOW(), NOW()
);

-- 4. Estabilidade Ombro 2
INSERT INTO workout_videos (
    title, description, youtube_url, thumbnail_url, duration, duration_minutes,
    difficulty, instructor_name, category, subcategory, order_index,
    is_new, is_popular, is_recommended, created_at, updated_at
) VALUES (
    'Estabilidade Ombro 2',
    'Segunda série de exercícios avançados para estabilização do ombro, progressão dos exercícios básicos de fortalecimento.',
    'https://youtu.be/rJGNTqBhqeE',
    'https://img.youtube.com/vi/rJGNTqBhqeE/maxresdefault.jpg',
    '12 min', 12, 'Intermediário', 'The Unit',
    'da178dba-ae94-425a-aaed-133af7b1bb0f', 'estabilidade', 4,
    true, true, true, NOW(), NOW()
);

-- 5. Dor x Lesão (Conceitos)
INSERT INTO workout_videos (
    title, description, youtube_url, thumbnail_url, duration, duration_minutes,
    difficulty, instructor_name, category, subcategory, order_index,
    is_new, is_popular, is_recommended, created_at, updated_at
) VALUES (
    'Dor x Lesão',
    'Entendimento teórico sobre a diferença entre dor e lesão, conceitos fundamentais para prevenção e tratamento em fisioterapia.',
    'https://youtu.be/9QMcoB0frWs',
    'https://img.youtube.com/vi/9QMcoB0frWs/maxresdefault.jpg',
    '15 min', 15, 'Iniciante', 'The Unit',
    'da178dba-ae94-425a-aaed-133af7b1bb0f', 'estabilidade', 5,
    true, true, true, NOW(), NOW()
);

-- 6. Dor Joelho (Prevenção)
INSERT INTO workout_videos (
    title, description, youtube_url, thumbnail_url, duration, duration_minutes,
    difficulty, instructor_name, category, subcategory, order_index,
    is_new, is_popular, is_recommended, created_at, updated_at
) VALUES (
    'Dor Joelho',
    'Exercícios específicos para prevenção e tratamento de dor no joelho, focando em estabilização e fortalecimento.',
    'https://youtu.be/goqV7FFXHX0',
    'https://img.youtube.com/vi/goqV7FFXHX0/maxresdefault.jpg',
    '14 min', 14, 'Intermediário', 'The Unit',
    'da178dba-ae94-425a-aaed-133af7b1bb0f', 'estabilidade', 6,
    true, true, true, NOW(), NOW()
);

-- 7. Dor Ombro (Prevenção)
INSERT INTO workout_videos (
    title, description, youtube_url, thumbnail_url, duration, duration_minutes,
    difficulty, instructor_name, category, subcategory, order_index,
    is_new, is_popular, is_recommended, created_at, updated_at
) VALUES (
    'Dor Ombro',
    'Protocolo de exercícios para prevenção e alívio da dor no ombro, incluindo fortalecimento e mobilização.',
    'https://youtu.be/ZLzfk3rvzB8',
    'https://img.youtube.com/vi/ZLzfk3rvzB8/maxresdefault.jpg',
    '13 min', 13, 'Intermediário', 'The Unit',
    'da178dba-ae94-425a-aaed-133af7b1bb0f', 'estabilidade', 7,
    true, true, true, NOW(), NOW()
);

-- 8. Estabilidade Quadril 1
INSERT INTO workout_videos (
    title, description, youtube_url, thumbnail_url, duration, duration_minutes,
    difficulty, instructor_name, category, subcategory, order_index,
    is_new, is_popular, is_recommended, created_at, updated_at
) VALUES (
    'Estabilidade Quadril 1',
    'Primeira série de exercícios para estabilização do quadril, fundamentais para prevenção de lesões nos membros inferiores.',
    'https://youtu.be/88Fr06Pt8Fc',
    'https://img.youtube.com/vi/88Fr06Pt8Fc/maxresdefault.jpg',
    '11 min', 11, 'Iniciante', 'The Unit',
    'da178dba-ae94-425a-aaed-133af7b1bb0f', 'estabilidade', 8,
    true, true, true, NOW(), NOW()
);

-- 9. Estabilidade Quadril 2
INSERT INTO workout_videos (
    title, description, youtube_url, thumbnail_url, duration, duration_minutes,
    difficulty, instructor_name, category, subcategory, order_index,
    is_new, is_popular, is_recommended, created_at, updated_at
) VALUES (
    'Estabilidade Quadril 2',
    'Segunda série de exercícios para quadril, progredindo em complexidade e desafio para estabilização.',
    'https://youtu.be/S1fbVnNlrGQ',
    'https://img.youtube.com/vi/S1fbVnNlrGQ/maxresdefault.jpg',
    '12 min', 12, 'Intermediário', 'The Unit',
    'da178dba-ae94-425a-aaed-133af7b1bb0f', 'estabilidade', 9,
    true, true, true, NOW(), NOW()
);

-- 10. Estabilidade Quadril 3
INSERT INTO workout_videos (
    title, description, youtube_url, thumbnail_url, duration, duration_minutes,
    difficulty, instructor_name, category, subcategory, order_index,
    is_new, is_popular, is_recommended, created_at, updated_at
) VALUES (
    'Estabilidade Quadril 3',
    'Terceira série de exercícios avançados para quadril, incluindo exercícios unilaterais e funcionais.',
    'https://youtu.be/iFbkzEKY9xA',
    'https://img.youtube.com/vi/iFbkzEKY9xA/maxresdefault.jpg',
    '13 min', 13, 'Avançado', 'The Unit',
    'da178dba-ae94-425a-aaed-133af7b1bb0f', 'estabilidade', 10,
    true, true, true, NOW(), NOW()
);

-- 11. Estabilidade Quadril 4
INSERT INTO workout_videos (
    title, description, youtube_url, thumbnail_url, duration, duration_minutes,
    difficulty, instructor_name, category, subcategory, order_index,
    is_new, is_popular, is_recommended, created_at, updated_at
) VALUES (
    'Estabilidade Quadril 4',
    'Quarta e última série de exercícios para quadril, focando em estabilização dinâmica e movimentos complexos.',
    'https://youtu.be/GELGxRjhvJc',
    'https://img.youtube.com/vi/GELGxRjhvJc/maxresdefault.jpg',
    '14 min', 14, 'Avançado', 'The Unit',
    'da178dba-ae94-425a-aaed-133af7b1bb0f', 'estabilidade', 11,
    true, true, true, NOW(), NOW()
);

-- 🤸 SUBCATEGORIA: MOBILIDADE (6 vídeos)
-- Exercícios para melhoria da amplitude de movimento

-- 12. Mobilidade Extensão Torácica
INSERT INTO workout_videos (
    title, description, youtube_url, thumbnail_url, duration, duration_minutes,
    difficulty, instructor_name, category, subcategory, order_index,
    is_new, is_popular, is_recommended, created_at, updated_at
) VALUES (
    'Mobilidade Extensão Torácica',
    'Exercícios específicos para melhoria da mobilidade em extensão da coluna torácica, essencial para postura.',
    'https://youtu.be/wP3gBqbQSiY',
    'https://img.youtube.com/vi/wP3gBqbQSiY/maxresdefault.jpg',
    '9 min', 9, 'Iniciante', 'The Unit',
    'da178dba-ae94-425a-aaed-133af7b1bb0f', 'mobilidade', 1,
    true, true, true, NOW(), NOW()
);

-- 13. Mobilidade Torácica e Rotação
INSERT INTO workout_videos (
    title, description, youtube_url, thumbnail_url, duration, duration_minutes,
    difficulty, instructor_name, category, subcategory, order_index,
    is_new, is_popular, is_recommended, created_at, updated_at
) VALUES (
    'Mobilidade Torácica e Rotação',
    'Sequência de movimentos para melhorar mobilidade torácica em rotação, importante para atividades funcionais.',
    'https://youtu.be/3rzx4pSg5WA',
    'https://img.youtube.com/vi/3rzx4pSg5WA/maxresdefault.jpg',
    '10 min', 10, 'Iniciante', 'The Unit',
    'da178dba-ae94-425a-aaed-133af7b1bb0f', 'mobilidade', 2,
    true, true, true, NOW(), NOW()
);

-- 14. Mobilidade Joelho
INSERT INTO workout_videos (
    title, description, youtube_url, thumbnail_url, duration, duration_minutes,
    difficulty, instructor_name, category, subcategory, order_index,
    is_new, is_popular, is_recommended, created_at, updated_at
) VALUES (
    'Mobilidade Joelho',
    'Exercícios para melhoria da amplitude de movimento do joelho, incluindo flexão e extensão.',
    'https://youtu.be/LBMCqtmpTDI',
    'https://img.youtube.com/vi/LBMCqtmpTDI/maxresdefault.jpg',
    '8 min', 8, 'Iniciante', 'The Unit',
    'da178dba-ae94-425a-aaed-133af7b1bb0f', 'mobilidade', 3,
    true, true, true, NOW(), NOW()
);

-- 15. Mobilidade Rotação Interna Ombro
INSERT INTO workout_videos (
    title, description, youtube_url, thumbnail_url, duration, duration_minutes,
    difficulty, instructor_name, category, subcategory, order_index,
    is_new, is_popular, is_recommended, created_at, updated_at
) VALUES (
    'Mobilidade Rotação Interna Ombro',
    'Exercícios específicos para melhoria da rotação interna do ombro, movimento frequentemente limitado.',
    'https://youtu.be/c6Tue-pNaFE',
    'https://img.youtube.com/vi/c6Tue-pNaFE/maxresdefault.jpg',
    '7 min', 7, 'Intermediário', 'The Unit',
    'da178dba-ae94-425a-aaed-133af7b1bb0f', 'mobilidade', 4,
    true, true, true, NOW(), NOW()
);

-- 16. Mobilidade Ombro
INSERT INTO workout_videos (
    title, description, youtube_url, thumbnail_url, duration, duration_minutes,
    difficulty, instructor_name, category, subcategory, order_index,
    is_new, is_popular, is_recommended, created_at, updated_at
) VALUES (
    'Mobilidade Ombro',
    'Sequência completa de exercícios para mobilidade geral do ombro em todos os planos de movimento.',
    'https://youtu.be/uHTKM322DBI',
    'https://img.youtube.com/vi/uHTKM322DBI/maxresdefault.jpg',
    '11 min', 11, 'Iniciante', 'The Unit',
    'da178dba-ae94-425a-aaed-133af7b1bb0f', 'mobilidade', 5,
    true, true, true, NOW(), NOW()
);

-- 17. Mobilidade Tornozelo
INSERT INTO workout_videos (
    title, description, youtube_url, thumbnail_url, duration, duration_minutes,
    difficulty, instructor_name, category, subcategory, order_index,
    is_new, is_popular, is_recommended, created_at, updated_at
) VALUES (
    'Mobilidade Tornozelo',
    'Exercícios para melhoria da mobilidade do tornozelo, fundamentais para prevenção de lesões em membros inferiores.',
    'https://youtu.be/5zwb-qtI-z0',
    'https://img.youtube.com/vi/5zwb-qtI-z0/maxresdefault.jpg',
    '9 min', 9, 'Iniciante', 'The Unit',
    'da178dba-ae94-425a-aaed-133af7b1bb0f', 'mobilidade', 6,
    true, true, true, NOW(), NOW()
);

-- ========================================
-- VERIFICAÇÕES E RELATÓRIOS
-- ========================================

-- Atualizar contador da categoria fisioterapia
UPDATE workout_categories 
SET "workoutsCount" = (
    SELECT COUNT(*) 
    FROM workout_videos 
    WHERE category = 'da178dba-ae94-425a-aaed-133af7b1bb0f'
),
updated_at = NOW()
WHERE id = 'da178dba-ae94-425a-aaed-133af7b1bb0f';

-- Verificar inserção por subcategoria
SELECT 
    '=== VÍDEOS INSERIDOS POR SUBCATEGORIA ===' as info;

SELECT 
    COALESCE(subcategory, '(sem subcategoria)') as subcategoria,
    COUNT(*) as quantidade_videos,
    STRING_AGG(title, ', ' ORDER BY order_index, title) as videos
FROM workout_videos 
WHERE category = 'da178dba-ae94-425a-aaed-133af7b1bb0f' -- Fisioterapia
GROUP BY subcategory
ORDER BY subcategoria;

-- Listar todos os vídeos de estabilidade
SELECT 
    '=== VÍDEOS DE ESTABILIDADE ===' as info;

SELECT 
    order_index,
    title,
    youtube_url,
    duration,
    difficulty
FROM workout_videos 
WHERE category = 'da178dba-ae94-425a-aaed-133af7b1bb0f'
  AND subcategory = 'estabilidade'
ORDER BY order_index;

-- Listar todos os vídeos de mobilidade
SELECT 
    '=== VÍDEOS DE MOBILIDADE ===' as info;

SELECT 
    order_index,
    title,
    youtube_url,
    duration,
    difficulty
FROM workout_videos 
WHERE category = 'da178dba-ae94-425a-aaed-133af7b1bb0f'
  AND subcategory = 'mobilidade'
ORDER BY order_index;

-- Verificação final de contagem
SELECT 
    '=== VERIFICAÇÃO FINAL ===' as info;

SELECT 
    wc.name as categoria,
    wc."workoutsCount" as total_videos_categoria,
    COUNT(wv.id) as videos_reais,
    CASE 
        WHEN wc."workoutsCount" = COUNT(wv.id) THEN '✅ Correto'
        ELSE '⚠️ Divergência'
    END as status
FROM workout_categories wc
LEFT JOIN workout_videos wv ON wv.category = wc.id
WHERE wc.id = 'da178dba-ae94-425a-aaed-133af7b1bb0f'
GROUP BY wc.id, wc.name, wc."workoutsCount";

-- ========================================
-- SUCESSO!
-- ========================================

SELECT 
    '🎉 17 VÍDEOS DE FISIOTERAPIA ADICIONADOS COM SUCESSO! 🎉' as resultado,
         '📊 Estabilidade: 11 vídeos | Mobilidade: 6 vídeos | Testes: 2 vídeos' as resumo,
    'Agora você pode testar todas as subcategorias no app!' as proximos_passos; 