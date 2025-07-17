# Guia de Implementação - Sistema Split de Registro de Treinos

Este guia apresenta os passos para implementar o novo sistema split de registro de treinos com foco em eficiência, consistência e velocidade de implementação.

## Fase 1: Preparação do Banco de Dados (30-45 minutos)

### 1.1. Criar tabelas de tracking

```sql
-- Execute no SQL Editor do Supabase

-- Tabela de fila de processamento
CREATE TABLE IF NOT EXISTS workout_processing_queue (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workout_id UUID NOT NULL REFERENCES workout_records(id) ON DELETE CASCADE,
    user_id UUID NOT NULL,
    challenge_id UUID,
    processed_for_ranking BOOLEAN DEFAULT FALSE,
    processed_for_dashboard BOOLEAN DEFAULT FALSE,
    processing_error TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    processed_at TIMESTAMP WITH TIME ZONE
);

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_workout_queue_processing 
ON workout_processing_queue(processed_for_ranking, processed_for_dashboard);

CREATE INDEX IF NOT EXISTS idx_workout_queue_workout_id
ON workout_processing_queue(workout_id);

-- Se a tabela check_in_error_logs ainda não existir, criar:
CREATE TABLE IF NOT EXISTS check_in_error_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    challenge_id UUID,
    workout_id UUID,
    request_data JSONB,
    response_data JSONB,
    error_message TEXT,
    error_detail TEXT,
    status TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_checkin_error_logs_user
ON check_in_error_logs(user_id);

CREATE INDEX IF NOT EXISTS idx_checkin_error_logs_date
ON check_in_error_logs(created_at);
```

## Fase 2: Implementação das Funções Core (1-1.5 horas)

### 2.1. Criar função de registro básico

```sql
CREATE OR REPLACE FUNCTION record_workout_basic(
    _user_id UUID,
    _workout_name TEXT,
    _workout_type TEXT,
    _duration_minutes INTEGER,
    _date TIMESTAMP WITH TIME ZONE,
    _challenge_id UUID DEFAULT NULL,
    _workout_id TEXT DEFAULT NULL
)
RETURNS JSONB AS $$
DECLARE
    result JSONB;
    workout_record_id UUID;
    v_workout_id UUID;
BEGIN
    -- Verificar se usuário existe e está ativo (verificação recomendada)
    IF NOT EXISTS (
        SELECT 1 FROM profiles 
        WHERE id = _user_id
        FOR SHARE
    ) THEN
        RAISE EXCEPTION 'Usuário não encontrado ou inativo';
    END IF;
    
    -- Converter workout_id para UUID ou gerar novo UUID
    BEGIN
        v_workout_id := _workout_id::UUID;
    EXCEPTION WHEN OTHERS THEN
        v_workout_id := gen_random_uuid();
    END;
    
    -- REGISTRAR O TREINO (SEMPRE)
    INSERT INTO workout_records(
        user_id,
        challenge_id,
        workout_id,
        workout_name,
        workout_type,
        date,
        duration_minutes,
        points,
        created_at
    ) VALUES (
        _user_id,
        _challenge_id,
        v_workout_id,
        _workout_name,
        _workout_type,
        _date,
        _duration_minutes,
        10, -- Pontos básicos
        NOW()
    ) RETURNING id INTO workout_record_id;
    
    -- Agendar processamento assíncrono
    INSERT INTO workout_processing_queue(
        workout_id,
        user_id,
        challenge_id,
        processed_for_ranking,
        processed_for_dashboard
    ) VALUES (
        workout_record_id,
        _user_id,
        _challenge_id,
        FALSE,
        FALSE
    );
    
    -- Notificar sistema de processamento assíncrono
    PERFORM pg_notify('workout_processing', json_build_object(
        'workout_id', workout_record_id,
        'user_id', _user_id,
        'challenge_id', _challenge_id
    )::text);
    
    result := jsonb_build_object(
        'success', TRUE,
        'message', 'Treino registrado com sucesso',
        'workout_id', workout_record_id,
        'processing_queued', TRUE
    );
    
    RETURN result;
EXCEPTION
    WHEN OTHERS THEN
        -- Registrar erro na tabela de erros
        INSERT INTO check_in_error_logs(
            user_id,
            challenge_id,
            workout_id,
            request_data,
            error_message,
            status,
            created_at
        ) VALUES (
            _user_id,
            _challenge_id,
            NULL,
            jsonb_build_object(
                'workout_name', _workout_name,
                'workout_type', _workout_type,
                'duration_minutes', _duration_minutes,
                'date', _date
            ),
            SQLERRM,
            'error',
            NOW()
        );
        
        RETURN jsonb_build_object(
            'success', FALSE,
            'message', 'Erro ao registrar treino: ' || SQLERRM
        );
END;
$$ LANGUAGE plpgsql;
```

### 2.2. Criar função de processamento de ranking

```sql
CREATE OR REPLACE FUNCTION process_workout_for_ranking(
    _workout_record_id UUID
)
RETURNS BOOLEAN AS $$
DECLARE
    workout RECORD;
    challenge_record RECORD;
    user_name TEXT;
    user_photo_url TEXT;
    already_has_checkin BOOLEAN := FALSE;
    points_to_add INTEGER := 10;
    check_in_id UUID;
    challenge_target_points INTEGER;
    check_ins_count INTEGER := 0;
    error_info JSONB;
BEGIN
    -- Obter informações do treino
    SELECT * INTO workout 
    FROM workout_records 
    WHERE id = _workout_record_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Treino não encontrado';
    END IF;
    
    -- Verificações básicas
    IF workout.challenge_id IS NULL THEN
        -- Sem desafio associado, marcar como processado e sair
        UPDATE workout_processing_queue 
        SET processed_for_ranking = TRUE,
            processed_at = NOW() 
        WHERE workout_id = _workout_record_id;
        RETURN FALSE;
    END IF;
    
    -- VERIFICAÇÕES INICIAIS
    SELECT * INTO challenge_record 
    FROM challenges 
    WHERE id = workout.challenge_id 
    FOR UPDATE SKIP LOCKED; -- Otimização para alta concorrência
    
    IF NOT FOUND THEN
        UPDATE workout_processing_queue 
        SET processed_for_ranking = TRUE,
            processing_error = 'Desafio não encontrado',
            processed_at = NOW() 
        WHERE workout_id = _workout_record_id;
        
        -- Registrar erro na tabela de erros
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
            'Desafio não encontrado: ' || workout.challenge_id,
            'error',
            NOW()
        );
        
        RETURN FALSE;
    END IF;
    
    -- Obter a meta de pontos do desafio para cálculo de porcentagem
    challenge_target_points := challenge_record.points;
    
    -- Verificar se o usuário é membro do desafio
    IF NOT EXISTS (
        SELECT 1 FROM challenge_participants 
        WHERE challenge_id = workout.challenge_id 
        AND user_id = workout.user_id
    ) THEN
        UPDATE workout_processing_queue 
        SET processed_for_ranking = TRUE,
            processing_error = 'Usuário não participa deste desafio',
            processed_at = NOW() 
        WHERE workout_id = _workout_record_id;
        
        -- Registrar erro na tabela de erros
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
            'Usuário não participa deste desafio',
            'error',
            NOW()
        );
        
        RETURN FALSE;
    END IF;
    
    -- Verificar duração mínima
    IF workout.duration_minutes < 45 THEN
        UPDATE workout_processing_queue 
        SET processed_for_ranking = TRUE,
            processing_error = 'Duração mínima não atingida (45min)',
            processed_at = NOW() 
        WHERE workout_id = _workout_record_id;
        
        -- Registrar como "skipped" na tabela de erros
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
            'Duração mínima não atingida: ' || workout.duration_minutes || 'min',
            'skipped',
            NOW()
        );
        
        RETURN FALSE;
    END IF;
    
    -- Verificar se já existe check-in para esta data
    SELECT EXISTS (
        SELECT 1 
        FROM challenge_check_ins 
        WHERE user_id = workout.user_id 
        AND challenge_id = workout.challenge_id
        AND DATE(check_in_date) = DATE(workout.date)
    ) INTO already_has_checkin;
    
    IF already_has_checkin THEN
        UPDATE workout_processing_queue 
        SET processed_for_ranking = TRUE,
            processing_error = 'Check-in já existe para esta data',
            processed_at = NOW() 
        WHERE workout_id = _workout_record_id;
        
        -- Registrar como "duplicate" na tabela de erros
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
            'Check-in já existe para a data: ' || workout.date,
            'duplicate',
            NOW()
        );
        
        RETURN FALSE;
    END IF;
    
    -- OBTER INFORMAÇÕES DO USUÁRIO
    SELECT 
        COALESCE(name, 'Usuário') AS name,
        photo_url
    INTO 
        user_name, user_photo_url
    FROM profiles 
    WHERE id = workout.user_id;
    
    -- CRIAR CHECK-IN PARA O DESAFIO
    INSERT INTO challenge_check_ins(
        id,
        challenge_id,
        user_id,
        check_in_date,
        workout_id,
        points_earned,
        created_at
    ) VALUES (
        gen_random_uuid(),
        workout.challenge_id,
        workout.user_id,
        workout.date,
        workout.workout_id,
        points_to_add,
        NOW()
    ) RETURNING id INTO check_in_id;
    
    -- ATUALIZAR PROGRESSO DO DESAFIO
    SELECT COUNT(*) INTO check_ins_count
    FROM challenge_check_ins
    WHERE challenge_id = workout.challenge_id
    AND user_id = workout.user_id;
    
    -- Atualizar ou criar registro de progresso
    INSERT INTO challenge_progress(
        challenge_id,
        user_id,
        points_earned,
        check_ins_count,
        last_check_in,
        completion_percentage,
        created_at,
        updated_at,
        user_name,
        user_photo
    ) VALUES (
        workout.challenge_id,
        workout.user_id,
        points_to_add,
        1,
        workout.date,
        (points_to_add::FLOAT / challenge_target_points::FLOAT) * 100.0,
        NOW(),
        NOW(),
        user_name,
        user_photo_url
    )
    ON CONFLICT (challenge_id, user_id) 
    DO UPDATE SET
        points_earned = challenge_progress.points_earned + points_to_add,
        check_ins_count = challenge_progress.check_ins_count + 1,
        last_check_in = workout.date,
        completion_percentage = ((challenge_progress.points_earned + points_to_add)::FLOAT / challenge_target_points::FLOAT) * 100.0,
        updated_at = NOW(),
        user_name = EXCLUDED.user_name,
        user_photo = EXCLUDED.user_photo;
    
    -- Marcar como processado
    UPDATE workout_processing_queue 
    SET processed_for_ranking = TRUE,
        processed_at = NOW() 
    WHERE workout_id = _workout_record_id;
    
    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        -- Registrar erro na tabela de erros
        INSERT INTO check_in_error_logs(
            user_id,
            challenge_id,
            workout_id,
            error_message,
            error_detail,
            status,
            created_at
        ) VALUES (
            workout.user_id,
            workout.challenge_id,
            _workout_record_id,
            SQLERRM,
            SQLSTATE || ' | ' || pg_exception_context(),
            'error',
            NOW()
        );
        
        RETURN FALSE;
END;
$$ LANGUAGE plpgsql;
```

### 2.3. Criar função de processamento de dashboard

```sql
CREATE OR REPLACE FUNCTION process_workout_for_dashboard(
    _workout_record_id UUID
)
RETURNS BOOLEAN AS $$
DECLARE
    workout RECORD;
    points_to_add INTEGER := 10;
BEGIN
    -- Obter informações do treino
    SELECT * INTO workout 
    FROM workout_records 
    WHERE id = _workout_record_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Treino não encontrado';
    END IF;
    
    -- ATUALIZAR PROGRESSO GERAL DO USUÁRIO (reutilizando código existente)
    INSERT INTO user_progress(
        user_id,
        challenge_points,
        challenges_joined_count,
        challenges_completed_count,
        updated_at
    ) VALUES (
        workout.user_id,
        points_to_add,
        1,
        0,
        NOW()
    ) 
    ON CONFLICT (user_id) 
    DO UPDATE SET
        challenge_points = user_progress.challenge_points + points_to_add,
        challenges_joined_count = user_progress.challenges_joined_count,
        challenges_completed_count = user_progress.challenges_completed_count,
        updated_at = NOW();
    
    -- Marcar como processado
    UPDATE workout_processing_queue 
    SET processed_for_dashboard = TRUE,
        processed_at = NOW() 
    WHERE workout_id = _workout_record_id;
    
    -- Emitir notificação para atualizar UI
    PERFORM pg_notify('dashboard_updates', json_build_object(
        'user_id', workout.user_id,
        'action', 'workout_processed',
        'workout_id', workout.id,
        'points', points_to_add
    )::text);
    
    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        -- Registrar erro na tabela de erros
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
            'Erro ao processar dashboard: ' || SQLERRM,
            'error',
            NOW()
        );
        
        RETURN FALSE;
END;
$$ LANGUAGE plpgsql;
```

## Fase 3: Manter Compatibilidade (30 minutos)

### 3.1. Criar função wrapper para compatibilidade

```sql
CREATE OR REPLACE FUNCTION record_challenge_check_in_v2(
    _challenge_id uuid, 
    _date timestamp with time zone, 
    _duration_minutes integer, 
    _user_id uuid, 
    _workout_id text, 
    _workout_name text, 
    _workout_type text
)
RETURNS jsonb AS $$
DECLARE
    result JSONB;
    workout_record_id UUID;
BEGIN
    -- Chamar função de registro básico
    result := record_workout_basic(
        _user_id,
        _workout_name,
        _workout_type,
        _duration_minutes,
        _date,
        _challenge_id,
        _workout_id
    );
    
    -- Se registrou com sucesso, processa imediatamente para compatibilidade
    IF (result->>'success')::BOOLEAN THEN
        workout_record_id := (result->>'workout_id')::UUID;
        
        -- Processar para ranking e dashboard de forma síncrona
        -- para manter a compatibilidade com o comportamento atual
        PERFORM process_workout_for_ranking(workout_record_id);
        PERFORM process_workout_for_dashboard(workout_record_id);
        
        -- Atualizar resultado para refletir processamento completo
        result := jsonb_build_object(
            'success', TRUE,
            'message', 'Check-in registrado com sucesso',
            'challenge_id', _challenge_id,
            'workout_id', _workout_id,
            'points_earned', 10,
            'is_already_checked_in', FALSE
        );
    END IF;
    
    RETURN result;
EXCEPTION
    WHEN OTHERS THEN
        -- Registrar erro na tabela de erros
        INSERT INTO check_in_error_logs(
            user_id,
            challenge_id,
            workout_id,
            request_data,
            error_message,
            status,
            created_at
        ) VALUES (
            _user_id,
            _challenge_id,
            NULL,
            jsonb_build_object(
                'workout_name', _workout_name,
                'workout_type', _workout_type,
                'duration_minutes', _duration_minutes,
                'date', _date
            ),
            'Erro wrapper: ' || SQLERRM,
            'error',
            NOW()
        );
        
        RETURN jsonb_build_object(
            'success', FALSE,
            'message', 'Erro ao registrar check-in: ' || SQLERRM,
            'is_already_checked_in', FALSE,
            'points_earned', 0,
            'streak', 0
        );
END;
$$ LANGUAGE plpgsql;
```

## Fase 4: Criação de Função de Recuperação (30 minutos)

### 4.1. Implementar função para recuperação de registros

```sql
CREATE OR REPLACE FUNCTION diagnose_and_recover_workout_records(
    days_back INTEGER DEFAULT 7
)
RETURNS JSONB AS $$
DECLARE
    result JSONB;
    missing_count INTEGER := 0;
    recovered_count INTEGER := 0;
    failed_count INTEGER := 0;
    error_records RECORD;
    workout_id UUID;
BEGIN
    -- 1. Identificar treinos que falharam no processamento de ranking
    FOR error_records IN 
        SELECT 
            q.workout_id, 
            q.user_id, 
            q.challenge_id,
            q.processing_error
        FROM workout_processing_queue q
        WHERE 
            (q.processed_for_ranking = FALSE OR q.processed_for_dashboard = FALSE)
            AND q.created_at > NOW() - (days_back || ' days')::INTERVAL
    LOOP
        -- 2. Tentar reprocessar cada registro
        BEGIN
            IF NOT error_records.processed_for_ranking THEN
                PERFORM process_workout_for_ranking(error_records.workout_id);
            END IF;
            
            IF NOT error_records.processed_for_dashboard THEN
                PERFORM process_workout_for_dashboard(error_records.workout_id);
            END IF;
            
            recovered_count := recovered_count + 1;
        EXCEPTION
            WHEN OTHERS THEN
                failed_count := failed_count + 1;
        END;
    END LOOP;
    
    -- 3. Verificar treinos registrados mas sem entrada na fila de processamento
    FOR workout_id IN 
        SELECT w.id 
        FROM workout_records w
        LEFT JOIN workout_processing_queue q ON w.id = q.workout_id
        WHERE 
            q.workout_id IS NULL
            AND w.created_at > NOW() - (days_back || ' days')::INTERVAL
    LOOP
        missing_count := missing_count + 1;
        
        -- Criar entrada na fila de processamento
        INSERT INTO workout_processing_queue(
            workout_id,
            user_id,
            challenge_id,
            processed_for_ranking,
            processed_for_dashboard
        )
        SELECT 
            id, 
            user_id, 
            challenge_id,
            FALSE,
            FALSE
        FROM workout_records 
        WHERE id = workout_id;
    END LOOP;
    
    -- 4. Preparar relatório
    result := jsonb_build_object(
        'period', days_back || ' days',
        'recovered_count', recovered_count,
        'missing_count', missing_count,
        'failed_count', failed_count,
        'timestamp', NOW()
    );
    
    RETURN result;
END;
$$ LANGUAGE plpgsql;
```

## Fase 5: Teste e Backup (30-45 minutos)

### 5.1. Teste de segurança

Antes de considerar a migração concluída, execute os seguintes testes:

1. **Teste de registro básico**:
```sql
SELECT record_workout_basic(
    '_user_id_teste_'::UUID, 
    'Treino Teste', 
    'Corrida', 
    50, 
    NOW(), 
    '_challenge_id_teste_'::UUID
);
```

2. **Teste de recuperação**:
```sql
SELECT diagnose_and_recover_workout_records(1);
```

3. **Verificação de logs**:
```sql
SELECT * FROM check_in_error_logs ORDER BY created_at DESC LIMIT 10;
SELECT * FROM workout_processing_queue WHERE processed_for_ranking = FALSE OR processed_for_dashboard = FALSE;
```

### 5.2. Criar backup da função original

```sql
CREATE OR REPLACE FUNCTION record_challenge_check_in_v2_backup(
    _challenge_id uuid, 
    _date timestamp with time zone, 
    _duration_minutes integer, 
    _user_id uuid, 
    _workout_id text, 
    _workout_name text, 
    _workout_type text
)
RETURNS jsonb AS $$
BEGIN
    -- Copiar corpo da função original aqui
    -- ...
END;
$$ LANGUAGE plpgsql;
```

## Fase 6: Implementar Agendamento de Manutenção (Opcional, 15 minutos)

```sql
-- Tabela para controle de tarefas periódicas
CREATE TABLE IF NOT EXISTS system_scheduled_tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    task_name TEXT NOT NULL,
    last_run TIMESTAMP WITH TIME ZONE,
    next_run TIMESTAMP WITH TIME ZONE NOT NULL,
    status TEXT DEFAULT 'pending',
    result JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Função para executar tarefas periódicas
CREATE OR REPLACE FUNCTION run_scheduled_maintenance()
RETURNS JSONB AS $$
DECLARE
    result JSONB;
    recovery_result JSONB;
    task_id UUID;
BEGIN
    -- Inserir registro de tarefa
    INSERT INTO system_scheduled_tasks(
        task_name,
        next_run,
        status
    ) VALUES (
        'workout_maintenance',
        NOW() + INTERVAL '1 day',
        'running'
    ) RETURNING id INTO task_id;
    
    -- Executar diagnóstico e recuperação
    recovery_result := diagnose_and_recover_workout_records(7);
    
    -- Atualizar status da tarefa
    UPDATE system_scheduled_tasks SET
        status = 'completed',
        last_run = NOW(),
        result = recovery_result
    WHERE id = task_id;
    
    result := jsonb_build_object(
        'task_id', task_id,
        'recovery', recovery_result,
        'status', 'completed'
    );
    
    RETURN result;
END;
$$ LANGUAGE plpgsql;
```

## Fase 7: Monitoramento Inicial (Obrigatório, 5-10 minutos)

Após a implementação, monitore o sistema:

1. Verifique os primeiros registros:
```sql
SELECT * FROM workout_processing_queue ORDER BY created_at DESC LIMIT 10;
```

2. Verifique erros processados:
```sql
SELECT status, COUNT(*) FROM check_in_error_logs 
WHERE created_at > NOW() - INTERVAL '1 hour'
GROUP BY status;
```

## Considerações Finais

1. **Plano de rollback**: Em caso de problemas, use a função de backup:
```sql
-- Renomear nova função
ALTER FUNCTION record_challenge_check_in_v2 RENAME TO record_challenge_check_in_v2_new;
-- Restaurar backup
ALTER FUNCTION record_challenge_check_in_v2_backup RENAME TO record_challenge_check_in_v2;
```

2. **Monitoramento contínuo**: Configure alertas para:
   - Registros não processados após 5 minutos
   - Taxa de erros > 1% dos registros

3. **Acompanhamento**: Após 24h, execute diagnóstico completo:
```sql
SELECT diagnose_and_recover_workout_records(1);
``` 