-- ============================================================================
-- INVESTIGAÇÃO FOCADA: Por que não está criando check-ins?
-- ============================================================================

-- 1. VERIFICAR O TREINO REGISTRADO QUE DEVERIA GERAR CHECK-IN
SELECT '📝 TREINO QUE DEVERIA GERAR CHECK-IN:' as investigacao;

SELECT 
    wr.id,
    wr.workout_name,
    wr.duration_minutes,
    wr.user_id,
    wr.challenge_id,
    wr.workout_id,
    wr.created_at
FROM workout_records wr
WHERE wr.user_id = '906a27bc-ccff-4c74-ad83-37692782305a'::uuid
AND wr.duration_minutes >= 45  -- Deve ser >= 45min para ser válido
AND wr.created_at > NOW() - INTERVAL '15 minutes'
ORDER BY wr.created_at DESC
LIMIT 1;

-- 2. VERIFICAR TODAS AS CONDIÇÕES NECESSÁRIAS
SELECT '🔍 VERIFICAÇÃO DAS CONDIÇÕES:' as investigacao;

WITH treino_teste AS (
    SELECT wr.*
    FROM workout_records wr
    WHERE wr.user_id = '906a27bc-ccff-4c74-ad83-37692782305a'::uuid
    AND wr.duration_minutes >= 45
    AND wr.created_at > NOW() - INTERVAL '15 minutes'
    LIMIT 1
)
SELECT 
    -- Condição 1: Duração mínima
    CASE 
        WHEN tt.duration_minutes >= 45 THEN '✅ Duração OK (' || tt.duration_minutes || 'min)'
        ELSE '❌ Duração insuficiente (' || tt.duration_minutes || 'min)'
    END as condicao_duracao,
    
    -- Condição 2: Usuário participa do desafio
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM challenge_participants cp 
            WHERE cp.user_id = tt.user_id 
            AND cp.challenge_id = tt.challenge_id
        ) THEN '✅ Participa do desafio'
        ELSE '❌ NÃO participa do desafio'
    END as condicao_participacao,
    
    -- Condição 3: Desafio existe e está ativo
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM challenges c 
            WHERE c.id = tt.challenge_id 
            AND c.status = 'active'
            AND NOW() BETWEEN c.start_date AND c.end_date
        ) THEN '✅ Desafio ativo'
        ELSE '❌ Desafio inativo/inexistente'
    END as condicao_desafio,
    
    -- Condição 4: Sem check-in no mesmo dia
    CASE 
        WHEN NOT EXISTS (
            SELECT 1 FROM challenge_check_ins cci 
            WHERE cci.user_id = tt.user_id 
            AND cci.challenge_id = tt.challenge_id 
            AND DATE(cci.check_in_date) = DATE(tt.created_at)
        ) THEN '✅ Sem check-in duplicado'
        ELSE '❌ Já existe check-in hoje'
    END as condicao_duplicata
    
FROM treino_teste tt;

-- 3. DETALHES DO DESAFIO
SELECT '🏆 DETALHES DO DESAFIO:' as investigacao;

SELECT 
    c.id,
    c.title,
    c.status,
    c.start_date,
    c.end_date,
    NOW() as agora,
    CASE 
        WHEN NOW() < c.start_date THEN 'FUTURO'
        WHEN NOW() > c.end_date THEN 'EXPIRADO'
        ELSE 'PERIODO_ATIVO'
    END as status_periodo
FROM challenges c
WHERE c.id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'::uuid;

-- 4. VERIFICAR PARTICIPAÇÃO NO DESAFIO
SELECT '👥 PARTICIPAÇÃO NO DESAFIO:' as investigacao;

SELECT 
    cp.user_id,
    cp.challenge_id,
    cp.joined_at,
    'CONFIRMADA' as status_participacao
FROM challenge_participants cp
WHERE cp.user_id = '906a27bc-ccff-4c74-ad83-37692782305a'::uuid
AND cp.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'::uuid;

-- Se não encontrar participação, mostrar mensagem
SELECT 
    CASE 
        WHEN NOT EXISTS (
            SELECT 1 FROM challenge_participants cp
            WHERE cp.user_id = '906a27bc-ccff-4c74-ad83-37692782305a'::uuid
            AND cp.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'::uuid
        ) THEN '❌ USUÁRIO NÃO PARTICIPA DO DESAFIO - ESTA É A CAUSA!'
        ELSE '✅ Participação confirmada'
    END as status_final_participacao;

-- 5. CHECK-INS EXISTENTES HOJE
SELECT '📅 CHECK-INS HOJE:' as investigacao;

SELECT 
    cci.workout_name,
    cci.points,
    cci.check_in_date,
    cci.created_at
FROM challenge_check_ins cci
WHERE cci.user_id = '906a27bc-ccff-4c74-ad83-37692782305a'::uuid
AND cci.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'::uuid
AND DATE(cci.check_in_date) = CURRENT_DATE;

-- 6. FUNÇÃO DE TESTE PARA CRIAR PARTICIPAÇÃO (SE NECESSÁRIO)
SELECT '🔧 SOLUÇÃO: Se o problema for participação, execute:' as solucao;

SELECT 'INSERT INTO challenge_participants (user_id, challenge_id, joined_at) VALUES (''906a27bc-ccff-4c74-ad83-37692782305a''::uuid, ''29c91ea0-7dc1-486f-8e4a-86686cbf5f82''::uuid, NOW()) ON CONFLICT DO NOTHING;' as comando_para_adicionar_participacao;

SELECT '🎯 INVESTIGAÇÃO CONCLUÍDA!' as final; 