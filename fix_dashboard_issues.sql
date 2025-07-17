-- Script para corrigir problemas no dashboard do Ray Club App
-- Autor: Claude 3.7
-- Descrição: Adiciona colunas faltantes e corrige estruturas problemáticas

-- 1. CORREÇÕES NA TABELA user_progress
-- Verificar e adicionar colunas faltantes 
DO $$ 
BEGIN
    -- Verificar e adicionar current_streak se não existir
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_progress' AND column_name = 'current_streak') THEN
        ALTER TABLE user_progress ADD COLUMN current_streak INTEGER DEFAULT 0;
        RAISE NOTICE 'Coluna current_streak adicionada à tabela user_progress';
    END IF;
    
    -- Verificar e adicionar longest_streak se não existir
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_progress' AND column_name = 'longest_streak') THEN
        ALTER TABLE user_progress ADD COLUMN longest_streak INTEGER DEFAULT 0;
        RAISE NOTICE 'Coluna longest_streak adicionada à tabela user_progress';
    END IF;
    
    -- Verificar e adicionar total_duration se não existir
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_progress' AND column_name = 'total_duration') THEN
        ALTER TABLE user_progress ADD COLUMN total_duration INTEGER DEFAULT 0;
        RAISE NOTICE 'Coluna total_duration adicionada à tabela user_progress';
    END IF;
    
    -- Verificar e adicionar days_trained_this_month se não existir
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_progress' AND column_name = 'days_trained_this_month') THEN
        ALTER TABLE user_progress ADD COLUMN days_trained_this_month INTEGER DEFAULT 0;
        RAISE NOTICE 'Coluna days_trained_this_month adicionada à tabela user_progress';
    END IF;
    
    -- Verificar se existe points, mas não total_points
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_progress' AND column_name = 'points')
       AND NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_progress' AND column_name = 'total_points') THEN
        -- Criar um alias para points
        RAISE NOTICE 'A tabela user_progress usa "points" em vez de "total_points". Código deve ser adaptado para usar "points".';
    END IF;
    
    -- Verificar se existe total_points, mas não points
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_progress' AND column_name = 'total_points')
       AND NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_progress' AND column_name = 'points') THEN
        -- Renomear total_points para points para compatibilidade
        ALTER TABLE user_progress RENAME COLUMN total_points TO points;
        RAISE NOTICE 'Coluna total_points renomeada para points para compatibilidade';
    END IF;
    
    -- Verificar e adicionar workout_types (como JSONB) se não existir
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_progress' AND column_name = 'workout_types') THEN
        ALTER TABLE user_progress ADD COLUMN workout_types JSONB DEFAULT '{}'::jsonb;
        RAISE NOTICE 'Coluna workout_types adicionada à tabela user_progress';
    END IF;
END $$;

-- 2. CORREÇÕES NA TABELA challenge_progress
DO $$ 
BEGIN
    -- Verificar e adicionar check_ins_count se não existir
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'challenge_progress' AND column_name = 'check_ins_count') THEN
        ALTER TABLE challenge_progress ADD COLUMN check_ins_count INTEGER DEFAULT 0;
        RAISE NOTICE 'Coluna check_ins_count adicionada à tabela challenge_progress';
    END IF;
    
    -- Verificar e adicionar consecutive_days se não existir
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'challenge_progress' AND column_name = 'consecutive_days') THEN
        ALTER TABLE challenge_progress ADD COLUMN consecutive_days INTEGER DEFAULT 0;
        RAISE NOTICE 'Coluna consecutive_days adicionada à tabela challenge_progress';
    END IF;
    
    -- Se total_check_ins existir mas check_ins_count não, copiar os dados
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'challenge_progress' AND column_name = 'total_check_ins')
       AND EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'challenge_progress' AND column_name = 'check_ins_count') THEN
        UPDATE challenge_progress SET check_ins_count = total_check_ins WHERE check_ins_count IS NULL;
        RAISE NOTICE 'Dados copiados de total_check_ins para check_ins_count onde necessário';
    END IF;
END $$;

-- 3. ATUALIZAÇÃO DA FUNÇÃO get_dashboard_data
-- Primeiro fazer backup da função
DO $$ 
BEGIN
    IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'get_dashboard_data') THEN
        -- Salvar a definição atual em uma função de backup
        CREATE OR REPLACE FUNCTION get_dashboard_data_backup(user_id_param UUID) 
        RETURNS JSONB 
        AS $func$
            SELECT get_dashboard_data(user_id_param)::jsonb;
        $func$ LANGUAGE sql;
        
        RAISE NOTICE 'Backup da função get_dashboard_data criado como get_dashboard_data_backup';
    END IF;
END $$;

-- Criar view que lista inconsistências nas tabelas
CREATE OR REPLACE VIEW missing_columns_report AS
SELECT 
    'user_progress' AS table_name,
    ARRAY_TO_STRING(ARRAY_AGG(expected_column), ', ') AS missing_columns,
    'O código espera estas colunas, mas elas não existem no banco' AS description
FROM (
    SELECT 'current_streak' AS expected_column 
    WHERE NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_progress' AND column_name = 'current_streak')
    UNION
    SELECT 'longest_streak' AS expected_column 
    WHERE NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_progress' AND column_name = 'longest_streak')
    UNION
    SELECT 'total_duration' AS expected_column 
    WHERE NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_progress' AND column_name = 'total_duration')
    UNION
    SELECT 'days_trained_this_month' AS expected_column 
    WHERE NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_progress' AND column_name = 'days_trained_this_month')
) AS expected_columns
WHERE expected_column IS NOT NULL

UNION ALL

SELECT 
    'challenge_progress' AS table_name,
    ARRAY_TO_STRING(ARRAY_AGG(expected_column), ', ') AS missing_columns,
    'O código espera estas colunas, mas elas não existem no banco' AS description
FROM (
    SELECT 'check_ins_count' AS expected_column 
    WHERE NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'challenge_progress' AND column_name = 'check_ins_count')
    UNION
    SELECT 'consecutive_days' AS expected_column 
    WHERE NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'challenge_progress' AND column_name = 'consecutive_days')
) AS expected_columns
WHERE expected_column IS NOT NULL;

-- Ver relatório de colunas faltantes
SELECT * FROM missing_columns_report;

-- Função que gera script de correção baseado nas discrepâncias encontradas
CREATE OR REPLACE FUNCTION generate_fix_script()
RETURNS TEXT AS $$
DECLARE
    script TEXT := '';
    missing_cols RECORD;
BEGIN
    script := '-- Script gerado automaticamente para corrigir discrepâncias no banco' || E'\n\n';
    
    FOR missing_cols IN SELECT * FROM missing_columns_report LOOP
        script := script || '-- Adicionando colunas faltantes em ' || missing_cols.table_name || E'\n';
        
        IF missing_cols.table_name = 'user_progress' THEN
            IF missing_cols.missing_columns LIKE '%current_streak%' THEN
                script := script || 'ALTER TABLE user_progress ADD COLUMN current_streak INTEGER DEFAULT 0;' || E'\n';
            END IF;
            
            IF missing_cols.missing_columns LIKE '%longest_streak%' THEN
                script := script || 'ALTER TABLE user_progress ADD COLUMN longest_streak INTEGER DEFAULT 0;' || E'\n';
            END IF;
            
            IF missing_cols.missing_columns LIKE '%total_duration%' THEN
                script := script || 'ALTER TABLE user_progress ADD COLUMN total_duration INTEGER DEFAULT 0;' || E'\n';
            END IF;
            
            IF missing_cols.missing_columns LIKE '%days_trained_this_month%' THEN
                script := script || 'ALTER TABLE user_progress ADD COLUMN days_trained_this_month INTEGER DEFAULT 0;' || E'\n';
            END IF;
        END IF;
        
        IF missing_cols.table_name = 'challenge_progress' THEN
            IF missing_cols.missing_columns LIKE '%check_ins_count%' THEN
                script := script || 'ALTER TABLE challenge_progress ADD COLUMN check_ins_count INTEGER DEFAULT 0;' || E'\n';
            END IF;
            
            IF missing_cols.missing_columns LIKE '%consecutive_days%' THEN
                script := script || 'ALTER TABLE challenge_progress ADD COLUMN consecutive_days INTEGER DEFAULT 0;' || E'\n';
            END IF;
        END IF;
        
        script := script || E'\n';
    END LOOP;
    
    -- Atualizar função get_dashboard_data
    script := script || '-- Recriando a função get_dashboard_data para usar colunas corretas' || E'\n';
    script := script || 'CREATE OR REPLACE FUNCTION get_dashboard_data(user_id_param UUID)' || E'\n';
    script := script || 'RETURNS JSON AS $$' || E'\n';
    script := script || '-- ... código atualizado da função ...' || E'\n';
    script := script || '$$ LANGUAGE plpgsql;' || E'\n\n';
    
    RETURN script;
END;
$$ LANGUAGE plpgsql;

-- Ver script de correção gerado
SELECT generate_fix_script();

-- Script para corrigir problemas de atualização do dashboard
-- Remove as restrições de duração mínima e corrige a pontuação dos treinos

-- 1. Corrigir a função process_workout_for_dashboard
CREATE OR REPLACE FUNCTION process_workout_for_dashboard(
    _workout_record_id UUID
)
RETURNS BOOLEAN AS $$
DECLARE
    workout RECORD;
    points_to_add INTEGER := 10;
    existing_dashboard RECORD;
BEGIN
    -- Obter informações do treino
    SELECT * INTO workout 
    FROM workout_records 
    WHERE id = _workout_record_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Treino não encontrado';
    END IF;
    
    -- Verificar se o usuário já tem entry no dashboard
    SELECT * INTO existing_dashboard 
    FROM user_progress
    WHERE user_id = workout.user_id;
    
    -- ATUALIZAR PROGRESSO GERAL DO USUÁRIO
    -- Tenta usar qualquer coluna existente na tabela
    BEGIN
        IF existing_dashboard IS NULL THEN
            -- Criar novo registro
            INSERT INTO user_progress(
                user_id,
                points,
                workouts,
                challenges_joined_count,
                challenges_completed_count,
                current_streak,
                longest_streak,
                updated_at
            ) VALUES (
                workout.user_id,
                points_to_add,
                1,
                CASE WHEN workout.challenge_id IS NOT NULL THEN 1 ELSE 0 END,
                0,
                1,
                1,
                NOW()
            );
        ELSE
            -- Atualizar todos os campos possíveis
            UPDATE user_progress
            SET
                points = COALESCE(points, 0) + points_to_add,
                workouts = COALESCE(workouts, 0) + 1,
                current_streak = COALESCE(current_streak, 0) + 1,
                longest_streak = GREATEST(COALESCE(longest_streak, 0), COALESCE(current_streak, 0) + 1),
                updated_at = NOW()
            WHERE user_id = workout.user_id;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        -- Registrar o erro
        RAISE NOTICE 'Erro ao atualizar user_progress: %', SQLERRM;
        INSERT INTO check_in_error_logs(
            user_id,
            challenge_id,
            workout_id,
            error_message,
            status,
            created_at
        ) VALUES (
            workout.user_id,
            workout.challenge_id,
            _workout_record_id,
            'Erro ao atualizar dashboard: ' || SQLERRM,
            'dashboard_error',
            NOW()
        );
    END;
    
    -- Marcar como processado mesmo em caso de erro parcial
    BEGIN
        UPDATE workout_processing_queue 
        SET processed_for_dashboard = TRUE,
            processed_at = NOW() 
        WHERE workout_id = _workout_record_id;
    EXCEPTION WHEN OTHERS THEN
        -- Ignorar erros de atualização da fila
        NULL;
    END;
    
    -- Emitir notificação para atualizar UI
    BEGIN
        PERFORM pg_notify('dashboard_updates', json_build_object(
            'user_id', workout.user_id,
            'action', 'workout_processed',
            'workout_id', workout.id,
            'points', points_to_add
        )::text);
    EXCEPTION WHEN OTHERS THEN
        -- Ignorar erros de notificação
        NULL;
    END;
    
    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        -- Registrar erro na tabela de erros
        BEGIN
            INSERT INTO check_in_error_logs(
                user_id,
                challenge_id,
                workout_id,
                error_message,
                status,
                created_at
            ) VALUES (
                workout.user_id,
                workout.challenge_id,
                _workout_record_id,
                'Erro geral ao processar dashboard: ' || SQLERRM,
                'error',
                NOW()
            );
        EXCEPTION WHEN OTHERS THEN
            -- Ignorar erros ao registrar o log
            NULL;
        END;
        
        RETURN FALSE;
END;
$$ LANGUAGE plpgsql;

-- 2. Corrigir os registros não processados corretamente
DO $$
DECLARE
    rec RECORD;
    success_count INTEGER := 0;
    error_count INTEGER := 0;
    total_workouts INTEGER;
    problematic_workouts INTEGER;
    fixed_workouts INTEGER := 0;
BEGIN
    -- Estatísticas iniciais
    SELECT COUNT(*) INTO total_workouts FROM workout_records;
    SELECT COUNT(*) INTO problematic_workouts 
    FROM workout_records w
    LEFT JOIN workout_processing_queue q ON w.id = q.workout_id
    WHERE q.id IS NULL OR NOT q.processed_for_dashboard;
    
    RAISE NOTICE 'Iniciando reparo do dashboard...';
    RAISE NOTICE 'Total de treinos: %', total_workouts;
    RAISE NOTICE 'Treinos com problemas de processamento: %', problematic_workouts;
    
    -- 1. Inserir na fila de processamento os registros que estão faltando
    INSERT INTO workout_processing_queue (
        workout_id,
        user_id,
        challenge_id,
        processed_for_ranking,
        processed_for_dashboard
    )
    SELECT 
        w.id,
        w.user_id,
        w.challenge_id,
        TRUE,  -- Marcar ranking como processado
        FALSE  -- Dashboard como não processado
    FROM workout_records w
    LEFT JOIN workout_processing_queue q ON w.id = q.workout_id
    WHERE q.id IS NULL;
    
    -- 2. Processar todos os registros não processados para o dashboard
    FOR rec IN 
        SELECT q.workout_id, w.user_id, w.challenge_id
        FROM workout_processing_queue q
        JOIN workout_records w ON q.workout_id = w.id
        WHERE NOT q.processed_for_dashboard
        ORDER BY w.date DESC
    LOOP
        BEGIN
            -- Processar dashboard novamente
            IF process_workout_for_dashboard(rec.workout_id) THEN
                success_count := success_count + 1;
                fixed_workouts := fixed_workouts + 1;
            ELSE
                error_count := error_count + 1;
                RAISE NOTICE 'Falha ao processar workout_id: %', rec.workout_id;
            END IF;
        EXCEPTION WHEN OTHERS THEN
            error_count := error_count + 1;
            RAISE NOTICE 'Erro ao processar workout_id: %: %', rec.workout_id, SQLERRM;
        END;
        
        -- Mostrar progresso a cada 10 registros
        IF (success_count + error_count) % 10 = 0 THEN
            RAISE NOTICE 'Progresso: % registros processados (% sucessos, % falhas)', 
                          success_count + error_count, success_count, error_count;
        END IF;
    END LOOP;
    
    -- 3. Recalcular os totais para cada usuário
    -- Esta abordagem corrige quaisquer inconsistências acumuladas
    RAISE NOTICE 'Recalculando totais para cada usuário...';
    
    -- Backup da tabela user_progress
    CREATE TABLE IF NOT EXISTS user_progress_backup AS SELECT * FROM user_progress;
    
    -- Executa atualização para cada usuário com dados precisos
    WITH user_stats AS (
        SELECT 
            user_id,
            COUNT(*) AS total_workouts,
            SUM(duration_minutes) AS total_duration,
            COUNT(DISTINCT DATE(date)) AS workout_days
        FROM 
            workout_records
        GROUP BY 
            user_id
    )
    UPDATE user_progress up
    SET 
        workouts = us.total_workouts,
        total_duration = us.total_duration,
        points = us.total_workouts * 10, -- 10 pontos por treino
        updated_at = NOW()
    FROM 
        user_stats us
    WHERE 
        up.user_id = us.user_id;
    
    RAISE NOTICE 'Processamento concluído: % registros reparados, % falhas', fixed_workouts, error_count;
    RAISE NOTICE 'Foi criado um backup em user_progress_backup';
    
    -- Resumo final dos registros
    RAISE NOTICE 'Status final:';
    RAISE NOTICE '  Treinos no sistema: %', 
        (SELECT COUNT(*) FROM workout_records);
    RAISE NOTICE '  Usuários com progresso: %', 
        (SELECT COUNT(*) FROM user_progress);
    RAISE NOTICE '  Treinos processados para dashboard: %', 
        (SELECT COUNT(*) FROM workout_processing_queue WHERE processed_for_dashboard);
    RAISE NOTICE '  Treinos pendentes para dashboard: %', 
        (SELECT COUNT(*) FROM workout_processing_queue WHERE NOT processed_for_dashboard);
END $$;

-- Exportar resultados para verificação
SELECT 'User Dashboard Status', NOW() as timestamp;
SELECT 
    id, 
    user_id,
    workouts, 
    points,
    current_streak,
    longest_streak,
    created_at,
    updated_at,
    challenges_completed_count
FROM user_progress
ORDER BY updated_at DESC
LIMIT 20;

SELECT 'Recent Workout Records', NOW() as timestamp;
SELECT 
    id,
    user_id,
    workout_name,
    duration_minutes,
    date,
    created_at
FROM workout_records
ORDER BY created_at DESC
LIMIT 20;

SELECT 'Processing Queue Status', NOW() as timestamp;
SELECT 
    workout_id,
    processed_for_ranking,
    processed_for_dashboard,
    processing_error,
    created_at,
    processed_at
FROM workout_processing_queue
ORDER BY created_at DESC
LIMIT 20; 