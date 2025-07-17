-- Tabela para armazenar informações de desafios
CREATE TABLE IF NOT EXISTS challenges (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  description TEXT,
  image_url TEXT,
  start_date TIMESTAMP WITH TIME ZONE NOT NULL,
  end_date TIMESTAMP WITH TIME ZONE NOT NULL,
  type TEXT,
  points INTEGER DEFAULT 0,
  requirements JSONB DEFAULT '{}'::JSONB,
  participants INTEGER DEFAULT 0,
  active BOOLEAN DEFAULT TRUE,
  creator_id UUID REFERENCES auth.users(id),
  is_official BOOLEAN DEFAULT FALSE,
  invited_users TEXT[] DEFAULT '{}'::TEXT[],
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL
);

-- Índices para melhorar a performance de consultas comuns
CREATE INDEX IF NOT EXISTS challenges_creator_id_idx ON challenges(creator_id);
CREATE INDEX IF NOT EXISTS challenges_start_date_idx ON challenges(start_date);
CREATE INDEX IF NOT EXISTS challenges_end_date_idx ON challenges(end_date);
CREATE INDEX IF NOT EXISTS challenges_is_official_idx ON challenges(is_official);

-- Trigger para atualizar o campo updated_at automaticamente
CREATE OR REPLACE FUNCTION update_challenges_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_challenges_updated_at ON challenges;
CREATE TRIGGER trigger_challenges_updated_at
BEFORE UPDATE ON challenges
FOR EACH ROW
EXECUTE FUNCTION update_challenges_updated_at();

-- Trigger para limitar desafios oficiais a um por vez
CREATE OR REPLACE FUNCTION check_official_challenge()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.is_official = TRUE THEN
    -- Se está marcando como oficial, desativa outros desafios oficiais
    UPDATE challenges
    SET is_official = FALSE
    WHERE id != NEW.id AND is_official = TRUE;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_check_official_challenge ON challenges;
CREATE TRIGGER trigger_check_official_challenge
BEFORE INSERT OR UPDATE OF is_official ON challenges
FOR EACH ROW
WHEN (NEW.is_official = TRUE)
EXECUTE FUNCTION check_official_challenge();

-- Políticas de segurança em nível de linha (RLS)
-- Habilitar RLS na tabela
ALTER TABLE challenges ENABLE ROW LEVEL SECURITY;

-- Políticas para usuários comuns
-- Qualquer usuário pode ver desafios
CREATE POLICY challenges_select_policy ON challenges
  FOR SELECT
  USING (true);

-- Apenas criadores podem modificar seus desafios
CREATE POLICY challenges_insert_policy ON challenges
  FOR INSERT
  WITH CHECK (creator_id = auth.uid());

CREATE POLICY challenges_update_policy ON challenges
  FOR UPDATE
  USING (creator_id = auth.uid())
  WITH CHECK (creator_id = auth.uid());

CREATE POLICY challenges_delete_policy ON challenges
  FOR DELETE
  USING (creator_id = auth.uid());

-- Políticas para administradores (via claims ou role)
-- Administradores podem gerenciar todos os desafios
CREATE POLICY challenges_admin_all_policy ON challenges
  FOR ALL
  USING (
    (SELECT role FROM profiles WHERE id = auth.uid()) = 'admin'
  );

-- Tabela para armazenar convites para desafios
CREATE TABLE IF NOT EXISTS challenge_invites (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  challenge_id UUID NOT NULL REFERENCES challenges(id) ON DELETE CASCADE,
  challenge_title TEXT NOT NULL,
  inviter_id UUID NOT NULL REFERENCES auth.users(id),
  inviter_name TEXT NOT NULL,
  invitee_id UUID NOT NULL REFERENCES auth.users(id),
  status INTEGER DEFAULT 0, -- 0: pending, 1: accepted, 2: declined
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  responded_at TIMESTAMP WITH TIME ZONE
);

-- Índices para convites
CREATE INDEX IF NOT EXISTS challenge_invites_challenge_id_idx ON challenge_invites(challenge_id);
CREATE INDEX IF NOT EXISTS challenge_invites_invitee_id_idx ON challenge_invites(invitee_id);
CREATE INDEX IF NOT EXISTS challenge_invites_status_idx ON challenge_invites(status);

-- Habilitar RLS para convites
ALTER TABLE challenge_invites ENABLE ROW LEVEL SECURITY;

-- Políticas para convites
CREATE POLICY challenge_invites_select_policy ON challenge_invites
  FOR SELECT
  USING (inviter_id = auth.uid() OR invitee_id = auth.uid());

CREATE POLICY challenge_invites_insert_policy ON challenge_invites
  FOR INSERT
  WITH CHECK (inviter_id = auth.uid());

CREATE POLICY challenge_invites_update_policy ON challenge_invites
  FOR UPDATE
  USING (invitee_id = auth.uid() OR inviter_id = auth.uid());

-- Tabela para progresso em desafios
CREATE TABLE IF NOT EXISTS challenge_progress (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  challenge_id UUID NOT NULL REFERENCES challenges(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  user_name TEXT NOT NULL,
  user_photo_url TEXT,
  points INTEGER DEFAULT 0,
  position INTEGER DEFAULT 0,
  completion_percentage DECIMAL(5,2) DEFAULT 0,
  last_updated TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  UNIQUE(challenge_id, user_id)
);

-- Índices para progresso
CREATE INDEX IF NOT EXISTS challenge_progress_challenge_id_idx ON challenge_progress(challenge_id);
CREATE INDEX IF NOT EXISTS challenge_progress_user_id_idx ON challenge_progress(user_id);
CREATE INDEX IF NOT EXISTS challenge_progress_points_idx ON challenge_progress(points);

-- Habilitar RLS para progresso
ALTER TABLE challenge_progress ENABLE ROW LEVEL SECURITY;

-- Políticas para progresso
CREATE POLICY challenge_progress_select_policy ON challenge_progress
  FOR SELECT
  USING (true);

CREATE POLICY challenge_progress_insert_policy ON challenge_progress
  FOR INSERT
  WITH CHECK (user_id = auth.uid());

CREATE POLICY challenge_progress_update_policy ON challenge_progress
  FOR UPDATE
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- Tabela para registrar check-ins diários (usado no desafio da Ray)
CREATE TABLE IF NOT EXISTS challenge_check_ins (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  challenge_id UUID NOT NULL REFERENCES challenges(id) ON DELETE CASCADE,
  check_in_date TIMESTAMP WITH TIME ZONE NOT NULL,
  points INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  UNIQUE(user_id, challenge_id, check_in_date)
);

-- Índices para check-ins
CREATE INDEX IF NOT EXISTS challenge_check_ins_user_challenge_idx 
  ON challenge_check_ins(user_id, challenge_id);
CREATE INDEX IF NOT EXISTS challenge_check_ins_date_idx 
  ON challenge_check_ins(check_in_date);

-- Habilitar RLS para check-ins
ALTER TABLE challenge_check_ins ENABLE ROW LEVEL SECURITY;

-- Políticas para check-ins
CREATE POLICY challenge_check_ins_select_policy ON challenge_check_ins
  FOR SELECT
  USING (true);

CREATE POLICY challenge_check_ins_insert_policy ON challenge_check_ins
  FOR INSERT
  WITH CHECK (user_id = auth.uid());

-- Tabela para registrar bônus (como streaks de 7 dias)
CREATE TABLE IF NOT EXISTS challenge_bonuses (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  challenge_id UUID NOT NULL REFERENCES challenges(id) ON DELETE CASCADE,
  bonus_points INTEGER NOT NULL DEFAULT 0,
  reason TEXT NOT NULL,
  awarded_at TIMESTAMP WITH TIME ZONE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL
);

-- Índices para bônus
CREATE INDEX IF NOT EXISTS challenge_bonuses_user_challenge_idx 
  ON challenge_bonuses(user_id, challenge_id);

-- Habilitar RLS para bônus
ALTER TABLE challenge_bonuses ENABLE ROW LEVEL SECURITY;

-- Políticas para bônus
CREATE POLICY challenge_bonuses_select_policy ON challenge_bonuses
  FOR SELECT
  USING (user_id = auth.uid() OR 
         (SELECT role FROM profiles WHERE id = auth.uid()) = 'admin');

CREATE POLICY challenge_bonuses_insert_policy ON challenge_bonuses
  FOR INSERT
  WITH CHECK ((SELECT role FROM profiles WHERE id = auth.uid()) = 'admin');

-- Inserir desafio oficial da Ray (exemplo)
INSERT INTO challenges (
  title, 
  description, 
  image_url,
  start_date, 
  end_date, 
  type, 
  points,
  requirements,
  is_official,
  creator_id
) VALUES (
  'Desafio Ray 21 Dias', 
  'Complete treinos por 21 dias consecutivos e transforme seu corpo e sua mente com o desafio oficial da Ray.',
  'https://ray-challenges.s3.amazonaws.com/ray_21_days.jpg',
  CURRENT_DATE, 
  CURRENT_DATE + INTERVAL '21 days', 
  'official', 
  1000,
  '{"min_checkins": 21, "daily_points": 10, "streak_bonus": 50}',
  true,
  (SELECT id FROM profiles WHERE role = 'admin' LIMIT 1)
) ON CONFLICT DO NOTHING; 