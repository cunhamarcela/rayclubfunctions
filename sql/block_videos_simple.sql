-- ========================================
-- BLOQUEIO SIMPLES E TEMPORÁRIO DE VÍDEOS
-- ========================================
-- Este script bloqueia todos os vídeos removendo temporariamente seus URLs
-- Sem criar funções, sem modificar o Flutter - apenas SQL direto

-- ========================================
-- 1. CRIAR TABELA DE BACKUP
-- ========================================

-- Criar tabela para guardar os URLs originais
CREATE TABLE IF NOT EXISTS workout_videos_backup AS 
SELECT 
  id,
  youtube_url,
  thumbnail_url,
  NOW() as backup_created_at
FROM workout_videos 
WHERE youtube_url IS NOT NULL;

-- Verificar quantos vídeos foram salvos no backup
SELECT 
  'Backup criado com sucesso!' as status,
  COUNT(*) as videos_salvos,
  NOW() as criado_em
FROM workout_videos_backup;

-- ========================================
-- 2. BLOQUEAR TODOS OS VÍDEOS
-- ========================================

-- Remover URLs do YouTube para tornar vídeos inacessíveis
UPDATE workout_videos 
SET 
  youtube_url = NULL,
  thumbnail_url = NULL,
  updated_at = NOW()
WHERE youtube_url IS NOT NULL;

-- Verificar resultado do bloqueio
SELECT 
  'Vídeos bloqueados!' as status,
  COUNT(*) as total_videos,
  COUNT(*) FILTER (WHERE youtube_url IS NULL) as videos_bloqueados,
  COUNT(*) FILTER (WHERE youtube_url IS NOT NULL) as videos_ainda_ativos
FROM workout_videos;

-- ========================================
-- 3. PARA REVERTER (DESBLOQUEAR)
-- ========================================

/*
-- Para reverter e desbloquear todos os vídeos, execute:

-- Restaurar URLs originais do backup
UPDATE workout_videos 
SET 
  youtube_url = b.youtube_url,
  thumbnail_url = b.thumbnail_url,
  updated_at = NOW()
FROM workout_videos_backup b
WHERE workout_videos.id = b.id;

-- Verificar se foi restaurado
SELECT 
  'Vídeos desbloqueados!' as status,
  COUNT(*) as total_videos,
  COUNT(*) FILTER (WHERE youtube_url IS NOT NULL) as videos_ativos,
  COUNT(*) FILTER (WHERE youtube_url IS NULL) as videos_bloqueados
FROM workout_videos;

-- Remover tabela de backup (opcional)
-- DROP TABLE workout_videos_backup;

*/

-- ========================================
-- 4. VERIFICAÇÃO FINAL
-- ========================================

-- Mostrar status atual
SELECT 
  '🔒 BLOQUEIO ATIVADO' as status,
  'Todos os vídeos estão sem URL' as detalhes,
  COUNT(*) as total_videos_bloqueados
FROM workout_videos 
WHERE youtube_url IS NULL;

RAISE NOTICE '✅ Bloqueio aplicado com sucesso!';
RAISE NOTICE '📱 No app: usuários verão vídeos sem poder reproduzir';
RAISE NOTICE '🔄 Para reverter: execute o script de desbloqueio nos comentários acima'; 