-- ========================================
-- BLOQUEAR VÍDEOS ESPECÍFICOS
-- ========================================
-- Este script bloqueia vídeos específicos que ainda estão aparecendo para usuários basic

-- ========================================
-- 1. IDENTIFICAR OS VÍDEOS PROBLEMÁTICOS
-- ========================================

-- Buscar vídeos pelos títulos mencionados
SELECT 
  id,
  title,
  instructor_name,
  youtube_url,
  requires_expert_access
FROM workout_videos 
WHERE 
  LOWER(title) LIKE '%treino d%semana 02%' OR
  LOWER(title) LIKE '%treino f%' OR
  LOWER(title) LIKE '%treino b%' OR
  LOWER(title) LIKE '%treino c%' OR
  LOWER(title) LIKE '%treino a%' OR
  LOWER(title) LIKE '%superiores%cardio%' OR
  LOWER(title) LIKE '%técnica%fight%' OR
  LOWER(title) LIKE '%tecnica%fight%' OR
  LOWER(title) LIKE '%o que eu faria diferente%' OR
  LOWER(title) LIKE '%bora%assessoria%' OR
  (LOWER(title) LIKE '%musculação%' AND LOWER(title) LIKE '%treino%')
ORDER BY instructor_name, title;

-- ========================================
-- 2. BACKUP DOS VÍDEOS ESPECÍFICOS
-- ========================================

-- Criar backup específico desses vídeos
CREATE TABLE IF NOT EXISTS specific_videos_backup AS 
SELECT 
  id,
  title,
  youtube_url,
  thumbnail_url,
  requires_expert_access,
  NOW() as backup_created_at
FROM workout_videos 
WHERE 
  id IN (
    SELECT id FROM workout_videos 
    WHERE 
      LOWER(title) LIKE '%treino d%semana 02%' OR
      LOWER(title) LIKE '%treino f%' OR
      LOWER(title) LIKE '%treino b%' OR
      LOWER(title) LIKE '%treino c%' OR
      LOWER(title) LIKE '%treino a%' OR
      LOWER(title) LIKE '%superiores%cardio%' OR
      LOWER(title) LIKE '%técnica%fight%' OR
      LOWER(title) LIKE '%tecnica%fight%' OR
      LOWER(title) LIKE '%o que eu faria diferente%' OR
      LOWER(title) LIKE '%bora%assessoria%' OR
      (LOWER(title) LIKE '%musculação%' AND LOWER(title) LIKE '%treino%')
  );

-- Verificar backup
SELECT 
  'Backup específico criado!' as status,
  COUNT(*) as videos_salvos
FROM specific_videos_backup;

-- ========================================
-- 3. BLOQUEAR OS VÍDEOS ESPECÍFICOS
-- ========================================

-- OPÇÃO 1: Remover URLs (torna inacessível)
UPDATE workout_videos 
SET 
  youtube_url = NULL,
  thumbnail_url = NULL,
  updated_at = NOW()
WHERE 
  LOWER(title) LIKE '%treino d%semana 02%' OR
  LOWER(title) LIKE '%treino f%' OR
  LOWER(title) LIKE '%treino b%' OR
  LOWER(title) LIKE '%treino c%' OR
  LOWER(title) LIKE '%treino a%' OR
  LOWER(title) LIKE '%superiores%cardio%' OR
  LOWER(title) LIKE '%técnica%fight%' OR
  LOWER(title) LIKE '%tecnica%fight%' OR
  LOWER(title) LIKE '%o que eu faria diferente%' OR
  LOWER(title) LIKE '%bora%assessoria%' OR
  (LOWER(title) LIKE '%musculação%' AND LOWER(title) LIKE '%treino%');

-- OPÇÃO 2: Marcar como expert (alternativa)
-- UPDATE workout_videos 
-- SET 
--   requires_expert_access = TRUE,
--   updated_at = NOW()
-- WHERE 
--   LOWER(title) LIKE '%treino d%semana 02%' OR
--   LOWER(title) LIKE '%treino f%' OR
--   LOWER(title) LIKE '%treino b%' OR
--   LOWER(title) LIKE '%treino c%' OR
--   LOWER(title) LIKE '%treino a%' OR
--   LOWER(title) LIKE '%superiores%cardio%' OR
--   LOWER(title) LIKE '%técnica%fight%' OR
--   LOWER(title) LIKE '%tecnica%fight%' OR
--   LOWER(title) LIKE '%o que eu faria diferente%' OR
--   LOWER(title) LIKE '%bora%assessoria%' OR
--   (LOWER(title) LIKE '%musculação%' AND LOWER(title) LIKE '%treino%');

-- ========================================
-- 4. VERIFICAR RESULTADO
-- ========================================

-- Mostrar vídeos que foram bloqueados
SELECT 
  'Vídeos bloqueados:' as status,
  title,
  instructor_name,
  CASE 
    WHEN youtube_url IS NULL THEN '🔒 Bloqueado'
    ELSE '✅ Ainda ativo'
  END as status_video
FROM workout_videos 
WHERE 
  LOWER(title) LIKE '%treino d%semana 02%' OR
  LOWER(title) LIKE '%treino f%' OR
  LOWER(title) LIKE '%treino b%' OR
  LOWER(title) LIKE '%treino c%' OR
  LOWER(title) LIKE '%treino a%' OR
  LOWER(title) LIKE '%superiores%cardio%' OR
  LOWER(title) LIKE '%técnica%fight%' OR
  LOWER(title) LIKE '%tecnica%fight%' OR
  LOWER(title) LIKE '%o que eu faria diferente%' OR
  LOWER(title) LIKE '%bora%assessoria%' OR
  (LOWER(title) LIKE '%musculação%' AND LOWER(title) LIKE '%treino%')
ORDER BY instructor_name, title;

-- Contar total de vídeos bloqueados
SELECT 
  COUNT(*) as total_bloqueados
FROM workout_videos 
WHERE youtube_url IS NULL;

RAISE NOTICE '✅ Vídeos específicos bloqueados com sucesso!';
RAISE NOTICE '📱 Usuários basic não conseguirão mais reproduzir esses vídeos'; 