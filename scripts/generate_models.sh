#!/bin/bash

# Verificar se o Flutter está instalado
if ! command -v flutter &> /dev/null; then
    echo "Flutter não encontrado. Verifique se está instalado e no PATH."
    exit 1
fi

echo "🔄 Iniciando geração de código para modelos..."
echo "⚙️ Executando build_runner..."

# Executar build_runner com a opção de deletar outputs conflitantes
flutter pub run build_runner build --delete-conflicting-outputs

# Verificar se o comando foi executado com sucesso
if [ $? -eq 0 ]; then
    echo "✅ Geração de código concluída com sucesso!"
    echo "🔍 Arquivos gerados:"
    find lib -name "*.g.dart" -o -name "*.freezed.dart" | sort
else
    echo "❌ Ocorreu um erro durante a geração de código."
    exit 1
fi

echo "🔄 Verificando se há problemas de análise..."
flutter analyze

echo "🏁 Processo finalizado!" 