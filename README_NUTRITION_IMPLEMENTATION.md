# Implementação da Tela de Nutrição

## Visão Geral

A tela de nutrição foi atualizada para suportar conteúdo real do Supabase, com três abas principais:
- **Receitas**: Receitas em texto com ingredientes, instruções e dicas
- **Vídeos**: Receitas em vídeo com player do YouTube integrado  
- **Materiais**: PDFs, ebooks e guias nutricionais (em desenvolvimento)

## Arquivos Criados/Modificados

### 1. Modelos
- `lib/features/nutrition/models/recipe.dart`: Modelo de dados para receitas
  - Suporta tipos de conteúdo: `text` e `video`
  - Campos específicos para cada tipo de conteúdo
  - Integração com Freezed para imutabilidade

### 2. Repositório
- `lib/features/nutrition/repositories/recipe_repository.dart`: Repositório para buscar receitas
  - Métodos para buscar receitas da nutricionista
  - Busca de receitas em destaque
  - Busca por ID
  - Busca com filtros

### 3. Providers
- `lib/features/nutrition/providers/recipe_providers.dart`: Providers Riverpod
  - `recipeRepositoryProvider`: Provider do repositório
  - `nutritionistRecipesProvider`: Receitas da nutricionista
  - `featuredRecipesProvider`: Receitas em destaque
  - `recipeByIdProvider`: Busca receita específica

### 4. Widgets
- `lib/features/nutrition/widgets/youtube_player_widget.dart`: Widget do YouTube Player
  - Player responsivo
  - Controles customizados
  - Suporte a fullscreen

### 5. Telas
- `lib/features/nutrition/screens/nutrition_screen.dart`: Tela principal atualizada
  - Três abas: Receitas, Vídeos e Materiais
  - Indicadores visuais para vídeos
  - Estados de loading e erro
  - Integração com dados reais
  - Vídeo de apresentação da nutricionista mantido

- `lib/features/nutrition/screens/recipe_detail_screen.dart`: Tela de detalhes
  - Suporta conteúdo de texto (ingredientes, instruções)
  - Suporta conteúdo de vídeo (YouTube Player)
  - Informações nutricionais
  - Design responsivo

### 6. Banco de Dados
- `sql/migrations/create_recipes_table.sql`: Script SQL para criar tabela
  - Tabela `recipes` com todos os campos necessários
  - Políticas RLS configuradas
  - Dados de exemplo inseridos

### 7. Testes
- `test/features/nutrition/screens/nutrition_screen_test.dart`: Testes básicos
  - Teste de loading
  - Teste de tabs (3 abas)
  - Teste de estado vazio
  - Teste de erro
  - Teste da aba Materiais

## Como Usar

### 1. Executar Migration no Supabase
```sql
-- Execute o arquivo sql/migrations/create_recipes_table.sql no Supabase
```

### 2. Configurar YouTube API (se necessário)
O `youtube_player_flutter` já está configurado no pubspec.yaml

### 3. Adicionar Receitas
As receitas podem ser adicionadas diretamente no Supabase com:
- `content_type`: 'text' ou 'video'
- `author_type`: 'nutritionist'
- Para vídeos: adicionar `video_id` do YouTube

## Estrutura de Dados

### Receita de Texto
```json
{
  "title": "Salada de Quinoa",
  "content_type": "text",
  "author_type": "nutritionist",
  "ingredients": ["1 xícara de quinoa", "..."],
  "instructions": ["Lave a quinoa", "..."],
  "nutritionist_tip": "Dica especial..."
}
```

### Receita de Vídeo
```json
{
  "title": "Bowl de Açaí",
  "content_type": "video",
  "author_type": "nutritionist",
  "video_id": "dQw4w9WgXcQ",
  "video_url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
}
```

## Estrutura das Abas

### Aba Receitas
- Exibe receitas do tipo `text`
- Lista com cards informativos
- Tempo de preparo e dificuldade
- Navegação para detalhes

### Aba Vídeos  
- Exibe receitas do tipo `video`
- Cards com indicador de vídeo
- Player integrado nos detalhes
- Thumbnails do YouTube

### Aba Materiais
- Placeholder para futuros materiais
- PDFs, ebooks e guias
- Interface preparada para expansão

## Próximos Passos

1. Implementar busca/filtros
2. Adicionar funcionalidade de favoritos
3. Implementar compartilhamento
4. Adicionar conteúdo na aba Materiais
5. Implementar cache offline 