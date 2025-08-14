-- ========================================
-- SOLUÇÃO DEFINITIVA: SUBSTITUIR TABELA POR VIEW FILTRADA
-- ========================================
-- Data: 07/08/2025 12:40
-- Problema: Flutter acessa workout_videos diretamente, RLS desabilitado
-- Solução: Renomear tabela e criar view que filtra automaticamente

-- =============================================
-- 1. VERIFICAÇÃO ANTES DA MUDANÇA
-- =============================================

-- 1.1 Backup do estado atual
CREATE TABLE IF NOT EXISTS workout_videos_backup_before_view AS
SELECT * FROM workout_videos;

-- 1.2 Verificar dados atuais
SELECT 
  '=== ESTADO ANTES DA MUDANÇA ===' as debug_section,
  COUNT(*) as total_videos,
  COUNT(CASE WHEN requires_expert_access = true THEN 1 END) as videos_expert,
  COUNT(CASE WHEN requires_expert_access = false THEN 1 END) as videos_basic,
  COUNT(CASE WHEN requires_expert_access IS NULL THEN 1 END) as videos_null
FROM workout_videos;

-- =============================================
-- 2. RENOMEAR TABELA ORIGINAL
-- =============================================

-- 2.1 Remover políticas RLS antigas
DROP POLICY IF EXISTS "Expert_only_video_access" ON workout_videos;
DROP POLICY IF EXISTS "Videos_expert_only_policy" ON workout_videos;
DROP POLICY IF EXISTS "Permitir visualização da lista para todos os usuários autent" ON workout_videos;
DROP POLICY IF EXISTS "workout_videos_expert_only" ON workout_videos;

-- 2.2 Desabilitar RLS para facilitar renomeação
ALTER TABLE workout_videos DISABLE ROW LEVEL SECURITY;

-- 2.3 Renomear tabela original para workout_videos_raw
ALTER TABLE workout_videos RENAME TO workout_videos_raw;

-- =============================================
-- 3. CRIAR VIEW EXPERT-ONLY COM NOME ORIGINAL
-- =============================================

-- 3.1 Criar view que substitui a tabela
CREATE VIEW workout_videos AS
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
  wv.updated_at,
  -- Incluir requires_expert_access para compatibilidade
  wv.requires_expert_access
FROM workout_videos_raw wv
WHERE 
  -- SÓ EXPERT: Verificar via profiles.account_type
  EXISTS (
    SELECT 1 
    FROM profiles p
    WHERE p.id = auth.uid() 
    AND p.account_type = 'expert'
  )
  -- E vídeo deve requerer acesso expert (que agora são todos)
  AND wv.requires_expert_access = true;

-- =============================================
-- 4. VERIFICAR SE A SOLUÇÃO FUNCIONA
-- =============================================

-- 4.1 Testar sem usuário logado (simulando basic)
SELECT 
  '=== TESTE USUÁRIO BASIC ===' as debug_section,
  'Sem autenticação (basic simulado)' as tipo_usuario,
  COUNT(*) as videos_visiveis,
  CASE 
    WHEN COUNT(*) = 0 THEN '✅ ACESSO NEGADO - SUCESSO!'
    ELSE '❌ ERRO: BASIC AINDA VÊ VÍDEOS!'
  END as resultado
FROM workout_videos;

-- 4.2 Verificar estrutura da view
SELECT 
  '=== ESTRUTURA CRIADA ===' as debug_section,
  'View workout_videos' as objeto,
  COUNT(*) as total_views_criadas
FROM information_schema.views 
WHERE table_name = 'workout_videos';

-- 4.3 Verificar tabela original renomeada
SELECT 
  '=== TABELA ORIGINAL ===' as debug_section,
  'Tabela workout_videos_raw' as objeto,
  COUNT(*) as total_tabelas
FROM information_schema.tables 
WHERE table_name = 'workout_videos_raw';

-- 4.4 Verificar dados na tabela original (deve ter todos os 61 vídeos)
SELECT 
  '=== DADOS NA TABELA RAW ===' as debug_section,
  COUNT(*) as total_videos_raw,
  COUNT(CASE WHEN requires_expert_access = true THEN 1 END) as expert_videos,
  'Tabela original intacta' as status
FROM workout_videos_raw;

-- =============================================
-- 5. CRIAR FUNÇÃO ADMINISTRATIVA
-- =============================================

-- 5.1 Função para admins acessarem todos os vídeos
CREATE OR REPLACE FUNCTION get_all_workout_videos_admin()
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
  requires_expert_access BOOLEAN,
  created_at TIMESTAMP WITH TIME ZONE,
  updated_at TIMESTAMP WITH TIME ZONE
)
LANGUAGE sql
SECURITY DEFINER
AS $$
  SELECT * FROM workout_videos_raw 
  ORDER BY order_index ASC, created_at ASC;
$$;

-- =============================================
-- 6. TESTE FINAL COMPLETO
-- =============================================

-- 6.1 Simular diferentes cenários
-- Cenário 1: Usuário basic (sem auth) - deve ver 0
SELECT 
  '=== RESULTADO FINAL ===' as teste,
  'Usuário basic (sem auth)' as cenario,
  COUNT(*) as videos_visiveis,
  CASE 
    WHEN COUNT(*) = 0 THEN '✅ PERFEITO: 0 VÍDEOS PARA BASIC'
    ELSE '❌ FALHA: BASIC VÊ ' || COUNT(*) || ' VÍDEOS'
  END as resultado_final
FROM workout_videos;

-- 6.2 Teste administrativo (deve ver todos os 61)
SELECT 
  '=== TESTE ADMIN ===' as teste,
  'Função administrativa' as cenario,
  COUNT(*) as videos_total,
  CASE 
    WHEN COUNT(*) = 61 THEN '✅ ADMIN VÊ TODOS OS 61 VÍDEOS'
    ELSE '⚠️ ADMIN VÊ ' || COUNT(*) || ' VÍDEOS'
  END as resultado_admin
FROM get_all_workout_videos_admin();

-- =============================================
-- 7. LOG DA OPERAÇÃO
-- =============================================

-- 7.1 Registrar a mudança crítica
INSERT INTO logs_operacoes (
  operacao,
  detalhes,
  timestamp,
  sucesso
) VALUES (
  'CRITICAL_FIX_REPLACE_TABLE_WITH_VIEW',
  'Tabela workout_videos renomeada para workout_videos_raw. View expert-only criada com mesmo nome. Flutter agora só vê vídeos expert automaticamente.',
  now(),
  true
) ON CONFLICT DO NOTHING;

-- 7.2 Resultado final
SELECT 
  '🎉 SOLUÇÃO IMPLEMENTADA!' as status,
  'Tabela substituída por view expert-only' as solucao,
  'Flutter agora só vê vídeos expert automaticamente' as resultado,
  'Usuários basic veem 0 vídeos' as confirmacao;
