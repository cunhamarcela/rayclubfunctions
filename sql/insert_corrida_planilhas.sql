-- ===================================================
-- SCRIPT: Inserir Planilhas de Corrida
-- DATA: 2025-01-21
-- OBJETIVO: Adicionar PDFs de corrida como materiais
-- ===================================================

-- Inserir planilhas de corrida na tabela materials
INSERT INTO materials (
    id,
    title,
    description,
    material_type,
    material_context,
    file_path,
    file_size,
    thumbnail_url,
    author_name,
    workout_video_id,
    order_index,
    is_featured,
    requires_expert_access,
    created_at,
    updated_at
) VALUES 
(
    gen_random_uuid(),
    'Planilha de Treino 5KM',
    'Guia completo para treinar e completar uma corrida de 5 quilômetros. Inclui cronograma semanal, progressão gradual e dicas importantes para iniciantes.',
    'pdf',
    'workout',
    'corrida/5km.pdf', -- Path relativo ao bucket materials
    NULL, -- file_size será calculado automaticamente
    NULL, -- thumbnail_url (opcional)
    'Ray Club', -- author_name
    NULL, -- workout_video_id (não está vinculado a um vídeo específico)
    1, -- order_index (primeira planilha)
    true, -- is_featured (destacar na interface)
    false, -- requires_expert_access (acessível para todos)
    NOW(),
    NOW()
),
(
    gen_random_uuid(),
    'Planilha de Treino 10KM',
    'Programa avançado para corredores que buscam completar 10 quilômetros. Inclui treinos intervalados, long runs e estratégias de recuperação.',
    'pdf',
    'workout',
    'corrida/10km.pdf', -- Path relativo ao bucket materials
    NULL, -- file_size será calculado automaticamente
    NULL, -- thumbnail_url (opcional)
    'Ray Club', -- author_name
    NULL, -- workout_video_id (não está vinculado a um vídeo específico)
    2, -- order_index (segunda planilha)
    true, -- is_featured (destacar na interface)
    false, -- requires_expert_access (acessível para todos)
    NOW(),
    NOW()
);

-- Verificar se os materiais foram inseridos corretamente
SELECT 
    id,
    title,
    description,
    material_type,
    material_context,
    file_path,
    is_featured,
    order_index,
    created_at
FROM materials 
WHERE material_context = 'workout' 
  AND (title ILIKE '%corrida%' OR title ILIKE '%km%')
ORDER BY order_index ASC; 