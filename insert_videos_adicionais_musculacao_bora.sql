-- =====================================================
-- SCRIPT: INSERÇÃO DE VÍDEOS ADICIONAIS
-- =====================================================
-- Data: Janeiro 2025
-- Descrição: Inserir 12 vídeos adicionais
-- 2 vídeos de Musculação + 10 vídeos da Bora Assessoria
-- =====================================================

-- Verificar as categorias existentes
SELECT 
    id,
    name,
    description,
    "workoutsCount"
FROM workout_categories 
WHERE id IN (
    'd2d2a9b8-d861-47c7-9d26-283539beda24', -- Musculação
    '07754890-b092-4386-be56-bb088a2a96f1'  -- Bora Assessoria (Corrida)
);

-- =====================================================
-- VÍDEOS DE MUSCULAÇÃO
-- =====================================================

-- 1. Musculação - Treino D - Semana 02
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
    'Musculação - Treino D - Semana 02',
    'Treino D da segunda semana - evolução do programa de musculação com exercícios progressivos para desenvolvimento muscular avançado.',
    'https://youtu.be/3yY_1SqWVs0',
    'https://img.youtube.com/vi/3yY_1SqWVs0/maxresdefault.jpg',
    '55 min',
    55,
    'Avançado',
    'Treinos de Musculação',
    'd2d2a9b8-d861-47c7-9d26-283539beda24',
    20,
    true,
    true,
    true,
    NOW(),
    NOW()
);

-- 2. Musculação - Treino G
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
    'Musculação - Treino G',
    'Treino G completo de musculação - rotina avançada com exercícios específicos para máximo desenvolvimento muscular.',
    'https://youtu.be/3zXH9PE6mBs',
    'https://img.youtube.com/vi/3zXH9PE6mBs/maxresdefault.jpg',
    '60 min',
    60,
    'Avançado',
    'Treinos de Musculação',
    'd2d2a9b8-d861-47c7-9d26-283539beda24',
    21,
    true,
    true,
    true,
    NOW(),
    NOW()
);

-- =====================================================
-- VÍDEOS DA BORA ASSESSORIA
-- =====================================================

-- 3. O que eu faria diferente se estivesse começando hoje
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
    'Bora Assessoria - O que eu faria diferente se estivesse começando hoje',
    'Dicas valiosas e experiências compartilhadas sobre como começar a correr da forma mais eficiente e evitar erros comuns.',
    'https://youtu.be/L5uFJCUfPqY',
    'https://img.youtube.com/vi/L5uFJCUfPqY/maxresdefault.jpg',
    '15 min',
    15,
    'Iniciante',
    'Bora Assessoria',
    '07754890-b092-4386-be56-bb088a2a96f1',
    10,
    true,
    false,
    true,
    NOW(),
    NOW()
);

-- 4. Existe um jeito certo para correr?
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
    'Bora Assessoria - Existe um jeito certo para correr?',
    'Análise técnica sobre a forma correta de correr, postura, pisada e técnicas para otimizar performance e prevenir lesões.',
    'https://youtu.be/q5Sdb78aKIU',
    'https://img.youtube.com/vi/q5Sdb78aKIU/maxresdefault.jpg',
    '20 min',
    20,
    'Iniciante',
    'Bora Assessoria',
    '07754890-b092-4386-be56-bb088a2a96f1',
    11,
    true,
    true,
    true,
    NOW(),
    NOW()
);

-- 5. Qual a frequência ideal na corrida?
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
    'Bora Assessoria - Qual a frequência ideal na corrida?',
    'Orientações sobre frequência de treinos semanais, recuperação adequada e como estruturar sua rotina de corrida.',
    'https://youtu.be/UMDV7_wxhw4',
    'https://img.youtube.com/vi/UMDV7_wxhw4/maxresdefault.jpg',
    '18 min',
    18,
    'Iniciante',
    'Bora Assessoria',
    '07754890-b092-4386-be56-bb088a2a96f1',
    12,
    true,
    true,
    true,
    NOW(),
    NOW()
);

-- 6. Termos da corrida que todo iniciante precisa saber
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
    'Bora Assessoria - Termos da corrida que todo iniciante precisa saber',
    'Glossário essencial com termos técnicos da corrida que todo iniciante deve conhecer para entender melhor o esporte.',
    'https://youtu.be/tl3Fimu0gpQ',
    'https://img.youtube.com/vi/tl3Fimu0gpQ/maxresdefault.jpg',
    '25 min',
    25,
    'Iniciante',
    'Bora Assessoria',
    '07754890-b092-4386-be56-bb088a2a96f1',
    13,
    true,
    false,
    true,
    NOW(),
    NOW()
);

-- 7. Dicas básicas de alimentação
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
    'Bora Assessoria - Dicas básicas de alimentação',
    'Orientações nutricionais básicas para corredores, incluindo pré e pós-treino, hidratação e alimentação balanceada.',
    'https://youtu.be/6yJKVsP20aQ',
    'https://img.youtube.com/vi/6yJKVsP20aQ/maxresdefault.jpg',
    '22 min',
    22,
    'Iniciante',
    'Bora Assessoria',
    '07754890-b092-4386-be56-bb088a2a96f1',
    14,
    true,
    true,
    true,
    NOW(),
    NOW()
);

-- 8. Dicas essenciais para iniciantes
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
    'Bora Assessoria - Dicas essenciais para iniciantes',
    'Compilado das dicas mais importantes para quem está começando a correr, incluindo equipamentos e primeiros passos.',
    'https://youtu.be/GOPI_6NDy4U',
    'https://img.youtube.com/vi/GOPI_6NDy4U/maxresdefault.jpg',
    '30 min',
    30,
    'Iniciante',
    'Bora Assessoria',
    '07754890-b092-4386-be56-bb088a2a96f1',
    15,
    true,
    true,
    true,
    NOW(),
    NOW()
);

-- 9. Por onde começar e fazer isso parte da sua rotina
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
    'Bora Assessoria - Por onde começar e fazer isso parte da sua rotina',
    'Estratégias práticas para incorporar a corrida na rotina diária e criar hábitos sustentáveis de exercício.',
    'https://youtu.be/801tkezxy6A',
    'https://img.youtube.com/vi/801tkezxy6A/maxresdefault.jpg',
    '28 min',
    28,
    'Iniciante',
    'Bora Assessoria',
    '07754890-b092-4386-be56-bb088a2a96f1',
    16,
    true,
    false,
    true,
    NOW(),
    NOW()
);

-- 10. Por onde começar?
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
    'Bora Assessoria - Por onde começar?',
    'Guia completo para iniciantes sobre os primeiros passos na corrida, escolha de equipamentos e planejamento inicial.',
    'https://youtu.be/QbVlhi8WFps',
    'https://img.youtube.com/vi/QbVlhi8WFps/maxresdefault.jpg',
    '20 min',
    20,
    'Iniciante',
    'Bora Assessoria',
    '07754890-b092-4386-be56-bb088a2a96f1',
    17,
    true,
    true,
    true,
    NOW(),
    NOW()
);

-- 11. Por que começar a correr?
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
    'Bora Assessoria - Por que começar a correr?',
    'Benefícios da corrida para saúde física e mental, motivações e transformações que o esporte pode proporcionar.',
    'https://youtu.be/rCofCuN-GKQ',
    'https://img.youtube.com/vi/rCofCuN-GKQ/maxresdefault.jpg',
    '15 min',
    15,
    'Iniciante',
    'Bora Assessoria',
    '07754890-b092-4386-be56-bb088a2a96f1',
    18,
    true,
    false,
    true,
    NOW(),
    NOW()
);

-- 12. Dicas de respiração
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
    'Bora Assessoria - Dicas de respiração',
    'Técnicas de respiração para corredores, como controlar o ritmo respiratório e otimizar a oxigenação durante a corrida.',
    'https://youtu.be/oAsp-YevYl8',
    'https://img.youtube.com/vi/oAsp-YevYl8/maxresdefault.jpg',
    '18 min',
    18,
    'Iniciante',
    'Bora Assessoria',
    '07754890-b092-4386-be56-bb088a2a96f1',
    19,
    true,
    true,
    true,
    NOW(),
    NOW()
);

-- =====================================================
-- ATUALIZAÇÃO DAS CATEGORIAS
-- =====================================================

-- Atualizar contagem de vídeos na categoria Musculação
UPDATE workout_categories 
SET 
    "workoutsCount" = (
        SELECT COUNT(*) 
        FROM workout_videos 
        WHERE category = 'd2d2a9b8-d861-47c7-9d26-283539beda24'
    ),
    updated_at = NOW()
WHERE id = 'd2d2a9b8-d861-47c7-9d26-283539beda24';

-- Atualizar contagem de vídeos na categoria Bora Assessoria (Corrida)
UPDATE workout_categories 
SET 
    "workoutsCount" = (
        SELECT COUNT(*) 
        FROM workout_videos 
        WHERE category = '07754890-b092-4386-be56-bb088a2a96f1'
    ),
    updated_at = NOW()
WHERE id = '07754890-b092-4386-be56-bb088a2a96f1';

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

-- Verificar contagem atualizada das categorias
SELECT 
    name,
    "workoutsCount",
    description
FROM workout_categories 
WHERE id IN (
    'd2d2a9b8-d861-47c7-9d26-283539beda24',
    '07754890-b092-4386-be56-bb088a2a96f1'
)
ORDER BY name;

-- Verificar total de vídeos por instrutor
SELECT 
    instructor_name,
    COUNT(*) as total_videos
FROM workout_videos 
WHERE instructor_name IN ('Treinos de Musculação', 'Bora Assessoria')
GROUP BY instructor_name
ORDER BY instructor_name; 