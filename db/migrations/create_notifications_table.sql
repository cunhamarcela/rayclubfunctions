-- Criação da tabela de notificações
CREATE TABLE IF NOT EXISTS notifications (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES auth.users NOT NULL,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  type TEXT NOT NULL, -- challenge, workout, system, etc.
  related_id UUID, -- ID do desafio, treino ou outro conteúdo relacionado
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  read_at TIMESTAMP WITH TIME ZONE,
  data JSONB DEFAULT '{}' -- Dados adicionais específicos do tipo de notificação
);

-- Índice para consultas de notificações não lidas por usuário
CREATE INDEX IF NOT EXISTS idx_notifications_user_unread ON notifications (user_id) WHERE is_read = false;

-- Índice para consultas por tipo
CREATE INDEX IF NOT EXISTS idx_notifications_type ON notifications (type);

-- Política RLS para notificações (apenas o usuário pode ver suas próprias notificações)
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY notifications_select_policy ON notifications 
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY notifications_update_policy ON notifications 
  FOR UPDATE USING (auth.uid() = user_id);

-- Função para criar notificação de desafio
CREATE OR REPLACE FUNCTION create_challenge_notification(
  p_user_id UUID,
  p_challenge_id UUID,
  p_title TEXT,
  p_message TEXT,
  p_data JSONB DEFAULT '{}'
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_notification_id UUID;
BEGIN
  INSERT INTO notifications (
    user_id, 
    title, 
    message, 
    type, 
    related_id, 
    data
  ) VALUES (
    p_user_id,
    p_title,
    p_message,
    'challenge',
    p_challenge_id,
    p_data
  ) RETURNING id INTO v_notification_id;
  
  RETURN v_notification_id;
END;
$$;

-- Trigger para criar notificação quando um usuário se junta a um desafio
CREATE OR REPLACE FUNCTION notify_on_challenge_join()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_challenge_title TEXT;
BEGIN
  -- Obter título do desafio
  SELECT title INTO v_challenge_title FROM challenges WHERE id = NEW.challenge_id;
  
  -- Criar notificação
  PERFORM create_challenge_notification(
    NEW.user_id,
    NEW.challenge_id,
    'Novo Desafio',
    'Você entrou no desafio: ' || v_challenge_title,
    jsonb_build_object('challenge_title', v_challenge_title)
  );
  
  RETURN NEW;
END;
$$;

-- Aplicar o trigger à tabela challenge_participants
CREATE TRIGGER challenge_join_notification_trigger
AFTER INSERT ON challenge_participants
FOR EACH ROW
EXECUTE FUNCTION notify_on_challenge_join();

-- Função para marcar notificações como lidas
CREATE OR REPLACE FUNCTION mark_notifications_as_read(p_notification_ids UUID[])
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE notifications
  SET is_read = true, read_at = now()
  WHERE id = ANY(p_notification_ids) AND user_id = auth.uid();
END;
$$; 