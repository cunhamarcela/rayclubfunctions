-- FUNÇÃO SQL PARA CONTAR TREINOS DE CARDIO DE UM PARTICIPANTE
-- Bypassa limitações do RLS e retorna contagem exata
-- IMPORTANTE: Usa EXATAMENTE os mesmos filtros que get_participant_cardio_workouts para consistência

CREATE OR REPLACE FUNCTION get_participant_cardio_count(
  participant_user_id UUID,
  date_from TIMESTAMPTZ DEFAULT NULL,
  date_to TIMESTAMPTZ DEFAULT NULL
)
RETURNS TABLE (
  total_workouts INTEGER,
  total_minutes INTEGER
) 
LANGUAGE plpgsql
SECURITY DEFINER -- Executa com privilégios do owner, não do usuário
SET search_path = public
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    COUNT(*)::INTEGER as total_workouts,
    COALESCE(SUM(wr.duration_minutes), 0)::INTEGER as total_minutes
  FROM public.workout_records wr
  INNER JOIN public.cardio_challenge_participants ccp ON wr.user_id = ccp.user_id
  WHERE wr.user_id = participant_user_id
    AND wr.workout_type = 'Cardio'  -- Exatamente igual à função get_participant_cardio_workouts
    AND wr.duration_minutes > 0
    AND ccp.active = true
    AND (date_from IS NULL OR wr.date >= date_from)
    AND (date_to IS NULL OR wr.date < date_to);
END;
$$;

-- CONCEDER PERMISSÃO para usuários autenticados
GRANT EXECUTE ON FUNCTION get_participant_cardio_count TO authenticated;

-- TESTE: Contar treinos da Raiany
-- SELECT * FROM get_participant_cardio_count('bbea26ca-f34c-499f-ad3a-48646a614cd3'::UUID);
