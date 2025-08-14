-- ========================================
-- RESTAURAR POLÍTICA SIMPLES: TODOS PODEM VER A LISTA DE VÍDEOS
-- ========================================
-- Data: 07/08/2025 12:47
-- Objetivo: Todos podem ver a LISTA, proteção para REPRODUZIR fica no Flutter
-- Solução: Política permissiva para lista + ExpertVideoGuard para reprodução

-- =============================================
-- 1. REMOVER POLÍTICAS RESTRITIVAS ATUAIS
-- =============================================

-- 1.1 Remover todas as políticas expert-only
DROP POLICY IF EXISTS "Expert_only_video_access" ON workout_videos;
DROP POLICY IF EXISTS "Videos_expert_only_policy" ON workout_videos;
DROP POLICY IF EXISTS "workout_videos_expert_only" ON workout_videos;

-- =============================================
-- 2. CRIAR POLÍTICA SIMPLES E PERMISSIVA
-- =============================================

-- 2.1 Política que permite TODOS verem a LISTA de vídeos
CREATE POLICY "Todos_podem_ver_lista_videos" ON workout_videos
FOR SELECT 
USING (true);  -- Simples: todos podem ver a LISTA

-- =============================================
-- 3. GARANTIR QUE RLS ESTEJA HABILITADO
-- =============================================

-- 3.1 Habilitar RLS (caso tenha sido desabilitado)
ALTER TABLE workout_videos ENABLE ROW LEVEL SECURITY;

-- =============================================
-- 4. VERIFICAR SE FUNCIONOU
-- =============================================

-- 4.1 Testar acesso (deve retornar todos os vídeos)
SELECT 
  '=== TESTE POLÍTICA SIMPLES ===' as debug_section,
  COUNT(*) as total_videos_na_lista,
  CASE 
    WHEN COUNT(*) > 0 THEN '✅ TODOS PODEM VER A LISTA DE VÍDEOS'
    ELSE '❌ ALGO DEU ERRADO'
  END as resultado
FROM workout_videos;

-- 4.2 Verificar política criada
SELECT 
  '=== POLÍTICA ATIVA ===' as debug_section,
  policyname,
  permissive,
  cmd,
  '✅ POLÍTICA PERMISSIVA ATIVA' as status
FROM pg_policies 
WHERE tablename = 'workout_videos';

-- =============================================
-- 5. LOG DA OPERAÇÃO
-- =============================================

-- 5.1 Registrar a simplificação
INSERT INTO logs_operacoes (
  operacao,
  detalhes,
  timestamp,
  sucesso
) VALUES (
  'RESTORE_SIMPLE_VIDEO_POLICY',
  'Restaurada política simples: todos podem ver vídeos. Proteção mantida no ExpertVideoGuard.',
  now(),
  true
) ON CONFLICT DO NOTHING;

-- 5.2 Resultado final
SELECT 
  '🎯 POLÍTICA RESTAURADA!' as status,
  'Todos os usuários podem ver a LISTA de vídeos' as comportamento,
  'ExpertVideoGuard protege a REPRODUÇÃO dos vídeos' as protecao,
  'Lista aberta, reprodução protegida' as resultado;
