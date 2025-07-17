-- ========================================
-- VERIFICAR STATUS DOS VÍDEOS
-- ========================================
-- Este script mostra quais vídeos estão ativos e quais estão bloqueados

-- ========================================
-- 1. RESUMO GERAL
-- ========================================

SELECT 
  'RESUMO GERAL:' as info,
  COUNT(*) as total_videos,
  COUNT(*) FILTER (WHERE youtube_url IS NOT NULL) as videos_ativos,
  COUNT(*) FILTER (WHERE youtube_url IS NULL) as videos_bloqueados,
  ROUND(
    (COUNT(*) FILTER (WHERE youtube_url IS NULL) * 100.0) / COUNT(*), 1
  ) as percentual_bloqueado
FROM workout_videos;

-- ========================================
-- 2. VÍDEOS AINDA ATIVOS (que usuários basic podem ver)
-- ========================================

SELECT 
  'VÍDEOS AINDA ATIVOS:' as info,
  title,
  instructor_name,
  category,
  requires_expert_access,
  CASE 
    WHEN requires_expert_access = TRUE THEN '🔒 Requer Expert'
    ELSE '👤 Acessível para Basic'
  END as nivel_acesso
FROM workout_videos 
WHERE youtube_url IS NOT NULL
ORDER BY 
  CASE WHEN requires_expert_access = FALSE OR requires_expert_access IS NULL THEN 0 ELSE 1 END,
  instructor_name, 
  title;

-- ========================================
-- 3. VÍDEOS QUE VOCÊ MENCIONOU (verificar status)
-- ========================================

SELECT 
  'VÍDEOS MENCIONADOS:' as info,
  title,
  instructor_name,
  CASE 
    WHEN youtube_url IS NULL THEN '🔒 BLOQUEADO'
    WHEN requires_expert_access = TRUE THEN '🔒 EXPERT ONLY'
    ELSE '⚠️ AINDA VISÍVEL PARA BASIC'
  END as status,
  youtube_url
FROM workout_videos 
WHERE 
  LOWER(title) LIKE '%treino d%semana 02%' OR
  LOWER(title) LIKE '%treino f%' OR
  LOWER(title) LIKE '%treino b%' OR
  LOWER(title) LIKE '%treino c%' OR
  LOWER(title) LIKE '%treino a%' OR
  LOWER(title) LIKE '%superiores%cardio%' OR
  LOWER(title) LIKE '%técnica%fight%' OR
  LOWER(title) LIKE '%tecnica%fight%' OR
  LOWER(title) LIKE '%o que eu faria diferente%' OR
  LOWER(title) LIKE '%bora%assessoria%' OR
  (LOWER(title) LIKE '%musculação%' AND LOWER(title) LIKE '%treino%')
ORDER BY 
  CASE 
    WHEN youtube_url IS NULL THEN 1
    WHEN requires_expert_access = TRUE THEN 2
    ELSE 3
  END,
  title;

-- ========================================
-- 4. VÍDEOS POR INSTRUTOR
-- ========================================

SELECT 
  'POR INSTRUTOR:' as info,
  instructor_name,
  COUNT(*) as total,
  COUNT(*) FILTER (WHERE youtube_url IS NOT NULL) as ativos,
  COUNT(*) FILTER (WHERE youtube_url IS NULL) as bloqueados
FROM workout_videos 
GROUP BY instructor_name
ORDER BY instructor_name;

-- ========================================
-- 5. BUSCAR PADRÕES PROBLEMÁTICOS
-- ========================================

-- Buscar todos os vídeos de musculação que podem estar ativos
SELECT 
  'MUSCULAÇÃO ATIVA:' as info,
  title,
  instructor_name,
  CASE 
    WHEN youtube_url IS NULL THEN '🔒 Bloqueado'
    WHEN requires_expert_access = TRUE THEN '🔒 Expert'
    ELSE '⚠️ Visível para Basic'
  END as status
FROM workout_videos 
WHERE LOWER(instructor_name) LIKE '%musculação%'
   OR LOWER(title) LIKE '%musculação%'
ORDER BY title;

-- Buscar vídeos Fight Fit que podem estar ativos
SELECT 
  'FIGHT FIT ATIVO:' as info,
  title,
  instructor_name,
  CASE 
    WHEN youtube_url IS NULL THEN '🔒 Bloqueado'
    WHEN requires_expert_access = TRUE THEN '🔒 Expert'
    ELSE '⚠️ Visível para Basic'
  END as status
FROM workout_videos 
WHERE LOWER(instructor_name) LIKE '%fight%'
   OR LOWER(title) LIKE '%fight%'
ORDER BY title;

-- Buscar vídeos Bora Assessoria que podem estar ativos
SELECT 
  'BORA ASSESSORIA ATIVO:' as info,
  title,
  instructor_name,
  CASE 
    WHEN youtube_url IS NULL THEN '🔒 Bloqueado'
    WHEN requires_expert_access = TRUE THEN '🔒 Expert'
    ELSE '⚠️ Visível para Basic'
  END as status
FROM workout_videos 
WHERE LOWER(instructor_name) LIKE '%bora%'
   OR LOWER(title) LIKE '%bora%'
ORDER BY title; 