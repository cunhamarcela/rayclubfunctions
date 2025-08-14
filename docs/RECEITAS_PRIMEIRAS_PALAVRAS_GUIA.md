# 📋 Guia: Análise das 74 Receitas por Primeiras Palavras

**Data de criação:** 2025-01-21 20:50  
**Objetivo:** Listar e analisar todas as receitas do banco com foco nas primeiras palavras dos títulos

## 🎯 Objetivo da Análise

Este guia contém scripts SQL para analisar as 74 receitas do Ray Club App, com foco específico nas **primeiras palavras** dos títulos das receitas. Isso ajuda a:

- ✅ Identificar padrões nos nomes das receitas
- ✅ Verificar consistência na nomenclatura  
- ✅ Encontrar oportunidades de organização
- ✅ Analisar a distribuição por categorias e autores

## 📁 Scripts Disponíveis

### 1. Script Completo: `sql/listar_74_receitas_primeiras_palavras.sql`

**O que faz:**
- Análise completa em 8 seções diferentes
- Contagem total e verificação
- Lista detalhada com primeiras palavras
- Análise de frequência das palavras
- Breakdown por categoria e autor
- Receitas destacadas e em vídeo
- Resumo estatístico final

**Quando usar:** Para uma análise completa e detalhada

### 2. Script Simples: `sql/receitas_primeiras_palavras_simples.sql`

**O que faz:**
- Lista direta ordenada por primeiras palavras
- Ranking das palavras mais usadas
- Busca rápida alfabética
- Contagem final simples

**Quando usar:** Para consulta rápida e resultados diretos

## 🔧 Como Executar

### No Supabase Dashboard:
1. Acesse o **SQL Editor** do seu projeto Supabase
2. Cole o conteúdo do script escolhido
3. Clique em **Run** para executar
4. Visualize os resultados em seções organizadas

### Via CLI do Supabase:
```bash
# Script completo
supabase db reset --db-url "sua-url-do-supabase" < sql/listar_74_receitas_primeiras_palavras.sql

# Script simples  
supabase db reset --db-url "sua-url-do-supabase" < sql/receitas_primeiras_palavras_simples.sql
```

## 📊 Resultados Esperados

### Script Completo (8 Seções):

1. **🔢 Contagem Total:** Verificação das 74 receitas + breakdown por tipo
2. **📋 Lista Completa:** Todas as receitas com 1ª, 2ª e 3ª palavras extraídas
3. **🔍 Frequência:** Ranking das primeiras palavras mais usadas
4. **📂 Por Categoria:** Análise agrupada por categoria culinária
5. **👨‍🍳 Por Autor:** Estatísticas por autor (Bruna Braga, Ray, etc.)
6. **⭐ Receitas Destaque:** Somente receitas marcadas como `is_featured = true`
7. **🎬 Receitas em Vídeo:** Análise específica de conteúdo em vídeo
8. **📊 Resumo Final:** Estatísticas consolidadas

### Script Simples (4 Consultas):

1. **🔤 Lista Ordenada:** Receitas ordenadas por primeira palavra + info essencial
2. **📊 Ranking de Palavras:** Top palavras mais frequentes com %
3. **🎯 Busca Alfabética:** Índice alfabético por primeira palavra
4. **📈 Contagem Final:** Totais e médias gerais

## 🎨 Funcionalidades Especiais

### Extração Inteligente de Palavras:
```sql
-- Primeira palavra
SPLIT_PART(title, ' ', 1) 

-- Duas primeiras palavras
SPLIT_PART(title, ' ', 1) || ' ' || SPLIT_PART(title, ' ', 2)

-- Três primeiras palavras (com lógica condicional)
CASE 
    WHEN SPLIT_PART(title, ' ', 3) != '' THEN 
        SPLIT_PART(title, ' ', 1) || ' ' || SPLIT_PART(title, ' ', 2) || ' ' || SPLIT_PART(title, ' ', 3)
    ELSE 
        SPLIT_PART(title, ' ', 1) || ' ' || SPLIT_PART(title, ' ', 2)
END
```

### Indicadores Visuais:
- ⭐ = Receita em destaque (`is_featured = true`)
- 🎬 = Receita em vídeo (`content_type = 'video'`)
- 📝 = Receita em texto (`content_type = 'text'`)

### Estatísticas Automáticas:
- Frequência e porcentagem de cada primeira palavra
- Tempo médio de preparo por categoria/autor
- Calorias médias e avaliações
- Contagem de receitas por tipo e autor

## 🛠️ Estrutura da Tabela Recipes

```sql
-- Campos principais analisados:
- title (VARCHAR(255)) - Título da receita
- category (VARCHAR(100)) - Categoria culinária  
- author_name (VARCHAR(255)) - Nome do autor
- author_type (ENUM) - 'nutritionist' ou 'ray'
- content_type (ENUM) - 'text' ou 'video'
- is_featured (BOOLEAN) - Se é receita destacada
- preparation_time_minutes (INTEGER) - Tempo de preparo
- calories (INTEGER) - Calorias por porção
- rating (DECIMAL) - Avaliação da receita
- tags (TEXT[]) - Tags associadas
```

## 💡 Casos de Uso

### Para Análise de Conteúdo:
- Identificar receitas com nomes similares
- Verificar consistência na nomenclatura
- Encontrar gaps nas categorias

### Para Organização:
- Agrupar receitas por palavras-chave
- Criar índices de busca mais eficientes
- Padronizar nomes de receitas

### Para Estratégia:
- Identificar tipos de receita mais populares
- Analisar distribuição por autor
- Planejar novos conteúdos baseado em padrões

## 🔍 Exemplos de Resultados

### Ranking de Primeiras Palavras (Exemplo):
```
Posição | Primeira Palavra | Quantidade | % Total | Receitas
1       | Smoothie         | 8          | 10.8%   | Smoothie Verde • Smoothie Tropical • ...
2       | Salada           | 6          | 8.1%    | Salada Caesar • Salada de Frutas • ...
3       | Bolo             | 5          | 6.8%    | Bolo de Cenoura • Bolo Integral • ...
```

### Lista Organizada (Exemplo):
```
# | 1ª Palavra | 2 Primeiras | Título Completo | Categoria | Autor | Destaque
1 | Açaí       | Açaí Bowl   | Açaí Bowl Nutritivo | Breakfast | Bruna | ⭐
2 | Bolo       | Bolo de     | Bolo de Banana Fit | Dessert   | Bruna |  
```

## 📝 Notas Importantes

- ✅ Scripts testados com a estrutura atual da tabela `recipes`
- ✅ Compatível com PostgreSQL (Supabase)
- ✅ Resultados organizados e legíveis
- ✅ Inclui tratamento para títulos longos (truncamento inteligente)
- ✅ Ordenação alfabética e por frequência
- ✅ Estatísticas percentuais automáticas

## 🚀 Próximos Passos

Após executar a análise, você pode:

1. **Identificar Inconsistências:** Receitas com nomes muito similares
2. **Padronizar Nomenclatura:** Definir padrões para novos títulos
3. **Otimizar Busca:** Criar índices baseados nas primeiras palavras mais comuns
4. **Planejar Conteúdo:** Focar em categorias com menos receitas

---

**📌 Suporte Técnico:**  
- Estrutura: MVVM + Riverpod
- Banco: Supabase (PostgreSQL)  
- Linguagem: SQL com funções específicas do PostgreSQL
- Tom: Linguagem acolhedora e otimista ✨ 