# Migração de Receitas - Bruna Braga Nutrição + RayClub

## Visão Geral
Esta migração atualiza completamente o sistema de receitas do app RayClub com 60 novas receitas fornecidas pela nutricionista Bruna Braga.

## Novos Filtros Implementados

### 1. Filtros de Objetivo (`filter_goal`)
- Emagrecimento
- Hipertrofia

### 2. Filtros de Paladar (`filter_taste`)
- Paladar Infantil
- Doce
- Salgado

### 3. Filtros de Refeição (`filter_meal`)
- Café da manhã
- Almoço
- Lanche da tarde
- Jantar

### 4. Filtros de Timing (`filter_timing`)
- Pré Treino
- Pós treino

### 5. Filtros de Nutrientes (`filter_nutrients`)
- Carboidratos
- Proteínas
- Gorduras

### 6. Outros Filtros (`filter_other`)
- Hidratante
- Detox
- Low Carb
- Vegano
- Funcional

## Estrutura dos Arquivos

1. **update_recipes_with_new_filters.sql**
   - Limpa as receitas antigas
   - Adiciona as novas colunas de filtros
   - Cria índices para otimizar as buscas

2. **insert_new_recipes_bruna_braga.sql** (Receitas 1-20)
3. **insert_new_recipes_bruna_braga_part2.sql** (Receitas 21-30)
4. **insert_new_recipes_bruna_braga_part3.sql** (Receitas 31-40)
5. **insert_new_recipes_bruna_braga_part4.sql** (Receitas 41-50)
6. **insert_new_recipes_bruna_braga_part5.sql** (Receitas 51-60)

## Como Executar

### Opção 1: Script Único
```bash
psql -U seu_usuario -d seu_banco -f sql/migrations/execute_recipes_migration.sql
```

### Opção 2: Arquivos Individuais
```bash
# 1. Atualizar estrutura
psql -U seu_usuario -d seu_banco -f sql/migrations/update_recipes_with_new_filters.sql

# 2. Inserir receitas
psql -U seu_usuario -d seu_banco -f sql/migrations/insert_new_recipes_bruna_braga.sql
psql -U seu_usuario -d seu_banco -f sql/migrations/insert_new_recipes_bruna_braga_part2.sql
psql -U seu_usuario -d seu_banco -f sql/migrations/insert_new_recipes_bruna_braga_part3.sql
psql -U seu_usuario -d seu_banco -f sql/migrations/insert_new_recipes_bruna_braga_part4.sql
psql -U seu_usuario -d seu_banco -f sql/migrations/insert_new_recipes_bruna_braga_part5.sql
```

## Informações das Receitas

Todas as receitas incluem:
- **Título**: Nome descritivo da receita
- **Descrição**: Breve descrição
- **Categoria**: Tipo de refeição
- **Tempo de preparo**: Em minutos
- **Valor calórico**: Estimado em kcal
- **Porções**: Quantidade que a receita rende
- **Ingredientes**: Lista completa
- **Modo de preparo**: Passo a passo
- **Dica nutricional**: Informação adicional da nutricionista
- **Informações nutricionais**: Proteínas, Carboidratos, Gorduras e Fibras
- **Filtros**: Múltiplos filtros para facilitar a busca

## Validação

Após executar a migração, você pode validar:

```sql
-- Verificar total de receitas
SELECT COUNT(*) FROM recipes;
-- Deve retornar: 60

-- Verificar receitas por autor
SELECT author_name, COUNT(*) FROM recipes GROUP BY author_name;
-- Deve retornar: Bruna Braga | 60
```

## Rollback

Se necessário reverter:

```sql
-- Remove apenas as receitas da Bruna Braga
DELETE FROM recipes WHERE author_name = 'Bruna Braga';

-- Remove as colunas de filtros (cuidado: isso afetará outras receitas se existirem)
ALTER TABLE recipes 
DROP COLUMN IF EXISTS filter_goal,
DROP COLUMN IF EXISTS filter_taste,
DROP COLUMN IF EXISTS filter_meal,
DROP COLUMN IF EXISTS filter_timing,
DROP COLUMN IF EXISTS filter_nutrients,
DROP COLUMN IF EXISTS filter_other;
``` 