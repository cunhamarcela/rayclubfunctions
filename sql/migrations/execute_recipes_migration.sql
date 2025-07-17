-- Script para executar a migração completa das receitas da Bruna Braga Nutrição + RayClub

-- 1. Primeiro, atualiza a estrutura da tabela com os novos filtros
\echo 'Atualizando estrutura da tabela recipes...'
\i sql/migrations/update_recipes_with_new_filters.sql

-- 2. Depois, insere todas as receitas (60 receitas no total)
\echo 'Inserindo receitas parte 1 (1-20)...'
\i sql/migrations/insert_new_recipes_bruna_braga.sql

\echo 'Inserindo receitas parte 2 (21-30)...'
\i sql/migrations/insert_new_recipes_bruna_braga_part2.sql

\echo 'Inserindo receitas parte 3 (31-40)...'
\i sql/migrations/insert_new_recipes_bruna_braga_part3.sql

\echo 'Inserindo receitas parte 4 (41-50)...'
\i sql/migrations/insert_new_recipes_bruna_braga_part4.sql

\echo 'Inserindo receitas parte 5 (51-60)...'
\i sql/migrations/insert_new_recipes_bruna_braga_part5.sql

\echo 'Verificando resultados...'

-- Verificar o total de receitas inseridas
SELECT COUNT(*) as total_recipes FROM recipes;

-- Verificar a distribuição por filtros
SELECT 
    'Objetivo' as filter_type,
    unnest(filter_goal) as filter_value,
    COUNT(*) as count
FROM recipes
WHERE filter_goal IS NOT NULL AND array_length(filter_goal, 1) > 0
GROUP BY unnest(filter_goal)

UNION ALL

SELECT 
    'Paladar' as filter_type,
    unnest(filter_taste) as filter_value,
    COUNT(*) as count
FROM recipes
WHERE filter_taste IS NOT NULL AND array_length(filter_taste, 1) > 0
GROUP BY unnest(filter_taste)

UNION ALL

SELECT 
    'Refeição' as filter_type,
    unnest(filter_meal) as filter_value,
    COUNT(*) as count
FROM recipes
WHERE filter_meal IS NOT NULL AND array_length(filter_meal, 1) > 0
GROUP BY unnest(filter_meal)

UNION ALL

SELECT 
    'Timing' as filter_type,
    unnest(filter_timing) as filter_value,
    COUNT(*) as count
FROM recipes
WHERE filter_timing IS NOT NULL AND array_length(filter_timing, 1) > 0
GROUP BY unnest(filter_timing)

UNION ALL

SELECT 
    'Nutrientes' as filter_type,
    unnest(filter_nutrients) as filter_value,
    COUNT(*) as count
FROM recipes
WHERE filter_nutrients IS NOT NULL AND array_length(filter_nutrients, 1) > 0
GROUP BY unnest(filter_nutrients)

UNION ALL

SELECT 
    'Outros' as filter_type,
    unnest(filter_other) as filter_value,
    COUNT(*) as count
FROM recipes
WHERE filter_other IS NOT NULL AND array_length(filter_other, 1) > 0
GROUP BY unnest(filter_other)

ORDER BY filter_type, count DESC; 