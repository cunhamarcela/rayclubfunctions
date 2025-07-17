-- Script para diagnosticar inconsistência entre treinos e check-ins

-- 1. Verificar treinos da Marcela
SELECT 
    'TREINOS MARCELA' as tipo,
    wr.id,
    wr.workout_name,
    wr.workout_type,
    wr.duration_minutes,
    wr.date,
    wr.challenge_id,
    wr.created_at
FROM workout_records wr
JOIN profiles p ON p.id = wr.user_id
WHERE p.name ILIKE '%marcela%'
ORDER BY wr.date DESC;

-- 2. Verificar check-ins da Marcela
SELECT 
    'CHECK-INS MARCELA' as tipo,
    cci.id,
    cci.challenge_id,
    cci.check_in_date,
    cci.workout_id,
    cci.workout_name,
    cci.workout_type,
    cci.duration_minutes,
    cci.points,
    cci.created_at
FROM challenge_check_ins cci
JOIN profiles p ON p.id = cci.user_id
WHERE p.name ILIKE '%marcela%'
ORDER BY cci.check_in_date DESC;

-- 3. Verificar progresso da Marcela nos desafios
SELECT 
    'PROGRESSO MARCELA' as tipo,
    cp.challenge_id,
    cp.points,
    cp.check_ins_count,
    cp.total_check_ins,
    cp.completion_percentage,
    cp.position,
    cp.last_check_in
FROM challenge_progress cp
JOIN profiles p ON p.id = cp.user_id
WHERE p.name ILIKE '%marcela%';

-- 4. Verificar treinos da Yolanda
SELECT 
    'TREINOS YOLANDA' as tipo,
    wr.id,
    wr.workout_name,
    wr.workout_type,
    wr.duration_minutes,
    wr.date,
    wr.challenge_id,
    wr.created_at
FROM workout_records wr
JOIN profiles p ON p.id = wr.user_id
WHERE p.name ILIKE '%yolanda%'
ORDER BY wr.date DESC;

-- 5. Verificar check-ins da Yolanda
SELECT 
    'CHECK-INS YOLANDA' as tipo,
    cci.id,
    cci.challenge_id,
    cci.check_in_date,
    cci.workout_id,
    cci.workout_name,
    cci.workout_type,
    cci.duration_minutes,
    cci.points,
    cci.created_at
FROM challenge_check_ins cci
JOIN profiles p ON p.id = cci.user_id
WHERE p.name ILIKE '%yolanda%'
ORDER BY cci.check_in_date DESC;

-- 6. Verificar progresso da Yolanda nos desafios
SELECT 
    'PROGRESSO YOLANDA' as tipo,
    cp.challenge_id,
    cp.points,
    cp.check_ins_count,
    cp.total_check_ins,
    cp.completion_percentage,
    cp.position,
    cp.last_check_in
FROM challenge_progress cp
JOIN profiles p ON p.id = cp.user_id
WHERE p.name ILIKE '%yolanda%';

-- 7. Verificar logs de erro para ambas
SELECT 
    'LOGS ERRO' as tipo,
    cel.user_id,
    p.name,
    cel.challenge_id,
    cel.workout_id,
    cel.error_message,
    cel.status,
    cel.created_at
FROM check_in_error_logs cel
JOIN profiles p ON p.id = cel.user_id
WHERE p.name ILIKE '%marcela%' OR p.name ILIKE '%yolanda%'
ORDER BY cel.created_at DESC;

-- 8. Verificar duplicações por data
SELECT 
    'DUPLICACOES POR DATA' as tipo,
    p.name,
    cci.challenge_id,
    DATE(cci.check_in_date) as data_checkin,
    COUNT(*) as quantidade_checkins
FROM challenge_check_ins cci
JOIN profiles p ON p.id = cci.user_id
WHERE p.name ILIKE '%marcela%' OR p.name ILIKE '%yolanda%'
GROUP BY p.name, cci.challenge_id, DATE(cci.check_in_date)
HAVING COUNT(*) > 1
ORDER BY p.name, data_checkin; 