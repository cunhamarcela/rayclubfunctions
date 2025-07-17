#!/bin/bash

# Nova chave anon
NEW_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpzYmJnY2hzaml1aWN3dnRybGRuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDIzMzU5ODYsImV4cCI6MjA1NzkxMTk4Nn0.HEN9Mh_tYA7beWvhNwFCKpi8JpYINbPUCYtT66DeaeM"

# Fazer backup do .env atual
cp .env .env.backup_$(date +%Y%m%d_%H%M%S)

# Atualizar todas as variáveis ANON_KEY
sed -i '' "s|SUPABASE_ANON_KEY=.*|SUPABASE_ANON_KEY=$NEW_KEY|g" .env
sed -i '' "s|DEV_SUPABASE_ANON_KEY=.*|DEV_SUPABASE_ANON_KEY=$NEW_KEY|g" .env
sed -i '' "s|STAGING_SUPABASE_ANON_KEY=.*|STAGING_SUPABASE_ANON_KEY=$NEW_KEY|g" .env
sed -i '' "s|PROD_SUPABASE_ANON_KEY=.*|PROD_SUPABASE_ANON_KEY=$NEW_KEY|g" .env

echo "✅ Chaves ANON_KEY atualizadas no .env"
echo "📋 Backup criado: .env.backup_$(date +%Y%m%d_%H%M%S)" 