-- Função para verificar se um usuário já fez check-in em uma data específica
CREATE OR REPLACE FUNCTION public.has_check_in_on_date(
    _user_id UUID,
    _challenge_id UUID,
    _check_date VARCHAR
) RETURNS BOOLEAN AS $$
DECLARE
  check_exists BOOLEAN;
BEGIN
  SELECT EXISTS (
    SELECT 1 
    FROM challenge_check_ins 
    WHERE user_id = _user_id 
      AND challenge_id = _challenge_id 
      AND formatted_date = _check_date
  ) INTO check_exists;
  
  RETURN check_exists;
END;
$$ LANGUAGE plpgsql; 