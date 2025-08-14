-- ========================================
-- FIX: REABILITAR RLS PARA WORKOUT_VIDEOS
-- ========================================
-- Data: 07/08/2025 12:30
-- Problema: RLS desabilitado permite acesso livre a todos os vídeos
-- Solução: Reabilitar RLS com políticas adequadas

-- =============================================
-- 1. VERIFICAR STATUS ATUAL
-- =============================================

-- 1.1 Verificar se RLS está habilitado
SELECT 
  '=== STATUS ATUAL DO RLS ===' as check_name,
  schemaname,
  tablename,
  rowsecurity as rls_habilitado,
  CASE 
    WHEN rowsecurity = true THEN '✅ RLS HABILITADO'
    WHEN rowsecurity = false THEN '❌ RLS DESABILITADO (PROBLEMA!)'
    ELSE '⚠️ STATUS DESCONHECIDO'
  END as status
FROM pg_tables 
WHERE tablename = 'workout_videos';

-- 1.2 Verificar políticas existentes
SELECT 
  '=== POLÍTICAS ATIVAS ===' as check_name,
  policyname,
  permissive,
  cmd,
  qual
FROM pg_policies 
WHERE tablename = 'workout_videos';

-- =============================================
-- 2. LIMPAR POLÍTICAS CONFLITANTES
-- =============================================

-- 2.1 Remover todas as políticas existentes
DROP POLICY IF EXISTS "Auto: Apenas experts veem vídeos" ON workout_videos;
DROP POLICY IF EXISTS "SUPER_STRICT: Só experts veem vídeos" ON workout_videos;
DROP POLICY IF EXISTS "RLS_STRICT: Apenas experts autenticados" ON workout_videos;
DROP POLICY IF EXISTS "Apenas experts podem ver vídeos" ON workout_videos;
DROP POLICY IF EXISTS "Controle de acesso aos vídeos dos parceiros" ON workout_videos;
DROP POLICY IF EXISTS "Usuários não autenticados veem apenas vídeos públicos" ON workout_videos;
DROP POLICY IF EXISTS "Vídeos são públicos" ON workout_videos;
DROP POLICY IF EXISTS "Vídeos básicos são públicos" ON workout_videos;
DROP POLICY IF EXISTS "workout_videos_select_policy" ON workout_videos;

-- =============================================
-- 3. CONFIGURAR RLS CORRETAMENTE
-- =============================================

-- 3.1 Reabilitar RLS
ALTER TABLE workout_videos ENABLE ROW LEVEL SECURITY;

-- 3.2 Criar política baseada na funcionalidade atual
-- ESTRATÉGIA: Deixar usuários basic verem a LISTA de vídeos,
-- mas o ExpertVideoGuard bloqueia o ACESSO aos links
CREATE POLICY "Permitir visualização da lista para todos os usuários autenticados" 
ON workout_videos FOR SELECT 
USING (
  -- Qualquer usuário autenticado pode ver a lista de vídeos
  auth.uid() IS NOT NULL
);

-- 3.3 ALTERNATIVA: Se quiser bloquear completamente vídeos expert na base
-- (descomente apenas se quiser implementar bloqueio no banco também)
/*
CREATE POLICY "Controle rigoroso baseado em account_type" 
ON workout_videos FOR SELECT 
USING (
  -- Vídeos que não requerem expert: todos autenticados podem ver
  (requires_expert_access = false OR requires_expert_access IS NULL)
  OR
  -- Vídeos expert: só usuários com account_type = 'expert' podem ver
  (
    requires_expert_access = true 
    AND EXISTS (
      SELECT 1 
      FROM profiles p
      WHERE p.id = auth.uid() 
        AND p.account_type = 'expert'
    )
  )
);
*/

-- =============================================
-- 4. VERIFICAÇÃO FINAL
-- =============================================

-- 4.1 Verificar se RLS foi reabilitado
SELECT 
  '=== STATUS FINAL DO RLS ===' as check_name,
  schemaname,
  tablename,
  rowsecurity as rls_habilitado,
  CASE 
    WHEN rowsecurity = true THEN '✅ RLS HABILITADO CORRETAMENTE'
    WHEN rowsecurity = false THEN '❌ AINDA DESABILITADO!'
    ELSE '⚠️ STATUS DESCONHECIDO'
  END as status_final
FROM pg_tables 
WHERE tablename = 'workout_videos';

-- 4.2 Verificar políticas criadas
SELECT 
  '=== POLÍTICAS CRIADAS ===' as check_name,
  policyname,
  permissive,
  cmd,
  CASE 
    WHEN policyname IS NOT NULL THEN '✅ POLÍTICA ATIVA'
    ELSE '❌ NENHUMA POLÍTICA'
  END as status
FROM pg_policies 
WHERE tablename = 'workout_videos';

-- 4.3 Estatísticas de vídeos
SELECT 
  '=== ESTATÍSTICAS DE VÍDEOS ===' as check_name,
  COUNT(*) as total_videos,
  COUNT(CASE WHEN requires_expert_access = true THEN 1 END) as videos_expert,
  COUNT(CASE WHEN requires_expert_access = false OR requires_expert_access IS NULL THEN 1 END) as videos_basic,
  ROUND(
    100.0 * COUNT(CASE WHEN requires_expert_access = true THEN 1 END) / COUNT(*), 
    1
  ) as percentage_expert
FROM workout_videos;

-- =============================================
-- 5. RESULTADO ESPERADO
-- =============================================

/*
✅ APÓS EXECUÇÃO DESTE SCRIPT:

1. ✅ RLS HABILITADO na tabela workout_videos
2. ✅ POLÍTICA permite usuários autenticados verem lista de vídeos
3. ✅ ExpertVideoGuard continua controlando acesso aos links no Flutter
4. ✅ Usuários basic veem lista mas não conseguem reproduzir vídeos expert
5. ✅ Usuários expert veem e reproduzem tudo

COMPORTAMENTO ESPERADO:
- 👤 Usuário BASIC: Vê lista, mas videos expert mostram overlay de bloqueio
- 🌟 Usuário EXPERT: Vê lista e reproduz todos os vídeos
- ❌ Usuário NÃO AUTENTICADO: Não vê nenhum vídeo

PROXIMOS PASSOS:
1. Execute este script no Supabase
2. Teste criação de novo usuário (deve ser account_type = 'basic')
3. Verifique que vídeos expert são bloqueados no app
4. Teste com usuário expert (se houver)
*/
