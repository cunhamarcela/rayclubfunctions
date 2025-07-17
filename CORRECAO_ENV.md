# Correção do Arquivo .env

O problema de autenticação do Ray Club App está relacionado ao arquivo `.env` incompleto. Observamos que o arquivo atual possui apenas 374 bytes, enquanto o arquivo de exemplo (`.env.example`) tem 1037 bytes, indicando que várias configurações importantes estão faltando.

## Problema Identificado

O arquivo `.env` atual contém apenas:
```
API_URL=https://api.rayclub.com
STORAGE_URL=https://storage.rayclub.com
SUPABASE_URL=https://rayclub-dev.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJheWNsdWItZGV2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTg3NzcwMDAsImV4cCI6MTcxNDA3MjQwMH0.eGYCNmKBuLXDUVeN8Hl62BzLnSPSjZ9W_jMEDSNZIbo
ENVIRONMENT=development
APP_VERSION=1.0.0
```

Estão faltando as seguintes configurações críticas:
- Variáveis específicas de ambiente (`DEV_SUPABASE_URL`, `STAGING_SUPABASE_URL`, `PROD_SUPABASE_URL`)
- Configurações de storage buckets
- Outras variáveis de configuração

## Solução

1. Faça backup do arquivo `.env` atual:
```bash
cp .env .env.backup
```

2. Substitua o conteúdo do arquivo `.env` pelo seguinte:

```
# Variáveis de ambiente do Ray Club App

# Ambiente
ENVIRONMENT=development
APP_VERSION=1.0.0

# URLs da API e Storage
API_URL=https://api.rayclub.com
STORAGE_URL=https://storage.rayclub.com

# Configurações do Supabase - Preservadas do arquivo original
SUPABASE_URL=https://rayclub-dev.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJheWNsdWItZGV2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTg3NzcwMDAsImV4cCI6MTcxNDA3MjQwMH0.eGYCNmKBuLXDUVeN8Hl62BzLnSPSjZ9W_jMEDSNZIbo

# Ambiente de desenvolvimento
DEV_SUPABASE_URL=https://rayclub-dev.supabase.co
DEV_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJheWNsdWItZGV2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTg3NzcwMDAsImV4cCI6MTcxNDA3MjQwMH0.eGYCNmKBuLXDUVeN8Hl62BzLnSPSjZ9W_jMEDSNZIbo
DEV_API_URL=https://api.rayclub.com

# Ambiente de staging
STAGING_SUPABASE_URL=https://rayclub-staging.supabase.co
STAGING_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJheWNsdWItZGV2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTg3NzcwMDAsImV4cCI6MTcxNDA3MjQwMH0.eGYCNmKBuLXDUVeN8Hl62BzLnSPSjZ9W_jMEDSNZIbo
STAGING_API_URL=https://staging-api.rayclub.com
STAGING_DEBUG_MODE=true

# Ambiente de produção (use as mesmas credenciais de desenvolvimento por enquanto)
PROD_SUPABASE_URL=https://rayclub-dev.supabase.co
PROD_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJheWNsdWItZGV2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTg3NzcwMDAsImV4cCI6MTcxNDA3MjQwMH0.eGYCNmKBuLXDUVeN8Hl62BzLnSPSjZ9W_jMEDSNZIbo
PROD_API_URL=https://api.rayclub.com

# Storage buckets
STORAGE_WORKOUT_BUCKET=workout-images
STORAGE_PROFILE_BUCKET=profile-images
STORAGE_NUTRITION_BUCKET=nutrition-images
STORAGE_FEATURED_BUCKET=featured-images
STORAGE_CHALLENGE_BUCKET=challenge-media

# Configurações de análise
ANALYTICS_ENABLED=true
ANALYTICS_KEY=development-key

# Nome do aplicativo
APP_NAME=Ray Club

# Versão da API
API_VERSION=v1

# Logging service
LOGGING_API_URL=https://logging.rayclub.com/api
LOGGING_API_KEY=development-key

# Flags de desenvolvimento
DEBUG_MODE=true
MOCK_API=false
```

3. Após atualizar o arquivo `.env`, execute os seguintes comandos para limpar o cache e reiniciar o aplicativo:

```bash
flutter clean
flutter pub get
flutter run
```

## Observações

- O código da aplicação utiliza o arquivo `lib/core/config/environment.dart` para acessar as variáveis específicas de ambiente (DEV, STAGING, PROD).
- A variável `ENVIRONMENT` determina qual conjunto de variáveis será usado.
- O acesso ao Supabase falha quando as variáveis específicas de ambiente não estão definidas.
- Mantenha as credenciais originais do Supabase que estavam no arquivo `.env`.

Este problema explica porque os serviços de autenticação como login normal, login com Google e recuperação de senha estavam falhando com o erro "No host specified in URI". 