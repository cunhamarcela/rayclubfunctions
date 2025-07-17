-- Tabela para grupos de desafio
CREATE TABLE challenge_groups (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  challenge_id UUID NOT NULL REFERENCES challenges(id) ON DELETE CASCADE,
  creator_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  member_ids UUID[] NOT NULL DEFAULT '{}',
  pending_invite_ids UUID[] NOT NULL DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Tabela para convites de grupo
CREATE TABLE challenge_group_invites (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  group_id UUID NOT NULL REFERENCES challenge_groups(id) ON DELETE CASCADE,
  group_name TEXT NOT NULL,
  inviter_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  inviter_name TEXT NOT NULL,
  invitee_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  status INTEGER NOT NULL DEFAULT 0, -- 0: pending, 1: accepted, 2: declined
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  responded_at TIMESTAMP WITH TIME ZONE
);

-- Índices para melhorar a performance de consultas comuns
CREATE INDEX idx_challenge_groups_challenge_id ON challenge_groups(challenge_id);
CREATE INDEX idx_challenge_groups_creator_id ON challenge_groups(creator_id);
CREATE INDEX idx_challenge_group_invites_group_id ON challenge_group_invites(group_id);
CREATE INDEX idx_challenge_group_invites_invitee_id ON challenge_group_invites(invitee_id);
CREATE INDEX idx_challenge_group_invites_status ON challenge_group_invites(status);

-- Políticas de segurança (RLS)
ALTER TABLE challenge_groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE challenge_group_invites ENABLE ROW LEVEL SECURITY;

-- Políticas para challenge_groups
-- Qualquer pessoa pode visualizar grupos
CREATE POLICY "Qualquer pessoa pode visualizar grupos" 
ON challenge_groups FOR SELECT USING (true);

-- Apenas usuários autenticados podem criar grupos
CREATE POLICY "Apenas usuários autenticados podem criar grupos" 
ON challenge_groups FOR INSERT 
TO authenticated 
WITH CHECK (creator_id = auth.uid());

-- Apenas o criador pode atualizar o grupo
CREATE POLICY "Apenas o criador pode atualizar o grupo" 
ON challenge_groups FOR UPDATE 
TO authenticated 
USING (creator_id = auth.uid());

-- Apenas o criador pode excluir o grupo
CREATE POLICY "Apenas o criador pode excluir o grupo" 
ON challenge_groups FOR DELETE 
TO authenticated 
USING (creator_id = auth.uid());

-- Políticas para challenge_group_invites
-- Qualquer pessoa pode visualizar convites
CREATE POLICY "Qualquer pessoa pode visualizar convites" 
ON challenge_group_invites FOR SELECT USING (true);

-- Apenas usuários autenticados podem criar convites
CREATE POLICY "Apenas usuários autenticados podem criar convites" 
ON challenge_group_invites FOR INSERT 
TO authenticated 
WITH CHECK (inviter_id = auth.uid());

-- Convidador ou convidado podem atualizar o convite
CREATE POLICY "Convidador ou convidado podem atualizar o convite" 
ON challenge_group_invites FOR UPDATE 
TO authenticated 
USING (inviter_id = auth.uid() OR invitee_id = auth.uid());

-- Convidador ou convidado podem excluir o convite
CREATE POLICY "Convidador ou convidado podem excluir o convite" 
ON challenge_group_invites FOR DELETE 
TO authenticated 
USING (inviter_id = auth.uid() OR invitee_id = auth.uid());

-- Trigger para atualizar o timestamp de updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_challenge_groups_updated_at
BEFORE UPDATE ON challenge_groups
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Função para obter o ranking de um grupo
CREATE OR REPLACE FUNCTION get_group_ranking(group_id UUID)
RETURNS SETOF challenge_progress AS $$
DECLARE
  group_record challenge_groups;
  challenge_id UUID;
BEGIN
  -- Buscar o grupo e o desafio associado
  SELECT * INTO group_record FROM challenge_groups
  WHERE id = group_id;
  
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Grupo não encontrado';
  END IF;
  
  challenge_id := group_record.challenge_id;
  
  -- Retornar apenas o progresso dos membros do grupo
  RETURN QUERY
  SELECT cp.*
  FROM challenge_progress cp
  WHERE cp.challenge_id = challenge_id
  AND cp.user_id = ANY(group_record.member_ids)
  ORDER BY cp.points DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER; 