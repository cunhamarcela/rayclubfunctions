#!/bin/bash

# ========================================
# SCRIPT PARA EXECUTAR DIAGNÓSTICO DE METAS
# ========================================
# Data: 29 de Janeiro de 2025 às 18:15
# Objetivo: Executar diagnóstico do sistema de metas
# Uso: ./scripts/run_goals_diagnosis.sh

echo "🔍 Iniciando diagnóstico do sistema de metas..."
echo ""

# Verificar se o arquivo SQL existe
if [ ! -f "sql/goals_backend_diagnosis.sql" ]; then
    echo "❌ Erro: Arquivo sql/goals_backend_diagnosis.sql não encontrado!"
    echo "   Certifique-se de estar na raiz do projeto."
    exit 1
fi

# Verificar se a URL do Supabase está configurada
if [ -z "$SUPABASE_DB_URL" ]; then
    echo "⚠️  Variável SUPABASE_DB_URL não configurada."
    echo "   Você pode:"
    echo "   1. Exportar: export SUPABASE_DB_URL='sua_url_aqui'"
    echo "   2. Ou informar manualmente quando solicitado"
    echo ""
fi

# Solicitar URL do banco se não estiver configurada
if [ -z "$SUPABASE_DB_URL" ]; then
    echo "📝 Digite a URL de conexão do Supabase:"
    echo "   Formato: postgresql://postgres:[senha]@[projeto].supabase.co:5432/postgres"
    read -p "URL: " SUPABASE_DB_URL
    echo ""
fi

# Verificar se a URL foi fornecida
if [ -z "$SUPABASE_DB_URL" ]; then
    echo "❌ URL do banco é obrigatória para executar o diagnóstico."
    exit 1
fi

echo "🚀 Executando diagnóstico..."
echo "📊 Isso pode levar alguns segundos..."
echo ""

# Executar o diagnóstico
psql "$SUPABASE_DB_URL" -f sql/goals_backend_diagnosis.sql

# Verificar se foi executado com sucesso
if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Diagnóstico executado com sucesso!"
    echo ""
    echo "📋 PRÓXIMOS PASSOS:"
    echo "   1. Analise os resultados acima"
    echo "   2. Identifique que tabelas/estruturas já existem"
    echo "   3. Decida se a migração unified_goals_migration.sql é necessária"
    echo "   4. Se for aplicar a migração, faça backup primeiro!"
    echo ""
    echo "💡 Dica: Salve a saída deste diagnóstico para referência futura"
else
    echo ""
    echo "❌ Erro ao executar o diagnóstico."
    echo "   Verifique:"
    echo "   - URL do banco de dados está correta"
    echo "   - Você tem permissões de leitura"
    echo "   - Conexão com internet está funcionando"
fi 