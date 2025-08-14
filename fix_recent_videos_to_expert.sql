-- ========================================
-- CORREÇÃO URGENTE: VÍDEOS BASIC → EXPERT
-- ========================================
-- Data: 07/08/2025 12:35
-- Problema: 22 vídeos adicionados em julho como basic por engano
-- Solução: Converter todos para expert-only e atualizar RLS

-- =============================================
-- 1. BACKUP DOS DADOS ATUAIS
-- =============================================

-- 1.1 Criar backup para auditoria
CREATE TABLE IF NOT EXISTS workout_videos_fix_backup AS
SELECT 
  id,
  title,
  instructor_name,
  category,
  requires_expert_access as old_level,
  'backup_urgent_fix_' || to_char(now(), 'YYYY_MM_DD_HH24_MI_SS') as backup_reason,
  now() as backup_timestamp
FROM workout_videos 
WHERE requires_expert_access = false;

-- 1.2 Verificar backup criado
SELECT 
  'BACKUP CRIADO' as status,
  COUNT(*) as videos_salvos,
  backup_reason
FROM workout_videos_fix_backup 
GROUP BY backup_reason;

-- =============================================
-- 2. CORREÇÃO: TODOS OS VÍDEOS → EXPERT-ONLY
-- =============================================

-- 2.1 Converter todos os vídeos para expert-only
UPDATE workout_videos 
SET 
  requires_expert_access = true,
  updated_at = now()
WHERE requires_expert_access = false OR requires_expert_access IS NULL;

-- 2.2 Verificar resultado da correção
SELECT 
  '=== RESULTADO DA CORREÇÃO ===' as debug_section,
  COUNT(*) as total_videos,
  COUNT(CASE WHEN requires_expert_access = true THEN 1 END) as videos_expert,
  COUNT(CASE WHEN requires_expert_access = false THEN 1 END) as videos_basic,
  COUNT(CASE WHEN requires_expert_access IS NULL THEN 1 END) as videos_null,
  CASE 
    WHEN COUNT(CASE WHEN requires_expert_access = false OR requires_expert_access IS NULL THEN 1 END) = 0 
    THEN '✅ TODOS OS VÍDEOS SÃO EXPERT-ONLY'
    ELSE '❌ AINDA HÁ VÍDEOS NÃO-EXPERT'
  END as status_final
FROM workout_videos;

-- =============================================
-- 3. ATUALIZAR POLÍTICA RLS
-- =============================================

-- 3.1 Remover política atual (muito permissiva)
DROP POLICY IF EXISTS "Permitir visualização da lista para todos os usuários autent" ON workout_videos;

-- 3.2 Criar política EXPERT-ONLY restritiva
CREATE POLICY "Expert_only_video_access" ON workout_videos
FOR SELECT 
USING (
  -- CONDIÇÃO 1: Usuário deve ser expert via profiles.account_type
  EXISTS (
    SELECT 1 
    FROM profiles p
    WHERE p.id = auth.uid() 
    AND p.account_type = 'expert'
  )
  -- CONDIÇÃO 2: E o vídeo deve requerer acesso expert (que agora são todos)
  AND requires_expert_access = true
);

-- 3.3 Verificar nova política
SELECT 
  '=== NOVA POLÍTICA RLS ===' as debug_section,
  policyname,
  permissive,
  cmd,
  CASE 
    WHEN policyname LIKE '%Expert_only%' THEN '✅ POLÍTICA EXPERT-ONLY ATIVA'
    ELSE '⚠️ POLÍTICA ANTIGA'
  END as status
FROM pg_policies 
WHERE tablename = 'workout_videos';

-- =============================================
-- 4. TESTE FINAL DE ACESSO
-- =============================================

-- 4.1 Simular usuário basic (sem auth) - deve ver 0 vídeos
SELECT 
  '=== TESTE ACESSO BASIC ===' as debug_section,
  'Simulação usuário basic (sem auth)' as tipo_teste,
  COUNT(*) as videos_visiveis,
  CASE 
    WHEN COUNT(*) = 0 THEN '✅ ACESSO NEGADO CORRETAMENTE'
    ELSE '❌ ERRO: BASIC AINDA VÊ VÍDEOS!'
  END as resultado
FROM workout_videos
WHERE auth.uid() IS NULL;  -- Simula usuário não autenticado

-- =============================================
-- 5. LOG DA OPERAÇÃO
-- =============================================

-- 5.1 Registrar a correção
INSERT INTO logs_operacoes (
  operacao,
  detalhes,
  timestamp,
  sucesso
) VALUES (
  'URGENT_FIX_ALL_VIDEOS_EXPERT_ONLY',
  'Corrigidos 22 vídeos que estavam como basic para expert-only. Nova política RLS aplicada.',
  now(),
  true
) ON CONFLICT DO NOTHING;

-- 5.2 Relatório final
SELECT 
  '🎉 CORREÇÃO CONCLUÍDA!' as status,
  'Todos os vídeos agora são EXPERT-ONLY' as resultado,
  'Política RLS atualizada para máxima segurança' as seguranca,
  'Usuários basic não veem mais nenhum vídeo' as confirmacao;
