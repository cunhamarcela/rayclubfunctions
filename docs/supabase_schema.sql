-- Ray Club App - Schema para Supabase

-- Tabela de usuários
CREATE TABLE IF NOT EXISTS users (
  id UUID REFERENCES auth.users NOT NULL PRIMARY KEY,
  name TEXT,
  email TEXT NOT NULL UNIQUE,
  avatar_url TEXT,
  is_subscriber BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL
);

-- Ativar realtime para tabela users
ALTER TABLE users REPLICA IDENTITY FULL;

-- Tabela de treinos
CREATE TABLE IF NOT EXISTS workouts (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES users(id) NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  type TEXT NOT NULL,
  duration_minutes INTEGER NOT NULL DEFAULT 30,
  difficulty TEXT NOT NULL DEFAULT 'medium',
  equipment TEXT[] DEFAULT '{}',
  image_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  creator_id UUID REFERENCES users(id),
  is_public BOOLEAN DEFAULT true
);

-- Ativar realtime para tabela workouts
ALTER TABLE workouts REPLICA IDENTITY FULL;

-- Adicionar índice para pesquisa de treinos por duração
CREATE INDEX IF NOT EXISTS workouts_duration_idx ON workouts(duration_minutes);

-- Tabela de desafios
CREATE TABLE IF NOT EXISTS challenges (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  is_official BOOLEAN DEFAULT false,
  creator_id UUID REFERENCES users(id),
  start_date TIMESTAMP WITH TIME ZONE NOT NULL,
  end_date TIMESTAMP WITH TIME ZONE NOT NULL,
  reward INTEGER DEFAULT 0,
  image_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL
);

-- Ativar realtime para tabela challenges
ALTER TABLE challenges REPLICA IDENTITY FULL;

-- Tabela de participantes de desafios
CREATE TABLE IF NOT EXISTS challenge_participants (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES users(id) NOT NULL,
  challenge_id UUID REFERENCES challenges(id) NOT NULL,
  points INTEGER DEFAULT 0,
  completion_percentage FLOAT DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  UNIQUE(user_id, challenge_id)
);

-- Tabela de convites para desafios
CREATE TABLE IF NOT EXISTS challenge_invites (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  challenge_id UUID REFERENCES challenges(id) NOT NULL,
  inviter_id UUID REFERENCES users(id) NOT NULL,
  invitee_id UUID REFERENCES users(id) NOT NULL,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'declined')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  UNIQUE(challenge_id, invitee_id)
);

-- Ativar realtime para tabelas
ALTER TABLE challenge_participants REPLICA IDENTITY FULL;
ALTER TABLE challenge_invites REPLICA IDENTITY FULL;

-- Tabela de cards de conteúdo
CREATE TABLE IF NOT EXISTS content_cards (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  title TEXT NOT NULL,
  subtitle TEXT,
  route_link TEXT NOT NULL,
  icon TEXT,
  category TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL
);

-- Tabela de notificações
CREATE TABLE IF NOT EXISTS notifications (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES users(id) NOT NULL,
  type TEXT NOT NULL,
  content TEXT NOT NULL,
  read_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL
);

-- Ativar realtime para tabela notifications
ALTER TABLE notifications REPLICA IDENTITY FULL;

-- Tabela de cupons
CREATE TABLE IF NOT EXISTS coupons (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  partner TEXT NOT NULL,
  qr_code_url TEXT,
  expires_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL
);

-- Verificar se a tabela nutrition_items já existe antes de criar
CREATE TABLE IF NOT EXISTS nutrition_items (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  image_url TEXT,
  calories INTEGER,
  protein FLOAT,
  carbs FLOAT,
  fat FLOAT,
  category TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL
);

-- Criar políticas de segurança para as tabelas
-- Política para users: cada usuário pode ler todos os usuários e atualizar apenas seu próprio perfil
CREATE POLICY "Usuários podem ler todos os perfis" ON users
  FOR SELECT USING (true);

CREATE POLICY "Usuários podem atualizar seu próprio perfil" ON users
  FOR UPDATE USING (auth.uid() = id);

-- Política para workouts: usuários podem ver treinos públicos ou seus próprios treinos
CREATE POLICY "Usuários podem ver treinos públicos" ON workouts
  FOR SELECT USING (is_public = true OR auth.uid() = user_id);

CREATE POLICY "Usuários podem criar seus próprios treinos" ON workouts
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuários podem atualizar seus próprios treinos" ON workouts
  FOR UPDATE USING (auth.uid() = user_id);

-- Política para challenges: todos podem ver desafios
CREATE POLICY "Todos podem ver desafios" ON challenges
  FOR SELECT USING (true);

CREATE POLICY "Usuários podem criar desafios" ON challenges
  FOR INSERT WITH CHECK (auth.uid() = creator_id);

CREATE POLICY "Usuários podem atualizar seus próprios desafios" ON challenges
  FOR UPDATE USING (auth.uid() = creator_id);

-- Política para challenge_participants: usuários podem ver suas próprias participações
CREATE POLICY "Usuários podem ver participações em desafios" ON challenge_participants
  FOR SELECT USING (true);

CREATE POLICY "Usuários podem se inscrever em desafios" ON challenge_participants
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuários podem atualizar seu próprio progresso" ON challenge_participants
  FOR UPDATE USING (auth.uid() = user_id);

-- Política para challenge_invites
CREATE POLICY "Usuários podem ver convites relacionados a eles" ON challenge_invites
  FOR SELECT USING (auth.uid() = inviter_id OR auth.uid() = invitee_id);

CREATE POLICY "Usuários podem enviar convites" ON challenge_invites
  FOR INSERT WITH CHECK (auth.uid() = inviter_id);

CREATE POLICY "Usuários podem responder a convites" ON challenge_invites
  FOR UPDATE USING (auth.uid() = invitee_id);

-- Política para content_cards: todos podem ver cards de conteúdo
CREATE POLICY "Todos podem ver cards de conteúdo" ON content_cards
  FOR SELECT USING (true);

-- Política para notifications: usuários podem ver apenas suas próprias notificações
CREATE POLICY "Usuários podem ver suas notificações" ON notifications
  FOR SELECT USING (auth.uid() = user_id);

-- Criar bucket no Storage para imagens de treino
-- (Isso precisa ser feito manualmente no console do Supabase ou via API) 