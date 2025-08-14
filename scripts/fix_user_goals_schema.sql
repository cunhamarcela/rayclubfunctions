-- Script para corrigir e padronizar a estrutura da tabela user_goals
-- Data: 2025-01-21 às 14:30
-- Objetivo: Resolver problemas de mapeamento entre campos do Supabase e modelo Flutter

-- 1. Verificar estrutura atual da tabela
DO $$
BEGIN
    RAISE NOTICE 'Verificando estrutura atual da tabela user_goals...';
END $$;

-- 2. Garantir que a tabela existe com a estrutura correta
CREATE TABLE IF NOT EXISTS user_goals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    type TEXT NOT NULL DEFAULT 'custom',
    target DECIMAL NOT NULL DEFAULT 0,
    progress DECIMAL NOT NULL DEFAULT 0,
    unit TEXT NOT NULL DEFAULT '',
    start_date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    end_date TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Adicionar colunas de compatibilidade se não existirem
-- (Para suportar diferentes versões do esquema)
ALTER TABLE user_goals 
ADD COLUMN IF NOT EXISTS current_value DECIMAL,
ADD COLUMN IF NOT EXISTS target_value DECIMAL,
ADD COLUMN IF NOT EXISTS goal_type TEXT,
ADD COLUMN IF NOT EXISTS is_completed BOOLEAN DEFAULT FALSE;

-- 4. Migrar dados dos campos antigos para os novos (se existirem dados)
UPDATE user_goals 
SET 
    current_value = COALESCE(current_value, progress),
    target_value = COALESCE(target_value, target),
    goal_type = COALESCE(goal_type, type)
WHERE current_value IS NULL OR target_value IS NULL OR goal_type IS NULL;

-- 5. Sincronizar dados entre campos (garantir consistência)
UPDATE user_goals 
SET 
    progress = COALESCE(current_value, progress, 0),
    target = COALESCE(target_value, target, 0),
    type = COALESCE(goal_type, type, 'custom'),
    is_completed = CASE 
        WHEN completed_at IS NOT NULL THEN true
        WHEN COALESCE(current_value, progress, 0) >= COALESCE(target_value, target, 1) THEN true
        ELSE false
    END;

-- 6. Criar índices para melhorar performance (se não existirem)
CREATE INDEX IF NOT EXISTS user_goals_user_id_idx ON user_goals (user_id);
CREATE INDEX IF NOT EXISTS user_goals_type_idx ON user_goals (type);
CREATE INDEX IF NOT EXISTS user_goals_completed_idx ON user_goals (user_id, completed_at);
CREATE INDEX IF NOT EXISTS user_goals_created_at_idx ON user_goals (created_at DESC);

-- 7. Garantir que RLS está habilitado
ALTER TABLE user_goals ENABLE ROW LEVEL SECURITY;

-- 8. Recriar políticas de segurança (DROP se existir e CREATE novamente)
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
    target = CASE WHEN target <= 0 THEN 1 ELSE target END,
    progress = CASE WHEN progress < 0 THEN 0 ELSE progress END
WHERE title = '' OR title IS NULL 
   OR unit = '' OR unit IS NULL 
   OR type = '' OR type IS NULL 
   OR target <= 0 
   OR progress < 0;

-- 11. Log final
DO $$
DECLARE
    total_goals INTEGER;
    completed_goals INTEGER;
BEGIN
    SELECT COUNT(*) INTO total_goals FROM user_goals;
    SELECT COUNT(*) INTO completed_goals FROM user_goals WHERE is_completed = true;
    
    RAISE NOTICE 'Estrutura da tabela user_goals corrigida!';
    RAISE NOTICE 'Total de metas: %', total_goals;
    RAISE NOTICE 'Metas completadas: %', completed_goals;
END $$; 