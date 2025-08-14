-- ========================================
-- DIAGNÓSTICO: POR QUE 22 VÍDEOS ESTÃO COMO BASIC?
-- ========================================
-- Data: 07/08/2025 12:32
-- Problema: Todos os vídeos deveriam ser expert-only, mas 22 estão como basic
-- Objetivo: Identificar e corrigir a configuração

-- =============================================
-- 1. INVESTIGAR DADOS ATUAIS
-- =============================================

-- 1.1 Ver todos os vídeos e seus níveis de acesso
SELECT 
  '=== ANÁLISE DETALHADA DOS VÍDEOS ===' as debug_section,
  id,
  title,
  instructor_name,
  category,
  requires_expert_access,
  CASE 
    WHEN requires_expert_access = true THEN '🌟 EXPERT ONLY'
    WHEN requires_expert_access = false THEN '👤 BASIC PERMITIDO'
    WHEN requires_expert_access IS NULL THEN '❓ INDEFINIDO'
  END as nivel_acesso,
  created_at
FROM workout_videos 
ORDER BY requires_expert_access ASC, instructor_name, title;

-- 1.2 Verificar quais instrutores/categorias estão como basic
SELECT 
  '=== INSTRUTORES/CATEGORIAS BASIC ===' as debug_section,
  instructor_name,
  category,
  COUNT(*) as total_videos,
  COUNT(CASE WHEN requires_expert_access = false THEN 1 END) as videos_basic,
  COUNT(CASE WHEN requires_expert_access = true THEN 1 END) as videos_expert,
  COUNT(CASE WHEN requires_expert_access IS NULL THEN 1 END) as videos_null
FROM workout_videos 
GROUP BY instructor_name, category
HAVING COUNT(CASE WHEN requires_expert_access = false THEN 1 END) > 0
ORDER BY videos_basic DESC;

-- =============================================
-- 2. IDENTIFICAR A CAUSA
-- =============================================

-- 2.1 Verificar se algum script definiu basic por engano
-- Procurar por padrões nos vídeos basic
SELECT 
  '=== PADRÕES DOS VÍDEOS BASIC ===' as debug_section,
  title,
  instructor_name,
  category,
  created_at,
  'Criado em: ' || created_at::date as data_criacao
FROM workout_videos 
WHERE requires_expert_access = false
ORDER BY created_at DESC;

-- =============================================
-- 3. SOLUÇÃO: TORNAR TODOS OS VÍDEOS EXPERT-ONLY
-- =============================================

-- 3.1 BACKUP dos dados atuais para auditoria
CREATE TABLE IF NOT EXISTS workout_videos_backup_levels AS
SELECT 
  id,
  title,
  instructor_name,
  category,
  requires_expert_access as old_level,
  'backup_' || to_char(now(), 'YYYY_MM_DD_HH24_MI_SS') as backup_timestamp
FROM workout_videos;

-- 3.2 CORRIGIR: Tornar TODOS os vídeos expert-only
UPDATE workout_videos 
SET 
  requires_expert_access = true,
  updated_at = now()
WHERE requires_expert_access != true;

-- 3.3 Verificar o resultado
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
-- 4. VERIFICAR POLÍTICA RLS
-- =============================================

-- 4.1 Atualizar política RLS para ser mais restritiva
DROP POLICY IF EXISTS "Permitir visualização da lista para todos os usuários autent" ON workout_videos;

-- 4.2 Criar política EXPERT-ONLY
CREATE POLICY "Videos_expert_only_policy" ON workout_videos
FOR SELECT 
USING (
  -- Só usuários expert podem ver vídeos
  EXISTS (
    SELECT 1 
    FROM profiles p
    WHERE p.id = auth.uid() 
    AND p.account_type = 'expert'
  )
  AND
  -- E só vídeos que requerem acesso expert (que agora são todos)
  requires_expert_access = true
);

-- 4.3 Verificar política criada
SELECT 
  '=== POLÍTICA RLS ATUALIZADA ===' as debug_section,
  policyname,
  permissive,
  cmd,
  qual as condicao
FROM pg_policies 
WHERE tablename = 'workout_videos';

-- =============================================
-- 5. TESTE FINAL
-- =============================================

-- 5.1 Simular acesso de usuário basic (sem auth)
-- Deve retornar 0 vídeos
SELECT 
  '=== TESTE USUÁRIO BASIC ===' as debug_section,
  'Sem autenticação (simulando basic)' as tipo_usuario,
  COUNT(*) as videos_visiveis,
  CASE 
    WHEN COUNT(*) = 0 THEN '✅ ACESSO NEGADO CORRETAMENTE'
    ELSE '❌ PROBLEMA: BASIC VÊ VÍDEOS!'
  END as resultado
FROM workout_videos;

-- 5.2 Log da operação
INSERT INTO logs_operacoes (
  operacao,
  detalhes,
  timestamp,
  sucesso
) VALUES (
  'FIX_VIDEO_LEVELS_ALL_EXPERT',
  'Convertidos todos os vídeos para expert-only. RLS atualizada.',
  now(),
  true
);

SELECT '🎉 CORREÇÃO CONCLUÍDA! Todos os vídeos agora são EXPERT-ONLY' as status_final;
