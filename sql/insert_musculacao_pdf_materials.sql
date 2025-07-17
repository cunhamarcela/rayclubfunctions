-- =====================================================
-- SCRIPT: INSERÇÃO DE MATERIAIS PDF PARA TREINOS DE MUSCULAÇÃO
-- =====================================================
-- Data: Janeiro 2025
-- Descrição: Associar PDFs do storage aos treinos de musculação específicos
-- =====================================================

-- Verificar se a tabela materials existe
SELECT table_name 
FROM information_schema.tables 
WHERE table_name = 'materials' AND table_schema = 'public';

-- Verificar se o bucket materials existe
SELECT name, public 
FROM storage.buckets 
WHERE name = 'materials';

-- =====================================================
-- PARTE 1: BUSCAR IDs DOS WORKOUT_VIDEOS DE MUSCULAÇÃO
-- =====================================================

-- Verificar treinos de musculação existentes
SELECT 
    id,
    title,
    category,
    instructor_name,
    youtube_url
FROM workout_videos 
WHERE category = 'Musculação' 
   OR instructor_name = 'Treinos de Musculação'
   OR LOWER(title) LIKE '%treino%'
ORDER BY title;

-- =====================================================
-- PARTE 2: INSERIR MATERIAIS PDF
-- =====================================================

-- Inserir PDFs associados aos treinos específicos
-- Assumindo que os PDFs estão no caminho: musculacao/TREINO_X.pdf

-- PDF para Treino A
INSERT INTO materials (
    title,
    description,
    material_type,
    material_context,
    file_path,
    author_name,
    workout_video_id,
    order_index,
    is_featured,
    requires_expert_access
)
SELECT 
    'Manual Treino A - PDF',
    'Material de apoio completo para o Treino A de musculação com instruções detalhadas, séries e repetições.',
    'pdf',
    'workout',
    'musculacao/TREINO A.pdf.pdf',
    'Treinos de Musculação',
    wv.id,
    1,
    true,
    false
FROM workout_videos wv
WHERE (LOWER(wv.title) LIKE '%treino a%' OR wv.title = 'Treino A')
  AND (wv.category = 'Musculação' OR wv.instructor_name = 'Treinos de Musculação')
LIMIT 1;

-- PDF para Treino B
INSERT INTO materials (
    title,
    description,
    material_type,
    material_context,
    file_path,
    author_name,
    workout_video_id,
    order_index,
    is_featured,
    requires_expert_access
)
SELECT 
    'Manual Treino B - PDF',
    'Material de apoio completo para o Treino B de musculação com progressão intermediária.',
    'pdf',
    'workout',
    'musculacao/TREINO B.pdf',
    'Treinos de Musculação',
    wv.id,
    1,
    true,
    false
FROM workout_videos wv
WHERE (LOWER(wv.title) LIKE '%treino b%' OR wv.title = 'Treino B - Musculação')
  AND (wv.category = 'Musculação' OR wv.instructor_name = 'Treinos de Musculação')
LIMIT 1;

-- PDF para Treino C
INSERT INTO materials (
    title,
    description,
    material_type,
    material_context,
    file_path,
    author_name,
    workout_video_id,
    order_index,
    is_featured,
    requires_expert_access
)
SELECT 
    'Manual Treino C - PDF',
    'Material de apoio completo para o Treino C de musculação com foco em hipertrofia.',
    'pdf',
    'workout',
    'musculacao/TREINO C.pdf',
    'Treinos de Musculação',
    wv.id,
    1,
    true,
    false
FROM workout_videos wv
WHERE (LOWER(wv.title) LIKE '%treino c%' OR wv.title = 'Treino C - Musculação')
  AND (wv.category = 'Musculação' OR wv.instructor_name = 'Treinos de Musculação')
LIMIT 1;

-- PDF para Treino D
INSERT INTO materials (
    title,
    description,
    material_type,
    material_context,
    file_path,
    author_name,
    workout_video_id,
    order_index,
    is_featured,
    requires_expert_access
)
SELECT 
    'Manual Treino D - PDF',
    'Material de apoio completo para o Treino D de musculação - nível avançado.',
    'pdf',
    'workout',
    'musculacao/TREINO D (1).pdf',
    'Treinos de Musculação',
    wv.id,
    1,
    true,
    false
FROM workout_videos wv
WHERE (LOWER(wv.title) LIKE '%treino d%' OR wv.title = 'Treino D - Musculação')
  AND (wv.category = 'Musculação' OR wv.instructor_name = 'Treinos de Musculação')
LIMIT 1;

-- PDF para Treino E
INSERT INTO materials (
    title,
    description,
    material_type,
    material_context,
    file_path,
    author_name,
    workout_video_id,
    order_index,
    is_featured,
    requires_expert_access
)
SELECT 
    'Manual Treino E - PDF',
    'Material de apoio completo para o Treino E de musculação com exercícios específicos.',
    'pdf',
    'workout',
    'musculacao/TREINO E (1).pdf',
    'Treinos de Musculação',
    wv.id,
    1,
    true,
    false
FROM workout_videos wv
WHERE (LOWER(wv.title) LIKE '%treino e%' OR wv.title = 'Treino E' OR wv.title = 'Musculação - Treino E')
  AND (wv.category = 'Musculação' OR wv.instructor_name = 'Treinos de Musculação')
LIMIT 1;

-- PDF para Treino F
INSERT INTO materials (
    title,
    description,
    material_type,
    material_context,
    file_path,
    author_name,
    workout_video_id,
    order_index,
    is_featured,
    requires_expert_access
)
SELECT 
    'Manual Treino F - PDF',
    'Material de apoio completo para o Treino F de musculação - programa avançado.',
    'pdf',
    'workout',
    'musculacao/TREINO F.pdf',
    'Treinos de Musculação',
    wv.id,
    1,
    true,
    false
FROM workout_videos wv
WHERE (LOWER(wv.title) LIKE '%treino f%' OR wv.title = 'Treino F')
  AND (wv.category = 'Musculação' OR wv.instructor_name = 'Treinos de Musculação')
LIMIT 1;

-- =====================================================
-- PARTE 3: VERIFICAÇÕES
-- =====================================================

-- Verificar se os materiais foram inseridos corretamente
SELECT 
    m.id,
    m.title,
    m.file_path,
    wv.title as workout_title,
    wv.instructor_name,
    m.created_at
FROM materials m
JOIN workout_videos wv ON m.workout_video_id = wv.id
WHERE m.material_context = 'workout'
  AND m.material_type = 'pdf'
  AND (wv.category = 'Musculação' OR wv.instructor_name = 'Treinos de Musculação')
ORDER BY wv.title;

-- Contagem de materiais por treino
SELECT 
    COUNT(*) as total_pdf_materials,
    COUNT(DISTINCT workout_video_id) as treinos_com_pdf
FROM materials 
WHERE material_context = 'workout' 
  AND material_type = 'pdf';

-- =====================================================
-- PARTE 4: ATUALIZAR WORKOUT_VIDEOS COM FLAG
-- =====================================================

-- Marcar vídeos que possuem material PDF associado
UPDATE workout_videos 
SET has_pdf_materials = true
WHERE id IN (
    SELECT DISTINCT workout_video_id 
    FROM materials 
    WHERE material_type = 'pdf' 
      AND workout_video_id IS NOT NULL
);

-- Verificar atualização
SELECT 
    wv.title,
    wv.has_pdf_materials,
    COUNT(m.id) as pdf_count
FROM workout_videos wv
LEFT JOIN materials m ON wv.id = m.workout_video_id AND m.material_type = 'pdf'
WHERE wv.category = 'Musculação' OR wv.instructor_name = 'Treinos de Musculação'
GROUP BY wv.id, wv.title, wv.has_pdf_materials
ORDER BY wv.title;

COMMIT; 