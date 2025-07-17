-- ========================================
-- RESTAURAR VÍDEOS ESPECÍFICOS
-- ========================================
-- Este script restaura os vídeos específicos que foram bloqueados

-- ========================================
-- 1. VERIFICAR BACKUP
-- ========================================

-- Verificar se existe backup específico
SELECT 
  'Backup específico encontrado!' as status,
  COUNT(*) as videos_no_backup,
  MIN(backup_created_at) as criado_em
FROM specific_videos_backup;

-- Mostrar vídeos no backup
SELECT 
  'Vídeos no backup:' as info,
  title,
  CASE 
    WHEN youtube_url IS NOT NULL THEN '✅ Tem URL'
    ELSE '❌ Sem URL'
  END as status_backup
FROM specific_videos_backup
ORDER BY title;

-- ========================================
-- 2. RESTAURAR VÍDEOS ESPECÍFICOS
-- ========================================

-- Restaurar URLs dos vídeos específicos
UPDATE workout_videos 
SET 
  youtube_url = b.youtube_url,
  thumbnail_url = b.thumbnail_url,
  requires_expert_access = b.requires_expert_access,
  updated_at = NOW()
FROM specific_videos_backup b
WHERE workout_videos.id = b.id;

-- ========================================
-- 3. VERIFICAR RESULTADO
-- ========================================

-- Verificar vídeos restaurados
SELECT 
  'Vídeos restaurados:' as status,
  title,
  instructor_name,
  CASE 
    WHEN youtube_url IS NOT NULL THEN '✅ Restaurado'
    ELSE '❌ Ainda bloqueado'
  END as status_video
FROM workout_videos 
WHERE id IN (SELECT id FROM specific_videos_backup)
ORDER BY instructor_name, title;

-- Contar restaurados
SELECT 
  COUNT(*) as total_restaurados
FROM workout_videos 
WHERE id IN (SELECT id FROM specific_videos_backup)
  AND youtube_url IS NOT NULL;

-- ========================================
-- 4. LIMPEZA (OPCIONAL)
-- ========================================

-- Remover backup específico (descomente se quiser)
-- DROP TABLE specific_videos_backup;

RAISE NOTICE '✅ Vídeos específicos restaurados com sucesso!';
RAISE NOTICE '📱 Usuários podem reproduzir esses vídeos novamente'; 