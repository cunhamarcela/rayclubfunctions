-- Tabela de desafios
CREATE TABLE challenges (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  description TEXT,
  image_url TEXT,
  start_date TIMESTAMP WITH TIME ZONE NOT NULL,
  end_date TIMESTAMP WITH TIME ZONE NOT NULL,
  is_official BOOLEAN DEFAULT FALSE,
  created_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de participantes dos desafios
CREATE TABLE challenge_participants (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  challenge_id UUID NOT NULL REFERENCES challenges(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id),
  joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  status TEXT DEFAULT 'active', -- active, completed, dropped
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(challenge_id, user_id)
);

-- Tabela de convites para desafios
CREATE TABLE challenge_invites (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  challenge_id UUID NOT NULL REFERENCES challenges(id) ON DELETE CASCADE,
  inviter_id UUID NOT NULL REFERENCES auth.users(id),
  invitee_id UUID NOT NULL REFERENCES auth.users(id),
  status TEXT DEFAULT 'pending', -- pending, accepted, rejected
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(challenge_id, invitee_id)
);

-- Tabela de metas dos desafios
CREATE TABLE challenge_goals (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  challenge_id UUID NOT NULL REFERENCES challenges(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  type TEXT NOT NULL, -- workout, steps, distance, etc.
  target_value FLOAT NOT NULL,
  unit TEXT, -- km, steps, minutes, etc.
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de progresso dos participantes nas metas
CREATE TABLE challenge_progress (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  challenge_id UUID NOT NULL REFERENCES challenges(id) ON DELETE CASCADE,
  goal_id UUID REFERENCES challenge_goals(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id),
  current_value FLOAT DEFAULT 0,
  last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(challenge_id, goal_id, user_id)
);

-- Segurança RLS
ALTER TABLE challenges ENABLE ROW LEVEL SECURITY;
ALTER TABLE challenge_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE challenge_invites ENABLE ROW LEVEL SECURITY;
ALTER TABLE challenge_goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE challenge_progress ENABLE ROW LEVEL SECURITY;

-- Políticas para desafios
CREATE POLICY "Desafios públicos são visíveis para usuários autenticados"
  ON challenges FOR SELECT
  TO authenticated
  USING (
    is_official = true OR
    created_by = auth.uid() OR
    EXISTS (
      SELECT 1 FROM challenge_participants
      WHERE challenge_participants.challenge_id = challenges.id
      AND challenge_participants.user_id = auth.uid()
    ) OR
    EXISTS (
      SELECT 1 FROM challenge_invites
      WHERE challenge_invites.challenge_id = challenges.id
      AND challenge_invites.invitee_id = auth.uid()
    )
  );

CREATE POLICY "Usuários podem criar desafios"
  ON challenges FOR INSERT
  TO authenticated
  WITH CHECK (created_by = auth.uid());

CREATE POLICY "Usuários podem atualizar seus próprios desafios"
  ON challenges FOR UPDATE
  TO authenticated
  USING (created_by = auth.uid());

-- Políticas para participantes
CREATE POLICY "Participantes são visíveis para membros do desafio"
  ON challenge_participants FOR SELECT
  TO authenticated
  USING (
    user_id = auth.uid() OR
    EXISTS (
      SELECT 1 FROM challenge_participants cp
      WHERE cp.challenge_id = challenge_participants.challenge_id
      AND cp.user_id = auth.uid()
    ) OR
    EXISTS (
      SELECT 1 FROM challenges
      WHERE challenges.id = challenge_participants.challenge_id
      AND challenges.created_by = auth.uid()
    )
  );

CREATE POLICY "Usuários podem participar de desafios"
  ON challenge_participants FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

-- Políticas para convites
CREATE POLICY "Usuários podem ver seus convites"
  ON challenge_invites FOR SELECT
  TO authenticated
  USING (
    inviter_id = auth.uid() OR
    invitee_id = auth.uid()
  );

CREATE POLICY "Usuários podem enviar convites"
  ON challenge_invites FOR INSERT
  TO authenticated
  WITH CHECK (inviter_id = auth.uid());

CREATE POLICY "Usuários podem responder seus convites"
  ON challenge_invites FOR UPDATE
  TO authenticated
  USING (invitee_id = auth.uid());

-- Políticas para metas
CREATE POLICY "Metas são visíveis para membros do desafio"
  ON challenge_goals FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM challenge_participants
      WHERE challenge_participants.challenge_id = challenge_goals.challenge_id
      AND challenge_participants.user_id = auth.uid()
    ) OR
    EXISTS (
      SELECT 1 FROM challenges
      WHERE challenges.id = challenge_goals.challenge_id
      AND challenges.created_by = auth.uid()
    )
  );

-- Políticas para progresso
CREATE POLICY "Usuários podem ver progresso dos participantes"
  ON challenge_progress FOR SELECT
  TO authenticated
  USING (
    user_id = auth.uid() OR
    EXISTS (
      SELECT 1 FROM challenge_participants
      WHERE challenge_participants.challenge_id = challenge_progress.challenge_id
      AND challenge_participants.user_id = auth.uid()
    ) OR
    EXISTS (
      SELECT 1 FROM challenges
      WHERE challenges.id = challenge_progress.challenge_id
      AND challenges.created_by = auth.uid()
    )
  );

CREATE POLICY "Usuários podem atualizar seu próprio progresso"
  ON challenge_progress FOR ALL
  TO authenticated
  USING (user_id = auth.uid());

-- Trigger para atualizar o updated_at automaticamente
CREATE TRIGGER update_challenges_updated_at
BEFORE UPDATE ON challenges
FOR EACH ROW
EXECUTE FUNCTION update_modified_column();

CREATE TRIGGER update_challenge_invites_updated_at
BEFORE UPDATE ON challenge_invites
FOR EACH ROW
EXECUTE FUNCTION update_modified_column();

-- Índices para melhor performance
CREATE INDEX idx_challenge_dates ON challenges(start_date, end_date);
CREATE INDEX idx_challenge_is_official ON challenges(is_official);
CREATE INDEX idx_challenge_participants_challenge ON challenge_participants(challenge_id);
CREATE INDEX idx_challenge_participants_user ON challenge_participants(user_id);
CREATE INDEX idx_challenge_invites_challenge ON challenge_invites(challenge_id);
CREATE INDEX idx_challenge_invites_invitee ON challenge_invites(invitee_id);
CREATE INDEX idx_challenge_progress_user ON challenge_progress(user_id);
CREATE INDEX idx_challenge_progress_challenge ON challenge_progress(challenge_id); 