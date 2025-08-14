-- Ray Club — Adicionar Participantes de Teste
-- Script para adicionar participantes fictícios para testar o ranking

-- 1. Verificar se usuário atual está participando
SELECT 'Usuario atual participando?' as info, 
       EXISTS(SELECT 1 FROM cardio_challenge_participants WHERE user_id = auth.uid() AND active = true) as participando;

-- 2. Se necessário, adicionar usuário atual
INSERT INTO cardio_challenge_participants (user_id, active)
SELECT auth.uid(), true
WHERE NOT EXISTS (
    SELECT 1 FROM cardio_challenge_participants 
    WHERE user_id = auth.uid()
)
AND auth.uid() IS NOT NULL;

-- 3. Para testar com múltiplos participantes, você pode executar manualmente:
-- (Substitua os UUIDs pelos IDs reais de outros usuários do sistema)

/*
-- EXEMPLO - só execute se houver outros usuários reais:
INSERT INTO cardio_challenge_participants (user_id, active) VALUES
('uuid-do-usuario-2', true),
('uuid-do-usuario-3', true)
ON CONFLICT (user_id) DO UPDATE SET active = true;

-- E adicionar treinos de teste para eles:
INSERT INTO workout_records (user_id, workout_name, workout_type, duration_minutes, date) VALUES
('uuid-do-usuario-2', 'Corrida de Teste', 'Cardio', 30, NOW() - INTERVAL '1 day'),
('uuid-do-usuario-3', 'Bike de Teste', 'Cardio', 45, NOW() - INTERVAL '2 days');
*/

-- 4. Verificar resultado final
SELECT 'Participantes após script:' as info;
SELECT user_id, active, joined_at FROM cardio_challenge_participants WHERE active = true;

SELECT 'Treinos de cardio existentes:' as info;
SELECT user_id, workout_name, workout_type, duration_minutes, date 
FROM workout_records 
WHERE LOWER(workout_type) = 'cardio' OR workout_type = 'Cardio'
ORDER BY date DESC;

