-- Script para verificar e garantir que as regras de processamento estejam corretas

-- Confirmar a lógica correta nas funções

-- 1. Verificar implementação da função record_challenge_check_in_v2
SELECT prosrc FROM pg_proc WHERE proname = 'record_challenge_check_in_v2' LIMIT 1;

-- 2. Verificar implementação da função process_workout_for_dashboard
SELECT prosrc FROM pg_proc WHERE proname = 'process_workout_for_dashboard' LIMIT 1;

-- 3. Verificar implementação da função process_workout_for_ranking
SELECT prosrc FROM pg_proc WHERE proname = 'process_workout_for_ranking' LIMIT 1;

-- 4. Verificar se a regra de 45 minutos está apenas no ranking e não no dashboard
-- (Esta verificação será manual baseada nos resultados acima)

-- 5. Verificar treinos sem desafio
SELECT COUNT(*) as no_challenge FROM workout_records WHERE challenge_id IS NULL;
SELECT COUNT(*) as with_challenge FROM workout_records WHERE challenge_id IS NOT NULL;

-- 6. Verificar treinos não processados para dashboard
SELECT COUNT(*) as not_processed_dashboard FROM workout_processing_queue WHERE NOT processed_for_dashboard;

-- 7. Listar os possíveis erros para ajuste manual
SELECT 
    processing_error, 
    COUNT(*) 
FROM 
    workout_processing_queue 
WHERE 
    processing_error IS NOT NULL
GROUP BY 
    processing_error;

-- 8. IMPORTANTE: Documentar regras em SQL para consulta futura
COMMENT ON FUNCTION process_workout_for_ranking IS 
'Processa um treino para o ranking de desafios.
REGRAS:
1. Só processa treinos com desafio associado
2. Requer duração mínima de 45 minutos
3. Verifica se usuário participa do desafio
4. Não permite check-ins duplicados para mesma data';

COMMENT ON FUNCTION process_workout_for_dashboard IS 
'Processa um treino para o dashboard do usuário.
REGRAS:
1. Processa TODOS os treinos independente da duração
2. Atualiza pontos, contagem de treinos e outras estatísticas
3. Não possui regra de tempo mínimo';

COMMENT ON FUNCTION record_challenge_check_in_v2 IS
'Função wrapper que mantém compatibilidade com sistema anterior.
Comportamento:
1. Registra o treino básico
2. Enfileira para processamento no ranking e dashboard
3. Tenta associar automaticamente a um desafio ativo se nenhum foi especificado';

-- 9. Verificar se há alguma consulta travada
SELECT 
    pid, 
    now() - pg_stat_activity.query_start AS duration, 
    query 
FROM 
    pg_stat_activity 
WHERE 
    state = 'active' AND 
    now() - pg_stat_activity.query_start > interval '5 minutes'
ORDER BY 
    duration DESC; 