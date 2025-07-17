#!/bin/bash

# Script para gerar arquivos Freezed e JSON serialization
# Autor: Ray Club Team
# Data: 28/04/2025

echo "Gerando arquivos Freezed e JSON serialization..."

# Verificar se o Flutter está instalado
if ! command -v flutter &> /dev/null; then
    echo "Flutter não encontrado. Verifique se está instalado e no PATH."
    exit 1
fi

# Limpar cache e arquivos antigos
echo "Limpando cache e arquivos gerados antigos..."
flutter clean
flutter pub get

# Gerar arquivos com build_runner
echo "Gerando arquivos com build_runner..."
flutter pub run build_runner build --delete-conflicting-outputs

# Verificar se houve erro
if [ $? -eq 0 ]; then
    echo "✅ Arquivos gerados com sucesso!"
    
    # Verificar especificamente arquivos importantes
    FILES_TO_CHECK=(
        "lib/features/help/models/help_search_result.freezed.dart"
        "lib/features/help/models/tutorial_model.freezed.dart"
        "lib/features/help/models/tutorial_model.g.dart"
        "lib/core/viewmodels/base_view_model.freezed.dart"
    )
    
    MISSING_FILES=false
    
    echo "Verificando arquivos críticos..."
    for file in "${FILES_TO_CHECK[@]}"; do
        if [ ! -f "$file" ]; then
            echo "❌ Arquivo não gerado: $file"
            MISSING_FILES=true
        else
            echo "✅ Arquivo encontrado: $file"
        fi
    done
    
    if [ "$MISSING_FILES" = true ]; then
        echo "⚠️ Alguns arquivos não foram gerados. Verifique possíveis problemas nos modelos."
    else
        echo "✅ Todos os arquivos críticos foram gerados com sucesso!"
    fi
else
    echo "❌ Erro ao gerar arquivos. Verifique possíveis erros nos modelos."
    exit 1
fi 