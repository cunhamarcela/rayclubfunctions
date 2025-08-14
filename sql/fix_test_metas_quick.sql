-- =====================================================
-- 🔧 CORREÇÃO RÁPIDA PARA TESTES DE METAS
-- =====================================================
-- Data: 2025-01-30
-- Problema: Coluna "description" não existe na tabela
-- =====================================================

-- 1. Verificar estrutura atual da tabela
SELECT 
    '📋 ESTRUTURA ATUAL DA TABELA user_goals' AS info,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'user_goals' 
  AND table_schema = 'public'
ORDER BY ordinal_position;

-- 2. Adicionar coluna description se não existir
ALTER TABLE public.user_goals ADD COLUMN IF NOT EXISTS description TEXT;

-- 3. Verificar se foi adicionada
SELECT 
    '✅ ESTRUTURA APÓS CORREÇÃO' AS info,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'user_goals' 
  AND table_schema = 'public'
  AND column_name IN ('category', 'measurement_type', 'description')
ORDER BY column_name;

-- 4. Ajustar o teste para usar apenas as colunas que existem
-- Meta de minutos (sem description por agora)
INSERT INTO public.user_goals (
    id, user_id, title, type, category, 
    target, progress, unit, measurement_type,
    start_date, created_at
) VALUES (
    '11111111-1111-1111-1111-111111111111'::uuid, 
    '01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid, 
    'TESTE: Meta Funcional', 
    'workout_category', 'Funcional',
    150.0, 0.0, 'minutos', 'minutes',
    NOW(), NOW()
) ON CONFLICT (id) DO UPDATE SET
    title = EXCLUDED.title,
    target = EXCLUDED.target,
    updated_at = NOW();

SELECT '✅ Meta de teste criada com sucesso!' AS resultado;

-- 5. Testar função de trigger
SELECT 
    '📊 Meta antes do treino' AS status,
    id,
    title,
    category,
    progress,
    measurement_type
FROM public.user_goals 
WHERE id = '11111111-1111-1111-1111-111111111111'::uuid;

