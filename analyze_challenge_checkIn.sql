-- 1. Analisar a definição da função atual
SELECT 
    routine_name,
    routine_type,
    data_type,
    external_language,
    routine_definition
FROM 
    information_schema.routines
WHERE 
    routine_name = 'record_challenge_check_in'
    AND routine_schema = 'public';

-- 2. Analisar os parâmetros da função
SELECT 
    p.parameter_name,
    p.data_type,
    p.parameter_mode
FROM 
    information_schema.parameters p
WHERE 
    p.specific_name = 'record_challenge_check_in' 
    AND p.specific_schema = 'public'
ORDER BY 
    p.ordinal_position;

-- 3. Analisar a estrutura da tabela challenge_check_ins
SELECT 
    column_name, 
    data_type, 
    is_nullable
FROM 
    information_schema.columns
WHERE 
    table_name = 'challenge_check_ins' 
    AND table_schema = 'public'
ORDER BY 
    ordinal_position;

-- 4. Verificar um exemplo de registro na tabela (para entender o formato de data esperado)
SELECT 
    * 
FROM 
    challenge_check_ins
LIMIT 5;

-- 5. Script para corrigir a função RPC (execute somente depois de analisar os resultados acima)
-- CREATE OR REPLACE FUNCTION public.record_challenge_check_in(
--     _user_id UUID,
--     _challenge_id UUID,
--     _workout_id VARCHAR,
--     _workout_name VARCHAR,
--     _workout_type VARCHAR,
--     _duration_minutes INTEGER,
--     _check_in_date TIMESTAMP WITH TIME ZONE
-- ) RETURNS JSONB AS $$
-- DECLARE
--   _points_awarded INTEGER := 0;
--   _challenge_points INTEGER := 0;
--   _current_date DATE := CURRENT_DATE;
--   _check_in_date_only DATE := _check_in_date::DATE;
--   _success BOOLEAN := TRUE;
--   _message VARCHAR := 'Check-in registrado com sucesso';
--   _streak_bonus_points INTEGER := 0;
--   _streak_count INTEGER := 0;
-- BEGIN
--   -- Verificar se o usuário já fez check-in nesse desafio hoje
--   IF EXISTS (
--     SELECT 1 FROM challenge_check_ins 
--     WHERE user_id = _user_id 
--       AND challenge_id = _challenge_id 
--       AND check_in_date::DATE = _check_in_date_only
--   ) THEN
--     RETURN jsonb_build_object(
--       'success', FALSE,
--       'points_awarded', 0,
--       'message', 'Você já fez check-in neste desafio hoje'
--     );
--   END IF;
--   
--   -- Obter os pontos do desafio
--   SELECT points INTO _challenge_points
--   FROM challenges
--   WHERE id = _challenge_id;
--   
--   -- Se não encontrou os pontos, usar um valor padrão
--   IF _challenge_points IS NULL THEN
--     _challenge_points := 10; -- Valor padrão
--   END IF;
--   
--   -- Atribuir pontos básicos pelo check-in
--   _points_awarded := _challenge_points;
--   
--   -- Inserir o registro de check-in
--   INSERT INTO challenge_check_ins (
--     user_id,
--     challenge_id,
--     workout_id,
--     workout_name,
--     workout_type,
--     check_in_date,
--     points_awarded,
--     duration_minutes
--   ) VALUES (
--     _user_id,
--     _challenge_id,
--     _workout_id,
--     _workout_name,
--     _workout_type,
--     _check_in_date,
--     _points_awarded,
--     _duration_minutes
--   );
--   
--   -- Atualizar o progresso do usuário no desafio
--   -- Verificar se já existe um registro de progresso
--   IF EXISTS (
--     SELECT 1 FROM challenge_progress
--     WHERE user_id = _user_id AND challenge_id = _challenge_id
--   ) THEN
--     -- Atualizar o progresso existente
--     UPDATE challenge_progress
--     SET 
--       points = points + _points_awarded,
--       last_check_in = _check_in_date,
--       updated_at = NOW()
--     WHERE 
--       user_id = _user_id AND challenge_id = _challenge_id;
--   ELSE
--     -- Criar novo registro de progresso
--     INSERT INTO challenge_progress (
--       user_id,
--       challenge_id,
--       points,
--       completion_percentage,
--       last_check_in,
--       position,
--       created_at,
--       updated_at
--     ) VALUES (
--       _user_id,
--       _challenge_id,
--       _points_awarded,
--       0.05, -- Porcentagem inicial de conclusão
--       _check_in_date,
--       0, -- Posição inicial (será atualizada posteriormente)
--       NOW(),
--       NOW()
--     );
--   END IF;
--   
--   -- Chamar a função para recalcular o ranking
--   PERFORM update_challenge_ranking(_challenge_id);
--   
--   RETURN jsonb_build_object(
--     'success', _success,
--     'points_awarded', _points_awarded,
--     'message', _message
--   );
-- END;
-- $$ LANGUAGE plpgsql; 

-- Script para analisar a tabela challenge_progress e seus triggers
-- Use esse script para diagnosticar problemas no sistema de check-in

-- 1. Verificar o esquema da tabela challenge_progress
SELECT 
    column_name, 
    data_type, 
    is_nullable 
FROM 
    information_schema.columns 
WHERE 
    table_name = 'challenge_progress'
ORDER BY 
    ordinal_position;

-- 2. Verificar triggers existentes na tabela challenge_check_ins
SELECT 
    trigger_name,
    event_manipulation, 
    action_statement,
    action_timing
FROM 
    information_schema.triggers
WHERE 
    event_object_table = 'challenge_check_ins'
ORDER BY 
    trigger_name;

-- 3. Verificar se existe a função update_challenge_progress_on_checkin
SELECT 
    routine_name,
    routine_type,
    data_type,
    external_language
FROM 
    information_schema.routines
WHERE 
    routine_name LIKE '%challenge_progress%'
    OR routine_name LIKE '%check_in%'
ORDER BY 
    routine_name;

-- 4. Verificar os últimos 10 check-ins registrados
SELECT 
    c.*,
    p.user_name,
    p.consecutive_days,
    p.check_ins_count,
    p.points
FROM 
    challenge_check_ins c
JOIN 
    challenge_progress p ON c.challenge_id = p.challenge_id AND c.user_id = p.user_id
ORDER BY 
    c.created_at DESC
LIMIT 10;

-- 5. Verificar contagem de check-ins por desafio
SELECT 
    challenge_id,
    COUNT(*) as total_check_ins,
    COUNT(DISTINCT user_id) as unique_users,
    MIN(check_in_date) as first_check_in,
    MAX(check_in_date) as last_check_in
FROM 
    challenge_check_ins
GROUP BY 
    challenge_id;

-- 6. Verificar se existem inconsistências nos dados
SELECT 
    cp.challenge_id,
    cp.user_id,
    cp.check_ins_count,
    COUNT(ci.id) as actual_check_ins,
    cp.points,
    cp.consecutive_days,
    cp.last_check_in,
    CASE
        WHEN cp.check_ins_count <> COUNT(ci.id) THEN 'Inconsistente'
        ELSE 'Ok'
    END as status
FROM 
    challenge_progress cp
LEFT JOIN 
    challenge_check_ins ci ON cp.challenge_id = ci.challenge_id AND cp.user_id = ci.user_id
GROUP BY 
    cp.challenge_id, cp.user_id, cp.check_ins_count, cp.points, cp.consecutive_days, cp.last_check_in
HAVING 
    cp.check_ins_count <> COUNT(ci.id)
LIMIT 25; 