-- Script para criar a tabela check_in_error_logs para registro de erros na função de check-in

-- Verificar se a tabela já existe
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 
    FROM information_schema.tables 
    WHERE table_name = 'check_in_error_logs'
  ) THEN
    -- Criar a tabela
    CREATE TABLE check_in_error_logs (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      user_id UUID NOT NULL,
      challenge_id UUID NOT NULL,
      error_message TEXT NOT NULL,
      error_detail TEXT,
      error_context TEXT,
      created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
      
      -- Referências para as tabelas relacionadas
      FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE,
      FOREIGN KEY (challenge_id) REFERENCES challenges(id) ON DELETE CASCADE
    );
    
    -- Adicionar permissões adequadas
    ALTER TABLE check_in_error_logs ENABLE ROW LEVEL SECURITY;
    
    -- Política para administradores verem todos os registros
    CREATE POLICY "Administradores podem ver todos os logs" 
      ON check_in_error_logs
      FOR SELECT
      USING (auth.uid() IN (
        SELECT id FROM profiles WHERE is_admin = true
      ));
      
    -- Política para usuários verem apenas seus próprios logs
    CREATE POLICY "Usuários podem ver seus próprios logs" 
      ON check_in_error_logs
      FOR SELECT
      USING (auth.uid() = user_id);
      
    -- Política para permitir inserção via função segura
    CREATE POLICY "Permitir inserção via função" 
      ON check_in_error_logs
      FOR INSERT
      WITH CHECK (true);
    
    -- Criar índices para melhorar performance de busca
    CREATE INDEX idx_check_in_error_logs_user_id 
      ON check_in_error_logs(user_id);
    
    CREATE INDEX idx_check_in_error_logs_challenge_id 
      ON check_in_error_logs(challenge_id);
    
    CREATE INDEX idx_check_in_error_logs_created_at 
      ON check_in_error_logs(created_at);
    
    RAISE NOTICE 'Tabela check_in_error_logs criada com sucesso!';
  ELSE
    RAISE NOTICE 'Tabela check_in_error_logs já existe.';
  END IF;
END
$$; 