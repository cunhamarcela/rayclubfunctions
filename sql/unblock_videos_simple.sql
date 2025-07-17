-- ========================================
-- DESBLOQUEAR VÍDEOS - RESTAURAR ACESSO
-- ========================================
-- Este script restaura todos os vídeos usando o backup criado anteriormente

-- ========================================
-- 1. VERIFICAR SE EXISTE BACKUP
-- ========================================

-- Verificar se a tabela de backup existe
DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'workout_videos_backup') THEN
    RAISE EXCEPTION 'Tabela de backup não encontrada! Execute primeiro o script de bloqueio.';
  END IF;
END $$;

-- Mostrar quantos vídeos estão no backup
SELECT 
  'Backup encontrado!' as status,
  COUNT(*) as videos_no_backup,
  MIN(backup_created_at) as backup_criado_em
FROM workout_videos_backup;

-- ========================================
-- 2. RESTAURAR TODOS OS VÍDEOS
-- ========================================

-- Restaurar URLs originais do backup
UPDATE workout_videos 
SET 
  youtube_url = b.youtube_url,
  thumbnail_url = b.thumbnail_url,
  updated_at = NOW()
FROM workout_videos_backup b
WHERE workout_videos.id = b.id;

-- ========================================
-- 3. VERIFICAR RESULTADO
-- ========================================

-- Verificar se foi restaurado com sucesso
SELECT 
  '✅ VÍDEOS DESBLOQUEADOS!' as status,
  COUNT(*) as total_videos,
  COUNT(*) FILTER (WHERE youtube_url IS NOT NULL) as videos_ativos,
  COUNT(*) FILTER (WHERE youtube_url IS NULL) as videos_ainda_bloqueados
FROM workout_videos;

-- Mostrar alguns exemplos de vídeos restaurados
SELECT 
  'Exemplos de vídeos restaurados:' as info,
  title,
  CASE 
    WHEN youtube_url IS NOT NULL THEN '✅ Ativo'
    ELSE '❌ Ainda bloqueado'
  END as status
FROM workout_videos 
LIMIT 5;

-- ========================================
-- 4. LIMPEZA (OPCIONAL)
-- ========================================

-- Remover tabela de backup (descomente se quiser)
-- DROP TABLE workout_videos_backup;

RAISE NOTICE '✅ Desbloqueio concluído com sucesso!';
RAISE NOTICE '📱 No app: usuários podem reproduzir vídeos normalmente';
RAISE NOTICE '🗑️ Para limpar: descomente a linha DROP TABLE acima'; 