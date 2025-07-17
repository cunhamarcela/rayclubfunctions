-- Script de teste para a função record_challenge_check_in_v2 corrigida (versão final)
-- Execute cada seção sequencialmente para validar se a função está funcionando corretamente

-- 1. Limpeza de dados de teste anteriores (opcional)
DO $$
DECLARE
  -- IMPORTANTE: Substitua estes IDs por IDs existentes em sua base de dados
  test_user_id UUID; -- Será preenchido com um ID real
  test_challenge_id UUID; -- Será preenchido com um ID real
BEGIN
  -- Primeiro, obter um ID de usuário válido da tabela profiles
  SELECT id INTO test_user_id
  FROM profiles
  LIMIT 1;
  
  -- Depois, obter um ID de desafio válido da tabela challenges
  SELECT id INTO test_challenge_id
  FROM challenges
  LIMIT 1;
  
  -- Se não encontrou IDs válidos, use os padrões (só em último caso)
  IF test_user_id IS NULL THEN
    test_user_id := '906a27bc-ccff-4c74-ad83-37692782305a';
  END IF;
  
  IF test_challenge_id IS NULL THEN
    test_challenge_id := 'c7e921a3-f66c-4c9d-b8d7-5ec7d69e3675';
  END IF;
  
  -- Exibir os IDs que serão usados no teste
  RAISE NOTICE 'Usando ID de usuário: %', test_user_id;
  RAISE NOTICE 'Usando ID de desafio: %', test_challenge_id;
  
  -- Limpar logs de erros anteriores (opcional)
  DELETE FROM check_in_error_logs WHERE user_id = test_user_id AND challenge_id = test_challenge_id;
  
  -- Remover check-ins de teste anteriores (opcional)
  DELETE FROM challenge_check_ins WHERE user_id = test_user_id AND challenge_id = test_challenge_id;
  
  -- Limpar progresso de teste anterior (opcional)
  DELETE FROM challenge_progress WHERE user_id = test_user_id AND challenge_id = test_challenge_id;
END $$;

-- 2. Testar a função record_challenge_check_in_v2
DO $$
DECLARE
  -- Usar os mesmos IDs que foram carregados na primeira seção
  test_user_id UUID;
  test_challenge_id UUID;
  result JSONB;
BEGIN
  -- Obter os mesmos IDs que usamos anteriormente
  SELECT id INTO test_user_id
  FROM profiles
  LIMIT 1;
  
  SELECT id INTO test_challenge_id
  FROM challenges
  LIMIT 1;
  
  -- Se não encontrou IDs válidos, use os padrões
  IF test_user_id IS NULL THEN
    test_user_id := '906a27bc-ccff-4c74-ad83-37692782305a';
  END IF;
  
  IF test_challenge_id IS NULL THEN
    test_challenge_id := 'c7e921a3-f66c-4c9d-b8d7-5ec7d69e3675';
  END IF;
  
  -- Chamar a função
  SELECT record_challenge_check_in_v2(
    test_challenge_id,  -- challenge_id_param
    NOW(),              -- date_param 
    30,                 -- duration_minutes_param
    test_user_id,       -- user_id_param
    'workout-test-123', -- workout_id_param
    'Teste Final',      -- workout_name_param
    'test'              -- workout_type_param
  ) INTO result;
  
  -- Verificar resultado
  RAISE NOTICE 'Resultado: %', jsonb_pretty(result);
END $$;

-- 3. Verificar os dados inseridos/atualizados
-- 3.1 Check-ins
SELECT 'Challenge Check-ins' as tabela, * 
FROM challenge_check_ins 
ORDER BY check_in_date DESC
LIMIT 5;

-- 3.2 Progresso do desafio
SELECT 'Challenge Progress' as tabela, * 
FROM challenge_progress 
ORDER BY updated_at DESC
LIMIT 5;

-- 3.3 Progresso do usuário
SELECT 'User Progress' as tabela, * 
FROM user_progress 
LIMIT 5;

-- 3.4 Participação em desafios
SELECT 'Challenge Participants' as tabela, * 
FROM challenge_participants 
ORDER BY joined_at DESC
LIMIT 5;

-- 3.5 Verificar logs de erro (se houver)
SELECT 'Error Logs' as tabela, * 
FROM check_in_error_logs 
ORDER BY created_at DESC
LIMIT 5;

-- 4. Verificar integridade referencial
DO $$
DECLARE
  test_user_id UUID;
  test_challenge_id UUID;
BEGIN
  -- Obter os mesmos IDs que usamos anteriormente
  SELECT id INTO test_user_id
  FROM profiles
  LIMIT 1;
  
  SELECT id INTO test_challenge_id
  FROM challenges
  LIMIT 1;
  
  -- Se não encontrou IDs válidos, use os padrões
  IF test_user_id IS NULL THEN
    test_user_id := '906a27bc-ccff-4c74-ad83-37692782305a';
  END IF;
  
  IF test_challenge_id IS NULL THEN
    test_challenge_id := 'c7e921a3-f66c-4c9d-b8d7-5ec7d69e3675';
  END IF;
  
  -- Exibir resumo dos dados
  RAISE NOTICE 'Resumo de Dados:';
  RAISE NOTICE 'Total de check-ins: %', (SELECT COUNT(*) FROM challenge_check_ins WHERE user_id = test_user_id AND challenge_id = test_challenge_id);
  RAISE NOTICE 'Total de registros de progresso: %', (SELECT COUNT(*) FROM challenge_progress WHERE user_id = test_user_id AND challenge_id = test_challenge_id);
  RAISE NOTICE 'Total de erros: %', (SELECT COUNT(*) FROM check_in_error_logs WHERE user_id = test_user_id AND challenge_id = test_challenge_id);
  RAISE NOTICE 'Total de participantes: %', (SELECT COUNT(*) FROM challenge_participants WHERE user_id = test_user_id AND challenge_id = test_challenge_id);
END $$; 