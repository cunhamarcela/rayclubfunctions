-- FUNÇÃO SQL PARA BUSCAR TREINOS DE PARTICIPANTES DIRETAMENTE
-- Bypassa limitações do Flutter client usando RPC

CREATE OR REPLACE FUNCTION get_participant_cardio_workouts(
  participant_user_id UUID,
  date_from TIMESTAMPTZ DEFAULT NULL,
  date_to TIMESTAMPTZ DEFAULT NULL,
  workout_limit INTEGER DEFAULT NULL,
  workout_offset INTEGER DEFAULT 0
)
RETURNS TABLE (
  id UUID,
  workout_name TEXT,
  workout_type TEXT,
  date TIMESTAMPTZ,
  duration_minutes INTEGER,
  notes TEXT,
  is_completed BOOLEAN,
  image_urls TEXT[]
) 
LANGUAGE plpgsql
SECURITY DEFINER -- Executa com privilégios do owner, não do usuário
SET search_path = public
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    wr.id,
    wr.workout_name,
    wr.workout_type,
    wr.date,
    wr.duration_minutes,
    wr.notes,
    wr.is_completed,
    wr.image_urls
  FROM public.workout_records wr
  INNER JOIN public.cardio_challenge_participants ccp ON wr.user_id = ccp.user_id
  WHERE wr.user_id = participant_user_id
    AND wr.workout_type = 'Cardio'
    AND wr.duration_minutes > 0
    AND ccp.active = true
    AND (date_from IS NULL OR wr.date >= date_from)
    AND (date_to IS NULL OR wr.date < date_to)
  ORDER BY wr.date DESC
  OFFSET workout_offset
  LIMIT COALESCE(workout_limit, 1000); -- Default alto se não especificado
END;
$$;

-- CONCEDER PERMISSÃO para usuários autenticados
GRANT EXECUTE ON FUNCTION get_participant_cardio_workouts TO authenticated;

-- TESTE: Buscar treinos da Raiany
-- SELECT * FROM get_participant_cardio_workouts('bbea26ca-f34c-499f-ad3a-48646a614cd3'::UUID);

