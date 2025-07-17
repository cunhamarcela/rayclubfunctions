-- Políticas de segurança para todas as tabelas
-- Este arquivo deve ser executado no Supabase

---------------------------------------------
-- CONFIGURAÇÕES GERAIS
---------------------------------------------

-- Habilitar extensões necessárias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Garantir que todas as tabelas tenham RLS ativado
ALTER TABLE IF EXISTS profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS workouts ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS workout_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS challenges ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS challenge_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS challenge_invites ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS benefits ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS redeemed_benefits ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS user_goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS goal_progress ENABLE ROW LEVEL SECURITY;

---------------------------------------------
-- POLÍTICAS PARA PROFILES
---------------------------------------------

-- Usuários podem visualizar todos os perfis (para funcionalidades sociais)
CREATE POLICY "Perfis são visíveis para todos usuários autenticados"
ON profiles FOR SELECT
TO authenticated
USING (true);

-- Usuários só podem atualizar seu próprio perfil
CREATE POLICY "Usuários podem atualizar somente seu próprio perfil"
ON profiles FOR UPDATE
TO authenticated
USING (id = auth.uid());

-- Usuarios só podem inserir seu próprio perfil
CREATE POLICY "Usuários podem inserir somente seu próprio perfil"
ON profiles FOR INSERT
TO authenticated
WITH CHECK (id = auth.uid());

---------------------------------------------
-- POLÍTICAS PARA WORKOUTS
---------------------------------------------

-- Workouts são visíveis para todos os usuários autenticados
CREATE POLICY "Workouts são visíveis para todos os usuários autenticados"
ON workouts FOR SELECT
TO authenticated
USING (true);

-- Apenas admins podem criar/editar workouts
CREATE POLICY "Apenas admins podem criar/editar workouts"
ON workouts FOR ALL
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM profiles
    WHERE profiles.id = auth.uid() AND profiles.is_admin = true
  )
);

---------------------------------------------
-- POLÍTICAS PARA WORKOUT_HISTORY
---------------------------------------------

-- Usuários podem ver apenas seu próprio histórico
CREATE POLICY "Usuários podem ver apenas seu próprio histórico de treinos"
ON workout_history FOR SELECT
TO authenticated
USING (user_id = auth.uid());

-- Usuários podem inserir apenas seu próprio histórico
CREATE POLICY "Usuários podem inserir apenas seu próprio histórico de treinos"
ON workout_history FOR INSERT
TO authenticated
WITH CHECK (user_id = auth.uid());

-- Usuários podem atualizar apenas seu próprio histórico
CREATE POLICY "Usuários podem atualizar apenas seu próprio histórico de treinos"
ON workout_history FOR UPDATE
TO authenticated
USING (user_id = auth.uid());

-- Usuários podem deletar apenas seu próprio histórico
CREATE POLICY "Usuários podem deletar apenas seu próprio histórico de treinos"
ON workout_history FOR DELETE
TO authenticated
USING (user_id = auth.uid());

---------------------------------------------
-- POLÍTICAS PARA CHALLENGES
---------------------------------------------

-- Challenges públicos são visíveis para todos
CREATE POLICY "Desafios públicos são visíveis para todos"
ON challenges FOR SELECT
TO authenticated
USING (
  is_public = true OR 
  created_by = auth.uid() OR
  EXISTS (
    SELECT 1 FROM challenge_participants
    WHERE challenge_participants.challenge_id = challenges.id 
    AND challenge_participants.user_id = auth.uid()
  )
);

-- Apenas o criador ou admin pode editar challenges
CREATE POLICY "Apenas o criador ou admin pode editar desafios"
ON challenges FOR UPDATE
TO authenticated
USING (
  created_by = auth.uid() OR 
  EXISTS (
    SELECT 1 FROM profiles
    WHERE profiles.id = auth.uid() AND profiles.is_admin = true
  )
);

-- Qualquer usuário autenticado pode criar desafios
CREATE POLICY "Qualquer usuário autenticado pode criar desafios"
ON challenges FOR INSERT
TO authenticated
WITH CHECK (auth.uid() IS NOT NULL);

-- Apenas o criador ou admin pode deletar challenges
CREATE POLICY "Apenas o criador ou admin pode deletar desafios"
ON challenges FOR DELETE
TO authenticated
USING (
  created_by = auth.uid() OR 
  EXISTS (
    SELECT 1 FROM profiles
    WHERE profiles.id = auth.uid() AND profiles.is_admin = true
  )
);

---------------------------------------------
-- POLÍTICAS PARA CHALLENGE_PARTICIPANTS
---------------------------------------------

-- Participantes podem ver desafios em que estão
CREATE POLICY "Participantes podem ver desafios em que estão"
ON challenge_participants FOR SELECT
TO authenticated
USING (
  user_id = auth.uid() OR
  EXISTS (
    SELECT 1 FROM challenges
    WHERE challenges.id = challenge_participants.challenge_id
    AND challenges.created_by = auth.uid()
  )
);

-- Participantes podem se adicionar a desafios públicos
CREATE POLICY "Participantes podem se adicionar a desafios públicos"
ON challenge_participants FOR INSERT
TO authenticated
WITH CHECK (
  user_id = auth.uid() AND
  EXISTS (
    SELECT 1 FROM challenges
    WHERE challenges.id = challenge_participants.challenge_id
    AND (challenges.is_public = true OR challenges.created_by = auth.uid())
  )
);

-- Participantes podem sair de um desafio
CREATE POLICY "Participantes podem sair de um desafio"
ON challenge_participants FOR DELETE
TO authenticated
USING (user_id = auth.uid());

---------------------------------------------
-- POLÍTICAS PARA CHALLENGE_INVITES
---------------------------------------------

-- Usuários podem ver convites destinados a eles
CREATE POLICY "Usuários podem ver convites destinados a eles"
ON challenge_invites FOR SELECT
TO authenticated
USING (
  invited_user_id = auth.uid() OR
  inviting_user_id = auth.uid()
);

-- Usuários podem criar convites
CREATE POLICY "Usuários podem criar convites"
ON challenge_invites FOR INSERT
TO authenticated
WITH CHECK (
  inviting_user_id = auth.uid() AND
  EXISTS (
    SELECT 1 FROM challenges
    WHERE challenges.id = challenge_invites.challenge_id
    AND (challenges.created_by = auth.uid() OR
        EXISTS (
          SELECT 1 FROM challenge_participants
          WHERE challenge_participants.challenge_id = challenge_invites.challenge_id
          AND challenge_participants.user_id = auth.uid()
        ))
  )
);

-- Usuários podem responder a convites destinados a eles
CREATE POLICY "Usuários podem responder a convites destinados a eles"
ON challenge_invites FOR UPDATE
TO authenticated
USING (invited_user_id = auth.uid());

-- Usuários podem cancelar convites que eles criaram
CREATE POLICY "Usuários podem cancelar convites que eles criaram"
ON challenge_invites FOR DELETE
TO authenticated
USING (inviting_user_id = auth.uid());

---------------------------------------------
-- POLÍTICAS PARA BENEFITS
---------------------------------------------

-- Benefits são visíveis para todos os usuários autenticados
CREATE POLICY "Benefícios são visíveis para todos os usuários autenticados"
ON benefits FOR SELECT
TO authenticated
USING (is_active = true OR auth.uid() IN (
  SELECT id FROM profiles WHERE is_admin = true
));

-- Apenas admins podem gerenciar benefícios
CREATE POLICY "Apenas admins podem gerenciar benefícios"
ON benefits FOR ALL
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM profiles
    WHERE profiles.id = auth.uid() AND profiles.is_admin = true
  )
);

---------------------------------------------
-- POLÍTICAS PARA REDEEMED_BENEFITS
---------------------------------------------

-- Usuários podem ver seus próprios benefícios resgatados
CREATE POLICY "Usuários podem ver seus próprios benefícios resgatados"
ON redeemed_benefits FOR SELECT
TO authenticated
USING (user_id = auth.uid());

-- Admins podem ver todos os benefícios resgatados
CREATE POLICY "Admins podem ver todos os benefícios resgatados"
ON redeemed_benefits FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM profiles
    WHERE profiles.id = auth.uid() AND profiles.is_admin = true
  )
);

-- Usuários podem resgatar benefícios
CREATE POLICY "Usuários podem resgatar benefícios"
ON redeemed_benefits FOR INSERT
TO authenticated
WITH CHECK (
  user_id = auth.uid() AND
  EXISTS (
    SELECT 1 FROM benefits
    WHERE benefits.id = redeemed_benefits.benefit_id
    AND benefits.is_active = true
  )
);

---------------------------------------------
-- POLÍTICAS PARA GOALS/USER_GOALS/GOAL_PROGRESS
---------------------------------------------

-- Goals são visíveis para todos
CREATE POLICY "Metas são visíveis para todos"
ON goals FOR SELECT
TO authenticated
USING (true);

-- Apenas admins podem criar/atualizar metas
CREATE POLICY "Apenas admins podem criar/atualizar metas"
ON goals FOR ALL
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM profiles
    WHERE profiles.id = auth.uid() AND profiles.is_admin = true
  )
);

-- Usuários podem ver suas próprias metas
CREATE POLICY "Usuários podem ver suas próprias metas"
ON user_goals FOR SELECT
TO authenticated
USING (user_id = auth.uid());

-- Usuários podem configurar suas próprias metas
CREATE POLICY "Usuários podem configurar suas próprias metas"
ON user_goals FOR INSERT
TO authenticated
WITH CHECK (user_id = auth.uid());

-- Usuários podem atualizar suas próprias metas
CREATE POLICY "Usuários podem atualizar suas próprias metas"
ON user_goals FOR UPDATE
TO authenticated
USING (user_id = auth.uid());

-- Usuários podem ver seu próprio progresso
CREATE POLICY "Usuários podem ver seu próprio progresso"
ON goal_progress FOR SELECT
TO authenticated
USING (user_id = auth.uid());

-- Usuários podem registrar seu próprio progresso
CREATE POLICY "Usuários podem registrar seu próprio progresso"
ON goal_progress FOR INSERT
TO authenticated
WITH CHECK (user_id = auth.uid());

-- Usuários podem atualizar seu próprio progresso
CREATE POLICY "Usuários podem atualizar seu próprio progresso"
ON goal_progress FOR UPDATE
TO authenticated
USING (user_id = auth.uid()); 