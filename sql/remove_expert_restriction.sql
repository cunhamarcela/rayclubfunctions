-- ========================================
-- REMOVER RESTRIÇÃO EXPERT DOS VÍDEOS
-- ========================================
-- Este script remove a restrição expert, permitindo acesso para usuários basic

-- ========================================
-- 1. VERIFICAR BACKUP
-- ========================================

-- Verificar se existe backup das restrições
SELECT 
  'Backup das restrições encontrado!' as status,
  COUNT(*) as videos_no_backup,
  MIN(backup_created_at) as criado_em
FROM expert_restriction_backup;

-- Mostrar estado original dos vídeos
SELECT 
  'Estado original dos vídeos:' as info,
  title,
  instructor_name,
  CASE 
    WHEN requires_expert_access = TRUE THEN '🔒 Era Expert'
    ELSE '👤 Era Basic'
  END as estado_original
FROM expert_restriction_backup
ORDER BY title;

-- ========================================
-- 2. REMOVER RESTRIÇÕES EXPERT
-- ========================================

-- Restaurar estado original dos vídeos
UPDATE workout_videos 
SET 
  requires_expert_access = b.requires_expert_access,
  updated_at = NOW()
FROM expert_restriction_backup b
WHERE workout_videos.id = b.id;

-- OU para tornar TODOS esses vídeos acessíveis para basic:
-- UPDATE workout_videos 
-- SET 
--   requires_expert_access = FALSE,
--   updated_at = NOW()
-- WHERE id IN (
--   '0414f81b-7eb7-46bf-ac03-4f342ac5172d',
--   '44475402-4549-4118-b76e-61f803f96745',
--   'b080dca6-a806-4bd4-afdd-8627edd5380e',
--   '52b46af0-2981-44ba-b288-1f66031f4016',
--   '6a93a70b-1a0f-4d95-8244-58a57f54fbcf',
--   '314ded3a-5868-4b92-9aee-8cf0d5be5dd8',
--   'd0abfbf5-90f8-4291-a4da-84f1724efba0',
--   '9756f2b7-cbad-477d-b612-8a5429b89b1a',
--   '69053e39-93ac-4d74-8d1b-ee6168ce5886',
--   '54a34c38-0c2c-41a9-a648-51905780e50e'
-- );

-- ========================================
-- 3. VERIFICAR RESULTADO
-- ========================================

-- Verificar estado após remoção das restrições
SELECT 
  'Estado após remoção de restrições:' as info,
  id,
  title,
  instructor_name,
  requires_expert_access,
  CASE 
    WHEN requires_expert_access = TRUE THEN '🔒 EXPERT ONLY'
    ELSE '👤 ACESSÍVEL PARA BASIC'
  END as status_acesso
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

-- Contar vídeos liberados para basic
SELECT 
  COUNT(*) as total_liberados_para_basic
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
AND (requires_expert_access = FALSE OR requires_expert_access IS NULL);

-- ========================================
-- 4. LIMPEZA (OPCIONAL)
-- ========================================

-- Remover backup das restrições (descomente se quiser)
-- DROP TABLE expert_restriction_backup;

RAISE NOTICE '✅ Restrições expert removidas com sucesso!';
RAISE NOTICE '👤 Usuários basic podem acessar esses vídeos novamente'; 