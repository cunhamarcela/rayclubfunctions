-- VERIFICAÇÃO ESPECÍFICA PARA USUÁRIO: bc0bfc71-f0cb-4636-a998-026b9e2b5b55
-- Challenge: 29c91ea0-7dc1-486f-8e4a-86686cbf5f82

-- =====================================================
-- 1. VERIFICAR DADOS DO USUÁRIO
-- =====================================================

-- Verificar se o usuário existe
SELECT 
    '👤 DADOS DO USUÁRIO' as status,
    name,
    email,
    created_at,
    CASE 
        WHEN name IS NOT NULL THEN '✅ Usuário válido'
        ELSE '❌ Usuário não encontrado'
    END as status_usuario
FROM profiles 
WHERE id = 'bc0bfc71-f0cb-4636-a998-026b9e2b5b55';

-- Verificar dados do desafio
SELECT 
    '🏆 DADOS DO DESAFIO' as status,
    name,
    start_date,
    end_date,
    points as points_per_checkin,
    CASE 
        WHEN NOW() BETWEEN start_date AND end_date THEN 'ATIVO'
        WHEN NOW() < start_date THEN 'FUTURO'
        ELSE 'FINALIZADO'
    END as status_desafio
FROM challenges 
WHERE id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82';

-- =====================================================
-- 2. VERIFICAR PROGRESSO ATUAL
-- =====================================================

-- Progresso registrado na tabela challenge_progress
SELECT 
    '📊 PROGRESSO REGISTRADO' as status,
    COALESCE(points, 0) as pontos,
    COALESCE(check_ins_count, 0) as check_ins,
    COALESCE(total_check_ins, 0) as total_check_ins,
    last_check_in,
    COALESCE(position, 0) as posicao,
    COALESCE(completion_percentage, 0) as percentual_conclusao,
    updated_at
FROM challenge_progress 
WHERE user_id = 'bc0bfc71-f0cb-4636-a998-026b9e2b5b55' 
  AND challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82';

-- Se não houver progresso registrado, mostrar mensagem
SELECT 
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM challenge_progress 
            WHERE user_id = 'bc0bfc71-f0cb-4636-a998-026b9e2b5b55' 
              AND challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
        ) THEN '✅ Progresso encontrado'
        ELSE '❌ Nenhum progresso registrado para este usuário no desafio'
    END as status_progresso;

-- =====================================================
-- 3. VERIFICAR CHECK-INS REAIS
-- =====================================================

-- Check-ins na tabela challenge_check_ins
SELECT 
    '✅ CHECK-INS REAIS' as status,
    COUNT(*) as total_checkins,
    COUNT(DISTINCT DATE(check_in_date)) as dias_unicos,
    MIN(check_in_date) as primeiro_checkin,
    MAX(check_in_date) as ultimo_checkin,
    SUM(COALESCE(points, 10)) as total_points_calculado
FROM challenge_check_ins 
WHERE user_id = 'bc0bfc71-f0cb-4636-a998-026b9e2b5b55' 
  AND challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82';

-- =====================================================
-- 4. VERIFICAR TREINOS RELACIONADOS
-- =====================================================

-- Treinos na tabela workout_records
SELECT 
    '🏋️ TREINOS RELACIONADOS' as status,
    COUNT(*) as total_treinos,
    COUNT(CASE WHEN duration_minutes >= 45 THEN 1 END) as treinos_validos_45min,
    MIN(date) as primeiro_treino,
    MAX(date) as ultimo_treino,
    AVG(duration_minutes)::integer as duracao_media,
    SUM(duration_minutes) as duracao_total
FROM workout_records 
WHERE user_id = 'bc0bfc71-f0cb-4636-a998-026b9e2b5b55' 
  AND challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82';

-- =====================================================
-- 5. VERIFICAR CONSISTÊNCIA DOS DADOS
-- =====================================================

-- Verificar check-ins órfãos (com workout_id mas sem treino correspondente)
SELECT 
    '🔍 CHECK-INS ÓRFÃOS' as status,
    COUNT(*) as checkins_orfaos,
    STRING_AGG(workout_id, ', ') as workout_ids_orfaos
FROM challenge_check_ins cci
WHERE cci.user_id = 'bc0bfc71-f0cb-4636-a998-026b9e2b5b55' 
  AND cci.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
  AND cci.workout_id IS NOT NULL
  AND cci.workout_id != ''
  AND NOT EXISTS (
      SELECT 1 FROM workout_records wr 
      WHERE wr.id = cci.workout_id::uuid
  );

-- Comparar pontos reais vs registrados
WITH real_stats AS (
    SELECT 
        COUNT(DISTINCT DATE(check_in_date)) as real_checkins,
        COUNT(DISTINCT DATE(check_in_date)) * 10 as real_points
    FROM challenge_check_ins cci
    WHERE cci.user_id = 'bc0bfc71-f0cb-4636-a998-026b9e2b5b55' 
      AND cci.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
      AND (cci.workout_id IS NULL OR EXISTS (
          SELECT 1 FROM workout_records wr 
          WHERE wr.id = cci.workout_id::uuid
      ))
),
progress_stats AS (
    SELECT 
        COALESCE(points, 0) as progress_points,
        COALESCE(check_ins_count, 0) as progress_checkins
    FROM challenge_progress
    WHERE user_id = 'bc0bfc71-f0cb-4636-a998-026b9e2b5b55' 
      AND challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
)
SELECT 
    '⚖️ COMPARAÇÃO PONTOS' as status,
    rs.real_points as pontos_reais,
    ps.progress_points as pontos_registrados,
    rs.real_checkins as checkins_reais,
    ps.progress_checkins as checkins_registrados,
    CASE 
        WHEN rs.real_points = ps.progress_points AND rs.real_checkins = ps.progress_checkins 
        THEN '✅ CONSISTENTE'
        ELSE '❌ INCONSISTENTE'
    END as status_consistencia,
    ABS(rs.real_points - ps.progress_points) as diferenca_pontos
FROM real_stats rs, progress_stats ps;

-- =====================================================
-- 6. HISTÓRICO DETALHADO DE CHECK-INS
-- =====================================================

-- Listar todos os check-ins em detalhes
SELECT 
    '📝 HISTÓRICO CHECK-INS' as status,
    check_in_date::date as data,
    workout_name,
    workout_type,
    duration_minutes,
    points,
    workout_id,
    CASE 
        WHEN workout_id IS NULL THEN '✅ Check-in manual'
        WHEN workout_id = '' THEN '✅ Check-in manual (vazio)'
        WHEN EXISTS (SELECT 1 FROM workout_records wr WHERE wr.id = workout_id::uuid) 
        THEN '✅ Treino válido'
        ELSE '❌ Treino removido'
    END as status_treino,
    created_at
FROM challenge_check_ins 
WHERE user_id = 'bc0bfc71-f0cb-4636-a998-026b9e2b5b55' 
  AND challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
ORDER BY check_in_date DESC;

-- =====================================================
-- 7. LISTAR TREINOS EXISTENTES
-- =====================================================

-- Mostrar treinos que ainda existem
SELECT 
    '🏃 TREINOS EXISTENTES' as status,
    date::date as data,
    workout_name,
    workout_type,
    duration_minutes,
    CASE 
        WHEN duration_minutes >= 45 THEN '✅ Válido para check-in'
        ELSE '⚠️ Duração insuficiente'
    END as status_duracao,
    id as workout_id,
    created_at
FROM workout_records 
WHERE user_id = 'bc0bfc71-f0cb-4636-a998-026b9e2b5b55' 
  AND challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
ORDER BY date DESC;

-- =====================================================
-- 8. POSIÇÃO NO RANKING
-- =====================================================

-- Ver posição no ranking geral
SELECT 
    '🏅 POSIÇÃO NO RANKING' as status,
    ROW_NUMBER() OVER (ORDER BY points DESC, last_check_in ASC NULLS LAST) as posicao_real,
    cp.position as posicao_registrada,
    COALESCE(p.name, 'Usuário') as nome,
    cp.points,
    cp.check_ins_count,
    CASE 
        WHEN cp.user_id = 'bc0bfc71-f0cb-4636-a998-026b9e2b5b55' THEN '👤 VOCÊ'
        ELSE ''
    END as destacar_usuario,
    CASE 
        WHEN ROW_NUMBER() OVER (ORDER BY points DESC, last_check_in ASC NULLS LAST) = cp.position 
        THEN '✅ CORRETO'
        ELSE '❌ INCORRETO'
    END as status_ranking
FROM challenge_progress cp
LEFT JOIN profiles p ON p.id = cp.user_id
WHERE cp.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
  AND cp.points > 0
ORDER BY cp.points DESC, cp.last_check_in ASC NULLS LAST
LIMIT 20;

-- =====================================================
-- 9. TESTE DE RECÁLCULO (SE NECESSÁRIO)
-- =====================================================

-- Mostrar se seria necessário recalcular
WITH needs_recalc AS (
    SELECT 
        CASE 
            WHEN EXISTS (
                SELECT 1 FROM challenge_check_ins cci
                WHERE cci.user_id = 'bc0bfc71-f0cb-4636-a998-026b9e2b5b55' 
                  AND cci.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
                  AND cci.workout_id IS NOT NULL
                  AND cci.workout_id != ''
                  AND NOT EXISTS (
                      SELECT 1 FROM workout_records wr 
                      WHERE wr.id = cci.workout_id::uuid
                  )
            ) THEN TRUE
            ELSE FALSE
        END as tem_orfaos
)
SELECT 
    '🔄 NECESSIDADE DE RECÁLCULO' as status,
    CASE 
        WHEN tem_orfaos THEN '❌ NECESSÁRIO - Há check-ins órfãos'
        ELSE '✅ NÃO NECESSÁRIO - Dados consistentes'
    END as resultado,
    CASE 
        WHEN tem_orfaos THEN 'Execute: SELECT recalculate_challenge_progress_complete_fixed(''bc0bfc71-f0cb-4636-a998-026b9e2b5b55''::UUID, ''29c91ea0-7dc1-486f-8e4a-86686cbf5f82''::UUID);'
        ELSE 'Nenhuma ação necessária'
    END as acao_recomendada
FROM needs_recalc;

-- =====================================================
-- 10. RESUMO EXECUTIVO
-- =====================================================

-- Resumo final da situação
WITH summary AS (
    SELECT 
        (SELECT COUNT(*) FROM challenge_check_ins WHERE user_id = 'bc0bfc71-f0cb-4636-a998-026b9e2b5b55' AND challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82') as total_checkins,
        (SELECT COUNT(*) FROM workout_records WHERE user_id = 'bc0bfc71-f0cb-4636-a998-026b9e2b5b55' AND challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82') as total_treinos,
        (SELECT COALESCE(points, 0) FROM challenge_progress WHERE user_id = 'bc0bfc71-f0cb-4636-a998-026b9e2b5b55' AND challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82') as pontos_atuais,
        (SELECT COUNT(*) FROM challenge_check_ins cci WHERE cci.user_id = 'bc0bfc71-f0cb-4636-a998-026b9e2b5b55' AND cci.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82' AND cci.workout_id IS NOT NULL AND cci.workout_id != '' AND NOT EXISTS (SELECT 1 FROM workout_records wr WHERE wr.id = cci.workout_id::uuid)) as checkins_orfaos
)
SELECT 
    '📋 RESUMO EXECUTIVO' as status,
    total_checkins as check_ins_totais,
    total_treinos as treinos_totais,
    pontos_atuais,
    checkins_orfaos,
    CASE 
        WHEN checkins_orfaos = 0 THEN '✅ SISTEMA ÍNTEGRO'
        WHEN checkins_orfaos > 0 THEN '⚠️ NECESSITA CORREÇÃO'
        ELSE '❓ SITUAÇÃO INDEFINIDA'
    END as status_geral
FROM summary;

SELECT 
    '🎯 VERIFICAÇÃO CONCLUÍDA' as status,
    'Análise completa para usuário bc0bfc71-f0cb-4636-a998-026b9e2b5b55' as resultado,
    NOW() as timestamp; 