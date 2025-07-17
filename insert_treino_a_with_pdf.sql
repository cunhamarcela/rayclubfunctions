-- Primeiro, adicionar campo PDF se não existir
ALTER TABLE workout_videos 
ADD COLUMN IF NOT EXISTS pdf_url TEXT;

-- Verificar se o Treino A já existe
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM workout_videos 
        WHERE title = 'Treino A' 
        AND category = 'd2d2a9b8-d861-47c7-9d26-283539beda24'::varchar
    ) THEN
        -- Inserir Treino A com vídeo e PDF
        INSERT INTO workout_videos (
            title,
            description,
            video_url,
            thumbnail_url,
            duration,
            difficulty,
            category,
            instructor,
            is_new,
            is_popular,
            pdf_url,
            created_at,
            updated_at
        ) VALUES (
            'Treino A',
            'Primeira semana de treinos de musculação para iniciantes',
            'https://youtu.be/Tb5IqAAJyD8',
            'https://img.youtube.com/vi/Tb5IqAAJyD8/maxresdefault.jpg',
            45, -- 45 minutos
            'Iniciante',
            'd2d2a9b8-d861-47c7-9d26-283539beda24'::varchar, -- ID da categoria Musculação
            'Treinos de Musculação',
            true, -- é novo
            true, -- é popular
            'URL_DO_SEU_PDF_AQUI', -- Substitua pela URL real do PDF
            NOW(),
            NOW()
        );
        
        -- Atualizar contador de vídeos na categoria
        UPDATE workout_categories 
        SET "workoutsCount" = "workoutsCount" + 1
        WHERE id = 'd2d2a9b8-d861-47c7-9d26-283539beda24';
        
        RAISE NOTICE 'Treino A inserido com sucesso!';
    ELSE
        -- Se já existe, apenas atualizar o PDF
        UPDATE workout_videos 
        SET pdf_url = 'URL_DO_SEU_PDF_AQUI', -- Substitua pela URL real do PDF
            updated_at = NOW()
        WHERE title = 'Treino A' 
        AND category = 'd2d2a9b8-d861-47c7-9d26-283539beda24'::varchar;
        
        RAISE NOTICE 'PDF do Treino A atualizado!';
    END IF;
END $$;

-- Verificar o resultado
SELECT id, title, video_url, pdf_url, created_at, updated_at
FROM workout_videos 
WHERE title = 'Treino A'; 