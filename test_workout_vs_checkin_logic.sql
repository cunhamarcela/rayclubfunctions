-- ============================================================================
-- SCRIPT DE TESTE: DIFERENÇA ENTRE REGISTRO DE TREINO E CHECK-IN VÁLIDO
-- ============================================================================

-- Limpar dados de teste anteriores
DO $$
BEGIN
    DELETE FROM challenge_check_ins WHERE user_id IN (
        SELECT id FROM profiles WHERE email LIKE 'teste_workout_%'
    );
    DELETE FROM challenge_progress WHERE user_id IN (
        SELECT id FROM profiles WHERE email LIKE 'teste_workout_%'
    );
    DELETE FROM workout_records WHERE user_id IN (
        SELECT id FROM profiles WHERE email LIKE 'teste_workout_%'
    );
    DELETE FROM challenge_participants WHERE user_id IN (
        SELECT id FROM profiles WHERE email LIKE 'teste_workout_%'
    );
    DELETE FROM profiles WHERE email LIKE 'teste_workout_%';
    DELETE FROM challenges WHERE title LIKE 'Teste Workout Logic%';
END $$;

-- ============================================================================
-- 1. SETUP: CRIAR DADOS DE TESTE
-- ============================================================================

-- Criar usuários de teste
INSERT INTO profiles (id, email, name, created_at) VALUES
    ('11111111-1111-1111-1111-111111111111', 'teste_workout_user1@test.com', 'Usuário Teste 1', NOW()),
    ('22222222-2222-2222-2222-222222222222', 'teste_workout_user2@test.com', 'Usuário Teste 2', NOW());

-- Criar desafio de teste
INSERT INTO challenges (id, title, description, start_date, end_date, points, created_at) VALUES
    ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Teste Workout Logic', 'Desafio para testar lógica', 
     CURRENT_DATE - INTERVAL '1 day', CURRENT_DATE + INTERVAL '10 days', 100, NOW());

-- Inscrever apenas USER1 no desafio (USER2 fica de fora)
INSERT INTO challenge_participants (challenge_id, user_id, created_at) VALUES
    ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '11111111-1111-1111-1111-111111111111', NOW());

SELECT '✅ Setup concluído - Dados de teste criados' as status;

-- ============================================================================
-- 2. CENÁRIOS DE TESTE
-- ============================================================================

-- CENÁRIO 1: Treino muito curto (< 45min) - DEVE SER REGISTRADO MAS SEM PONTOS
SELECT '🧪 CENÁRIO 1: Treino muito curto (30min)' as teste;

SELECT record_workout_basic(
    '11111111-1111-1111-1111-111111111111'::uuid,  -- user_id
    'Treino Curto',                                 -- workout_name
    'Cardio',                                       -- workout_type
    30,                                             -- duration_minutes (< 45)
    NOW(),                                          -- date
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid, -- challenge_id
    'workout-curto-001'                             -- workout_id
) as resultado_treino_curto;

-- CENÁRIO 2: Treino sem desafio - DEVE SER REGISTRADO MAS SEM PONTOS
SELECT '🧪 CENÁRIO 2: Treino sem desafio (60min)' as teste;

SELECT record_workout_basic(
    '11111111-1111-1111-1111-111111111111'::uuid,  -- user_id
    'Treino Sem Desafio',                          -- workout_name
    'Musculação',                                   -- workout_type
    60,                                             -- duration_minutes (>= 45)
    NOW(),                                          -- date
    NULL,                                           -- challenge_id (SEM DESAFIO)
    'workout-sem-desafio-001'                       -- workout_id
) as resultado_treino_sem_desafio;

-- CENÁRIO 3: Usuário não participa do desafio - DEVE SER REGISTRADO MAS SEM PONTOS
SELECT '🧪 CENÁRIO 3: Usuário não inscrito no desafio (60min)' as teste;

SELECT record_workout_basic(
    '22222222-2222-2222-2222-222222222222'::uuid,  -- user_id (NÃO INSCRITO)
    'Treino Não Inscrito',                         -- workout_name
    'Funcional',                                    -- workout_type
    60,                                             -- duration_minutes (>= 45)
    NOW(),                                          -- date
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid, -- challenge_id
    'workout-nao-inscrito-001'                      -- workout_id
) as resultado_treino_nao_inscrito;

-- CENÁRIO 4: Treino válido - DEVE SER REGISTRADO E GANHAR PONTOS
SELECT '🧪 CENÁRIO 4: Treino válido para check-in (60min)' as teste;

SELECT record_workout_basic(
    '11111111-1111-1111-1111-111111111111'::uuid,  -- user_id
    'Treino Válido',                               -- workout_name
    'CrossFit',                                     -- workout_type
    60,                                             -- duration_minutes (>= 45)
    NOW(),                                          -- date
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid, -- challenge_id
    'workout-valido-001'                            -- workout_id
) as resultado_treino_valido;

-- CENÁRIO 5: Segundo treino no mesmo dia - DEVE SER REGISTRADO MAS SEM PONTOS
SELECT '🧪 CENÁRIO 5: Segundo treino no mesmo dia (90min)' as teste;

SELECT record_workout_basic(
    '11111111-1111-1111-1111-111111111111'::uuid,  -- user_id (MESMO USUÁRIO)
    'Segundo Treino Hoje',                         -- workout_name
    'Yoga',                                         -- workout_type
    90,                                             -- duration_minutes (>= 45)
    NOW(),                                          -- date (MESMO DIA)
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid, -- challenge_id (MESMO DESAFIO)
    'workout-segundo-001'                           -- workout_id
) as resultado_segundo_treino;

-- Aguardar processamento
SELECT pg_sleep(2);

-- ============================================================================
-- 3. VERIFICAR RESULTADOS
-- ============================================================================

SELECT '📊 RELATÓRIO DE RESULTADOS' as secao;

-- 3.1 Verificar todos os treinos registrados
SELECT '📝 TREINOS REGISTRADOS (workout_records):' as subsecao;

SELECT 
    wr.workout_name,
    wr.workout_type,
    wr.duration_minutes,
    CASE WHEN wr.challenge_id IS NULL THEN 'SEM DESAFIO' ELSE 'COM DESAFIO' END as tem_desafio,
    wr.points as pontos_iniciais,
    wr.created_at,
    p.name as usuario
FROM workout_records wr
JOIN profiles p ON p.id = wr.user_id
WHERE p.email LIKE 'teste_workout_%'
ORDER BY wr.created_at;

-- 3.2 Verificar check-ins criados (só os que passaram nas validações)
SELECT '✅ CHECK-INS VÁLIDOS (challenge_check_ins):' as subsecao;

SELECT 
    cci.workout_name,
    cci.workout_type,
    cci.duration_minutes,
    cci.points as pontos_check_in,
    cci.user_name,
    cci.created_at
FROM challenge_check_ins cci
JOIN profiles p ON p.id = cci.user_id
WHERE p.email LIKE 'teste_workout_%'
ORDER BY cci.created_at;

-- 3.3 Verificar progresso dos usuários
SELECT '🏆 PROGRESSO NO RANKING (challenge_progress):' as subsecao;

SELECT 
    cp.user_name,
    cp.points as pontos_totais,
    cp.check_ins_count as check_ins_validos,
    cp.completion_percentage as percentual_conclusao,
    cp.position as posicao_ranking
FROM challenge_progress cp
JOIN profiles p ON p.id = cp.user_id
WHERE p.email LIKE 'teste_workout_%'
ORDER BY cp.points DESC;

-- 3.4 Verificar erros/logs
SELECT '⚠️ LOGS DE ERROS (check_in_error_logs):' as subsecao;

SELECT 
    cel.error_message,
    cel.status,
    p.name as usuario,
    cel.created_at
FROM check_in_error_logs cel
JOIN profiles p ON p.id = cel.user_id
WHERE p.email LIKE 'teste_workout_%'
ORDER BY cel.created_at;

-- 3.5 Resumo final
SELECT '📈 RESUMO FINAL:' as subsecao;

WITH stats AS (
    SELECT 
        COUNT(*) as total_treinos_registrados,
        SUM(CASE WHEN wr.challenge_id IS NOT NULL THEN 1 ELSE 0 END) as treinos_com_desafio,
        SUM(CASE WHEN wr.duration_minutes >= 45 THEN 1 ELSE 0 END) as treinos_longa_duracao
    FROM workout_records wr
    JOIN profiles p ON p.id = wr.user_id
    WHERE p.email LIKE 'teste_workout_%'
),
checkins AS (
    SELECT COUNT(*) as total_checkins_validos
    FROM challenge_check_ins cci
    JOIN profiles p ON p.id = cci.user_id
    WHERE p.email LIKE 'teste_workout_%'
),
pontos AS (
    SELECT COALESCE(SUM(cp.points), 0) as total_pontos
    FROM challenge_progress cp
    JOIN profiles p ON p.id = cp.user_id
    WHERE p.email LIKE 'teste_workout_%'
)
SELECT 
    s.total_treinos_registrados,
    s.treinos_com_desafio,
    s.treinos_longa_duracao,
    c.total_checkins_validos,
    p.total_pontos,
    CASE 
        WHEN s.total_treinos_registrados > c.total_checkins_validos 
        THEN '✅ CORRETO: Nem todo treino vira check-in'
        ELSE '❌ ERRO: Todos os treinos viraram check-ins'
    END as validacao_logica
FROM stats s, checkins c, pontos p;

-- ============================================================================
-- 4. TESTES ESPECÍFICOS DE VALIDAÇÃO
-- ============================================================================

SELECT '🔍 VALIDAÇÕES ESPECÍFICAS:' as secao;

-- Teste 1: Treino curto NÃO deve gerar check-in
SELECT 
    CASE 
        WHEN NOT EXISTS (
            SELECT 1 FROM challenge_check_ins cci 
            JOIN workout_records wr ON wr.id::text = cci.workout_id::text
            WHERE wr.workout_name = 'Treino Curto' AND wr.duration_minutes = 30
        )
        THEN '✅ CORRETO: Treino < 45min NÃO gerou check-in'
        ELSE '❌ ERRO: Treino < 45min GEROU check-in indevidamente'
    END as teste_duracao_minima;

-- Teste 2: Treino sem desafio NÃO deve gerar check-in
SELECT 
    CASE 
        WHEN NOT EXISTS (
            SELECT 1 FROM challenge_check_ins cci 
            JOIN workout_records wr ON wr.id::text = cci.workout_id::text
            WHERE wr.workout_name = 'Treino Sem Desafio'
        )
        THEN '✅ CORRETO: Treino sem desafio NÃO gerou check-in'
        ELSE '❌ ERRO: Treino sem desafio GEROU check-in indevidamente'
    END as teste_sem_desafio;

-- Teste 3: Usuário não inscrito NÃO deve gerar check-in
SELECT 
    CASE 
        WHEN NOT EXISTS (
            SELECT 1 FROM challenge_check_ins cci 
            JOIN workout_records wr ON wr.id::text = cci.workout_id::text
            WHERE wr.workout_name = 'Treino Não Inscrito'
        )
        THEN '✅ CORRETO: Usuário não inscrito NÃO gerou check-in'
        ELSE '❌ ERRO: Usuário não inscrito GEROU check-in indevidamente'
    END as teste_nao_inscrito;

-- Teste 4: Treino válido DEVE gerar check-in
SELECT 
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM challenge_check_ins cci 
            JOIN workout_records wr ON wr.id::text = cci.workout_id::text
            WHERE wr.workout_name = 'Treino Válido' AND cci.points = 10
        )
        THEN '✅ CORRETO: Treino válido GEROU check-in com 10 pontos'
        ELSE '❌ ERRO: Treino válido NÃO gerou check-in'
    END as teste_treino_valido;

-- Teste 5: Segundo treino no dia NÃO deve gerar check-in
SELECT 
    CASE 
        WHEN NOT EXISTS (
            SELECT 1 FROM challenge_check_ins cci 
            JOIN workout_records wr ON wr.id::text = cci.workout_id::text
            WHERE wr.workout_name = 'Segundo Treino Hoje'
        )
        THEN '✅ CORRETO: Segundo treino do dia NÃO gerou check-in'
        ELSE '❌ ERRO: Segundo treino do dia GEROU check-in indevidamente'
    END as teste_segundo_treino;

SELECT '🎯 TESTE CONCLUÍDO!' as final_status; 