# Configuração Final dos Vídeos dos Parceiros

## Status das Categorias ✅

As categorias foram criadas com sucesso com os seguintes IDs:

- **Musculação**: `d2d2a9b8-d861-47c7-9d26-283539beda24` (já existia)
- **Pilates**: `fe034f6d-aa79-436c-b0b7-7aea572f08c1`
- **Funcional**: `43eb2044-38cf-4193-848c-da46fd7e9cb4`
- **Corrida**: `07754890-b092-4386-be56-bb088a2a96f1`
- **Fisioterapia**: `da178dba-ae94-425a-aaed-133af7b1bb0f`

## Próximo Passo: Inserir os Vídeos

Execute o script `sql/migrations/insert_partner_videos_with_ids.sql` no Supabase SQL Editor.

Este script irá:
1. Limpar vídeos antigos dos parceiros (se existirem)
2. Inserir todos os vídeos com os IDs corretos das categorias
3. Marcar vídeos como novos e populares
4. Atualizar a contagem de vídeos por categoria

## Vídeos que Serão Inseridos

### Treinos de Musculação (1 vídeo)
- Apresentação

### Goya Health Club - Pilates (2 vídeos)
- Apresentação Pilates
- Mobilidade

### Fight Fit - Funcional (3 vídeos)
- Apresentação Fight Fit
- Abdominal
- Técnica

### Bora Assessoria - Corrida (1 vídeo)
- Apresentação

### The Unit - Fisioterapia (1 vídeo)
- Apresentação

**Total: 8 vídeos**

## Verificação Final

Após executar o script, você deve ver:
- 8 vídeos inseridos no total
- Contagem de vídeos atualizada em cada categoria
- Vídeos marcados como `is_new` e `is_popular`

## Teste no App

1. **Navegação**: Clique em cada parceiro na home
2. **Listagem**: Verifique se os vídeos aparecem na categoria correta
3. **Player**: Teste se os vídeos do YouTube abrem corretamente

## Troubleshooting

### Se algum vídeo não aparecer:
```sql
-- Verificar vídeos inseridos
SELECT wv.*, wc.name as category_name 
FROM workout_videos wv 
JOIN workout_categories wc ON wc.id = wv.category
WHERE wv.instructor_name IN ('Treinos de Musculação', 'Goya Health Club', 'Fight Fit', 'Bora Assessoria', 'The Unit')
ORDER BY wc.name, wv.order_index;
```

### Se a navegação falhar:
- Verifique se o método `getCategoryByName` está retornando as categorias
- Confirme que as rotas estão configuradas corretamente

## Scripts Disponíveis

1. **fix_partner_categories_correct.sql** - Cria/atualiza categorias
2. **insert_partner_videos_with_ids.sql** - Insere vídeos com IDs corretos
3. **partner_videos_complete_solution.sql** - Script completo (categorias + vídeos)

Use o script 2 agora, já que as categorias foram criadas! 