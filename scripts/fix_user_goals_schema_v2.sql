-- Script para corrigir e padronizar a estrutura da tabela user_goals (Versão 2)
-- Data: 2025-01-21 às 14:40
-- Objetivo: Resolver problemas de mapeamento entre campos do Supabase e modelo Flutter

-- 1. Verificar estrutura atual da tabela
DO $$
BEGIN
    RAISE NOTICE 'Verificando estrutura atual da tabela user_goals...';
END $$;

-- 2. Primeiro, vamos consultar as colunas existentes
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'user_goals' 
ORDER BY ordinal_position;

-- 3. Garantir que a tabela existe com a estrutura básica
CREATE TABLE IF NOT EXISTS user_goals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL DEFAULT '',
    description TEXT,
    type TEXT NOT NULL DEFAULT 'custom',
    unit TEXT NOT NULL DEFAULT '',
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. Adicionar colunas que podem estar faltando (sem tentar migrar dados ainda)
ALTER TABLE user_goals 
ADD COLUMN IF NOT EXISTS target DECIMAL DEFAULT 0,
ADD COLUMN IF NOT EXISTS progress DECIMAL DEFAULT 0,
ADD COLUMN IF NOT EXISTS current_value DECIMAL DEFAULT 0,
ADD COLUMN IF NOT EXISTS target_value DECIMAL DEFAULT 0,
ADD COLUMN IF NOT EXISTS goal_type TEXT DEFAULT 'custom',
ADD COLUMN IF NOT EXISTS start_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
ADD COLUMN IF NOT EXISTS end_date TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS completed_at TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS is_completed BOOLEAN DEFAULT FALSE;

-- 5. Agora vamos sincronizar dados entre campos existentes de forma segura
-- Somente atualizar se as colunas existirem e os valores forem nulos

DO $$
BEGIN
    -- Verificar se a coluna progress existe antes de tentar migrar
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_goals' AND column_name = 'progress') THEN
        UPDATE user_goals 
        SET current_value = COALESCE(current_value, progress)
        WHERE current_value IS NULL OR current_value = 0;
    END IF;
    
    -- Verificar se a coluna target existe antes de tentar migrar
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_goals' AND column_name = 'target') THEN
        UPDATE user_goals 
        SET target_value = COALESCE(target_value, target)
        WHERE target_value IS NULL OR target_value = 0;
    END IF;
    
    -- Sincronizar campos de tipo
    UPDATE user_goals 
    SET goal_type = COALESCE(goal_type, type)
    WHERE goal_type IS NULL OR goal_type = '';
    
    -- Garantir consistência entre campos duplicados
    UPDATE user_goals 
    SET 
        progress = COALESCE(progress, current_value, 0),
        target = COALESCE(target, target_value, 1),
        type = COALESCE(type, goal_type, 'custom'),
        is_completed = CASE 
            WHEN completed_at IS NOT NULL THEN true
            WHEN COALESCE(current_value, progress, 0) >= COALESCE(target_value, target, 1) THEN true
            ELSE false
        END;
    
    RAISE NOTICE 'Migração de dados concluída com sucesso!';
END $$;

-- 6. Criar índices para melhorar performance (se não existirem)
CREATE INDEX IF NOT EXISTS user_goals_user_id_idx ON user_goals (user_id);
CREATE INDEX IF NOT EXISTS user_goals_type_idx ON user_goals (type);
CREATE INDEX IF NOT EXISTS user_goals_completed_idx ON user_goals (user_id, completed_at);
CREATE INDEX IF NOT EXISTS user_goals_created_at_idx ON user_goals (created_at DESC);

-- 7. Garantir que RLS está habilitado
ALTER TABLE user_goals ENABLE ROW LEVEL SECURITY;

-- 8. Recriar políticas de segurança
DROP POLICY IF EXISTS "Usuários podem visualizar suas próprias metas" ON user_goals;
DROP POLICY IF EXISTS "Usuários podem criar suas próprias metas" ON user_goals;
DROP POLICY IF EXISTS "Usuários podem atualizar suas próprias metas" ON user_goals;
DROP POLICY IF EXISTS "Usuários podem excluir suas próprias metas" ON user_goals;

CREATE POLICY "Usuários podem visualizar suas próprias metas"
ON user_goals FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Usuários podem criar suas próprias metas"
ON user_goals FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuários podem atualizar suas próprias metas"
ON user_goals FOR UPDATE
USING (auth.uid() = user_id);

CREATE POLICY "Usuários podem excluir suas próprias metas"
ON user_goals FOR DELETE
USING (auth.uid() = user_id);

-- 9. Criar trigger para atualizar updated_at automaticamente
CREATE OR REPLACE FUNCTION update_user_goals_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_user_goals_updated_at_trigger ON user_goals;
CREATE TRIGGER update_user_goals_updated_at_trigger
    BEFORE UPDATE ON user_goals
    FOR EACH ROW
    EXECUTE FUNCTION update_user_goals_updated_at();

-- 10. Validar dados e corrigir inconsistências
UPDATE user_goals 
SET 
    title = COALESCE(NULLIF(title, ''), 'Meta sem título'),
    unit = COALESCE(NULLIF(unit, ''), 'unidade'),
    type = COALESCE(NULLIF(type, ''), 'custom'),
    target = CASE WHEN COALESCE(target, target_value, 0) <= 0 THEN 1 ELSE COALESCE(target, target_value, 1) END,
    progress = CASE WHEN COALESCE(progress, current_value, 0) < 0 THEN 0 ELSE COALESCE(progress, current_value, 0) END
WHERE title = '' OR title IS NULL 
   OR unit = '' OR unit IS NULL 
   OR type = '' OR type IS NULL 
   OR COALESCE(target, target_value, 0) <= 0 
   OR COALESCE(progress, current_value, 0) < 0;

-- 11. Log final com contagem
DO $$
DECLARE
    total_goals INTEGER;
    completed_goals INTEGER;
    goal_columns TEXT;
BEGIN
    SELECT COUNT(*) INTO total_goals FROM user_goals;
    SELECT COUNT(*) INTO completed_goals FROM user_goals WHERE is_completed = true;
    
    -- Listar colunas da tabela
    SELECT string_agg(column_name, ', ' ORDER BY ordinal_position) INTO goal_columns
    FROM information_schema.columns 
    WHERE table_name = 'user_goals';
    
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Estrutura da tabela user_goals corrigida!';
    RAISE NOTICE 'Total de metas: %', total_goals;
    RAISE NOTICE 'Metas completadas: %', completed_goals;
    RAISE NOTICE 'Colunas disponíveis: %', goal_columns;
    RAISE NOTICE '========================================';
END $$; 