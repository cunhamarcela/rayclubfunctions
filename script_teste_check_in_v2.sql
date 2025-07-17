-- Script de teste para a função record_challenge_check_in_v2 corrigida
-- Execute cada seção sequencialmente para validar se a função está funcionando corretamente

-- 1. Limpeza de dados de teste anteriores (opcional)
DO $$
DECLARE
  test_user_id UUID := '906a27bc-ccff-4c74-ad83-37692782305a'; -- Use um ID de usuário real ou crie um novo
  test_challenge_id UUID := 'c7e921a3-f66c-4c9d-b8d7-5ec7d69e3675'; -- Use um ID de desafio real ou crie um novo
BEGIN
  -- Limpar logs de erros anteriores (opcional)
  DELETE FROM check_in_logs WHERE user_id = test_user_id AND challenge_id = test_challenge_id;
  
  -- Remover check-ins de teste anteriores (opcional)
  DELETE FROM challenge_check_ins WHERE user_id = test_user_id AND challenge_id = test_challenge_id;
  
  -- Limpar progresso de teste anterior (opcional)
  DELETE FROM challenge_progress WHERE user_id = test_user_id AND challenge_id = test_challenge_id;
END $$;

-- 2. Testar a função record_challenge_check_in_v2
DO $$
DECLARE
  test_user_id UUID := '906a27bc-ccff-4c74-ad83-37692782305a'; -- Use um ID de usuário real
  test_challenge_id UUID := 'c7e921a3-f66c-4c9d-b8d7-5ec7d69e3675'; -- Use um ID de desafio real
  result JSONB;
BEGIN
  -- Chamar a função
  SELECT record_challenge_check_in_v2(
    test_challenge_id,  -- challenge_id_param
    NOW(),              -- date_param 
    30,                 -- duration_minutes_param
    test_user_id,       -- user_id_param
    'workout-test-123', -- workout_id_param
    'Teste de Auditoria Corrigido', -- workout_name_param
    'test'              -- workout_type_param
  ) INTO result;
  
  -- Verificar resultado
  PERFORM jsonb_pretty(result);
END $$;

-- 3. Verificar os dados inseridos/atualizados
-- 3.1 Check-ins
SELECT 'Challenge Check-ins' as tabela, * 
FROM challenge_check_ins 
WHERE user_id = '906a27bc-ccff-4c74-ad83-37692782305a' 
ORDER BY check_in_date DESC
LIMIT 5;

-- 3.2 Progresso do desafio
SELECT 'Challenge Progress' as tabela, * 
FROM challenge_progress 
WHERE user_id = '906a27bc-ccff-4c74-ad83-37692782305a' 
AND challenge_id = 'c7e921a3-f66c-4c9d-b8d7-5ec7d69e3675';

-- 3.3 Progresso do usuário
SELECT 'User Progress' as tabela, * 
FROM user_progress 
WHERE user_id = '906a27bc-ccff-4c74-ad83-37692782305a';

-- 3.4 Participação em desafios
SELECT 'Challenge Participants' as tabela, * 
FROM challenge_participants 
WHERE user_id = '906a27bc-ccff-4c74-ad83-37692782305a' 
AND challenge_id = 'c7e921a3-f66c-4c9d-b8d7-5ec7d69e3675';

-- 3.5 Verificar logs de erro (se houver)
SELECT 'Error Logs' as tabela, * 
FROM check_in_logs 
WHERE user_id = '906a27bc-ccff-4c74-ad83-37692782305a' 
ORDER BY created_at DESC
LIMIT 5;

-- 4. Verificar integridade referencial
SELECT 
  'Resumo de Dados' as resumo,
  (SELECT COUNT(*) FROM challenge_check_ins WHERE user_id = '906a27bc-ccff-4c74-ad83-37692782305a' AND challenge_id = 'c7e921a3-f66c-4c9d-b8d7-5ec7d69e3675') as total_checkins,
  (SELECT COUNT(*) FROM challenge_progress WHERE user_id = '906a27bc-ccff-4c74-ad83-37692782305a' AND challenge_id = 'c7e921a3-f66c-4c9d-b8d7-5ec7d69e3675') as total_progress_records,
  (SELECT COUNT(*) FROM check_in_logs WHERE user_id = '906a27bc-ccff-4c74-ad83-37692782305a' AND challenge_id = 'c7e921a3-f66c-4c9d-b8d7-5ec7d69e3675') as total_errors,
  (SELECT COUNT(*) FROM challenge_participants WHERE user_id = '906a27bc-ccff-4c74-ad83-37692782305a' AND challenge_id = 'c7e921a3-f66c-4c9d-b8d7-5ec7d69e3675') as total_participants; 