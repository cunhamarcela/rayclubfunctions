-- =====================================
-- SISTEMA DE RECEITAS FAVORITAS
-- Criado em: 2025-01-27 às 23:15
-- Objetivo: Permitir usuários salvarem suas receitas favoritas
-- =====================================

-- Criar tabela para favoritos de receitas
CREATE TABLE IF NOT EXISTS user_favorite_recipes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    recipe_id UUID NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Garantir que um usuário não pode favoritar a mesma receita duas vezes
    CONSTRAINT user_favorite_recipes_unique UNIQUE (user_id, recipe_id)
);

-- Criar índices para performance
CREATE INDEX IF NOT EXISTS idx_user_favorite_recipes_user_id 
    ON user_favorite_recipes(user_id);
    
CREATE INDEX IF NOT EXISTS idx_user_favorite_recipes_recipe_id 
    ON user_favorite_recipes(recipe_id);
    
CREATE INDEX IF NOT EXISTS idx_user_favorite_recipes_created_at 
    ON user_favorite_recipes(created_at DESC);

-- Trigger para atualizar updated_at automaticamente
CREATE OR REPLACE FUNCTION update_user_favorite_recipes_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_user_favorite_recipes_timestamp
    BEFORE UPDATE ON user_favorite_recipes
    FOR EACH ROW
    EXECUTE FUNCTION update_user_favorite_recipes_timestamp();

-- Configurar Row Level Security (RLS)
ALTER TABLE user_favorite_recipes ENABLE ROW LEVEL SECURITY;

-- Políticas de segurança: usuários só podem ver/modificar seus próprios favoritos
CREATE POLICY "Usuários podem visualizar seus próprios favoritos" 
    ON user_favorite_recipes FOR SELECT 
    USING (auth.uid() = user_id);

CREATE POLICY "Usuários podem adicionar seus próprios favoritos" 
    ON user_favorite_recipes FOR INSERT 
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuários podem remover seus próprios favoritos" 
    ON user_favorite_recipes FOR DELETE 
    USING (auth.uid() = user_id);

-- Função para verificar se uma receita é favorita de um usuário
CREATE OR REPLACE FUNCTION is_recipe_favorited(p_user_id UUID, p_recipe_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM user_favorite_recipes 
        WHERE user_id = p_user_id AND recipe_id = p_recipe_id
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para obter receitas favoritas com dados completos
CREATE OR REPLACE FUNCTION get_user_favorite_recipes(p_user_id UUID)
RETURNS TABLE (
    recipe_id UUID,
    title TEXT,
    description TEXT,
    category TEXT,
    image_url TEXT,
    preparation_time_minutes INTEGER,
    calories INTEGER,
    servings INTEGER,
    difficulty TEXT,
    rating DECIMAL(2,1),
    content_type recipe_content_type,
    author_name TEXT,
    is_featured BOOLEAN,
    tags TEXT[],
    favorited_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        r.id,
        r.title,
        r.description,
        r.category,
        r.image_url,
        r.preparation_time_minutes,
        r.calories,
        r.servings,
        r.difficulty,
        r.rating,
        r.content_type,
        r.author_name,
        r.is_featured,
        r.tags,
        ufr.created_at as favorited_at
    FROM recipes r
    INNER JOIN user_favorite_recipes ufr ON r.id = ufr.recipe_id
    WHERE ufr.user_id = p_user_id
    ORDER BY ufr.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant permissions para as funções
GRANT EXECUTE ON FUNCTION is_recipe_favorited(UUID, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_user_favorite_recipes(UUID) TO authenticated; 