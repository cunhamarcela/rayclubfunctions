-- Script para criar índices para otimizar consultas de desafios no Supabase

-- Índice para consultas de desafios ativos
CREATE INDEX IF NOT EXISTS idx_challenge_active ON challenges (active);

-- Índice para organizar desafios por data de início e fim
CREATE INDEX IF NOT EXISTS idx_challenge_dates ON challenges (start_date, end_date);

-- Índice composto para participantes de desafios (útil para filtrar por usuário e desafio)
CREATE INDEX IF NOT EXISTS idx_user_challenges ON challenge_participants (user_id, challenge_id);

-- Índice para otimizar consultas de progress por usuário e desafio
CREATE INDEX IF NOT EXISTS idx_challenge_progress_user ON challenge_progress (user_id, challenge_id);

-- Índice para otimizar ordenação no ranking de progresso
CREATE INDEX IF NOT EXISTS idx_challenge_progress_points ON challenge_progress (challenge_id, points DESC);

-- Índice para otimizar consultas de check-ins por data
CREATE INDEX IF NOT EXISTS idx_challenge_checkins_date ON challenge_check_ins (challenge_id, user_id, check_in_date);

-- Índice para otimizar consultas de grupos por criador
CREATE INDEX IF NOT EXISTS idx_challenge_groups_creator ON challenge_groups (creator_id);

-- Índice para otimizar consultas de convites por destinatário
CREATE INDEX IF NOT EXISTS idx_challenge_group_invites ON challenge_group_invites (invitee_id, status);

-- Comentários sobre a escolha dos índices:
--
-- 1. idx_challenge_active: Permite filtrar rapidamente desafios ativos/inativos
-- 2. idx_challenge_dates: Otimiza consultas por período (ex: desafios atuais)
-- 3. idx_user_challenges: Acelera a busca por desafios de um usuário específico
-- 4. idx_challenge_progress_user: Otimiza a busca do progresso de um usuário em um desafio
-- 5. idx_challenge_progress_points: Acelera o ordenamento por pontos ao gerar rankings
-- 6. idx_challenge_checkins_date: Otimiza consultas de check-ins por data
-- 7. idx_challenge_groups_creator: Acelera a busca de grupos criados por um usuário
-- 8. idx_challenge_group_invites: Otimiza a busca de convites pendentes para um usuário 