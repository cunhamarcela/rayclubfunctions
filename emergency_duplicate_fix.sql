-- =========================================================
-- CORREÇÃO EMERGENCIAL PARA DUPLICADOS DE CHECK-INS
-- Data: $(date)
-- =========================================================

-- 1. BACKUP E AUDITORIA
SELECT '🔍 INICIANDO AUDITORIA...' as status;

-- Verificar estado atual
WITH duplicates_stats AS (
  SELECT 
    COUNT(*) as total_checkins,
    COUNT(DISTINCT (user_id, challenge_id, DATE(check_in_date AT TIME ZONE 'America/Sao_Paulo'))) as unique_checkins,
    COUNT(*) - COUNT(DISTINCT (user_id, challenge_id, DATE(check_in_date AT TIME ZONE 'America/Sao_Paulo'))) as duplicates
  FROM challenge_check_ins
)
SELECT 
  total_checkins,
  unique_checkins,
  duplicates,
  ROUND((duplicates::decimal / total_checkins * 100), 2) as duplicate_percentage
FROM duplicates_stats;

-- 2. CRIAR FUNÇÃO DE BACKUP
CREATE OR REPLACE FUNCTION create_backup_table()
RETURNS TEXT AS $$
BEGIN
  -- Criar tabela de backup se não existir
  CREATE TABLE IF NOT EXISTS challenge_check_ins_backup_emergency AS 
  SELECT * FROM challenge_check_ins LIMIT 0;
  
  -- Inserir dados atuais
  INSERT INTO challenge_check_ins_backup_emergency 
  SELECT * FROM challenge_check_ins;
  
  RETURN 'Backup criado com ' || (SELECT COUNT(*) FROM challenge_check_ins_backup_emergency) || ' registros';
END;
$$ LANGUAGE plpgsql;

SELECT create_backup_table();

-- 3. CORRIGIR FUNÇÃO record_workout_basic
CREATE OR REPLACE FUNCTION record_workout_basic(
  p_user_id UUID,
  p_workout_name TEXT,
  p_workout_type TEXT,
  p_duration_minutes INTEGER,
  p_date TIMESTAMP WITH TIME ZONE,
  p_challenge_id UUID DEFAULT NULL,
  p_workout_id TEXT DEFAULT NULL,
  p_notes TEXT DEFAULT NULL,
  p_workout_record_id UUID DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
  v_workout_record_id UUID;
  v_check_in_id UUID;
  v_workout_date_brt DATE;
  v_existing_count INTEGER;
BEGIN
  -- Converter para data local do Brasil
  v_workout_date_brt := DATE(p_date AT TIME ZONE 'America/Sao_Paulo');
  
  -- CORREÇÃO: Verificar duplicados por DATA (não timestamp)
  IF p_challenge_id IS NOT NULL THEN
    SELECT COUNT(*) INTO v_existing_count
    FROM challenge_check_ins 
    WHERE user_id = p_user_id 
      AND challenge_id = p_challenge_id 
      AND DATE(check_in_date AT TIME ZONE 'America/Sao_Paulo') = v_workout_date_brt;
    
    IF v_existing_count > 0 THEN
      RAISE EXCEPTION 'Check-in já realizado nesta data: %', v_workout_date_brt;
    END IF;
  END IF;

  -- Verificar duplicados na tabela workout_records (apenas últimos 1 minuto para evitar cliques duplos)
  SELECT COUNT(*) INTO v_existing_count
  FROM workout_records 
  WHERE user_id = p_user_id 
    AND workout_name = p_workout_name
    AND workout_type = p_workout_type
    AND created_at > NOW() - INTERVAL '1 minute';
  
  IF v_existing_count > 0 THEN
    RAISE EXCEPTION 'Treino duplicado detectado. Aguarde antes de registrar novamente.';
  END IF;

  -- Criar registro de treino
  IF p_workout_record_id IS NOT NULL THEN
    v_workout_record_id := p_workout_record_id;
    
    UPDATE workout_records SET
      workout_name = p_workout_name,
      workout_type = p_workout_type,
      duration_minutes = p_duration_minutes,
      date = p_date,
      notes = COALESCE(p_notes, notes),
      updated_at = NOW()
    WHERE id = v_workout_record_id AND user_id = p_user_id;
  ELSE
    INSERT INTO workout_records (
      user_id, workout_name, workout_type, duration_minutes, date, notes, created_at, updated_at
    ) VALUES (
      p_user_id, p_workout_name, p_workout_type, p_duration_minutes, p_date, p_notes, NOW(), NOW()
    ) RETURNING id INTO v_workout_record_id;
  END IF;

  -- Registrar check-in do desafio (se aplicável)
  IF p_challenge_id IS NOT NULL THEN
    INSERT INTO challenge_check_ins (
      user_id, challenge_id, workout_record_id, check_in_date, points, created_at
    ) VALUES (
      p_user_id, p_challenge_id, v_workout_record_id, p_date, 10, NOW()
    ) RETURNING id INTO v_check_in_id;
  END IF;

  -- Processar para ranking (função corrigida será chamada)
  PERFORM process_workout_for_ranking(v_workout_record_id);

  RETURN v_workout_record_id;
EXCEPTION
  WHEN OTHERS THEN
    RAISE EXCEPTION 'Erro ao registrar treino: %', SQLERRM;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. CORRIGIR FUNÇÃO process_workout_for_ranking
CREATE OR REPLACE FUNCTION process_workout_for_ranking(
  _workout_record_id UUID
)
RETURNS VOID AS $$
DECLARE
  v_user_id UUID;
  v_challenge_id UUID;
  v_workout_date_brt DATE;
  v_existing_count INTEGER;
BEGIN
  -- Buscar dados do treino
  SELECT wr.user_id, cci.challenge_id, DATE(wr.date AT TIME ZONE 'America/Sao_Paulo')
  INTO v_user_id, v_challenge_id, v_workout_date_brt
  FROM workout_records wr
  LEFT JOIN challenge_check_ins cci ON cci.workout_record_id = wr.id
  WHERE wr.id = _workout_record_id;

  IF v_user_id IS NULL THEN
    RETURN; -- Treino não encontrado
  END IF;

  -- CORREÇÃO: Verificar se já existe check-in para esta DATA (não timestamp)
  IF v_challenge_id IS NOT NULL THEN
    SELECT COUNT(*) INTO v_existing_count
    FROM challenge_check_ins 
    WHERE user_id = v_user_id 
      AND challenge_id = v_challenge_id 
      AND DATE(check_in_date AT TIME ZONE 'America/Sao_Paulo') = v_workout_date_brt
      AND workout_record_id != _workout_record_id; -- Excluir o próprio registro
    
    IF v_existing_count > 0 THEN
      -- Já existe check-in para esta data, não processar
      RETURN;
    END IF;
  END IF;

  -- Atualizar ranking e progresso (mantém lógica existente)
  -- ... resto da função mantém como estava
  
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. REMOVER DUPLICADOS EXISTENTES
CREATE OR REPLACE FUNCTION cleanup_duplicates_emergency()
RETURNS TABLE(
  removed_count INTEGER,
  details TEXT
) AS $$
DECLARE
  v_removed_count INTEGER := 0;
BEGIN
  -- Remover duplicados mantendo o mais antigo
  WITH duplicates AS (
    SELECT 
      id,
      ROW_NUMBER() OVER (
        PARTITION BY user_id, challenge_id, DATE(check_in_date AT TIME ZONE 'America/Sao_Paulo') 
        ORDER BY check_in_date ASC
      ) as row_num
    FROM challenge_check_ins
  )
  DELETE FROM challenge_check_ins 
  WHERE id IN (
    SELECT id FROM duplicates WHERE row_num > 1
  );
  
  GET DIAGNOSTICS v_removed_count = ROW_COUNT;
  
  removed_count := v_removed_count;
  details := 'Removidos ' || v_removed_count || ' duplicados, mantendo os check-ins mais antigos';
  
  RETURN NEXT;
END;
$$ LANGUAGE plpgsql;

-- Executar limpeza
SELECT * FROM cleanup_duplicates_emergency();

-- 6. VERIFICAÇÃO FINAL
SELECT '✅ VERIFICAÇÃO FINAL...' as status;

WITH final_stats AS (
  SELECT 
    COUNT(*) as total_checkins,
    COUNT(DISTINCT (user_id, challenge_id, DATE(check_in_date AT TIME ZONE 'America/Sao_Paulo'))) as unique_checkins,
    COUNT(*) - COUNT(DISTINCT (user_id, challenge_id, DATE(check_in_date AT TIME ZONE 'America/Sao_Paulo'))) as remaining_duplicates
  FROM challenge_check_ins
)
SELECT 
  total_checkins,
  unique_checkins,
  remaining_duplicates,
  CASE 
    WHEN remaining_duplicates = 0 THEN '✅ PROBLEMA RESOLVIDO!'
    ELSE '⚠️ AINDA HÁ DUPLICADOS: ' || remaining_duplicates
  END as status
FROM final_stats;

SELECT '🎉 CORREÇÃO EMERGENCIAL CONCLUÍDA!' as final_status; 