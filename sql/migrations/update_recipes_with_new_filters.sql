-- Limpar receitas antigas
TRUNCATE TABLE recipes CASCADE;

-- Adicionar novos campos de filtros se não existirem
ALTER TABLE recipes 
ADD COLUMN IF NOT EXISTS filter_goal TEXT[] DEFAULT '{}',
ADD COLUMN IF NOT EXISTS filter_taste TEXT[] DEFAULT '{}',
ADD COLUMN IF NOT EXISTS filter_meal TEXT[] DEFAULT '{}',
ADD COLUMN IF NOT EXISTS filter_timing TEXT[] DEFAULT '{}',
ADD COLUMN IF NOT EXISTS filter_nutrients TEXT[] DEFAULT '{}',
ADD COLUMN IF NOT EXISTS filter_other TEXT[] DEFAULT '{}';

-- Criar índices para os novos campos de filtros
CREATE INDEX IF NOT EXISTS idx_recipes_filter_goal ON recipes USING GIN(filter_goal);
CREATE INDEX IF NOT EXISTS idx_recipes_filter_taste ON recipes USING GIN(filter_taste);
CREATE INDEX IF NOT EXISTS idx_recipes_filter_meal ON recipes USING GIN(filter_meal);
CREATE INDEX IF NOT EXISTS idx_recipes_filter_timing ON recipes USING GIN(filter_timing);
CREATE INDEX IF NOT EXISTS idx_recipes_filter_nutrients ON recipes USING GIN(filter_nutrients);
CREATE INDEX IF NOT EXISTS idx_recipes_filter_other ON recipes USING GIN(filter_other);

-- Comentário sobre os filtros
COMMENT ON COLUMN recipes.filter_goal IS 'Filtros de objetivo: Emagrecimento, Hipertrofia';
COMMENT ON COLUMN recipes.filter_taste IS 'Filtros de paladar: Paladar Infantil, Doce, Salgado';
COMMENT ON COLUMN recipes.filter_meal IS 'Filtros de refeição: Café da manhã, Almoço, Lanche da tarde, Jantar';
COMMENT ON COLUMN recipes.filter_timing IS 'Filtros de timing: Pré Treino, Pós treino';
COMMENT ON COLUMN recipes.filter_nutrients IS 'Filtros de nutrientes: Carboidratos, Proteínas, Gorduras';
COMMENT ON COLUMN recipes.filter_other IS 'Outros filtros: Hidratante, Detox, Low Carb, Vegano, Funcional, etc'; 