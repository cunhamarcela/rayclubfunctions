-- =====================================================
-- MIGRAÇÃO: ADICIONAR SUPORTE A VÍDEOS NA TABELA MATERIALS
-- =====================================================
-- Data: Janeiro 2025
-- Descrição: Adicionar campos e tipo 'video' à tabela materials
-- =====================================================

-- 1. Adicionar o tipo 'video' ao enum de material_type
ALTER TABLE materials 
DROP CONSTRAINT IF EXISTS materials_material_type_check;

ALTER TABLE materials 
ADD CONSTRAINT materials_material_type_check 
CHECK (material_type IN ('pdf', 'ebook', 'guide', 'document', 'video'));

-- 2. Adicionar campos específicos para vídeos
ALTER TABLE materials 
ADD COLUMN IF NOT EXISTS video_url TEXT,
ADD COLUMN IF NOT EXISTS video_id TEXT,
ADD COLUMN IF NOT EXISTS video_duration INTEGER;

-- 3. Criar índices para os novos campos
CREATE INDEX IF NOT EXISTS idx_materials_video_id ON materials(video_id);
CREATE INDEX IF NOT EXISTS idx_materials_type ON materials(material_type);

-- 4. Comentários para documentação
COMMENT ON COLUMN materials.video_url IS 'URL completa do vídeo (ex: YouTube URL)';
COMMENT ON COLUMN materials.video_id IS 'ID do vídeo do YouTube para embed';
COMMENT ON COLUMN materials.video_duration IS 'Duração do vídeo em segundos';

-- =====================================================
-- VERIFICAÇÃO DA MIGRAÇÃO
-- =====================================================

-- Verificar se as colunas foram adicionadas
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'materials' 
  AND column_name IN ('video_url', 'video_id', 'video_duration')
ORDER BY column_name;

-- Verificar se o constraint foi atualizado
SELECT conname, consrc 
FROM pg_constraint 
WHERE conname = 'materials_material_type_check';

-- =====================================================
-- MENSAGEM DE SUCESSO
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE '✅ Migração concluída! Tabela materials agora suporta vídeos.';
    RAISE NOTICE '📹 Campos adicionados: video_url, video_id, video_duration';
    RAISE NOTICE '🏷️ Tipo "video" adicionado ao enum material_type';
    RAISE NOTICE '🔍 Índices criados para otimização';
END $$; 