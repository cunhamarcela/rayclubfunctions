#!/bin/bash

# Script para copiar o arquivo .env correto durante o build no Xcode
# Este script será executado como uma Build Phase no Xcode

echo "🔧 Configurando arquivo .env para o build..."

# Diretório raiz do projeto Flutter (dois níveis acima do script)
PROJECT_ROOT="$SRCROOT/../.."

# Verificar se estamos em um build de Release/Production
if [ "${CONFIGURATION}" = "Release" ] || [ "${CONFIGURATION}" = "Profile" ]; then
    echo "📱 Build de produção detectado"
    
    # Verificar se existe um arquivo .env.production
    if [ -f "$PROJECT_ROOT/.env.production" ]; then
        cp "$PROJECT_ROOT/.env.production" "$PROJECT_ROOT/.env"
        echo "✅ Arquivo .env.production copiado para .env"
    elif [ -f "$PROJECT_ROOT/env.production.example" ]; then
        cp "$PROJECT_ROOT/env.production.example" "$PROJECT_ROOT/.env"
        echo "✅ Arquivo env.production.example copiado para .env"
    else
        echo "⚠️ Arquivo de produção não encontrado, mantendo .env atual"
    fi
else
    echo "🔧 Build de desenvolvimento detectado"
    # Em desenvolvimento, manter o .env atual ou usar .env.development se existir
    if [ -f "$PROJECT_ROOT/.env.development" ] && [ ! -f "$PROJECT_ROOT/.env" ]; then
        cp "$PROJECT_ROOT/.env.development" "$PROJECT_ROOT/.env"
        echo "✅ Arquivo .env.development copiado para .env"
    fi
fi

# Verificar se o arquivo .env existe
if [ -f "$PROJECT_ROOT/.env" ]; then
    echo "✅ Arquivo .env configurado com sucesso"
    # Mostrar as primeiras linhas para confirmação (sem mostrar valores sensíveis)
    echo "📋 Primeiras linhas do .env:"
    head -n 5 "$PROJECT_ROOT/.env" | sed 's/=.*/=***/'
else
    echo "❌ AVISO: Arquivo .env não encontrado!"
    echo "O app usará as configurações de fallback em ProductionConfig"
fi 