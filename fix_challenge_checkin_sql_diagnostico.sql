-- Consulta de diagnóstico para identificar problemas nos check-ins de desafios

-- 1. Verificar se existem check-ins duplicados para o mesmo usuário, desafio e data
SELECT 
  user_id, 
  challenge_id, 
  DATE(check_in_date) as check_in_date,
  COUNT(*) as num_check_ins,
  STRING_AGG(id::text, ', ') as check_in_ids,
  STRING_AGG(workout_name, ', ') as workout_names
FROM challenge_check_ins
GROUP BY user_id, challenge_id, DATE(check_in_date)
HAVING COUNT(*) > 1
ORDER BY DATE(check_in_date) DESC;

-- 2. Verificar check-ins com duração zero ou menor que 45min (mínimo para contabilizar)
SELECT 
  id,
  user_id,
  challenge_id,
  check_in_date,
  workout_name,
  duration_minutes
FROM challenge_check_ins
WHERE duration_minutes < 45
ORDER BY check_in_date DESC;

-- 3. Verificar check-ins com valores nulos em campos importantes
SELECT 
  id,
  user_id,
  challenge_id,
  check_in_date,
  workout_id,
  workout_name,
  workout_type,
  duration_minutes
FROM challenge_check_ins
WHERE 
  user_id IS NULL OR
  challenge_id IS NULL OR
  workout_id IS NULL OR
  workout_name IS NULL OR
  check_in_date IS NULL
ORDER BY check_in_date DESC;

-- 4. Limpar check-ins duplicados mantendo apenas o mais recente (se necessário)
-- ATENÇÃO: Execute esta consulta com cuidado, após backups
/*
WITH duplicados AS (
  SELECT 
    user_id, 
    challenge_id, 
    DATE(check_in_date) as check_in_date,
    MAX(id) as check_in_mais_recente
  FROM challenge_check_ins
  GROUP BY user_id, challenge_id, DATE(check_in_date)
  HAVING COUNT(*) > 1
)
DELETE FROM challenge_check_ins 
WHERE id IN (
  SELECT c.id 
  FROM challenge_check_ins c
  JOIN duplicados d ON 
    c.user_id = d.user_id AND 
    c.challenge_id = d.challenge_id AND 
    DATE(c.check_in_date) = d.check_in_date AND
    c.id <> d.check_in_mais_recente
);
*/

-- 5. Verificar check-ins do último dia para acompanhamento
SELECT 
  id,
  user_id,
  challenge_id,
  check_in_date,
  workout_id,
  workout_name,
  workout_type,
  duration_minutes,
  user_name
FROM challenge_check_ins
WHERE check_in_date >= CURRENT_DATE - INTERVAL '1 day'
ORDER BY check_in_date DESC; 