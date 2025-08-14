-- =====================================================
-- 🎯 ATUALIZAÇÃO FINAL DO ESQUEMA DE METAS
-- =====================================================
-- Data: 2025-01-30
-- Objetivo: Alinhar sistema de metas com workout_records
-- Funcionalidade: Integração automática treinos → metas
-- =====================================================

-- 1. Adicionar colunas necessárias à tabela user_goals
ALTER TABLE public.user_goals ADD COLUMN IF NOT EXISTS category TEXT;
ALTER TABLE public.user_goals ADD COLUMN IF NOT EXISTS measurement_type TEXT NOT NULL DEFAULT 'minutes';

-- 2. Criar índices para performance
CREATE INDEX IF NOT EXISTS idx_user_goals_category ON public.user_goals(category);
CREATE INDEX IF NOT EXISTS idx_user_goals_measurement_type ON public.user_goals(measurement_type);

-- 3. Adicionar comentários para documentação
COMMENT ON COLUMN public.user_goals.category IS 'Categoria da meta (ex: Funcional, Musculação). NULL para metas personalizadas.';
COMMENT ON COLUMN public.user_goals.measurement_type IS 'Tipo de medição: "minutes" (progresso numérico) ou "days" (check-ins).';

-- 4. Função para atualizar metas automaticamente quando treinos são registrados
CREATE OR REPLACE FUNCTION update_goals_from_workout()
RETURNS TRIGGER AS $$
BEGIN
    -- Atualizar metas que coincidem com o tipo de treino registrado
    -- e que são medidas em minutos
    UPDATE public.user_goals 
    SET 
        progress = progress + NEW.duration_minutes,
        updated_at = NOW()
    WHERE 
        user_id = NEW.user_id
        AND category = NEW.workout_type
        AND measurement_type = 'minutes'
        AND completed_at IS NULL; -- Apenas metas não concluídas
    
    -- Log da operação (opcional)
    RAISE NOTICE 'Meta atualizada para usuário % com % minutos de %', 
        NEW.user_id, NEW.duration_minutes, NEW.workout_type;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 5. Criar trigger para executar a função automaticamente
DROP TRIGGER IF EXISTS trigger_update_goals_from_workout ON public.workout_records;
CREATE TRIGGER trigger_update_goals_from_workout
    AFTER INSERT OR UPDATE ON public.workout_records
    FOR EACH ROW
    WHEN (NEW.is_completed = true)
    EXECUTE FUNCTION update_goals_from_workout();

-- 6. Função para registrar check-in manual (para metas medidas em dias)
CREATE OR REPLACE FUNCTION register_goal_checkin(
    p_goal_id UUID,
    p_user_id UUID
)
RETURNS BOOLEAN AS $$
DECLARE
    v_goal_exists BOOLEAN;
    v_current_progress INTEGER;
    v_target INTEGER;
BEGIN
    -- Verificar se a meta existe e pertence ao usuário
    SELECT 
        (progress::INTEGER) < (target::INTEGER),
        progress::INTEGER,
        target::INTEGER
    INTO v_goal_exists, v_current_progress, v_target
    FROM public.user_goals 
    WHERE 
        id = p_goal_id 
        AND user_id = p_user_id 
        AND measurement_type = 'days'
        AND completed_at IS NULL;
    
    -- Se não encontrou a meta ou já está completa
    IF NOT FOUND OR NOT v_goal_exists THEN
        RETURN FALSE;
    END IF;
    
    -- Incrementar progresso
    UPDATE public.user_goals 
    SET 
        progress = progress + 1,
        updated_at = NOW(),
        -- Marcar como concluída se atingiu o target
        completed_at = CASE 
            WHEN (progress + 1) >= target THEN NOW() 
            ELSE completed_at 
        END
    WHERE id = p_goal_id;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- 7. Criar constraint para validar measurement_type
ALTER TABLE public.user_goals 
DROP CONSTRAINT IF EXISTS check_measurement_type;

ALTER TABLE public.user_goals 
ADD CONSTRAINT check_measurement_type 
CHECK (measurement_type IN ('minutes', 'days'));

-- 8. Atualizar dados existentes (se houver)
UPDATE public.user_goals 
SET measurement_type = 'minutes' 
WHERE measurement_type IS NULL;

-- =====================================================
-- VERIFICAÇÕES FINAIS
-- =====================================================

-- Verificar se as colunas foram criadas
SELECT 
    'Verificação do esquema atualizado' as status,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'user_goals' 
  AND column_name IN ('category', 'measurement_type')
ORDER BY column_name;

-- Verificar se os triggers foram criados
SELECT 
    'Triggers criados' as status,
    trigger_name,
    event_manipulation,
    action_timing,
    action_statement
FROM information_schema.triggers 
WHERE trigger_name = 'trigger_update_goals_from_workout';

-- Verificar se as funções foram criadas
SELECT 
    'Funções criadas' as status,
    routine_name,
    routine_type
FROM information_schema.routines 
WHERE routine_name IN ('update_goals_from_workout', 'register_goal_checkin')
  AND routine_schema = 'public';

