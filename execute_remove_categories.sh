#!/bin/bash

# Script para executar a remoção de categorias duplicadas
echo "🚀 Iniciando remoção de categorias duplicadas..."
echo "📱 Este script vai remover: Cardio, Yoga, HIIT"
echo ""

# Verificar se o .env existe
if [ ! -f ".env" ]; then
    echo "❌ Arquivo .env não encontrado!"
    echo "💡 Certifique-se de que o arquivo .env existe na raiz do projeto"
    exit 1
fi

# Executar o script Dart
echo "🔧 Executando script de limpeza..."
dart run scripts/remove_duplicate_categories.dart

# Verificar se executou com sucesso
if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Script executado com sucesso!"
    echo "📱 As categorias Cardio, Yoga e HIIT foram removidas"
    echo "🔄 Cards duplicados foram removidos"
    echo "📋 Ordem das categorias foi reorganizada"
    echo ""
    echo "🎯 Próximos passos:"
    echo "1. Teste o app para verificar as mudanças"
    echo "2. Faça commit das alterações se estiver tudo correto"
else
    echo ""
    echo "❌ Erro durante a execução do script"
    echo "💡 Verifique as credenciais do Supabase no arquivo .env"
fi 