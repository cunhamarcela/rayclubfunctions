-- Adiciona a coluna 'category' para armazenar a categoria da meta pré-definida.
-- Esta coluna será usada para as novas opções: Funcional, Musculação, Yoga, etc.
ALTER TABLE public.user_goals
ADD COLUMN category TEXT;

-- Adiciona um índice na nova coluna para otimizar as consultas.
CREATE INDEX idx_user_goals_category ON public.user_goals(category);

-- Adiciona um comentário na coluna para documentar seu propósito.
COMMENT ON COLUMN public.user_goals.category IS 'Categoria da meta pré-definida (ex: funcional, yoga, cardio). Aplicável quando o tipo da meta é "workout".';

-- Adiciona a coluna 'measurement_type' para diferenciar a forma de medição.
-- 'days' será usado para metas de check-in (bolinhas) e 'minutes' para progresso numérico.
ALTER TABLE public.user_goals
ADD COLUMN measurement_type TEXT NOT NULL DEFAULT 'minutes';

-- Adiciona um índice na nova coluna.
CREATE INDEX idx_user_goals_measurement_type ON public.user_goals(measurement_type);

-- Adiciona um comentário na coluna para documentação.
COMMENT ON COLUMN public.user_goals.measurement_type IS 'Tipo de medição da meta: "days" (para check-ins) ou "minutes" (para progresso numérico).'; 