# Configuração do pubspec.yaml - Ray Club Migration

## Passo 1: Criar pubspec.yaml

Crie um arquivo `pubspec.yaml` na raiz do projeto com o seguinte conteúdo:

```yaml
name: ray_club_app
description: Ray Club - Fitness and Challenge App
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # Supabase (base de dados)
  supabase_flutter: ^2.0.2
  supabase: ^2.6.3
  postgrest: ^2.0.0
  realtime_client: ^2.0.0
  
  # Cloudflare e Storage
  aws_signature_v4: ^0.5.1
  dio_smart_retry: ^6.0.0
  path: ^1.8.3

  # State Management
  flutter_bloc: ^8.1.3
  bloc: ^8.1.2
  equatable: ^2.0.5
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3

  # UI e Estilo
  cupertino_icons: ^1.0.2
  flutter_svg: ^2.0.9
  cached_network_image: ^3.3.0
  shimmer: ^3.0.0
  google_fonts: ^6.1.0
  intl: ^0.19.0
  flutter_spinkit: ^5.2.0

  # Utilitários
  shared_preferences: ^2.2.2
  url_launcher: ^6.2.2
  image_picker: ^1.0.5
  google_sign_in: ^6.1.6
  connectivity_plus: ^5.0.2
  path_provider: ^2.1.1
  logger: ^2.0.2+1

  # Navegação e Rotas
  auto_route: ^7.8.4
  provider: ^6.1.1

  # HTTP e Utilidades
  http: ^1.1.2
  uuid: ^4.2.1
  flutter_staggered_grid_view: ^0.7.0
  flutter_cache_manager: ^3.3.1
  flutter_image_compress: ^2.1.0
  carousel_slider: ^4.2.1
  table_calendar: ^3.1.3

  # Segurança e Networking
  flutter_secure_storage: ^9.0.0
  dio: ^5.4.0
  permission_handler: ^11.3.0
  device_info_plus: ^9.1.1
  flutter_local_notifications: ^16.3.3
  get_it: ^7.6.4
  share_plus: ^7.2.2
  video_player: ^2.8.3
  fl_chart: ^0.65.0

  # Persistência de Dados (Hive)
  hive_flutter: ^1.1.0
  hive: ^2.2.3
  
  # Assets e Animações
  introduction_screen: ^3.1.14
  lottie: ^3.1.0
  flutter_dotenv: ^5.1.0

  # Tracking
  app_tracking_transparency: ^2.0.4

dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter

  # Testes e Mocking
  bloc_test: ^9.1.5
  mockito: ^5.4.3
  mocktail: ^1.0.3

  # Qualidade do Código
  flutter_lints: ^2.0.0
  build_runner: ^2.4.7
  hive_generator: ^2.0.1
  riverpod_generator: ^2.3.9
  
  # App Icons & Splash
  flutter_launcher_icons: ^0.13.1
  flutter_native_splash: ^2.3.1

flutter:
  uses-material-design: true
  assets:
    - .env
    - assets/images/
    - assets/icons/
    - assets/fonts/

  fonts:
    - family: Poppins
      fonts:
        - asset: assets/fonts/Poppins-Regular.ttf
        - asset: assets/fonts/Poppins-Medium.ttf
          weight: 500
        - asset: assets/fonts/Poppins-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Poppins-Bold.ttf
          weight: 700
```

## Passo 2: Instalar Dependências

Execute o seguinte comando para instalar as dependências:

```bash
flutter pub get
```

## Checklist de Verificação

- [x] Arquivo pubspec.yaml criado
- [x] Todas as dependências necessárias incluídas
- [x] Versões das dependências compatíveis
- [x] Assets configurados corretamente
- [x] Fontes configuradas corretamente
- [x] `flutter pub get` executado com sucesso

## Próximos Passos

1. Verifique se todas as dependências foram instaladas corretamente
2. Confirme se não há conflitos de versões
3. Prossiga para o próximo arquivo: `03_env.md`

## Observações

- As versões das dependências foram atualizadas para as mais recentes estáveis
- Certifique-se de que todas as fontes listadas existem no diretório de assets
- Algumas dependências podem requerer configuração adicional em arquivos específicos da plataforma (iOS/Android)
- Se encontrar conflitos de versão, ajuste as versões conforme necessário 