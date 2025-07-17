-- ========================================
-- RESTRINGIR VÍDEOS PARA EXPERT APENAS
-- ========================================
-- Este script marca vídeos específicos como restritos para usuários expert

-- ========================================
-- 1. BACKUP DOS VÍDEOS ESPECÍFICOS
-- ========================================

-- Criar backup antes da alteração
CREATE TABLE IF NOT EXISTS expert_restriction_backup AS 
SELECT 
  id,
  title,
  instructor_name,
  requires_expert_access,
  NOW() as backup_created_at
FROM workout_videos 
WHERE id IN (
  '0414f81b-7eb7-46bf-ac03-4f342ac5172d', -- O que eu faria diferente se estivesse começando hoje
  '44475402-4549-4118-b76e-61f803f96745', -- Superiores + Cardio (1)
  'b080dca6-a806-4bd4-afdd-8627edd5380e', -- Superiores + Cardio (2)
  '52b46af0-2981-44ba-b288-1f66031f4016', -- Treino A - Semana 02
  '6a93a70b-1a0f-4d95-8244-58a57f54fbcf', -- Treino B - Semana 02
  '314ded3a-5868-4b92-9aee-8cf0d5be5dd8', -- Treino F
  'd0abfbf5-90f8-4291-a4da-84f1724efba0', -- Treino A
  '9756f2b7-cbad-477d-b612-8a5429b89b1a', -- Treino B
  '69053e39-93ac-4d74-8d1b-ee6168ce5886', -- Treino C
  '54a34c38-0c2c-41a9-a648-51905780e50e'  -- Treino D - Semana 02
);

-- Verificar backup
SELECT 
  'Backup criado para restrição expert!' as status,
  COUNT(*) as videos_salvos
FROM expert_restriction_backup;

-- ========================================
-- 2. MARCAR VÍDEOS COMO EXPERT ONLY
-- ========================================

-- Garantir que esses vídeos específicos sejam restritos para expert
UPDATE workout_videos 
SET 
  requires_expert_access = TRUE,
  updated_at = NOW()
WHERE id IN (
  '0414f81b-7eb7-46bf-ac03-4f342ac5172d', -- O que eu faria diferente se estivesse começando hoje
  '44475402-4549-4118-b76e-61f803f96745', -- Superiores + Cardio (1)
  'b080dca6-a806-4bd4-afdd-8627edd5380e', -- Superiores + Cardio (2)
  '52b46af0-2981-44ba-b288-1f66031f4016', -- Treino A - Semana 02
  '6a93a70b-1a0f-4d95-8244-58a57f54fbcf', -- Treino B - Semana 02
  '314ded3a-5868-4b92-9aee-8cf0d5be5dd8', -- Treino F
  'd0abfbf5-90f8-4291-a4da-84f1724efba0', -- Treino A
  '9756f2b7-cbad-477d-b612-8a5429b89b1a', -- Treino B
  '69053e39-93ac-4d74-8d1b-ee6168ce5886', -- Treino C
  '54a34c38-0c2c-41a9-a648-51905780e50e'  -- Treino D - Semana 02
);

-- ========================================
-- 3. VERIFICAR RESULTADO
-- ========================================

-- Verificar se foram marcados corretamente
SELECT 
  'Status dos vídeos restritos:' as info,
  id,
  title,
  instructor_name,
  requires_expert_access,
  CASE 
    WHEN requires_expert_access = TRUE THEN '🔒 EXPERT ONLY'
    ELSE '⚠️ AINDA ACESSÍVEL PARA BASIC'
  END as status_restricao
FROM workout_videos 
WHERE id IN (
  '0414f81b-7eb7-46bf-ac03-4f342ac5172d',
  '44475402-4549-4118-b76e-61f803f96745',
  'b080dca6-a806-4bd4-afdd-8627edd5380e',
  '52b46af0-2981-44ba-b288-1f66031f4016',
  '6a93a70b-1a0f-4d95-8244-58a57f54fbcf',
  '314ded3a-5868-4b92-9aee-8cf0d5be5dd8',
  'd0abfbf5-90f8-4291-a4da-84f1724efba0',
  '9756f2b7-cbad-477d-b612-8a5429b89b1a',
  '69053e39-93ac-4d74-8d1b-ee6168ce5886',
  '54a34c38-0c2c-41a9-a648-51905780e50e'
)
ORDER BY instructor_name, title;

-- Contar quantos foram atualizados
SELECT 
  COUNT(*) as total_expert_only
FROM workout_videos 
WHERE id IN (
  '0414f81b-7eb7-46bf-ac03-4f342ac5172d',
  '44475402-4549-4118-b76e-61f803f96745',
  'b080dca6-a806-4bd4-afdd-8627edd5380e',
  '52b46af0-2981-44ba-b288-1f66031f4016',
  '6a93a70b-1a0f-4d95-8244-58a57f54fbcf',
  '314ded3a-5868-4b92-9aee-8cf0d5be5dd8',
  'd0abfbf5-90f8-4291-a4da-84f1724efba0',
  '9756f2b7-cbad-477d-b612-8a5429b89b1a',
  '69053e39-93ac-4d74-8d1b-ee6168ce5886',
  '54a34c38-0c2c-41a9-a648-51905780e50e'
)
AND requires_expert_access = TRUE;

-- ========================================
-- 4. RESUMO GERAL
-- ========================================

-- Mostrar resumo de todos os vídeos por nível de acesso
SELECT 
  'RESUMO POR NÍVEL DE ACESSO:' as info,
  CASE 
    WHEN requires_expert_access = TRUE THEN 'EXPERT ONLY'
    ELSE 'BÁSICO'
  END as nivel_acesso,
  COUNT(*) as total_videos
FROM workout_videos 
GROUP BY requires_expert_access
ORDER BY requires_expert_access;

RAISE NOTICE '✅ Vídeos restritos para expert com sucesso!';
RAISE NOTICE '👤 Usuários basic não verão mais esses vídeos';
RAISE NOTICE '💎 Apenas usuários expert podem acessar'; 