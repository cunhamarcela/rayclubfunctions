-- Script para aplicar a função get_participant_cardio_count no Supabase
-- Execute este script no SQL Editor do Supabase Dashboard
-- 
-- OBJETIVO: Corrigir discrepância entre estatísticas (3 treinos) e lista real de treinos
-- PROBLEMA: Função get_cardio_ranking usa estimativa, mas lista usa dados reais
-- SOLUÇÃO: Nova função RPC que conta treinos exatos usando mesmos filtros da listagem

-- FUNÇÃO SQL PARA CONTAR TREINOS DE CARDIO DE UM PARTICIPANTE
-- Bypassa limitações do RLS e retorna contagem exata
-- IMPORTANTE: Usa EXATAMENTE os mesmos filtros que get_participant_cardio_workouts

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

-- TESTE: Verificar se a função funciona
-- Substitua o UUID pelo ID de um usuário real do seu sistema
-- SELECT * FROM get_participant_cardio_count('bbea26ca-f34c-499f-ad3a-48646a614cd3'::UUID);

-- Verificar se a função foi criada corretamente
SELECT proname, proargnames, prosrc 
FROM pg_proc 
WHERE proname = 'get_participant_cardio_count';

-- NOTA: Após executar este script, as estatísticas de cardio mostrarão contagem exata
-- ao invés da estimativa baseada em minutos ÷ 50
