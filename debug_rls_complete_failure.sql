-- ========================================
-- DEBUG URGENTE: POR QUE RLS NÃO FUNCIONA?
-- ========================================
-- Data: 07/08/2025 12:37
-- Problema: Política RLS criada mas usuários basic ainda veem todos os vídeos
-- Objetivo: Identificar e corrigir falha no RLS

-- =============================================
-- 1. VERIFICAR STATUS ATUAL DO RLS
-- =============================================

-- 1.1 Verificar se RLS está realmente habilitado
SELECT 
  '=== STATUS RLS ===' as debug_section,
  schemaname,
  tablename,
  rowsecurity as rls_habilitado,
  CASE 
    WHEN rowsecurity = true THEN '✅ RLS HABILITADO'
    WHEN rowsecurity = false THEN '❌ RLS DESABILITADO - PROBLEMA!'
    ELSE '⚠️ STATUS INDEFINIDO'
  END as status_rls
FROM pg_tables 
WHERE tablename = 'workout_videos';

-- 1.2 Verificar todas as políticas ativas
SELECT 
  '=== POLÍTICAS ATIVAS ===' as debug_section,
  policyname,
  permissive,
  cmd,
  qual,
  CASE 
    WHEN policyname LIKE '%Expert_only%' THEN '✅ NOSSA POLÍTICA'
    ELSE '⚠️ POLÍTICA ANTIGA/EXTERNA'
  END as tipo_politica
FROM pg_policies 
WHERE tablename = 'workout_videos'
ORDER BY policyname;

-- 1.3 Verificar se existe policy conflitante
SELECT 
  '=== ANÁLISE DE CONFLITOS ===' as debug_section,
  COUNT(*) as total_policies,
  COUNT(CASE WHEN permissive = 'PERMISSIVE' THEN 1 END) as permissive_policies,
  COUNT(CASE WHEN permissive = 'RESTRICTIVE' THEN 1 END) as restrictive_policies,
  CASE 
    WHEN COUNT(CASE WHEN permissive = 'PERMISSIVE' THEN 1 END) > 1 
    THEN '❌ MÚLTIPLAS POLÍTICAS PERMISSIVE - CONFLITO!'
    WHEN COUNT(*) = 0 
    THEN '❌ NENHUMA POLÍTICA ATIVA!'
    ELSE '✅ CONFIGURAÇÃO OK'
  END as diagnostico
FROM pg_policies 
WHERE tablename = 'workout_videos';

-- =============================================
-- 2. TESTE DETALHADO DE ACESSO
-- =============================================

-- 2.1 Simular diferentes cenários de usuário
-- Cenário 1: Sem autenticação (basic simulado)
SELECT 
  '=== TESTE SEM AUTH ===' as debug_section,
  'Sem autenticação' as cenario,
  COUNT(*) as videos_visiveis,
  CASE 
    WHEN COUNT(*) = 0 THEN '✅ BLOQUEADO'
    ELSE '❌ VAZANDO!'
  END as resultado
FROM workout_videos;

-- Cenário 2: Testar função auth.uid() funcionando
SELECT 
  '=== TESTE AUTH UID ===' as debug_section,
  'Função auth.uid()' as teste,
  auth.uid() as user_id,
  CASE 
    WHEN auth.uid() IS NULL THEN '⚠️ SEM USUÁRIO LOGADO'
    ELSE '✅ USUÁRIO IDENTIFICADO'
  END as status_auth;

-- =============================================
-- 3. INVESTIGAR PROBLEMAS CONHECIDOS
-- =============================================

-- 3.1 Verificar se existem views que bypassam RLS
SELECT 
  '=== VIEWS SUSPEITAS ===' as debug_section,
  table_name,
  view_definition
FROM information_schema.views 
WHERE table_name LIKE '%workout_video%'
OR view_definition LIKE '%workout_videos%';

-- 3.2 Verificar se Flutter está usando a tabela correta
-- Procurar por renomeações ou aliases
SELECT 
  '=== TABELAS RELACIONADAS ===' as debug_section,
  table_name,
  table_type
FROM information_schema.tables 
WHERE table_name LIKE '%workout_video%'
ORDER BY table_name;

-- =============================================
-- 4. SOLUÇÃO RADICAL: DESABILITAR TABELA ORIGINAL
-- =============================================

-- 4.1 Se RLS não funciona, vamos usar approach alternativo
-- Renomear tabela original para forçar uso correto
DROP VIEW IF EXISTS workout_videos_public;
DROP VIEW IF EXISTS workout_videos_filtered;

-- 4.2 Criar view restritiva que substitui a tabela
CREATE OR REPLACE VIEW workout_videos_public AS
SELECT 
  wv.id,
  wv.title,
  wv.duration,
  wv.duration_minutes,
  wv.difficulty,
  wv.youtube_url,
  wv.thumbnail_url,
  wv.category,
  wv.instructor_name,
  wv.description,
  wv.order_index,
  wv.is_new,
  wv.is_popular,
  wv.is_recommended,
  wv.created_at,
  wv.updated_at
FROM workout_videos wv
WHERE 
  -- CONDIÇÃO EXPERT: Só se usuário é expert
  EXISTS (
    SELECT 1 
    FROM profiles p
    WHERE p.id = auth.uid() 
    AND p.account_type = 'expert'
  )
  -- E vídeo requer acesso expert
  AND wv.requires_expert_access = true;

-- 4.3 Testar a view restritiva
SELECT 
  '=== TESTE VIEW RESTRITIVA ===' as debug_section,
  'workout_videos_public' as view_name,
  COUNT(*) as videos_na_view,
  CASE 
    WHEN COUNT(*) = 0 THEN '✅ VIEW BLOQUEANDO ACESSO'
    ELSE '❌ VIEW AINDA VAZANDO'
  END as resultado_view
FROM workout_videos_public;

-- =============================================
-- 5. ALTERNATIVA: SOLUÇÃO POR FLUTTER
-- =============================================

-- 5.1 Se nem RLS nem view funcionam, problema pode ser no Flutter
-- Verificar se Flutter está usando WHERE corretamente

-- 5.2 Criar função que sempre retorna vazio para basic
CREATE OR REPLACE FUNCTION get_workout_videos_for_user()
RETURNS TABLE (
  id UUID,
  title VARCHAR(255),
  duration VARCHAR(50),
  duration_minutes INTEGER,
  difficulty VARCHAR(50),
  youtube_url TEXT,
  thumbnail_url TEXT,
  category VARCHAR(100),
  instructor_name VARCHAR(255),
  description TEXT,
  order_index INTEGER,
  is_new BOOLEAN,
  is_popular BOOLEAN,
  is_recommended BOOLEAN,
  created_at TIMESTAMP WITH TIME ZONE,
  updated_at TIMESTAMP WITH TIME ZONE
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  user_account_type TEXT;
BEGIN
  -- Buscar tipo de conta do usuário
  SELECT account_type INTO user_account_type
  FROM profiles 
  WHERE profiles.id = auth.uid();
  
  -- Se não é expert, retorna vazio
  IF user_account_type != 'expert' OR user_account_type IS NULL THEN
    RETURN;
  END IF;
  
  -- Se é expert, retorna todos os vídeos
  RETURN QUERY
  SELECT 
    wv.id,
    wv.title,
    wv.duration,
    wv.duration_minutes,
    wv.difficulty,
    wv.youtube_url,
    wv.thumbnail_url,
    wv.category,
    wv.instructor_name,
    wv.description,
    wv.order_index,
    wv.is_new,
    wv.is_popular,
    wv.is_recommended,
    wv.created_at,
    wv.updated_at
  FROM workout_videos wv
  WHERE wv.requires_expert_access = true;
END;
$$;

-- 5.3 Testar a função
SELECT 
  '=== TESTE FUNÇÃO SEGURA ===' as debug_section,
  'get_workout_videos_for_user()' as funcao,
  COUNT(*) as videos_retornados,
  CASE 
    WHEN COUNT(*) = 0 THEN '✅ FUNÇÃO BLOQUEANDO'
    ELSE '❌ FUNÇÃO VAZANDO'
  END as resultado_funcao
FROM get_workout_videos_for_user();

-- =============================================
-- 6. RELATÓRIO DE DIAGNÓSTICO
-- =============================================

SELECT 
  '🚨 DIAGNÓSTICO COMPLETO' as titulo,
  'RLS falhou - investigação completa realizada' as status,
  'Views e função alternativas criadas' as solucoes,
  'Flutter pode precisar usar get_workout_videos_for_user()' as recomendacao;
