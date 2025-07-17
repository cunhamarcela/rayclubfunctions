-- Script para validar e corrigir estruturas necessárias para o dashboard
CREATE OR REPLACE FUNCTION check_dashboard_dependencies()
RETURNS TABLE (
  table_name TEXT,
  column_name TEXT,
  "exists" BOOLEAN,
  notes TEXT
) AS $$
BEGIN
  -- Verificar cada tabela e coluna necessária para o dashboard
  
  -- user_progress
  RETURN QUERY SELECT 'user_progress', 'id', EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_progress' AND column_name = 'id'), 'Coluna básica';
  RETURN QUERY SELECT 'user_progress', 'user_id', EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_progress' AND column_name = 'user_id'), 'Coluna básica';
  RETURN QUERY SELECT 'user_progress', 'workouts', EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_progress' AND column_name = 'workouts'), 'Para total_workouts';
  RETURN QUERY SELECT 'user_progress', 'current_streak', EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_progress' AND column_name = 'current_streak'), 'Para streak atual';
  RETURN QUERY SELECT 'user_progress', 'longest_streak', EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_progress' AND column_name = 'longest_streak'), 'Para maior streak';
  RETURN QUERY SELECT 'user_progress', 'points', EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_progress' AND column_name = 'points'), 'Para total_points';
  RETURN QUERY SELECT 'user_progress', 'days_trained_this_month', EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_progress' AND column_name = 'days_trained_this_month'), 'Estatística mensal';
  RETURN QUERY SELECT 'user_progress', 'workout_types', EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_progress' AND column_name = 'workout_types'), 'Tipos de treino';
  RETURN QUERY SELECT 'user_progress', 'workouts_by_type', EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_progress' AND column_name = 'workouts_by_type'), 'Alternativa para workout_types';
  
  -- water_intake
  RETURN QUERY SELECT 'water_intake', 'id', EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'water_intake' AND column_name = 'id'), 'Coluna básica';
  RETURN QUERY SELECT 'water_intake', 'user_id', EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'water_intake' AND column_name = 'user_id'), 'Coluna básica';
  RETURN QUERY SELECT 'water_intake', 'date', EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'water_intake' AND column_name = 'date'), 'Data do registro';
  RETURN QUERY SELECT 'water_intake', 'cups', EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'water_intake' AND column_name = 'cups'), 'Quantidade de copos';
  RETURN QUERY SELECT 'water_intake', 'goal', EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'water_intake' AND column_name = 'goal'), 'Meta diária';
  
  -- user_goals
  RETURN QUERY SELECT 'user_goals', 'id', EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_goals' AND column_name = 'id'), 'Coluna básica';
  RETURN QUERY SELECT 'user_goals', 'user_id', EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_goals' AND column_name = 'user_id'), 'Coluna básica';
  RETURN QUERY SELECT 'user_goals', 'title', EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_goals' AND column_name = 'title'), 'Título da meta';
  RETURN QUERY SELECT 'user_goals', 'current_value', EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_goals' AND column_name = 'current_value'), 'Valor atual';
  RETURN QUERY SELECT 'user_goals', 'target_value', EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_goals' AND column_name = 'target_value'), 'Valor objetivo';
  RETURN QUERY SELECT 'user_goals', 'unit', EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_goals' AND column_name = 'unit'), 'Unidade de medida';
  RETURN QUERY SELECT 'user_goals', 'is_completed', EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_goals' AND column_name = 'is_completed'), 'Status da meta';
  
  -- workout_records
  RETURN QUERY SELECT 'workout_records', 'id', EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'workout_records' AND column_name = 'id'), 'Coluna básica';
  RETURN QUERY SELECT 'workout_records', 'user_id', EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'workout_records' AND column_name = 'user_id'), 'Coluna básica';
  RETURN QUERY SELECT 'workout_records', 'workout_name', EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'workout_records' AND column_name = 'workout_name'), 'Nome do treino';
  RETURN QUERY SELECT 'workout_records', 'workout_type', EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'workout_records' AND column_name = 'workout_type'), 'Tipo de treino';
  RETURN QUERY SELECT 'workout_records', 'date', EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'workout_records' AND column_name = 'date'), 'Data do treino';
  RETURN QUERY SELECT 'workout_records', 'duration_minutes', EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'workout_records' AND column_name = 'duration_minutes'), 'Duração do treino';
  RETURN QUERY SELECT 'workout_records', 'is_completed', EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'workout_records' AND column_name = 'is_completed'), 'Status do treino';
  
  -- challenges
  RETURN QUERY SELECT 'challenges', 'id', EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'challenges' AND column_name = 'id'), 'Coluna básica';
  RETURN QUERY SELECT 'challenges', 'title', EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'challenges' AND column_name = 'title'), 'Título do desafio';
  RETURN QUERY SELECT 'challenges', 'description', EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'challenges' AND column_name = 'description'), 'Descrição do desafio';
  RETURN QUERY SELECT 'challenges', 'image_url', EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'challenges' AND column_name = 'image_url'), 'Imagem do desafio';
  RETURN QUERY SELECT 'challenges', 'start_date', EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'challenges' AND column_name = 'start_date'), 'Data inicial';
  RETURN QUERY SELECT 'challenges', 'end_date', EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'challenges' AND column_name = 'end_date'), 'Data final';
  RETURN QUERY SELECT 'challenges', 'points', EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'challenges' AND column_name = 'points'), 'Pontos do desafio';
  RETURN QUERY SELECT 'challenges', 'type', EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'challenges' AND column_name = 'type'), 'Tipo do desafio';
  RETURN QUERY SELECT 'challenges', 'is_official', EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'challenges' AND column_name = 'is_official'), 'Se é oficial';
  RETURN QUERY SELECT 'challenges', 'active', EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'challenges' AND column_name = 'active'), 'Status do desafio';
  
  -- challenge_participants
  RETURN QUERY SELECT 'challenge_participants', 'id', EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'challenge_participants' AND column_name = 'id'), 'Coluna básica';
  RETURN QUERY SELECT 'challenge_participants', 'user_id', EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'challenge_participants' AND column_name = 'user_id'), 'Coluna básica';
  RETURN QUERY SELECT 'challenge_participants', 'challenge_id', EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'challenge_participants' AND column_name = 'challenge_id'), 'ID do desafio';
  
  -- challenge_progress
  RETURN QUERY SELECT 'challenge_progress', 'id', EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'challenge_progress' AND column_name = 'id'), 'Coluna básica';
  RETURN QUERY SELECT 'challenge_progress', 'user_id', EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'challenge_progress' AND column_name = 'user_id'), 'Coluna básica';
  RETURN QUERY SELECT 'challenge_progress', 'challenge_id', EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'challenge_progress' AND column_name = 'challenge_id'), 'ID do desafio';
  RETURN QUERY SELECT 'challenge_progress', 'points', EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'challenge_progress' AND column_name = 'points'), 'Pontos do usuário';
  RETURN QUERY SELECT 'challenge_progress', 'position', EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'challenge_progress' AND column_name = 'position'), 'Posição no ranking';
  RETURN QUERY SELECT 'challenge_progress', 'check_ins_count', EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'challenge_progress' AND column_name = 'check_ins_count'), 'Total de check-ins';
  RETURN QUERY SELECT 'challenge_progress', 'total_check_ins', EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'challenge_progress' AND column_name = 'total_check_ins'), 'Alternativa para check-ins';
  RETURN QUERY SELECT 'challenge_progress', 'consecutive_days', EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'challenge_progress' AND column_name = 'consecutive_days'), 'Dias consecutivos';
  
  -- Verificar a tabela benefits
  RETURN QUERY SELECT 'benefits', 'id', EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'benefits' AND column_name = 'id'), 'Coluna básica';
  RETURN QUERY SELECT 'benefits', 'title', EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'benefits' AND column_name = 'title'), 'Título do benefício';
  RETURN QUERY SELECT 'benefits', 'image_url', EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'benefits' AND column_name = 'image_url'), 'Imagem do benefício';
  
  -- Verificar se existe a tabela user_benefits ou redeemed_benefits
  RETURN QUERY SELECT 'user_benefits', 'EXISTS', EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'user_benefits'), 'Tabela para benefícios';
  RETURN QUERY SELECT 'redeemed_benefits', 'EXISTS', EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'redeemed_benefits'), 'Tabela alternativa para benefícios';
  
  -- Verificar colunas das tabelas de benefícios resgatados
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'user_benefits') THEN
    RETURN QUERY SELECT 'user_benefits', 'id', EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_benefits' AND column_name = 'id'), 'Coluna básica';
    RETURN QUERY SELECT 'user_benefits', 'user_id', EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_benefits' AND column_name = 'user_id'), 'Coluna básica';
    RETURN QUERY SELECT 'user_benefits', 'benefit_id', EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_benefits' AND column_name = 'benefit_id'), 'ID do benefício';
    RETURN QUERY SELECT 'user_benefits', 'redeemed_at', EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_benefits' AND column_name = 'redeemed_at'), 'Data de resgate';
    RETURN QUERY SELECT 'user_benefits', 'redemption_code', EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_benefits' AND column_name = 'redemption_code'), 'Código de resgate';
    RETURN QUERY SELECT 'user_benefits', 'is_redeemed', EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_benefits' AND column_name = 'is_redeemed'), 'Status de resgate';
    RETURN QUERY SELECT 'user_benefits', 'expires_at', EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_benefits' AND column_name = 'expires_at'), 'Data de expiração';
  END IF;
  
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'redeemed_benefits') THEN
    RETURN QUERY SELECT 'redeemed_benefits', 'id', EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'redeemed_benefits' AND column_name = 'id'), 'Coluna básica';
    RETURN QUERY SELECT 'redeemed_benefits', 'user_id', EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'redeemed_benefits' AND column_name = 'user_id'), 'Coluna básica';
    RETURN QUERY SELECT 'redeemed_benefits', 'benefit_id', EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'redeemed_benefits' AND column_name = 'benefit_id'), 'ID do benefício';
    RETURN QUERY SELECT 'redeemed_benefits', 'redeemed_at', EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'redeemed_benefits' AND column_name = 'redeemed_at'), 'Data de resgate';
    RETURN QUERY SELECT 'redeemed_benefits', 'code', EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'redeemed_benefits' AND column_name = 'code'), 'Código de resgate';
    RETURN QUERY SELECT 'redeemed_benefits', 'status', EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'redeemed_benefits' AND column_name = 'status'), 'Status do benefício';
    RETURN QUERY SELECT 'redeemed_benefits', 'expiration_date', EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'redeemed_benefits' AND column_name = 'expiration_date'), 'Data de expiração';
  END IF;
END;
$$ LANGUAGE plpgsql;

-- Função que gera um script para adicionar colunas que faltam
CREATE OR REPLACE FUNCTION generate_dashboard_fix_script()
RETURNS TEXT AS $$
DECLARE
  script TEXT := '';
  missing_record RECORD;
BEGIN
  script := '-- Script para corrigir estruturas faltantes no dashboard' || E'\n\n';
  
  -- Verificar cada tabela e coluna que falta
  FOR missing_record IN
    SELECT * FROM check_dashboard_dependencies() WHERE NOT "exists"
  LOOP
    IF missing_record.column_name = 'EXISTS' THEN
      -- Tabela inteira faltando
      IF missing_record.table_name = 'user_benefits' THEN
        -- Não criar tabela user_benefits se ela não existe mas redeemed_benefits existe
        IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'redeemed_benefits') THEN
          script := script || '-- Tabela user_benefits não existe, mas redeemed_benefits existe, usando esta como alternativa' || E'\n';
        ELSE
          script := script || 'CREATE TABLE IF NOT EXISTS user_benefits (' || E'\n';
          script := script || '  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),' || E'\n';
          script := script || '  user_id UUID NOT NULL REFERENCES auth.users(id),' || E'\n';
          script := script || '  benefit_id UUID NOT NULL REFERENCES benefits(id),' || E'\n';
          script := script || '  redeemed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),' || E'\n';
          script := script || '  redemption_code TEXT,' || E'\n';
          script := script || '  is_redeemed BOOLEAN DEFAULT TRUE,' || E'\n';
          script := script || '  expires_at TIMESTAMP WITH TIME ZONE,' || E'\n';
          script := script || '  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),' || E'\n';
          script := script || '  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()' || E'\n';
          script := script || ');' || E'\n\n';
        END IF;
      ELSIF missing_record.table_name = 'redeemed_benefits' THEN
        -- Não criar tabela redeemed_benefits se ela não existe mas user_benefits existe
        IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'user_benefits') THEN
          script := script || '-- Tabela redeemed_benefits não existe, mas user_benefits existe, usando esta como alternativa' || E'\n';
        ELSE
          script := script || 'CREATE TABLE IF NOT EXISTS redeemed_benefits (' || E'\n';
          script := script || '  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),' || E'\n';
          script := script || '  user_id UUID NOT NULL REFERENCES auth.users(id),' || E'\n';
          script := script || '  benefit_id UUID NOT NULL REFERENCES benefits(id),' || E'\n';
          script := script || '  redeemed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),' || E'\n';
          script := script || '  code TEXT,' || E'\n';
          script := script || '  status TEXT DEFAULT ''active'',' || E'\n';
          script := script || '  expiration_date TIMESTAMP WITH TIME ZONE,' || E'\n';
          script := script || '  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),' || E'\n';
          script := script || '  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()' || E'\n';
          script := script || ');' || E'\n\n';
        END IF;
      ELSE
        script := script || '-- Tabela ' || missing_record.table_name || ' não existe e é necessária para o dashboard' || E'\n';
      END IF;
    ELSE
      -- Coluna faltando
      IF missing_record.table_name = 'user_progress' THEN
        IF missing_record.column_name = 'workout_types' AND EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_progress' AND column_name = 'workouts_by_type') THEN
          script := script || '-- Coluna workout_types não existe, mas workouts_by_type existe e será usada como alternativa' || E'\n';
        ELSIF missing_record.column_name = 'workouts_by_type' AND EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_progress' AND column_name = 'workout_types') THEN
          script := script || '-- Coluna workouts_by_type não existe, mas workout_types existe e será usada como alternativa' || E'\n';
        ELSE
          script := script || 'ALTER TABLE ' || missing_record.table_name || ' ADD COLUMN IF NOT EXISTS ' || missing_record.column_name || ' ';
          
          -- Determinar o tipo de dados baseado no nome da coluna
          IF missing_record.column_name IN ('id', 'user_id', 'benefit_id', 'challenge_id') THEN
            script := script || 'UUID';
            IF missing_record.column_name = 'id' THEN
              script := script || ' PRIMARY KEY DEFAULT uuid_generate_v4()';
            END IF;
          ELSIF missing_record.column_name IN ('is_completed', 'is_redeemed', 'is_official', 'active') THEN
            script := script || 'BOOLEAN DEFAULT FALSE';
          ELSIF missing_record.column_name IN ('workouts', 'cups', 'current_value', 'target_value', 'points', 'position', 'check_ins_count', 'total_check_ins', 'consecutive_days', 'days_trained_this_month', 'duration_minutes') THEN
            script := script || 'INTEGER DEFAULT 0';
          ELSIF missing_record.column_name IN ('workout_types', 'workouts_by_type') THEN
            script := script || 'JSONB DEFAULT ''{}''::{jsonb}';
          ELSIF missing_record.column_name IN ('redeemed_at', 'expires_at', 'created_at', 'updated_at', 'start_date', 'end_date', 'expiration_date') THEN
            script := script || 'TIMESTAMP WITH TIME ZONE DEFAULT NOW()';
          ELSIF missing_record.column_name = 'date' THEN
            script := script || 'DATE DEFAULT CURRENT_DATE';
          ELSE
            script := script || 'TEXT';
          END IF;
          
          script := script || ';' || E'\n';
        END IF;
      ELSIF missing_record.table_name = 'challenge_progress' THEN
        IF missing_record.column_name = 'check_ins_count' AND EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'challenge_progress' AND column_name = 'total_check_ins') THEN
          script := script || '-- Coluna check_ins_count não existe, mas total_check_ins existe e será usada como alternativa' || E'\n';
        ELSIF missing_record.column_name = 'total_check_ins' AND EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'challenge_progress' AND column_name = 'check_ins_count') THEN
          script := script || '-- Coluna total_check_ins não existe, mas check_ins_count existe e será usada como alternativa' || E'\n';
        ELSE
          script := script || 'ALTER TABLE ' || missing_record.table_name || ' ADD COLUMN IF NOT EXISTS ' || missing_record.column_name || ' ';
          
          -- Determinar o tipo de dados baseado no nome da coluna
          IF missing_record.column_name IN ('id', 'user_id', 'challenge_id') THEN
            script := script || 'UUID';
            IF missing_record.column_name = 'id' THEN
              script := script || ' PRIMARY KEY DEFAULT uuid_generate_v4()';
            END IF;
          ELSIF missing_record.column_name IN ('points', 'position', 'check_ins_count', 'total_check_ins', 'consecutive_days') THEN
            script := script || 'INTEGER DEFAULT 0';
          ELSE
            script := script || 'TEXT';
          END IF;
          
          script := script || ';' || E'\n';
        END IF;
      ELSE
        -- Para outras tabelas
        script := script || 'ALTER TABLE ' || missing_record.table_name || ' ADD COLUMN IF NOT EXISTS ' || missing_record.column_name || ' ';
        
        -- Determinar o tipo de dados baseado no nome da coluna
        IF missing_record.column_name IN ('id', 'user_id', 'benefit_id', 'challenge_id') THEN
          script := script || 'UUID';
          IF missing_record.column_name = 'id' THEN
            script := script || ' PRIMARY KEY DEFAULT uuid_generate_v4()';
          END IF;
        ELSIF missing_record.column_name IN ('is_completed', 'is_redeemed', 'is_official', 'active') THEN
          script := script || 'BOOLEAN DEFAULT FALSE';
        ELSIF missing_record.column_name IN ('workouts', 'cups', 'current_value', 'target_value', 'points', 'position', 'check_ins_count', 'total_check_ins', 'consecutive_days', 'days_trained_this_month', 'duration_minutes') THEN
          script := script || 'INTEGER DEFAULT 0';
        ELSIF missing_record.column_name IN ('redeemed_at', 'expires_at', 'created_at', 'updated_at', 'start_date', 'end_date', 'expiration_date') THEN
          script := script || 'TIMESTAMP WITH TIME ZONE DEFAULT NOW()';
        ELSIF missing_record.column_name = 'date' THEN
          script := script || 'DATE DEFAULT CURRENT_DATE';
        ELSE
          script := script || 'TEXT';
        END IF;
        
        script := script || ';' || E'\n';
      END IF;
    END IF;
  END LOOP;
  
  script := script || E'\n-- Notificar sobre a execução do script\n';
  script := script || $notify$DO $$ BEGIN RAISE NOTICE 'Estruturas para o dashboard atualizadas'; END $$;$notify$;
  
  RETURN script;
END;
$$ LANGUAGE plpgsql;

-- Verifique as dependências do dashboard
SELECT * FROM check_dashboard_dependencies() WHERE NOT "exists";

-- Gere o script de correção
SELECT generate_dashboard_fix_script(); 