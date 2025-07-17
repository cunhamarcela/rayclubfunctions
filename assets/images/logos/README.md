# Diretório de Logos do Ray Club

Este diretório contém todos os logos utilizados no aplicativo Ray Club, organizados por categoria.

## Estrutura de Pastas

```
logos/
├── app/          # Logos do próprio Ray Club (diferentes variações)
├── partners/     # Logos de parceiros e patrocinadores
├── brands/       # Logos de marcas relacionadas
├── social/       # Logos de redes sociais
├── backgrounds/  # Imagens de background/fundos para telas
└── README.md     # Este arquivo
```

## Convenções de Nomenclatura

Para manter a consistência, siga estas convenções ao adicionar novos logos:

1. Use apenas letras minúsculas e underscores no nome dos arquivos
2. Para logos principais, use o formato: `nome_do_logo.png` (preferencialmente PNG com fundo transparente)
3. Para variações, use o formato: `nome_do_logo_variante.png` (ex: ray_club_horizontal.png)
4. Para versões coloridas diferentes, use: `nome_do_logo_cor.png` (ex: ray_club_white.png)

## Otimização de Imagens

Para manter o aplicativo com tamanho reduzido e garantir que os logos sejam exibidos corretamente:

- Formato: Prefira PNG para logos com transparência, SVG para logos vetoriais (escaláveis)
- Resolução: 
  - Logos padrão: 512x512px ou proporcional
  - Ícones: 192x192px
  - Logos horizontais: mantenha proporção adequada (ex: 800x300px)
  - Backgrounds: Prefira JPG com compressão adequada (1200x1600px ou proporcional à tela)
- Compressão: Use ferramentas como TinyPNG para otimizar os arquivos sem perder qualidade
- Transparência: Certifique-se de que os logos com fundo transparente realmente têm transparência
- Backgrounds: Use JPG comprimido (qualidade 75-80%) para fundos que não precisam de transparência

## Como Adicionar um Novo Logo

1. Prepare a imagem seguindo as convenções acima
2. Coloque o arquivo na pasta da categoria apropriada
3. Abra o arquivo `lib/core/constants/app_logos.dart`
4. Adicione a constante para o novo logo seguindo o modelo existente
5. Adicione o logo à lista da categoria correspondente
6. Execute `flutter pub get` para atualizar o cache de assets

## Exemplo de Adição no Código

```dart
// No arquivo lib/core/constants/app_logos.dart

// 1. Adicione a constante
static const Logo novoLogo = Logo(
  id: 'novo_logo_id',
  name: 'Nome do Novo Logo',
  path: '$_partnersPath/novo_logo.png',
  category: LogoCategory.partners,
  hasTransparency: true,
);

// 2. Adicione à lista da categoria apropriada
static const List<Logo> partnerLogos = [
  // logos existentes...
  novoLogo,
];

// 3. Certifique-se de que está incluído na lista allLogos
static const List<Logo> allLogos = [
  ...appLogos,
  ...socialLogos,
  ...partnerLogos,
  // outras categorias...
];
```

## Uso em Widgets

Para usar um logo no código:

```dart
import 'package:ray_club_app/core/constants/app_logos.dart';

// Usando logo diretamente
Image.asset(
  AppLogos.rayClubPrimary.path,
  width: 120,
  height: 120,
)

// Ou pelo ID
final logo = AppLogos.getLogoById('ray_club_primary');
if (logo != null) {
  Image.asset(
    logo.path,
    width: 120,
    height: 120,
  )
}

// Buscando por categoria
final socialLogos = AppLogos.getLogosByCategory(LogoCategory.social);
``` 