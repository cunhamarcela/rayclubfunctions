-- ========================================
-- CORRIGIR ACESSO DE TODAS AS USUÁRIAS EXPERT
-- ========================================
-- Script para garantir que todas as usuárias expert tenham acesso completo

-- 1. Verificar usuárias que já estão como expert
SELECT 
  user_id,
  current_level,
  level_expires_at,
  array_length(unlocked_features, 1) as total_features,
  unlocked_features
FROM user_progress_level
WHERE current_level = 'expert';

-- 2. Verificar usuárias que podem precisar ser promovidas
-- (Buscar por emails específicos ou outros critérios)
SELECT 
  p.user_id,
  p.email,
  upl.current_level,
  upl.level_expires_at
FROM profiles p
LEFT JOIN user_progress_level upl ON p.user_id = upl.user_id
WHERE p.email LIKE '%@%' -- Ajustar critério conforme necessário
ORDER BY p.email;

-- 3. Função para promover múltiplas usuárias para expert
CREATE OR REPLACE FUNCTION promote_multiple_users_to_expert(user_ids UUID[])
RETURNS TABLE(user_id UUID, status TEXT) AS $$
DECLARE
  user_id_item UUID;
  expert_features TEXT[];
BEGIN
  expert_features := get_expert_features();
  
  FOREACH user_id_item IN ARRAY user_ids
  LOOP
    BEGIN
      -- Promover usuária para expert
      INSERT INTO user_progress_level (
        user_id,
        current_level,
        unlocked_features,
        level_expires_at,
        created_at,
        updated_at,
        last_activity
      ) VALUES (
        user_id_item,
        'expert',
        expert_features,
        NULL, -- NULL = acesso permanente
        NOW(),
        NOW(),
        NOW()
      )
      ON CONFLICT (user_id) 
      DO UPDATE SET 
        current_level = 'expert',
        unlocked_features = expert_features,
        level_expires_at = NULL,
        updated_at = NOW(),
        last_activity = NOW();
      
      -- Retornar sucesso
      user_id := user_id_item;
      status := 'SUCCESS: Promovida para expert permanente';
      RETURN NEXT;
      
    EXCEPTION WHEN OTHERS THEN
      -- Retornar erro
      user_id := user_id_item;
      status := 'ERROR: ' || SQLERRM;
      RETURN NEXT;
    END;
  END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. Exemplo de como promover usuárias específicas
-- Substitua pelos IDs das usuárias que devem ser expert
/*
SELECT * FROM promote_multiple_users_to_expert(ARRAY[
  '01d4a292-1873-4af6-948b-a55eed56d6b9'::UUID,
  -- Adicione outros IDs aqui
  -- 'outro-user-id'::UUID,
  -- 'mais-um-user-id'::UUID
]);
*/

-- 5. Verificar todas as usuárias expert após a correção
SELECT 
  p.email,
  upl.user_id,
  upl.current_level,
  upl.level_expires_at,
  array_length(upl.unlocked_features, 1) as total_features
FROM user_progress_level upl
JOIN profiles p ON upl.user_id = p.user_id
WHERE upl.current_level = 'expert'
ORDER BY p.email;

-- 6. Função para verificar status de múltiplas usuárias
CREATE OR REPLACE FUNCTION check_multiple_users_access(user_ids UUID[])
RETURNS TABLE(
  user_id UUID,
  email TEXT,
  access_level TEXT,
  has_extended_access BOOLEAN,
  total_features INTEGER,
  is_permanent BOOLEAN
) AS $$
DECLARE
  user_id_item UUID;
  user_access JSON;
BEGIN
  FOREACH user_id_item IN ARRAY user_ids
  LOOP
    -- Buscar dados do usuário
    SELECT check_user_access_level(user_id_item) INTO user_access;
    
    -- Buscar email
    SELECT p.email INTO email
    FROM profiles p
    WHERE p.user_id = user_id_item;
    
    -- Retornar dados
    user_id := user_id_item;
    access_level := user_access->>'access_level';
    has_extended_access := (user_access->>'has_extended_access')::BOOLEAN;
    total_features := array_length(
      ARRAY(SELECT json_array_elements_text(user_access->'available_features')), 1
    );
    is_permanent := (user_access->>'valid_until') IS NULL;
    
    RETURN NEXT;
  END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 7. Exemplo de verificação de múltiplas usuárias
/*
SELECT * FROM check_multiple_users_access(ARRAY[
  '01d4a292-1873-4af6-948b-a55eed56d6b9'::UUID
  -- Adicione outros IDs aqui
]);
*/

-- 8. Script para encontrar usuárias que podem precisar ser expert
-- (Baseado em critérios como email, data de criação, etc.)
SELECT 
  p.user_id,
  p.email,
  p.created_at,
  COALESCE(upl.current_level, 'sem_nivel') as current_level,
  upl.level_expires_at
FROM profiles p
LEFT JOIN user_progress_level upl ON p.user_id = upl.user_id
WHERE 
  -- Critérios para identificar usuárias que devem ser expert
  p.email IS NOT NULL
  AND p.created_at IS NOT NULL
  -- Adicione outros critérios conforme necessário
ORDER BY p.created_at DESC;

-- ========================================
-- INSTRUÇÕES DE USO
-- ========================================

/*
PASSO 1: Execute as consultas de verificação (itens 1, 2, 8) para identificar usuárias

PASSO 2: Identifique os IDs das usuárias que devem ser expert

PASSO 3: Execute a função promote_multiple_users_to_expert com os IDs:
SELECT * FROM promote_multiple_users_to_expert(ARRAY[
  'user-id-1'::UUID,
  'user-id-2'::UUID,
  'user-id-3'::UUID
]);

PASSO 4: Verifique se foi aplicado corretamente:
SELECT * FROM check_multiple_users_access(ARRAY[
  'user-id-1'::UUID,
  'user-id-2'::UUID,
  'user-id-3'::UUID
]);

PASSO 5: Peça para as usuárias fazerem hot restart do app
*/ 