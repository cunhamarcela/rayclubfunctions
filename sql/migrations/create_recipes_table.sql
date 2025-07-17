-- Criar enum para tipo de conteúdo
CREATE TYPE recipe_content_type AS ENUM ('text', 'video');

-- Criar enum para tipo de autor
CREATE TYPE recipe_author_type AS ENUM ('nutritionist', 'ray');

-- Criar tabela de receitas
CREATE TABLE IF NOT EXISTS recipes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    category VARCHAR(100) NOT NULL,
    image_url TEXT NOT NULL,
    preparation_time_minutes INTEGER NOT NULL,
    calories INTEGER NOT NULL,
    servings INTEGER NOT NULL,
    difficulty VARCHAR(50) NOT NULL,
    rating DECIMAL(2,1) DEFAULT 0,
    content_type recipe_content_type NOT NULL,
    author_name VARCHAR(255) NOT NULL,
    author_type recipe_author_type NOT NULL,
    is_featured BOOLEAN DEFAULT FALSE,
    
    -- Campos para conteúdo de texto
    ingredients TEXT[],
    instructions TEXT[],
    nutritionist_tip TEXT,
    
    -- Campos para conteúdo de vídeo
    video_url TEXT,
    video_id VARCHAR(50),
    video_duration INTEGER,
    
    -- Campos comuns
    tags TEXT[] NOT NULL DEFAULT '{}',
    nutritional_info JSONB,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Criar índices
CREATE INDEX idx_recipes_author_type ON recipes(author_type);
CREATE INDEX idx_recipes_content_type ON recipes(content_type);
CREATE INDEX idx_recipes_is_featured ON recipes(is_featured);
CREATE INDEX idx_recipes_category ON recipes(category);
CREATE INDEX idx_recipes_created_at ON recipes(created_at DESC);

-- Trigger para atualizar updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_recipes_updated_at BEFORE UPDATE
    ON recipes FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Políticas RLS
ALTER TABLE recipes ENABLE ROW LEVEL SECURITY;

-- Política de leitura: Todos podem ler
CREATE POLICY "Recipes are viewable by everyone" ON recipes
    FOR SELECT USING (true);

-- Política de inserção: Apenas admins
CREATE POLICY "Only admins can insert recipes" ON recipes
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM profiles
            WHERE profiles.id = auth.uid()
            AND profiles.is_admin = true
        )
    );

-- Política de atualização: Apenas admins
CREATE POLICY "Only admins can update recipes" ON recipes
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM profiles
            WHERE profiles.id = auth.uid()
            AND profiles.is_admin = true
        )
    );

-- Política de exclusão: Apenas admins
CREATE POLICY "Only admins can delete recipes" ON recipes
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM profiles
            WHERE profiles.id = auth.uid()
            AND profiles.is_admin = true
        )
    );

-- Inserir algumas receitas de exemplo
INSERT INTO recipes (
    title,
    description,
    category,
    image_url,
    preparation_time_minutes,
    calories,
    servings,
    difficulty,
    rating,
    content_type,
    author_name,
    author_type,
    is_featured,
    ingredients,
    instructions,
    nutritionist_tip,
    video_url,
    video_id,
    video_duration,
    tags,
    nutritional_info
) VALUES
(
    'Salada de Quinoa com Legumes',
    'Rica em proteínas e fibras, perfeita para o almoço',
    'Saladas',
    'https://images.unsplash.com/photo-1512621776951-a57141f2eefd',
    25,
    320,
    3,
    'Fácil',
    4.5,
    'text',
    'Dra. Maria Silva',
    'nutritionist',
    true,
    ARRAY[
        '1 xícara de quinoa',
        '2 xícaras de água',
        '1 pepino médio cortado em cubos',
        '2 tomates médios cortados em cubos',
        '1/2 pimentão vermelho cortado em cubos',
        '1/4 xícara de cebola roxa picada',
        '1/4 xícara de salsinha fresca picada',
        '3 colheres de sopa de azeite',
        '2 colheres de sopa de suco de limão',
        'Sal e pimenta a gosto'
    ],
    ARRAY[
        'Lave a quinoa em água corrente',
        'Em uma panela, leve a água para ferver e adicione a quinoa',
        'Cozinhe por 15 minutos ou até a água secar',
        'Deixe esfriar completamente',
        'Em uma tigela grande, misture a quinoa fria com os legumes cortados',
        'Em um recipiente pequeno, misture o azeite, suco de limão, sal e pimenta',
        'Despeje o molho sobre a salada e misture bem',
        'Adicione a salsinha e sirva gelada'
    ],
    'Para deixar a salada ainda mais nutritiva, adicione grão-de-bico ou feijão branco cozido!',
    NULL,
    NULL,
    NULL,
    ARRAY['vegano', 'sem glúten', 'rico em fibras', 'proteínas vegetais'],
    '{"Proteínas": "12g", "Carboidratos": "45g", "Gorduras": "14g", "Fibras": "8g", "Sódio": "250mg"}'::jsonb
),
(
    'Smoothie Verde Detox',
    'Perfeito para desintoxicar o organismo pela manhã',
    'Bebidas',
    'https://images.unsplash.com/photo-1556881286-fc6915169721',
    5,
    150,
    1,
    'Fácil',
    4.6,
    'text',
    'Dra. Maria Silva',
    'nutritionist',
    false,
    ARRAY[
        '1 folha de couve sem o talo',
        '1/2 maçã verde',
        '1/2 pepino',
        'Suco de 1/2 limão',
        '1 pedaço pequeno de gengibre',
        '200ml de água de coco',
        'Folhas de hortelã a gosto',
        'Gelo a gosto'
    ],
    ARRAY[
        'Lave bem todos os ingredientes',
        'Corte a maçã e o pepino em pedaços',
        'Coloque todos os ingredientes no liquidificador',
        'Bata por 2 minutos ou até ficar homogêneo',
        'Coe se preferir uma textura mais lisa',
        'Sirva imediatamente com gelo'
    ],
    'Tome em jejum para potencializar os efeitos detox!',
    NULL,
    NULL,
    NULL,
    ARRAY['detox', 'vegano', 'sem glúten', 'baixa caloria'],
    '{"Proteínas": "2g", "Carboidratos": "28g", "Gorduras": "1g", "Fibras": "4g", "Vitamina C": "45mg"}'::jsonb
),
(
    'Wrap de Frango Fit',
    'Perfeito para o pós-treino, rico em proteínas',
    'Lanches',
    'https://images.unsplash.com/photo-1626700051175-6818013e1d4f',
    15,
    380,
    1,
    'Médio',
    4.7,
    'video',
    'Ray Tavares',
    'ray',
    true,
    NULL,
    NULL,
    NULL,
    'https://youtu.be/ABC123',
    'ABC123',
    420,
    ARRAY['proteína', 'pós-treino', 'fitness', 'low carb'],
    '{"Proteínas": "38g", "Carboidratos": "22g", "Gorduras": "15g", "Fibras": "5g", "Sódio": "380mg"}'::jsonb
),
(
    'Panquecas de Aveia e Banana',
    'Café da manhã saudável e energético',
    'Café da Manhã',
    'https://images.unsplash.com/photo-1565299543923-37dd37887442',
    15,
    310,
    2,
    'Fácil',
    4.8,
    'text',
    'Dra. Maria Silva',
    'nutritionist',
    false,
    ARRAY[
        '1 banana madura',
        '2 ovos',
        '1/2 xícara de aveia em flocos',
        '1 colher de chá de canela em pó',
        '1 colher de chá de essência de baunilha',
        '1 pitada de sal',
        'Óleo de coco para untar'
    ],
    ARRAY[
        'Amasse a banana com um garfo',
        'Adicione os ovos e misture bem',
        'Acrescente a aveia, canela, baunilha e sal',
        'Misture até formar uma massa homogênea',
        'Aqueça uma frigideira antiaderente com um pouco de óleo de coco',
        'Coloque pequenas porções da massa na frigideira',
        'Cozinhe por 2-3 minutos de cada lado até dourar',
        'Sirva com frutas frescas e mel'
    ],
    'Adicione whey protein à massa para aumentar o valor proteico!',
    NULL,
    NULL,
    NULL,
    ARRAY['café da manhã', 'sem glúten', 'fitness', 'energia'],
    '{"Proteínas": "12g", "Carboidratos": "45g", "Gorduras": "8g", "Fibras": "6g", "Potássio": "420mg"}'::jsonb
),
(
    'Shake Proteico de Morango',
    'Recuperação muscular pós-treino',
    'Bebidas',
    'https://images.unsplash.com/photo-1553530666-ba11a90bb0b1',
    5,
    250,
    1,
    'Fácil',
    4.9,
    'video',
    'Ray Tavares',
    'ray',
    false,
    NULL,
    NULL,
    NULL,
    'https://youtu.be/XYZ789',
    'XYZ789',
    180,
    ARRAY['proteína', 'shake', 'pós-treino', 'morango'],
    '{"Proteínas": "25g", "Carboidratos": "28g", "Gorduras": "3g", "Fibras": "2g", "Cálcio": "250mg"}'::jsonb
); 