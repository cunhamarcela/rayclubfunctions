# Correção de Navegação e Vídeos dos Parceiros

## Problemas Identificados

1. **Navegação incorreta**: Ao clicar no parceiro na home, não navegava diretamente para a categoria correta
2. **Vídeos vazios**: As categorias apareciam sem vídeos
3. **Erro 404 na thumbnail**: URL do vídeo "Abdominal" tinha um espaço extra causando erro
4. **Erro SQL**: Tabela `workout_categories` não tem coluna `icon` e usa UUID como ID

## Correções Aplicadas

### 1. Correção da Navegação (✅ Aplicada no código)

**Arquivo**: `lib/features/home/screens/home_screen.dart`

- Modificado o método `_navigateToWorkoutsByCategory` para:
  - Mapear corretamente as categorias dos parceiros
  - Buscar o ID da categoria pelo nome no banco
  - Navegar diretamente para a tela de vídeos da categoria específica

### 2. Correção do Espaço na URL (✅ Aplicada no código)

**Arquivo**: `lib/features/home/screens/home_screen.dart`

- Removido espaço extra na URL do vídeo "Abdominal"

### 3. Adição de Método no Repositório (✅ Aplicada no código)

**Arquivo**: `lib/features/workout/repositories/workout_repository.dart`

- Adicionado método `getCategoryByName` para buscar categoria por nome

### 4. Script SQL Corrigido (✅ Criado)

**Arquivo**: `sql/migrations/fix_partner_videos_final.sql`

- Script atualizado baseado na estrutura real da tabela
- Usa `workoutsCount` ao invés de `workouts_count`
- Remove referência à coluna `icon` inexistente
- Usa subqueries para buscar IDs das categorias dinamicamente

## Instruções de Execução

### 1. Execute o Script SQL no Supabase

Execute o script `sql/migrations/fix_partner_videos_final.sql` no Supabase SQL Editor:

```sql
-- 1. Primeiro execute para ver as categorias existentes
SELECT id, name, description FROM workout_categories ORDER BY name;

-- 2. Se as categorias dos parceiros não existirem, execute o script completo
-- O script criará as categorias e inserirá os vídeos automaticamente
```

### 2. Verifique os Resultados

Após executar o script, verifique se:
- As categorias foram criadas
- Os vídeos foram inseridos
- A contagem de vídeos foi atualizada

### 3. Teste no App

1. **Navegação dos Parceiros**:
   - Clique em um parceiro na home
   - Deve navegar diretamente para a tela de vídeos da categoria
   - Os vídeos devem aparecer listados

2. **Reprodução de Vídeos**:
   - Clique em um vídeo
   - O player do YouTube deve abrir corretamente

## Estrutura das Categorias

As categorias dos parceiros são mapeadas assim:

- **Treinos de Musculação** → Categoria: "Musculação"
- **Goya Health Club** → Categoria: "Pilates"
- **Fight Fit** → Categoria: "Funcional"
- **Bora Assessoria** → Categoria: "Corrida"
- **The Unit** → Categoria: "Fisioterapia"

## Troubleshooting

### Se as categorias não aparecerem:

1. Verifique se as categorias existem no banco:
```sql
SELECT * FROM workout_categories WHERE name IN ('Musculação', 'Pilates', 'Funcional', 'Corrida', 'Fisioterapia');
```

2. Se não existirem, execute apenas a parte de criação de categorias do script

### Se os vídeos não aparecerem:

1. Verifique se os vídeos foram inseridos:
```sql
SELECT wv.*, wc.name as category_name 
FROM workout_videos wv 
JOIN workout_categories wc ON wc.id = wv.category
ORDER BY wc.name;
```

2. Verifique se o campo `category` dos vídeos corresponde aos IDs das categorias

### Se a navegação falhar:

1. Verifique os logs do console para erros
2. Certifique-se de que o método `getCategoryByName` está funcionando
3. Verifique se as rotas estão configuradas corretamente no `app_router.dart`

## Status Final

- ✅ Navegação corrigida
- ✅ Método de busca por nome implementado
- ✅ Script SQL atualizado para estrutura real
- ✅ URLs dos vídeos corrigidas
- ✅ Importações necessárias adicionadas

O sistema agora deve funcionar corretamente, navegando diretamente para a categoria do parceiro e exibindo os vídeos correspondentes. 