-- CORRIGIR POLÍTICAS RLS PARA RANKING DE CARDIO
-- Data: 2025-08-13
-- Objetivo: Permitir que participantes do desafio de cardio vejam treinos de outros participantes

-- 1. DROPAR a política restritiva que bloqueia visualização
DROP POLICY IF EXISTS "Usuários podem ver seus próprios registros" ON public.workout_records;

-- 2. CRIAR nova política que permite ver treinos próprios E de participantes do desafio de cardio
CREATE POLICY "Ver treinos próprios e do desafio de cardio" ON public.workout_records
FOR SELECT 
USING (
  -- Pode ver próprios treinos
  user_id = auth.uid() 
  OR 
  -- OU pode ver treinos de outros participantes do desafio de cardio
  (
    workout_type = 'Cardio' 
    AND user_id IN (
      SELECT ccp.user_id 
      FROM public.cardio_challenge_participants ccp 
      WHERE ccp.active = true
    )
    AND auth.uid() IN (
      SELECT ccp2.user_id 
      FROM public.cardio_challenge_participants ccp2 
      WHERE ccp2.active = true
    )
  )
);

-- 3. VERIFICAR se a política foi criada corretamente
SELECT 
    policyname,
    cmd,
    qual
FROM pg_policies 
WHERE tablename = 'workout_records' 
AND cmd = 'SELECT'
ORDER BY policyname;

