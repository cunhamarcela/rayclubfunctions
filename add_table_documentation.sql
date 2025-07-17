-- Script para adicionar documentação às tabelas sobre a arquitetura atual
-- Execute este script no SQL Editor do Supabase para evitar confusões futuras

-- Documentar tabela challenge_check_ins
COMMENT ON TABLE challenge_check_ins IS 'Registros de check-in em desafios. IMPORTANTE: A atualização do progresso é feita diretamente pela função record_challenge_check_in, não por triggers nesta tabela.';

-- Documentar tabela challenge_progress
COMMENT ON TABLE challenge_progress IS 'Progresso dos usuários em desafios. IMPORTANTE: Esta tabela é atualizada diretamente pela função record_challenge_check_in, não por triggers.';

-- Documentar tabela workout_records
COMMENT ON TABLE workout_records IS 'Registros de treinos dos usuários. Esta tabela contém o challenge_id para associar o treino diretamente a um desafio específico.';

-- Documentar função record_challenge_check_in
COMMENT ON FUNCTION record_challenge_check_in(uuid, timestamp with time zone, integer, uuid, text, text, text, integer) IS 'Função principal para registrar check-ins em desafios. Esta função é responsável por (1) registrar o treino, (2) inserir o check-in, (3) atualizar o progresso e (4) atualizar o ranking.';

-- Opcional: Adicionar um comentário em outra versão da função se existir
-- COMMENT ON FUNCTION record_challenge_check_in(uuid, uuid, text, text, text, integer, text) IS 'Versão alternativa da função para registrar check-ins. Ver documentação principal para detalhes.'; 