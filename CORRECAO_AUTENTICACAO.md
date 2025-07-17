# Correção dos Problemas de Autenticação do Ray Club App

## Problemas Identificados

Após análise dos logs e do código-fonte, identificamos os seguintes problemas no sistema de autenticação:

1. **Falta configuração do Supabase**: As solicitações HTTP estão falhando com erro "No host specified in URI"
2. **Autenticação Google não configurada corretamente**: Falha no processo de autenticação com o provedor Google
3. **Ícone do Google não encontrado**: O asset `assets/icons/google.png` não está sendo localizado
4. **Rota de recuperação de senha não funciona**: Erro ao acessar a rota de recuperação de senha

## Soluções

### 1. Configurar arquivo .env

Crie ou atualize o arquivo `.env` na raiz do projeto com as seguintes informações:

```
# Variáveis de ambiente do Ray Club App

# Ambiente (development, staging, production)
ENVIRONMENT=development
APP_VERSION=1.0.0

# URLs da API e Storage
API_URL=https://api.rayclub.app
STORAGE_URL=https://storage.rayclub.app

# Configurações do Supabase - SUBSTITUA COM SUAS CREDENCIAIS REAIS
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here

# Ambiente de desenvolvimento - SUBSTITUA COM SUAS CREDENCIAIS REAIS
DEV_SUPABASE_URL=https://your-dev-project-id.supabase.co
DEV_SUPABASE_ANON_KEY=your-dev-anon-key-here
DEV_API_URL=https://dev-api.rayclub.app

# Ambiente de staging
STAGING_SUPABASE_URL=https://your-staging-project-id.supabase.co
STAGING_SUPABASE_ANON_KEY=your-staging-anon-key-here
STAGING_API_URL=https://staging-api.rayclub.app
STAGING_DEBUG_MODE=true

# Ambiente de produção
PROD_SUPABASE_URL=https://your-prod-project-id.supabase.co
PROD_SUPABASE_ANON_KEY=your-prod-anon-key-here
PROD_API_URL=https://api.rayclub.app

# Storage buckets
STORAGE_WORKOUT_BUCKET=workout-images
STORAGE_PROFILE_BUCKET=profile-images
STORAGE_NUTRITION_BUCKET=nutrition-images
STORAGE_FEATURED_BUCKET=featured-images
STORAGE_CHALLENGE_BUCKET=challenge-media

# Configurações de análise
ANALYTICS_ENABLED=true
ANALYTICS_KEY=your-analytics-key

# Nome do aplicativo
APP_NAME=Ray Club

# Versão da API
API_VERSION=v1
```

### 2. Configurar Auth do Supabase

1. Acesse o console do Supabase
2. Vá para Authentication > Providers
3. Confirme que o "Email" está habilitado para login/senha
4. Configure o provedor "Google OAuth" com as seguintes informações:
   - **Redirect URL**: `rayclub://login-callback/` para aplicativo móvel
   - **Authorized domains**: adicione os domínios necessários
   - **Client ID** e **Client Secret**: obtenha do Google Cloud Console

### 3. Corrigir ícone do Google

Verifique se o ícone do Google existe no diretório correto:

```
assets/
└── icons/
    └── google.png
```

Se não existir, adicione-o. Se o caminho estiver incorreto no código, atualize o caminho no arquivo que carrega o ícone.

### 4. Configurar Deep Links

1. Configure corretamente os deep links no arquivo `AndroidManifest.xml`:

```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="rayclub" android:host="login-callback" />
</intent-filter>
```

2. E no `Info.plist` para iOS:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>rayclub</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>rayclub</string>
        </array>
    </dict>
</array>
```

### 5. Verificar tabelas do Supabase

Segundo o esquema em `SUPABASE_SCHEMA.md`, certifique-se de que as seguintes tabelas existem no Supabase:

- `auth.users` (gerenciada pelo Supabase Auth)
- `profiles` com as colunas:
  - `id` (UUID, igual ao auth.users.id)
  - `name`
  - `email`
  - `photo_url`
  - `daily_water_goal`
  - `is_admin`

### 6. Configurar RLS (Row Level Security)

Verifique se as políticas de segurança estão configuradas corretamente:

1. Para a tabela `profiles`:
   - Políticas para permitir leitura pública
   - Políticas para permitir que usuários atualizem apenas seus próprios perfis
   - Políticas para permitir que administradores atualizem qualquer perfil

## Confirmação

Após fazer estas alterações:

1. Limpe o cache: `flutter clean`
2. Obtenha dependências: `flutter pub get`
3. Execute o aplicativo: `flutter run`

O login com email/senha e Google deve funcionar corretamente, assim como a recuperação de senha.

# 🔧 Correção Final - Autenticação OAuth Ray Club

## ✅ Problema Resolvido

O erro **"Unable to exchange external code"** ocorria porque:
- O app estava usando `rayclub://login-callback/` como redirect URL
- Mas o Supabase precisa usar sua própria URL HTTPS para trocar o código

## 🎯 Solução Aplicada

### 1. **Redirect URL Correta**
```dart
// ANTES (causava erro):
const String redirectUrl = 'rayclub://login-callback/';

// DEPOIS (funciona):
const String redirectUrl = 'https://zsbbgchsjiuicwvtrldn.supabase.co/auth/v1/callback';
```

### 2. **Configurações Verificadas**

#### ✅ Google Cloud Console
- Client ID: `187648853060-1dcptn3rrnjh1unvpa9segd6o9bdnnqt`
- Client Secret: `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`
- Redirect URIs:
  - `https://zsbbgchsjiuicwvtrldn.supabase.co/auth/v1/callback` ✅
  - `https://rayclub.com.br/auth/callback` ✅

#### ✅ Supabase Dashboard
- Google Provider: HABILITADO
- Client ID e Secret: Configurados corretamente
- Redirect URLs configuradas

## 🚀 Como Funciona Agora

1. Usuário clica em "Login com Google"
2. App abre o browser com a URL do Supabase
3. Usuário faz login no Google
4. Google redireciona para `https://zsbbgchsjiuicwvtrldn.supabase.co/auth/v1/callback`
5. Supabase troca o código por token (funcionando!)
6. Supabase redireciona para o app via deep link
7. App detecta a sessão e autentica o usuário

## 📝 Notas Importantes

- **NÃO use** `rayclub://` como redirect URL principal
- **USE** sempre a URL HTTPS do Supabase para OAuth
- O deep link `rayclub://` é usado apenas no final do processo

## 🔍 Se Ainda Houver Problemas

1. Verifique se o Google Provider está HABILITADO no Supabase
2. Confirme que o Client Secret está correto no Supabase
3. Certifique-se de que não há espaços extras no Client ID/Secret
4. Aguarde alguns minutos após mudanças no Supabase (cache) 