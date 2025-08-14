-- CORREÇÃO URGENTE: Sincronizar ranking com participantes ativos

-- 1. Verificar quais usuários estão no ranking mas não são participantes ativos
SELECT 'Usuários no ranking atual:' as status;
SELECT user_id, full_name, total_cardio_minutes FROM public.get_cardio_ranking();

SELECT 'Participantes ativos na tabela:' as status;
SELECT user_id, active, joined_at FROM public.cardio_challenge_participants WHERE active = true;

-- 2. Adicionar Raiany Ricardo como participante ativa (se não estiver)
INSERT INTO public.cardio_challenge_participants (user_id, joined_at, active)
VALUES ('bbea26ca-f34c-499f-ad3a-48646a614cd3', '2025-08-13 13:39:30+00', true)
ON CONFLICT (user_id) DO UPDATE SET active = true, joined_at = EXCLUDED.joined_at;

-- 3. Verificar resultado
SELECT 'Participantes após correção:' as status;
SELECT user_id, active, joined_at FROM public.cardio_challenge_participants WHERE active = true;

-- 4. Testar ranking novamente
SELECT 'Ranking após correção:' as status;
SELECT user_id, full_name, total_cardio_minutes FROM public.get_cardio_ranking();

