-- =====================================================
-- 🔍 DIAGNÓSTICO COMPLETO - RAY CLUB METAS SYSTEM
-- =====================================================
-- Data: 2025-01-30
-- Objetivo: Análise completa da estrutura atual de metas
-- Versão: 1.0.0
-- =====================================================

-- ============== SEÇÃO 1: ANÁLISE DE ESTRUTURA ==============

-- 1.1 - Verificar se a tabela user_goals existe e sua estrutura
DO $$
BEGIN
    RAISE NOTICE '🏗️  === ANÁLISE DE ESTRUTURA DA TABELA user_goals ===';
END $$;

SELECT 
    '📋 ESTRUTURA DA TABELA user_goals' as diagnostico,
    column_name as coluna,
    data_type as tipo,
    is_nullable as permite_null,
    column_default as valor_padrao,
    character_maximum_length as tamanho_max
FROM information_schema.columns 
WHERE table_schema = 'public' AND table_name = 'user_goals'
ORDER BY ordinal_position;

-- 1.2 - Verificar índices existentes
SELECT 
    '🔍 ÍNDICES DA TABELA user_goals' as diagnostico,
    indexname as nome_indice,
    indexdef as definicao
FROM pg_indexes 
WHERE tablename = 'user_goals' AND schemaname = 'public';

-- 1.3 - Verificar políticas de segurança (RLS)
SELECT 
    '🔒 POLÍTICAS RLS da user_goals' as diagnostico,
    policyname as nome_politica,
    permissive as tipo,
    roles as funcoes,
    cmd as comando,
    qual as condicao
FROM pg_policies 
WHERE tablename = 'user_goals' AND schemaname = 'public';

-- ============== SEÇÃO 2: ANÁLISE DE DADOS EXISTENTES ==============

DO $$
BEGIN
    RAISE NOTICE '📊 === ANÁLISE DE DADOS EXISTENTES ===';
END $$;

-- 2.1 - Contagem total de metas
SELECT 
    '📈 ESTATÍSTICAS GERAIS' as diagnostico,
    COUNT(*) as total_metas,
    COUNT(DISTINCT user_id) as usuarios_com_metas,
    COUNT(CASE WHEN completed_at IS NOT NULL THEN 1 END) as metas_concluidas,
    COUNT(CASE WHEN completed_at IS NULL THEN 1 END) as metas_ativas
FROM user_goals;

-- 2.2 - Análise por tipo de meta
SELECT 
    '🏷️  DISTRIBUIÇÃO POR TIPO' as diagnostico,
    type as tipo_meta,
    COUNT(*) as quantidade,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM user_goals), 2) as percentual
FROM user_goals 
GROUP BY type 
ORDER BY quantidade DESC;

-- 2.3 - Análise por unidade de medida
SELECT 
    '📏 DISTRIBUIÇÃO POR UNIDADE' as diagnostico,
    unit as unidade,
    COUNT(*) as quantidade,
    ROUND(AVG(target), 2) as meta_media,
    ROUND(AVG(progress), 2) as progresso_medio
FROM user_goals 
GROUP BY unit 
ORDER BY quantidade DESC;

-- 2.4 - Metas criadas por mês (últimos 6 meses)
SELECT 
    '📅 CRIAÇÃO DE METAS (ÚLTIMOS 6 MESES)' as diagnostico,
    DATE_TRUNC('month', created_at) as mes,
    COUNT(*) as metas_criadas,
    COUNT(CASE WHEN completed_at IS NOT NULL THEN 1 END) as metas_concluidas_no_mes
FROM user_goals 
WHERE created_at >= NOW() - INTERVAL '6 months'
GROUP BY DATE_TRUNC('month', created_at)
ORDER BY mes DESC;

-- ============== SEÇÃO 3: VERIFICAÇÃO DE CONSISTÊNCIA ==============

DO $$
BEGIN
    RAISE NOTICE '🔧 === VERIFICAÇÃO DE CONSISTÊNCIA ===';
END $$;

-- 3.1 - Verificar metas com problemas de dados
SELECT 
    '⚠️  METAS COM PROBLEMAS' as diagnostico,
    'Target menor ou igual a zero' as problema,
    COUNT(*) as quantidade
FROM user_goals 
WHERE target <= 0

UNION ALL

SELECT 
    '⚠️  METAS COM PROBLEMAS' as diagnostico,
    'Progress maior que target' as problema,
    COUNT(*) as quantidade
FROM user_goals 
WHERE progress > target

UNION ALL

SELECT 
    '⚠️  METAS COM PROBLEMAS' as problema,
    'Data fim anterior a data início' as diagnostico,
    COUNT(*) as quantidade
FROM user_goals 
WHERE end_date IS NOT NULL AND end_date < start_date

UNION ALL

SELECT 
    '⚠️  METAS COM PROBLEMAS' as diagnostico,
    'Título vazio ou muito curto' as problema,
    COUNT(*) as quantidade
FROM user_goals 
WHERE title IS NULL OR LENGTH(TRIM(title)) < 3;

-- 3.2 - Verificar referências de usuários
SELECT 
    '👥 VERIFICAÇÃO DE USUÁRIOS' as diagnostico,
    COUNT(DISTINCT ug.user_id) as usuarios_com_metas,
    COUNT(DISTINCT au.id) as usuarios_validos_auth,
    COUNT(DISTINCT ug.user_id) - COUNT(DISTINCT au.id) as usuarios_orfaos
FROM user_goals ug
FULL OUTER JOIN auth.users au ON ug.user_id = au.id;

-- ============== SEÇÃO 4: ANÁLISE DE PERFORMANCE ==============

DO $$
BEGIN
    RAISE NOTICE '⚡ === ANÁLISE DE PERFORMANCE ===';
END $$;

-- 4.1 - Tamanho da tabela
SELECT 
    '💾 INFORMAÇÕES DE ARMAZENAMENTO' as diagnostico,
    pg_size_pretty(pg_total_relation_size('user_goals')) as tamanho_total,
    pg_size_pretty(pg_relation_size('user_goals')) as tamanho_tabela,
    (SELECT COUNT(*) FROM user_goals) as total_registros;

-- 4.2 - Queries mais lentas (se houver extensão pg_stat_statements)
SELECT 
    '🐌 QUERIES MAIS LENTAS (se disponível)' as diagnostico,
    CASE 
        WHEN EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_stat_statements') 
        THEN 'Extensão disponível - análise possível'
        ELSE 'Extensão pg_stat_statements não instalada'
    END as status;

-- ============== SEÇÃO 5: AMOSTRAS DE DADOS ==============

DO $$
BEGIN
    RAISE NOTICE '🎯 === AMOSTRAS DE DADOS ===';
END $$;

-- 5.1 - Primeiros 5 registros para análise
SELECT 
    '📋 AMOSTRA DOS DADOS (5 primeiros)' as diagnostico,
    id,
    user_id,
    title,
    type,
    target,
    progress,
    unit,
    created_at,
    CASE 
        WHEN completed_at IS NOT NULL THEN 'Concluída'
        ELSE 'Ativa'
    END as status
FROM user_goals 
ORDER BY created_at DESC 
LIMIT 5;

-- 5.2 - Metas com maior progresso
SELECT 
    '🏆 TOP 5 METAS COM MAIOR PROGRESSO' as diagnostico,
    title,
    type,
    ROUND((progress / NULLIF(target, 0)) * 100, 2) as percentual_conclusao,
    unit,
    created_at
FROM user_goals 
WHERE target > 0
ORDER BY (progress / target) DESC 
LIMIT 5;

-- ============== SEÇÃO 6: RECOMENDAÇÕES ==============

DO $$
BEGIN
    RAISE NOTICE '💡 === RECOMENDAÇÕES ===';
END $$;

-- 6.1 - Verificar se as novas colunas (category, measurement_type) existem
SELECT 
    '🔍 VERIFICAÇÃO DAS NOVAS COLUNAS' as diagnostico,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'user_goals' AND column_name = 'category'
        ) THEN 'Coluna category EXISTE'
        ELSE 'Coluna category NÃO EXISTE - Executar script update_goals_schema.sql'
    END as status_category,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'user_goals' AND column_name = 'measurement_type'
        ) THEN 'Coluna measurement_type EXISTE'
        ELSE 'Coluna measurement_type NÃO EXISTE - Executar script update_goals_schema.sql'
    END as status_measurement_type;

-- ============== SEÇÃO 7: OUTRAS TABELAS RELACIONADAS ==============

DO $$
BEGIN
    RAISE NOTICE '🔗 === TABELAS RELACIONADAS ===';
END $$;

-- 7.1 - Verificar outras tabelas de metas que podem existir
SELECT 
    '📋 OUTRAS TABELAS DE METAS NO SISTEMA' as diagnostico,
    table_name as nome_tabela,
    CASE 
        WHEN table_name LIKE '%goal%' OR table_name LIKE '%meta%' THEN 'Relacionada a metas'
        ELSE 'Possivelmente relacionada'
    END as relevancia
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND (table_name LIKE '%goal%' OR table_name LIKE '%meta%' OR table_name LIKE '%weekly%')
ORDER BY table_name;

-- 7.2 - Verificar se existem funções SQL relacionadas a metas
SELECT 
    '⚙️  FUNÇÕES SQL RELACIONADAS A METAS' as diagnostico,
    routine_name as nome_funcao,
    routine_type as tipo
FROM information_schema.routines 
WHERE routine_schema = 'public' 
  AND (routine_name LIKE '%goal%' OR routine_name LIKE '%meta%' OR routine_name LIKE '%weekly%')
ORDER BY routine_name;

-- ============== FINAL DO DIAGNÓSTICO ==============

DO $$
BEGIN
    RAISE NOTICE '✅ === DIAGNÓSTICO COMPLETO FINALIZADO ===';
    RAISE NOTICE '📊 Execute este script no SQL Editor do Supabase';
    RAISE NOTICE '🔍 Analise os resultados para entender o estado atual';
    RAISE NOTICE '🛠️  Use as recomendações para próximos passos';
END $$; 