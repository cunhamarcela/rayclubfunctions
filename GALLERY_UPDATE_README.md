# Atualização da Galeria de Destaques do Ray Club

Implementamos uma nova galeria de destaques no estilo NFT para a tela inicial do Ray Club App. Esta atualização transforma a seção "Destaques da Semana" em uma galeria visual moderna similar à referência fornecida.

## O que foi alterado

1. **Componente de Galeria**: Criamos o novo componente `WeeklyGalleryGrid` que exibe os destaques em cards visuais com imagens artísticas e preços estilizados em ETH.

2. **Modelo de Dados**: Atualizamos o modelo `WeeklyHighlight` para incluir:
   - `artImage`: Campo para a imagem artística do card
   - `price`: Valor exibido em ETH no card

3. **Interface do Usuário**: Redesenhamos a seção de destaques na tela inicial para seguir a referência visual fornecida.

4. **Tratamento de Erros**: Implementamos fallbacks para quando as imagens não estão disponíveis.

## Como usar

### 1. Adicionar imagens de arte

Para completar a implementação, você precisa adicionar imagens de arte no diretório `assets/images/`. Consulte o arquivo `assets/images/README_ART_IMAGES.md` para detalhes sobre as imagens necessárias:

- `art_landscape_1.jpg`
- `art_landscape_2.jpg`
- `art_castle.jpg`
- `art_mountains.jpg`
- `art_seascape.jpg`
- `art_building.jpg`

### 2. Atualizar o pubspec.yaml

Certifique-se de que as imagens estão declaradas no `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/images/
```

### 3. Personalizando os destaques

Para personalizar os destaques exibidos, você pode:

1. Editar o método `getMockWeeklyHighlights()` em `lib/features/home/models/weekly_highlight.dart`
2. Ou implementar o repositório `SupabaseWeeklyHighlightsRepository` para buscar dados reais do backend.

## Personalização adicional

Você pode personalizar ainda mais a galeria modificando:

- **Valores exibidos**: Altere o campo `price` nos modelos
- **Formatação**: Ajuste o formato de exibição em `_GalleryCard` no arquivo `lib/features/home/widgets/weekly_gallery_grid.dart`
- **Estilo**: Modifique as bordas, sombras e outras propriedades visuais

## Próximos passos

1. Implementar a integração com Supabase para dados reais
2. Adicionar animações de transição ao selecionar um card
3. Implementar a tela de detalhes para cada item da galeria 