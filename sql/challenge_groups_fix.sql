-- Script para criar tabelas de grupos de desafios

-- Tabela para armazenar grupos
CREATE TABLE IF NOT EXISTS challenge_groups (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT,
  creator_id UUID NOT NULL REFERENCES auth.users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela para armazenar membros dos grupos
CREATE TABLE IF NOT EXISTS challenge_group_members (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  group_id UUID NOT NULL REFERENCES challenge_groups(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id),
  joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(group_id, user_id)
);

-- Tabela para armazenar convites para grupos
CREATE TABLE IF NOT EXISTS challenge_group_invites (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  group_id UUID NOT NULL REFERENCES challenge_groups(id) ON DELETE CASCADE,
  group_name TEXT NOT NULL,
  inviter_id UUID NOT NULL REFERENCES auth.users(id),
  inviter_name TEXT NOT NULL,
  invitee_id UUID NOT NULL REFERENCES auth.users(id),
  status SMALLINT DEFAULT 0, -- 0: pendente, 1: aceito, 2: rejeitado
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  responded_at TIMESTAMP WITH TIME ZONE,
  UNIQUE(group_id, invitee_id)
);

-- Configuração de políticas de segurança (RLS)
ALTER TABLE challenge_groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE challenge_group_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE challenge_group_invites ENABLE ROW LEVEL SECURITY;

-- Políticas para challenge_groups
CREATE POLICY "Qualquer usuário autenticado pode visualizar grupos" ON challenge_groups
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "Criadores podem inserir grupos" ON challenge_groups
  FOR INSERT TO authenticated WITH CHECK (creator_id = auth.uid());

CREATE POLICY "Criadores podem atualizar seus grupos" ON challenge_groups
  FOR UPDATE TO authenticated USING (creator_id = auth.uid());

CREATE POLICY "Criadores podem excluir seus grupos" ON challenge_groups
  FOR DELETE TO authenticated USING (creator_id = auth.uid());

-- Políticas para challenge_group_members
CREATE POLICY "Membros e criadores podem ver membros do grupo" ON challenge_group_members
  FOR SELECT TO authenticated USING (
    user_id = auth.uid() OR
    EXISTS (
      SELECT 1 FROM challenge_group_members WHERE group_id = challenge_group_members.group_id AND user_id = auth.uid()
    ) OR
    EXISTS (
      SELECT 1 FROM challenge_groups WHERE id = challenge_group_members.group_id AND creator_id = auth.uid()
    )
  );

CREATE POLICY "Usuários podem se adicionar a grupos" ON challenge_group_members
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());

CREATE POLICY "Criadores podem adicionar membros" ON challenge_group_members
  FOR INSERT TO authenticated WITH CHECK (
    EXISTS (
      SELECT 1 FROM challenge_groups WHERE id = challenge_group_members.group_id AND creator_id = auth.uid()
    )
  );

CREATE POLICY "Usuários podem sair de grupos" ON challenge_group_members
  FOR DELETE TO authenticated USING (user_id = auth.uid());

CREATE POLICY "Criadores podem remover membros" ON challenge_group_members
  FOR DELETE TO authenticated USING (
    EXISTS (
      SELECT 1 FROM challenge_groups WHERE id = challenge_group_members.group_id AND creator_id = auth.uid()
    )
  );

-- Políticas para challenge_group_invites
CREATE POLICY "Envolvidos podem ver convites" ON challenge_group_invites
  FOR SELECT TO authenticated USING (
    inviter_id = auth.uid() OR invitee_id = auth.uid() OR
    EXISTS (
      SELECT 1 FROM challenge_groups WHERE id = challenge_group_invites.group_id AND creator_id = auth.uid()
    )
  );

CREATE POLICY "Membros do grupo podem enviar convites" ON challenge_group_invites
  FOR INSERT TO authenticated WITH CHECK (
    inviter_id = auth.uid() AND (
      EXISTS (
        SELECT 1 FROM challenge_group_members WHERE group_id = challenge_group_invites.group_id AND user_id = auth.uid()
      ) OR
      EXISTS (
        SELECT 1 FROM challenge_groups WHERE id = challenge_group_invites.group_id AND creator_id = auth.uid()
      )
    )
  );

CREATE POLICY "Envolvidos podem atualizar convites" ON challenge_group_invites
  FOR UPDATE TO authenticated USING (
    inviter_id = auth.uid() OR invitee_id = auth.uid()
  );

-- Adicionar trigger para atualizar automaticamente o campo updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_challenge_groups_updated_at ON challenge_groups;
CREATE TRIGGER set_challenge_groups_updated_at
BEFORE UPDATE ON challenge_groups
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Índices para melhorar performance
CREATE INDEX IF NOT EXISTS idx_challenge_group_members_group_id ON challenge_group_members(group_id);
CREATE INDEX IF NOT EXISTS idx_challenge_group_members_user_id ON challenge_group_members(user_id);
CREATE INDEX IF NOT EXISTS idx_challenge_group_invites_group_id ON challenge_group_invites(group_id);
CREATE INDEX IF NOT EXISTS idx_challenge_group_invites_invitee_id ON challenge_group_invites(invitee_id);
CREATE INDEX IF NOT EXISTS idx_challenge_group_invites_inviter_id ON challenge_group_invites(inviter_id); 