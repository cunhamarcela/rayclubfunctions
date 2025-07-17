#!/bin/bash

# Script para build do IPA do Ray Club App
# Versão: 1.0.16+25

echo "🚀 Iniciando build do IPA para Ray Club App v1.0.16+25"

# Limpar builds anteriores
echo "🧹 Limpando builds anteriores..."
flutter clean
flutter pub get

# Build do Flutter para iOS
echo "📱 Fazendo build do Flutter para iOS..."
flutter build ios --release --no-codesign

# Verificar se o build foi bem-sucedido
if [ $? -eq 0 ]; then
    echo "✅ Build do Flutter concluído com sucesso!"
    
    # Abrir Xcode para archive
    echo "🔧 Abrindo Xcode para archive..."
    open ios/Runner.xcworkspace
    
    echo ""
    echo "📋 PRÓXIMOS PASSOS NO XCODE:"
    echo "1. Selecione 'Any iOS Device (arm64)' como destino"
    echo "2. Vá em Product > Archive"
    echo "3. Aguarde o processo de archive"
    echo "4. Na janela do Organizer, clique em 'Distribute App'"
    echo "5. Selecione 'App Store Connect'"
    echo "6. Siga o processo de upload"
    echo ""
    echo "📊 INFORMAÇÕES DA BUILD:"
    echo "- Versão: 1.0.16"
    echo "- Build Number: 25"
    echo "- Bundle ID: com.rayclub.app"
    echo "- Team: 5X5AG58L34"
    echo ""
    
else
    echo "❌ Erro no build do Flutter!"
    exit 1
fi 