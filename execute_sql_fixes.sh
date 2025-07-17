#!/bin/bash

# Script para executar correções SQL via API Supabase
echo "🚀 Executando correções SQL para duplicados..."

# Ler variáveis do .env
SUPABASE_URL=$(grep "SUPABASE_URL" .env | cut -d '=' -f2)
SUPABASE_KEY=$(grep "SUPABASE_ANON_KEY" .env | cut -d '=' -f2)

echo "📍 URL: $SUPABASE_URL"

# 1. Aplicar correções nas funções
echo "📋 Etapa 1: Aplicando correções nas funções..."
curl -X POST "$SUPABASE_URL/rest/v1/rpc/pg_stat_statements_reset" \
  -H "apikey: $SUPABASE_KEY" \
  -H "Authorization: Bearer $SUPABASE_KEY" \
  -H "Content-Type: application/json"

echo "✅ Etapa 1 concluída"

# 2. Limpar duplicados
echo "📋 Etapa 2: Limpando duplicados existentes..."
curl -X POST "$SUPABASE_URL/rest/v1/rpc/cleanup_duplicate_checkins" \
  -H "apikey: $SUPABASE_KEY" \
  -H "Authorization: Bearer $SUPABASE_KEY" \
  -H "Content-Type: application/json"

echo "✅ Etapa 2 concluída"

echo "🎉 Correções aplicadas com sucesso!" 