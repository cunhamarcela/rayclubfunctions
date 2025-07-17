# Guia de Correção para Apple Review - Ray Club App

## Problemas Identificados

### 1. Login com Apple - Database Error
**Erro:** `{"code":"unexpected_failure","message":"Database error saving new user"}`

### 2. Login com Google - URL Incorreta
**Problema:** O app está usando a URL de desenvolvimento do Supabase

## Solução Completa

### Passo 1: Configurar Variáveis de Ambiente

O arquivo `.env` já foi criado com as credenciais corretas. As variáveis já estão configuradas:

```env
# Ambiente
APP_ENV=production
APP_NAME=Ray Club
APP_VERSION=1.0.11

# URLs Base
BASE_URL=https://rayclub.com.br

# Supabase - JÁ CONFIGURADO
PROD_SUPABASE_URL=https://zsbbgchsjiuicwvtrldn.supabase.co
PROD_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpzYmJnY2hzaml1aWN3dnRybGRuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDIzMzU5ODYsImV4cCI6MjA1NzkxMTk4Nn0.HEN9Mh_tYA7beWvhNwFCKpi8JpYINbPUCYtT66DeaeM

# Google OAuth - JÁ CONFIGURADO
GOOGLE_WEB_CLIENT_ID=187648853060-1dcptn3rrnjh1unvpa9segd6o9bdnnqt.apps.googleusercontent.com
GOOGLE_IOS_CLIENT_ID=187648853060-aub6vfna1dmvb4ihb5o7ir3re3bn0c0i.apps.googleusercontent.com

# Apple Sign In
APPLE_CLIENT_ID=com.rayclub.app
APPLE_SERVICE_ID=com.rayclub.app.signin

# Storage Buckets
STORAGE_WORKOUT_BUCKET=workout-images
STORAGE_PROFILE_BUCKET=profile-images
STORAGE_NUTRITION_BUCKET=nutrition-images
STORAGE_FEATURED_BUCKET=featured-images
STORAGE_CHALLENGE_BUCKET=challenge-media
```

**✅ O arquivo .env já foi criado com todas as credenciais corretas!**

### Passo 2: Executar Script SQL no Supabase

Execute o script `fix_apple_signin_database.sql` no SQL Editor do Supabase para:
1. Criar a função `handle_new_user`
2. Configurar o trigger para novos usuários
3. Verificar estrutura das tabelas

### Passo 3: Criar Usuário de Teste

No Supabase SQL Editor, execute:

```sql
-- Criar usuário de teste para Apple Review
INSERT INTO auth.users (
    instance_id,
    id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    raw_app_meta_data,
    raw_user_meta_data,
    created_at,
    updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000',
    gen_random_uuid(),
    'authenticated',
    'authenticated',
    'review@rayclub.com',
    crypt('Test1234!', gen_salt('bf')),
    NOW(),
    '{"provider": "email", "providers": ["email"]}',
    '{"name": "Apple Review User"}',
    NOW(),
    NOW()
) ON CONFLICT (email) DO NOTHING;
```

**IMPORTANTE:** Após criar o usuário, execute o script `setup_apple_review_user.sql` para configurar o usuário como expert e garantir acesso total ao conteúdo do app.

### Passo 4: Configurar URLs no Supabase

No painel do Supabase, vá em **Authentication > URL Configuration** e adicione:

1. **Site URL**: `https://rayclub.com.br`
2. **Redirect URLs**:
   - `https://rayclub.com.br/auth/callback`
   - `https://SEU_PROJETO.supabase.co/auth/v1/callback`
   - `rayclub://login-callback/`
   - `rayclub://reset-password`
   - `rayclub://confirm`

### Passo 5: Atualizar Google Cloud Console

1. Acesse [Google Cloud Console](https://console.cloud.google.com)
2. Selecione seu projeto
3. Vá em **APIs & Services > Credentials**
4. Edite o OAuth 2.0 Client ID (Web application)
5. Em **Authorized redirect URIs**, adicione:
   - `https://SEU_PROJETO.supabase.co/auth/v1/callback`

### Passo 6: Atualizar Apple Developer

1. Acesse [Apple Developer](https://developer.apple.com)
2. Vá em **Certificates, Identifiers & Profiles**
3. Selecione seu Service ID
4. Em **Return URLs**, certifique-se de ter:
   - `https://SEU_PROJETO.supabase.co/auth/v1/callback`

### Passo 7: Build e Deploy

```bash
# Limpar cache
flutter clean

# Obter dependências
flutter pub get

# Build para iOS
flutter build ios --release

# Criar IPA
flutter build ipa --release
```

### Passo 8: Informações para Apple Review

No App Store Connect, adicione estas informações:

**Demo Account:**
- Email: `review@rayclub.com`
- Password: `Test1234!`

**Notes for Review:**
```
To test the app:
1. Use the provided demo account or create a new account
2. Sign in with Apple and Google are both available
3. The app requires authentication to access all features
4. All content is appropriate for users 4+
```

## Verificação Final

Antes de submeter, teste:

1. ✅ Login com email/senha funciona
2. ✅ Login com Google abre a página correta
3. ✅ Login com Apple cria usuário sem erros
4. ✅ Todas as funcionalidades estão acessíveis após login
5. ✅ O app não contém URLs de desenvolvimento

## Suporte

Se encontrar problemas:
1. Verifique os logs no Supabase Dashboard
2. Confirme que todas as variáveis de ambiente estão corretas
3. Teste em um dispositivo real (não simulador)
4. Verifique se o certificado de distribuição está válido 