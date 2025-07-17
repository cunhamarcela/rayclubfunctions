-- Script de configuração para o sistema de desafios no Supabase 
-- Estruturas e políticas de RLS para as tabelas de desafios

-- Passo 1: Criar a tabela challenge_participants se não existir
CREATE TABLE IF NOT EXISTS public.challenge_participants (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  challenge_id UUID NOT NULL REFERENCES public.challenges(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id),
  joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  status TEXT DEFAULT 'active',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(challenge_id, user_id)
);

-- Passo 2: Criar a tabela para check-ins diários
CREATE TABLE IF NOT EXISTS public.challenge_check_ins (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id),
  challenge_id UUID NOT NULL REFERENCES public.challenges(id) ON DELETE CASCADE,
  check_in_date TIMESTAMP WITH TIME ZONE NOT NULL,
  points INT NOT NULL DEFAULT 10,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Passo 3: Criar a tabela para bônus
CREATE TABLE IF NOT EXISTS public.challenge_bonuses (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id),
  challenge_id UUID NOT NULL REFERENCES public.challenges(id) ON DELETE CASCADE,
  bonus_points INT NOT NULL,
  reason TEXT NOT NULL,
  awarded_at TIMESTAMP WITH TIME ZONE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Passo 4: Criar os índices básicos
CREATE INDEX IF NOT EXISTS idx_challenge_check_ins_user ON public.challenge_check_ins(user_id);
CREATE INDEX IF NOT EXISTS idx_challenge_check_ins_challenge ON public.challenge_check_ins(challenge_id);
CREATE INDEX IF NOT EXISTS idx_challenge_check_ins_date ON public.challenge_check_ins(check_in_date);
CREATE INDEX IF NOT EXISTS idx_challenge_bonuses_user ON public.challenge_bonuses(user_id);
CREATE INDEX IF NOT EXISTS idx_challenge_bonuses_challenge ON public.challenge_bonuses(challenge_id);
CREATE INDEX IF NOT EXISTS idx_challenge_participants_user ON public.challenge_participants(user_id);
CREATE INDEX IF NOT EXISTS idx_challenge_participants_challenge ON public.challenge_participants(challenge_id);

-- Passo 5: Ativar RLS nas novas tabelas
ALTER TABLE public.challenge_check_ins ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.challenge_bonuses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.challenge_participants ENABLE ROW LEVEL SECURITY;

-- Passo 6: Criar políticas de segurança para challenge_participants
CREATE POLICY "Usuários podem ver desafios em que participam"
  ON public.challenge_participants FOR SELECT
  TO authenticated
  USING (
    user_id = auth.uid() OR
    EXISTS (
      SELECT 1 FROM public.challenges
      WHERE challenges.id = challenge_participants.challenge_id
      AND challenges.creator_id = auth.uid()
    )
  );

CREATE POLICY "Usuários podem participar de desafios"
  ON public.challenge_participants FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Usuários podem sair de desafios"
  ON public.challenge_participants FOR DELETE
  TO authenticated
  USING (user_id = auth.uid());

-- Passo 7: Criar políticas de segurança para check-ins
CREATE POLICY "Usuários podem ver check-ins de desafios em que participam"
  ON public.challenge_check_ins FOR SELECT
  TO authenticated
  USING (
    user_id = auth.uid() OR
    EXISTS (
      SELECT 1 FROM public.challenge_participants
      WHERE challenge_participants.challenge_id = challenge_check_ins.challenge_id
      AND challenge_participants.user_id = auth.uid()
    ) OR
    EXISTS (
      SELECT 1 FROM public.challenges
      WHERE challenges.id = challenge_check_ins.challenge_id
      AND challenges.creator_id = auth.uid()
    )
  );

CREATE POLICY "Usuários podem registrar seus próprios check-ins"
  ON public.challenge_check_ins FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

-- Passo 8: Criar políticas de segurança para bônus
CREATE POLICY "Usuários podem ver bônus de desafios em que participam"
  ON public.challenge_bonuses FOR SELECT
  TO authenticated
  USING (
    user_id = auth.uid() OR
    EXISTS (
      SELECT 1 FROM public.challenge_participants
      WHERE challenge_participants.challenge_id = challenge_bonuses.challenge_id
      AND challenge_participants.user_id = auth.uid()
    ) OR
    EXISTS (
      SELECT 1 FROM public.challenges
      WHERE challenges.id = challenge_bonuses.challenge_id
      AND challenges.creator_id = auth.uid()
    )
  );

CREATE POLICY "Administradores podem atribuir bônus"
  ON public.challenge_bonuses FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.challenges
      WHERE challenges.id = challenge_bonuses.challenge_id
      AND challenges.creator_id = auth.uid()
    )
  );

-- Passo 9: Adicionar novos campos à tabela challenge_progress se necessário
DO $$
BEGIN
  BEGIN
    ALTER TABLE public.challenge_progress ADD COLUMN check_ins_count INT DEFAULT 0;
  EXCEPTION
    WHEN duplicate_column THEN NULL;
  END;
  
  BEGIN
    ALTER TABLE public.challenge_progress ADD COLUMN last_check_in TIMESTAMP WITH TIME ZONE;
  EXCEPTION
    WHEN duplicate_column THEN NULL;
  END;
  
  BEGIN
    ALTER TABLE public.challenge_progress ADD COLUMN consecutive_days INT DEFAULT 0;
  EXCEPTION
    WHEN duplicate_column THEN NULL;
  END;
  
  BEGIN
    ALTER TABLE public.challenge_progress ADD COLUMN completed BOOLEAN DEFAULT FALSE;
  EXCEPTION
    WHEN duplicate_column THEN NULL;
  END;
END $$;

-- Passo 10: Funções para atualizar o progresso
CREATE OR REPLACE FUNCTION update_challenge_progress_on_check_in()
RETURNS TRIGGER AS $$
BEGIN
  -- Atualizar contagem de check-ins e última data de check-in
  UPDATE public.challenge_progress
  SET 
    check_ins_count = check_ins_count + 1,
    last_check_in = NEW.check_in_date,
    points = points + NEW.points,
    last_updated = NOW()
  WHERE 
    challenge_id = NEW.challenge_id AND
    user_id = NEW.user_id;
  
  -- Se não existe progresso, criar um novo
  IF NOT FOUND THEN
    INSERT INTO public.challenge_progress(
      challenge_id, user_id, points, check_ins_count, last_check_in, last_updated
    ) VALUES (
      NEW.challenge_id, NEW.user_id, NEW.points, 1, NEW.check_in_date, NOW()
    );
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para atualizar progresso após check-in
DROP TRIGGER IF EXISTS trg_update_progress_on_check_in ON public.challenge_check_ins;
CREATE TRIGGER trg_update_progress_on_check_in
AFTER INSERT ON public.challenge_check_ins
FOR EACH ROW
EXECUTE PROCEDURE update_challenge_progress_on_check_in();

-- Passo 11: Função para atualizar progresso em bônus
CREATE OR REPLACE FUNCTION update_challenge_progress_on_bonus()
RETURNS TRIGGER AS $$
BEGIN
  -- Atualizar pontos no progresso
  UPDATE public.challenge_progress
  SET 
    points = points + NEW.bonus_points,
    last_updated = NOW()
  WHERE 
    challenge_id = NEW.challenge_id AND
    user_id = NEW.user_id;
  
  -- Se não existe progresso, criar um novo
  IF NOT FOUND THEN
    INSERT INTO public.challenge_progress(
      challenge_id, user_id, points, last_updated
    ) VALUES (
      NEW.challenge_id, NEW.user_id, NEW.bonus_points, NOW()
    );
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para atualizar progresso após bônus
DROP TRIGGER IF EXISTS trg_update_progress_on_bonus ON public.challenge_bonuses;
CREATE TRIGGER trg_update_progress_on_bonus
AFTER INSERT ON public.challenge_bonuses
FOR EACH ROW
EXECUTE PROCEDURE update_challenge_progress_on_bonus();

-- Passo 12: Verificação de unicidade para check-ins diários (1 por dia)
CREATE OR REPLACE FUNCTION check_daily_check_in()
RETURNS TRIGGER AS $$
DECLARE
  existing_check_in UUID;
BEGIN
  -- Verificar se já existe um check-in para este usuário, desafio e data
  SELECT id INTO existing_check_in
  FROM public.challenge_check_ins
  WHERE 
    user_id = NEW.user_id AND
    challenge_id = NEW.challenge_id AND
    DATE(check_in_date) = DATE(NEW.check_in_date);
    
  IF existing_check_in IS NOT NULL THEN
    RAISE EXCEPTION 'Já existe um check-in para este desafio nesta data';
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para validar check-in único por dia
DROP TRIGGER IF EXISTS trg_check_daily_check_in ON public.challenge_check_ins;
CREATE TRIGGER trg_check_daily_check_in
BEFORE INSERT ON public.challenge_check_ins
FOR EACH ROW
EXECUTE PROCEDURE check_daily_check_in(); 