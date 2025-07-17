-- Script para diagnóstico de transações e bloqueios no banco de dados

-- 1. Visualizar transações ativas
SELECT txid_current() as current_transaction_id;

-- 2. Visualizar todas as transações ativas
SELECT 
    pid,
    usename,
    application_name,
    client_addr,
    backend_start,
    xact_start,
    query_start,
    state,
    state_change,
    wait_event_type,
    wait_event,
    backend_xid,
    backend_xmin,
    query
FROM 
    pg_stat_activity
WHERE 
    state = 'active'
    AND pid <> pg_backend_pid()
ORDER BY 
    xact_start;

-- 3. Verificar bloqueios
SELECT 
    blocked_locks.pid AS blocked_pid,
    blocked_activity.usename AS blocked_user,
    blocking_locks.pid AS blocking_pid,
    blocking_activity.usename AS blocking_user,
    blocked_activity.query AS blocked_statement,
    blocking_activity.query AS blocking_statement
FROM 
    pg_catalog.pg_locks blocked_locks
JOIN 
    pg_catalog.pg_stat_activity blocked_activity ON blocked_activity.pid = blocked_locks.pid
JOIN 
    pg_catalog.pg_locks blocking_locks ON blocking_locks.locktype = blocked_locks.locktype
    AND blocking_locks.DATABASE IS NOT DISTINCT FROM blocked_locks.DATABASE
    AND blocking_locks.relation IS NOT DISTINCT FROM blocked_locks.relation
    AND blocking_locks.page IS NOT DISTINCT FROM blocked_locks.page
    AND blocking_locks.tuple IS NOT DISTINCT FROM blocked_locks.tuple
    AND blocking_locks.virtualxid IS NOT DISTINCT FROM blocked_locks.virtualxid
    AND blocking_locks.transactionid IS NOT DISTINCT FROM blocked_locks.transactionid
    AND blocking_locks.classid IS NOT DISTINCT FROM blocked_locks.classid
    AND blocking_locks.objid IS NOT DISTINCT FROM blocked_locks.objid
    AND blocking_locks.objsubid IS NOT DISTINCT FROM blocked_locks.objsubid
    AND blocking_locks.pid != blocked_locks.pid
JOIN 
    pg_catalog.pg_stat_activity blocking_activity ON blocking_activity.pid = blocking_locks.pid
WHERE 
    NOT blocked_locks.GRANTED;

-- 4. Verificar deadlocks (se houver suporte PG_STAT_STATEMENTS)
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM pg_extension WHERE extname = 'pg_stat_statements'
    ) THEN
        EXECUTE 'SELECT * FROM pg_stat_statements WHERE query LIKE ''%deadlock%'' OR query LIKE ''%lock%'' LIMIT 10';
    ELSE
        RAISE NOTICE 'Extensão pg_stat_statements não está disponível. Não é possível verificar estatísticas de deadlocks.';
    END IF;
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Erro ao verificar deadlocks: %', SQLERRM;
END $$;

-- 5. Verificar estatísticas específicas de record_challenge_check_in_v2
SELECT 
    routine_name, 
    routine_definition
FROM 
    information_schema.routines
WHERE 
    routine_name = 'record_challenge_check_in_v2'
    AND routine_type = 'FUNCTION';

-- 6. Verificar tabelas relacionadas ao processo de conclusão de desafio
SELECT 
    table_name, 
    (SELECT count(*) FROM information_schema.columns WHERE table_name = t.table_name) as column_count
FROM 
    information_schema.tables t
WHERE 
    table_name IN ('challenge_participants', 'workout_records', 'challenges', 'workouts')
    AND table_schema = 'public'
ORDER BY 
    table_name; 