-- Adicionar campo para URL do PDF se não existir
ALTER TABLE workout_videos 
ADD COLUMN IF NOT EXISTS pdf_url TEXT;

-- Adicionar comentário ao campo
COMMENT ON COLUMN workout_videos.pdf_url IS 'URL do arquivo PDF associado ao treino (opcional)';

-- Verificar se o campo foi adicionado
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'workout_videos' 
AND column_name = 'pdf_url';

-- Atualizar o Treino A com o PDF
UPDATE workout_videos 
SET pdf_url = 'URL_DO_SEU_PDF_AQUI'  -- Substitua pela URL real do PDF
WHERE title = 'Treino A' 
AND category = 'd2d2a9b8-d861-47c7-9d26-283539beda24'::varchar;

-- Verificar o resultado
SELECT id, title, video_url, pdf_url 
FROM workout_videos 
WHERE title = 'Treino A'; 