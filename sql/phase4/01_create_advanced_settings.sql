-- Criação de tabela para armazenar configurações avançadas de usuários
-- Esta tabela será usada para sincronizar configurações entre dispositivos na Fase 4

-- Verifica se a tabela já existe para evitar erros
CREATE TABLE IF NOT EXISTS user_settings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  language_code TEXT NOT NULL DEFAULT 'pt_BR',
  theme_mode INT NOT NULL DEFAULT 0, -- 0: system, 1: light, 2: dark
  privacy_settings JSONB NOT NULL DEFAULT '{
    "shareActivityWithFriends": true,
    "allowFindingMe": true,
    "publicProfile": true,
    "showInRanking": true,
    "shareAnalyticsData": true
  }',
  notification_settings JSONB NOT NULL DEFAULT '{
    "enableNotifications": true,
    "workoutReminders": true,
    "dailyReminders": true,
    "challengeUpdates": true,
    "nutritionReminders": true,
    "promotionalNotifications": true,
    "reminderTime": "18:00"
  }',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  
  -- Cria índice para buscas por usuário
  CONSTRAINT user_settings_user_id_unique UNIQUE (user_id)
);

-- Adiciona comentários às colunas para documentação
COMMENT ON TABLE user_settings IS 'Armazena configurações avançadas dos usuários com suporte à sincronização entre dispositivos';
COMMENT ON COLUMN user_settings.language_code IS 'Código do idioma selecionado pelo usuário';
COMMENT ON COLUMN user_settings.theme_mode IS 'Modo de tema (0: system, 1: light, 2: dark)';
COMMENT ON COLUMN user_settings.privacy_settings IS 'Configurações de privacidade do usuário';
COMMENT ON COLUMN user_settings.notification_settings IS 'Configurações de notificação do usuário';

-- Adiciona trigger para atualizar updated_at automaticamente
CREATE OR REPLACE FUNCTION update_user_settings_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_user_settings_updated_at_trigger
BEFORE UPDATE ON user_settings
FOR EACH ROW
EXECUTE FUNCTION update_user_settings_updated_at();

-- Configura RLS (Row Level Security) para a tabela
ALTER TABLE user_settings ENABLE ROW LEVEL SECURITY;

-- Política para permitir que usuários vejam apenas suas próprias configurações
CREATE POLICY user_settings_select_policy 
ON user_settings 
FOR SELECT 
USING (auth.uid() = user_id);

-- Política para permitir que usuários atualizem apenas suas próprias configurações
CREATE POLICY user_settings_update_policy 
ON user_settings 
FOR UPDATE 
USING (auth.uid() = user_id);

-- Política para permitir que usuários inserem suas próprias configurações
CREATE POLICY user_settings_insert_policy 
ON user_settings 
FOR INSERT 
WITH CHECK (auth.uid() = user_id);

-- Função para sincronizar configurações entre dispositivos
CREATE OR REPLACE FUNCTION sync_user_settings(p_user_id UUID, p_client_updated_at TIMESTAMP WITH TIME ZONE)
RETURNS TIMESTAMP WITH TIME ZONE AS $$
DECLARE
  server_updated_at TIMESTAMP WITH TIME ZONE;
BEGIN
  -- Obtém a data de atualização no servidor
  SELECT updated_at INTO server_updated_at
  FROM user_settings
  WHERE user_id = p_user_id;
  
  -- Se não existe no servidor ou o cliente tem dados mais recentes, retorna a data do cliente
  IF server_updated_at IS NULL OR p_client_updated_at > server_updated_at THEN
    RETURN p_client_updated_at;
  END IF;
  
  -- Se o servidor tem dados mais recentes, retorna a data do servidor
  RETURN server_updated_at;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER; 