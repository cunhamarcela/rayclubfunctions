-- ========================================
-- COMANDOS PRÁTICOS PARA PROTEÇÃO DE VÍDEOS
-- ========================================
-- Use estes comandos para controlar a proteção temporária dos vídeos

-- ========================================
-- 🔒 ATIVAR PROTEÇÃO (Bloquear todos os vídeos)
-- ========================================

-- Comando simples para bloquear tudo
SELECT enable_video_protection('Manutenção temporária do sistema');

-- OU com motivo personalizado
-- SELECT enable_video_protection('Atualizações de conteúdo em andamento');

-- ========================================
-- ✅ DESATIVAR PROTEÇÃO (Voltar ao normal)
-- ========================================

-- Comando para restaurar acesso normal
SELECT disable_video_protection();

-- ========================================
-- 📊 VERIFICAR STATUS ATUAL
-- ========================================

-- Executar verificação completa
\i check_video_status.sql

-- ========================================
-- 🔒 BLOQUEAR VÍDEOS ESPECÍFICOS
-- ========================================

-- Bloquear vídeos que ainda estão aparecendo para usuários basic
\i block_specific_videos.sql

-- ========================================
-- 🔒 BLOQUEAR TODOS OS VÍDEOS
-- ========================================

-- Bloquear TODOS os vídeos do sistema
\i block_videos_simple.sql

-- ========================================
-- ✅ DESBLOQUEAR VÍDEOS
-- ========================================

-- Desbloquear vídeos específicos
\i restore_specific_videos.sql

-- Desbloquear TODOS os vídeos
\i unblock_videos_simple.sql

-- ========================================
-- 🚨 COMANDOS DIRETOS DE EMERGÊNCIA
-- ========================================

-- Verificar rapidamente quantos vídeos estão bloqueados
SELECT 
  COUNT(*) as total_videos,
  COUNT(*) FILTER (WHERE youtube_url IS NOT NULL) as ativos,
  COUNT(*) FILTER (WHERE youtube_url IS NULL) as bloqueados
FROM workout_videos;

-- Bloquear TUDO imediatamente
-- UPDATE workout_videos SET youtube_url = NULL, thumbnail_url = NULL WHERE youtube_url IS NOT NULL;

-- Desbloquear usando backup completo
-- UPDATE workout_videos SET youtube_url = b.youtube_url, thumbnail_url = b.thumbnail_url FROM workout_videos_backup b WHERE workout_videos.id = b.id;

-- Desbloquear usando backup específico
-- UPDATE workout_videos SET youtube_url = b.youtube_url, thumbnail_url = b.thumbnail_url FROM specific_videos_backup b WHERE workout_videos.id = b.id;

-- ========================================
-- 🔍 DIAGNÓSTICO COMPLETO
-- ========================================

-- Script para verificar tudo de uma vez
DO $$
BEGIN
  RAISE NOTICE '========================================';
  RAISE NOTICE '🔍 DIAGNÓSTICO DO SISTEMA DE PROTEÇÃO';
  RAISE NOTICE '========================================';
END $$;

-- Status da proteção
SELECT 
  CASE 
    WHEN protection_active THEN '🔒 ATIVADA - Vídeos bloqueados'
    ELSE '✅ DESATIVADA - Acesso normal'
  END as status,
  CASE 
    WHEN protection_active THEN 'Desde: ' || enabled_since::TEXT
    ELSE 'Sistema funcionando normalmente'
  END as detalhes,
  reason as motivo
FROM check_video_protection_status();

-- Estatísticas do sistema
SELECT 
  '📊 Estatísticas:' as info,
  COUNT(*) as total_videos,
  COUNT(*) FILTER (WHERE instructor_name IS NOT NULL) as videos_com_instrutor,
  COUNT(DISTINCT category) as total_categorias,
  COUNT(DISTINCT instructor_name) as total_instrutores
FROM workout_videos;

-- ========================================
-- 🚨 COMANDOS DE EMERGÊNCIA
-- ========================================

/*

Se algo der errado, use estes comandos:

1. FORÇAR DESBLOQUEIO:
   UPDATE global_video_protection SET is_enabled = FALSE WHERE id = 1;

2. RESETAR SISTEMA COMPLETAMENTE:
   DROP TABLE IF EXISTS global_video_protection CASCADE;
   DROP FUNCTION IF EXISTS enable_video_protection(TEXT);
   DROP FUNCTION IF EXISTS disable_video_protection();
   DROP FUNCTION IF EXISTS check_video_protection_status();

3. VERIFICAR SE FUNÇÃO EXISTE:
   SELECT proname FROM pg_proc WHERE proname = 'can_user_access_video_link';

4. TESTAR ACESSO DE UM USUÁRIO ESPECÍFICO:
   SELECT can_user_access_video_link('USER_ID_HERE'::UUID, 'VIDEO_ID_HERE'::UUID);

*/ 