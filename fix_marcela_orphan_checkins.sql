-- CORREÇÃO ESPECÍFICA PARA MARCELA - CHECK-INS ÓRFÃOS
-- Problema: Check-ins contando pontos mas treinos foram removidos

-- =====================================================
-- 1. INVESTIGAR O PROBLEMA
-- =====================================================

-- Verificar todos os check-ins da Marcela em detalhes
SELECT 
    '🔍 ANÁLISE DETALHADA' as status,
    check_in_date::date as data,
    workout_name,
    workout_id,
    points,
    CASE 
        WHEN workout_id IS NULL THEN 'Check-in manual (sem workout_id)'
        WHEN workout_id = '' THEN 'Check-in com workout_id vazio'
        WHEN EXISTS (SELECT 1 FROM workout_records wr WHERE wr.id = workout_id::uuid) 
        THEN 'Treino existe'
        ELSE 'Treino foi removido'
    END as status_detalhado,
    created_at
FROM challenge_check_ins 
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9' 
  AND challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
ORDER BY check_in_date DESC;

-- Verificar se há workout_ids vazios ou com problemas
SELECT 
    '📊 TIPOS DE WORKOUT_ID' as status,
    CASE 
        WHEN workout_id IS NULL THEN 'NULL'
        WHEN workout_id = '' THEN 'STRING_VAZIA'
        WHEN LENGTH(workout_id) != 36 THEN 'FORMATO_INVALIDO'
        ELSE 'UUID_VALIDO'
    END as tipo_workout_id,
    COUNT(*) as quantidade
FROM challenge_check_ins 
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9' 
  AND challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
GROUP BY 
    CASE 
        WHEN workout_id IS NULL THEN 'NULL'
        WHEN workout_id = '' THEN 'STRING_VAZIA'
        WHEN LENGTH(workout_id) != 36 THEN 'FORMATO_INVALIDO'
        ELSE 'UUID_VALIDO'
    END;

-- =====================================================
-- 2. BACKUP ANTES DA CORREÇÃO
-- =====================================================

-- Fazer backup dos check-ins da Marcela
CREATE TABLE IF NOT EXISTS marcela_checkins_backup AS
SELECT 
    cci.*,
    'backup_before_correction_' || NOW()::text as backup_reason
FROM challenge_check_ins cci
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9' 
  AND challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82';

SELECT 
    '💾 BACKUP CRIADO' as status,
    COUNT(*) as registros_salvos
FROM marcela_checkins_backup
WHERE backup_reason LIKE 'backup_before_correction_%';

-- =====================================================
-- 3. ESTRATÉGIA DE CORREÇÃO
-- =====================================================

-- Opção A: Remover check-ins com treinos removidos (mais drástica)
-- Opção B: Converter para check-ins manuais (preserva histórico)
-- Opção C: Recalcular baseado apenas em treinos válidos

-- Vamos mostrar o que cada opção faria:

-- OPÇÃO A: Quantos check-ins seriam removidos
SELECT 
    '🗑️ OPÇÃO A - REMOÇÃO' as status,
    COUNT(*) as checkins_a_remover,
    SUM(COALESCE(points, 10)) as pontos_perdidos
FROM challenge_check_ins cci
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9' 
  AND challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
  AND workout_id IS NOT NULL
  AND workout_id != ''
  AND NOT EXISTS (
      SELECT 1 FROM workout_records wr 
      WHERE wr.id = workout_id::uuid
  );

-- OPÇÃO B: Quantos check-ins seriam convertidos para manuais
SELECT 
    '🔄 OPÇÃO B - CONVERSÃO' as status,
    COUNT(*) as checkins_a_converter,
    'Manter pontos mas remover referência ao treino' as descricao
FROM challenge_check_ins cci
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9' 
  AND challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
  AND workout_id IS NOT NULL
  AND workout_id != ''
  AND NOT EXISTS (
      SELECT 1 FROM workout_records wr 
      WHERE wr.id = workout_id::uuid
  );

-- OPÇÃO C: Recalcular baseado apenas em treinos existentes
WITH treinos_validos AS (
    SELECT 
        DATE(wr.date) as data_treino,
        wr.workout_name,
        wr.workout_type,
        wr.duration_minutes
    FROM workout_records wr
    WHERE wr.user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9' 
      AND wr.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
      AND wr.duration_minutes >= 45  -- Critério mínimo para check-in
)
SELECT 
    '📈 OPÇÃO C - RECÁLCULO' as status,
    COUNT(*) as checkins_validos,
    COUNT(*) * 10 as pontos_corretos,
    'Baseado apenas em treinos existentes' as descricao
FROM treinos_validos;

-- =====================================================
-- 4. IMPLEMENTAR CORREÇÃO (OPÇÃO B - MAIS CONSERVADORA)
-- =====================================================

-- Converter check-ins órfãos para manuais (remover workout_id)
WITH checkins_orfaos AS (
    UPDATE challenge_check_ins 
    SET 
        workout_id = NULL,  -- Remove referência ao treino removido
        workout_name = COALESCE(workout_name, 'Check-in manual'),
        updated_at = NOW()
    WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9' 
      AND challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
      AND workout_id IS NOT NULL
      AND workout_id != ''
      AND NOT EXISTS (
          SELECT 1 FROM workout_records wr 
          WHERE wr.id = workout_id::uuid
      )
    RETURNING id, check_in_date, workout_name
)
SELECT 
    '✅ CORREÇÃO APLICADA' as status,
    COUNT(*) as checkins_corrigidos,
    'Check-ins convertidos para manuais' as descricao
FROM checkins_orfaos;

-- =====================================================
-- 5. RECALCULAR PROGRESSO APÓS CORREÇÃO
-- =====================================================

-- Forçar recálculo do progresso
SELECT 
    '🔄 RECÁLCULO FINAL' as status,
    recalculate_challenge_progress_complete_fixed(
        '01d4a292-1873-4af6-948b-a55eed56d6b9'::UUID,
        '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'::UUID
    ) as resultado;

-- =====================================================
-- 6. VERIFICAÇÃO FINAL
-- =====================================================

-- Verificar estado após correção
SELECT 
    '📊 ESTADO FINAL' as status,
    points as pontos_finais,
    check_ins_count as checkins_finais,
    position as posicao_final
FROM challenge_progress 
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9' 
  AND challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82';

-- Verificar se ainda há check-ins órfãos
SELECT 
    '🔍 VERIFICAÇÃO ÓRFÃOS' as status,
    COUNT(*) as checkins_orfaos_restantes
FROM challenge_check_ins cci
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9' 
  AND challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
  AND workout_id IS NOT NULL
  AND workout_id != ''
  AND NOT EXISTS (
      SELECT 1 FROM workout_records wr 
      WHERE wr.id = workout_id::uuid
  );

-- Mostrar histórico final corrigido
SELECT 
    '📝 HISTÓRICO CORRIGIDO' as status,
    check_in_date::date as data,
    workout_name,
    workout_type,
    points,
    CASE 
        WHEN workout_id IS NULL THEN '✅ Check-in manual'
        WHEN EXISTS (SELECT 1 FROM workout_records wr WHERE wr.id = workout_id::uuid) 
        THEN '✅ Treino válido'
        ELSE '❌ Ainda órfão'
    END as status_final
FROM challenge_check_ins 
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9' 
  AND challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
ORDER BY check_in_date DESC;

SELECT 
    '🎉 CORREÇÃO CONCLUÍDA' as status,
    'Check-ins órfãos corrigidos e progresso recalculado' as resultado,
    NOW() as timestamp; 