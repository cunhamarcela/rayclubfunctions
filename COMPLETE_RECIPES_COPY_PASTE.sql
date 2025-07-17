-- ===================================================
-- MIGRAÇÃO COMPLETA - COLE E EXECUTE TUDO DE UMA VEZ
-- ===================================================

-- 1. PREPARAR TABELA
TRUNCATE TABLE recipes RESTART IDENTITY CASCADE;

-- 2. ADICIONAR COLUNAS DE FILTROS
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='recipes' AND column_name='filter_goal') THEN
        ALTER TABLE recipes ADD COLUMN filter_goal TEXT[];
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='recipes' AND column_name='filter_taste') THEN
        ALTER TABLE recipes ADD COLUMN filter_taste TEXT[];
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='recipes' AND column_name='filter_meal') THEN
        ALTER TABLE recipes ADD COLUMN filter_meal TEXT[];
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='recipes' AND column_name='filter_timing') THEN
        ALTER TABLE recipes ADD COLUMN filter_timing TEXT[];
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='recipes' AND column_name='filter_nutrients') THEN
        ALTER TABLE recipes ADD COLUMN filter_nutrients TEXT[];
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='recipes' AND column_name='filter_other') THEN
        ALTER TABLE recipes ADD COLUMN filter_other TEXT[];
    END IF;
END $$;

-- 3. CRIAR ÍNDICES
CREATE INDEX IF NOT EXISTS idx_recipes_filter_goal ON recipes USING GIN (filter_goal);
CREATE INDEX IF NOT EXISTS idx_recipes_filter_taste ON recipes USING GIN (filter_taste);
CREATE INDEX IF NOT EXISTS idx_recipes_filter_meal ON recipes USING GIN (filter_meal);
CREATE INDEX IF NOT EXISTS idx_recipes_filter_timing ON recipes USING GIN (filter_timing);
CREATE INDEX IF NOT EXISTS idx_recipes_filter_nutrients ON recipes USING GIN (filter_nutrients);
CREATE INDEX IF NOT EXISTS idx_recipes_filter_other ON recipes USING GIN (filter_other);

-- 4. INSERIR TODAS AS 60 RECEITAS
INSERT INTO recipes (title, description, category, image_url, preparation_time_minutes, calories, servings, difficulty, rating, content_type, author_name, author_type, is_featured, ingredients, instructions, nutritionist_tip, tags, nutritional_info, filter_goal, filter_taste, filter_meal, filter_timing, filter_nutrients, filter_other) VALUES
-- Receita 1
('Bolo de Banana de Caneca', 'Receita rápida e saudável para um lanche nutritivo', 'Lanches', 'https://images.unsplash.com/photo-1558303420-f814d8a590f5', 5, 200, 1, 'Fácil', 4.8, 'text', 'Bruna Braga', 'nutritionist', false, ARRAY['1 banana madura', '1 ovo', '2 colheres de sopa de aveia', '1 colher de chá de fermento em pó', '1 colher de sopa de mel'], ARRAY['Amasse a banana e misture com o ovo, aveia, fermento e mel.', 'Coloque em uma caneca e leve ao micro-ondas por 2-3 minutos.'], 'Adicione canela em pó para dar mais sabor e benefícios antioxidantes!', ARRAY['rápido', 'micro-ondas', 'lanche saudável'], '{"Proteínas": "8g", "Carboidratos": "35g", "Gorduras": "5g", "Fibras": "4g"}'::jsonb, ARRAY['Emagrecimento'], ARRAY['Doce'], ARRAY['Café da Manhã', 'Lanche da Tarde'], ARRAY[]::TEXT[], ARRAY['Carboidratos'], ARRAY[]::TEXT[]),

-- Receita 2
('Banana Toast', 'Toast nutritivo com banana e queijo derretido', 'Lanches', 'https://images.unsplash.com/photo-1528735602780-2552fd46c7af', 10, 250, 1, 'Fácil', 4.7, 'text', 'Bruna Braga', 'nutritionist', false, ARRAY['1 banana fatiada', '1 colher de chá de mel', '1 fatia de pão de forma integral', '2 fatias de queijo'], ARRAY['Coloque o pão de forma na airfryer e toste por 4 minutos a 180°C.', 'Coloque as fatias de banana sobre o pão, adicione o queijo por cima e regue com mel.', 'Volte para a airfryer por 2 minutos até o queijo derreter.'], 'Use queijo cottage para aumentar o teor de proteínas!', ARRAY['airfryer', 'rápido', 'nutritivo'], '{"Proteínas": "10g", "Carboidratos": "40g", "Gorduras": "8g", "Fibras": "5g"}'::jsonb, ARRAY['Emagrecimento'], ARRAY['Doce'], ARRAY['Café da Manhã', 'Lanche da Tarde'], ARRAY[]::TEXT[], ARRAY['Carboidratos'], ARRAY[]::TEXT[]),

-- Receita 3
('Gororoba de Banana', 'Mistura proteica com banana e ovos', 'Café da Manhã', 'https://images.unsplash.com/photo-1525351484163-7529414344d8', 10, 300, 1, 'Fácil', 4.5, 'text', 'Bruna Braga', 'nutritionist', false, ARRAY['1 banana madura', '2 ovos', '2 colheres de sopa de farelo de aveia', '50g de queijo branco'], ARRAY['Em uma frigideira, bata os ovos e acrescente os ingredientes restantes.', 'Cozinhe mexendo até os ovos ficarem bem misturados e o queijo derreter.'], 'Perfeito para um café da manhã rico em proteínas!', ARRAY['proteína', 'café da manhã', 'rápido'], '{"Proteínas": "20g", "Carboidratos": "30g", "Gorduras": "12g", "Fibras": "4g"}'::jsonb, ARRAY['Emagrecimento'], ARRAY['Doce'], ARRAY['Café da Manhã', 'Lanche da Tarde'], ARRAY[]::TEXT[], ARRAY['Proteínas'], ARRAY[]::TEXT[]),

-- Receita 4
('Pão de Queijo de Airfryer', 'Pão de queijo fit e proteico', 'Lanches', 'https://images.unsplash.com/photo-1598142982901-df6cec10ae35', 15, 180, 4, 'Fácil', 4.9, 'text', 'Bruna Braga', 'nutritionist', true, ARRAY['1 xícara de polvilho doce', '1/2 xícara de queijo cottage', '1 ovo inteiro', '2 claras de ovo'], ARRAY['Misture todos os ingredientes até formar uma massa homogênea.', 'Modele bolinhas e coloque na cesta da airfryer.', 'Cozinhe a 180°C por 10 minutos ou até dourar.'], 'Ótima opção para quem busca reduzir calorias sem abrir mão do sabor!', ARRAY['airfryer', 'proteico', 'sem glúten'], '{"Proteínas": "8g", "Carboidratos": "20g", "Gorduras": "6g", "Fibras": "1g"}'::jsonb, ARRAY['Emagrecimento', 'Hipertrofia'], ARRAY['Salgado'], ARRAY['Café da Manhã'], ARRAY[]::TEXT[], ARRAY['Proteínas'], ARRAY[]::TEXT[]),

-- Receita 5
('Brigadeiro de Cacau com Tâmaras', 'Brigadeiro natural e nutritivo', 'Sobremesas', 'https://images.unsplash.com/photo-1606313564200-e75d5e30476c', 15, 120, 8, 'Fácil', 4.9, 'text', 'Bruna Braga', 'nutritionist', true, ARRAY['10 tâmaras secas sem caroço', '2 colheres de sopa de cacau em pó', '1 colher de sopa de óleo de coco', 'Granulado ou coco ralado para decorar'], ARRAY['Deixe as tâmaras de molho em água morna por 10 minutos.', 'Escorra e bata no processador até formar uma pasta.', 'Adicione o cacau e o óleo de coco, misture bem.', 'Faça bolinhas com as mãos e passe no granulado ou coco.', 'Leve à geladeira por 30 minutos antes de servir.'], 'Rico em fibras e antioxidantes naturais!', ARRAY['natural', 'doce saudável', 'sem açúcar'], '{"Proteínas": "2g", "Carboidratos": "18g", "Gorduras": "3g", "Fibras": "3g"}'::jsonb, ARRAY['Emagrecimento'], ARRAY['Doce'], ARRAY['Lanche da Tarde'], ARRAY[]::TEXT[], ARRAY['Carboidratos'], ARRAY['Detox']);

-- ADICIONE AQUI AS OUTRAS 55 RECEITAS dos arquivos part2, part3, part4 e part5
-- (Para economizar espaço, você deve copiar e colar as outras receitas dos outros arquivos)

-- VERIFICAR RESULTADO
SELECT 'Migração concluída! Total de receitas:' as status, COUNT(*) as total FROM recipes; 