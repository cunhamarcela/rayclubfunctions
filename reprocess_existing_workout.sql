-- ============================================================================
-- TEST: Reprocessar treino existente após adicionar participação
-- ============================================================================

-- 1. Adicionar participação (caso ainda não tenha sido feito)
INSERT INTO challenge_participants (user_id, challenge_id, joined_at) 
VALUES (
    '906a27bc-ccff-4c74-ad83-37692782305a'::uuid, 
    '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'::uuid, 
    NOW()
) ON CONFLICT DO NOTHING;

-- 2. Tentar reprocessar o treino válido que já existia
SELECT '🔄 REPROCESSANDO: Treino válido existente' as teste;

SELECT 
    'Tentando reprocessar treino: ' || wr.workout_name as info,
    wr.id as workout_id,
    process_workout_for_ranking_one_per_day(wr.id) as resultado_reprocessamento
FROM workout_records wr
WHERE wr.user_id = '906a27bc-ccff-4c74-ad83-37692782305a'::uuid
AND wr.workout_name = 'Teste Válido Separado'
AND wr.duration_minutes = 60
LIMIT 1;

-- 3. Verificar se agora criou check-in para o treino reprocessado
SELECT 
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM challenge_check_ins cci 
            WHERE cci.user_id = '906a27bc-ccff-4c74-ad83-37692782305a'::uuid
            AND cci.workout_name = 'Teste Válido Separado'
            AND cci.points = 10
        )
        THEN '🎉 SUCESSO: Treino existente gerou check-in após correção!'
        ELSE '⚠️ Treino existente ainda não gerou check-in'
    END as resultado_reprocessamento;

-- 4. Mostrar todos os check-ins criados hoje
SELECT 
    cci.workout_name,
    cci.duration_minutes || ' min' as duracao,
    cci.points || ' pontos' as pontuacao,
    cci.created_at
FROM challenge_check_ins cci
WHERE cci.user_id = '906a27bc-ccff-4c74-ad83-37692782305a'::uuid
AND cci.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'::uuid
AND DATE(cci.check_in_date) = CURRENT_DATE
ORDER BY cci.created_at DESC; 