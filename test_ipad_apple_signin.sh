#!/bin/bash

echo "🍎 ========== TESTE ESPECÍFICO PARA IPAD =========="
echo "🍎 Simulando condições do Apple Store Review"
echo "🍎 Dispositivo: iPad Air (5th generation) - iPadOS 18.5"
echo "🍎 Review ID: cb624e88-424d-4ed1-8d84-e86fdeeeb5dc"
echo ""

# Verificar se há iPad conectado
echo "1️⃣ VERIFICANDO DISPOSITIVOS CONECTADOS"
echo ""

DEVICES=$(flutter devices)
echo "$DEVICES"
echo ""

# Procurar por iPad
if echo "$DEVICES" | grep -i "ipad" > /dev/null; then
    IPAD_ID=$(echo "$DEVICES" | grep -i "ipad" | head -1 | awk '{print $NF}')
    echo "✅ iPad encontrado: $IPAD_ID"
    DEVICE_ID="$IPAD_ID"
    DEVICE_TYPE="iPad Físico"
elif echo "$DEVICES" | grep -i "mac designed for ipad" > /dev/null; then
    echo "⚠️ iPad físico não encontrado, usando Mac Designed for iPad"
    DEVICE_ID="mac-designed-for-ipad"
    DEVICE_TYPE="Mac Designed for iPad"
else
    echo "❌ Nenhum iPad encontrado"
    echo ""
    echo "📋 INSTRUÇÕES PARA CONECTAR IPAD:"
    echo "   1. Conecte um iPad físico via USB"
    echo "   2. Ou habilite desenvolvimento wireless no iPad"
    echo "   3. Ou use o Simulator com iPad Air"
    echo ""
    echo "⚠️ IMPORTANTE: Apple Sign In NÃO funciona no simulador!"
    echo "⚠️ Para teste real, use iPad físico"
    echo ""
    exit 1
fi

echo ""
echo "2️⃣ CONFIGURAÇÃO DO TESTE"
echo "   Dispositivo: $DEVICE_TYPE"
echo "   Device ID: $DEVICE_ID"
echo "   Teste: Apple Sign In específico para iPad"
echo ""

# Verificar se é dispositivo físico
if [[ "$DEVICE_ID" == *"simulator"* ]] || [[ "$DEVICE_ID" == *"mac-designed"* ]]; then
    echo "⚠️ AVISO: Apple Sign In pode não funcionar em simulador/Mac"
    echo "⚠️ Para teste definitivo, use iPad físico"
    echo ""
fi

echo "3️⃣ EXECUTANDO APP NO IPAD"
echo ""

# Limpar build anterior
echo "🧹 Limpando build anterior..."
flutter clean > /dev/null 2>&1
flutter pub get > /dev/null 2>&1

echo "🔨 Compilando para iPad..."
echo ""

# Executar no iPad com logs verbosos
echo "🚀 Iniciando app no iPad..."
echo "📱 Device: $DEVICE_TYPE ($DEVICE_ID)"
echo ""
echo "🔍 INSTRUÇÕES DE TESTE:"
echo "   1. Aguarde o app abrir no iPad"
echo "   2. Vá para a tela de login"
echo "   3. Toque em 'Continuar com Apple'"
echo "   4. Observe os logs abaixo para erros"
echo "   5. Teste em orientação portrait E landscape"
echo ""
echo "📊 LOGS DO APPLE SIGN IN:"
echo "=========================================="

# Executar com logs filtrados para Apple Sign In
flutter run --device-id "$DEVICE_ID" --verbose 2>&1 | grep -E "(🍎|Apple|apple|signin|SignIn|auth|Auth|error|Error|Exception|exception)" || {
    echo ""
    echo "❌ Erro ao executar o app no iPad"
    echo "💡 Tente:"
    echo "   - Verificar se o iPad está desbloqueado"
    echo "   - Verificar se o desenvolvimento está habilitado"
    echo "   - Conectar o iPad via USB"
    echo ""
    exit 1
}

echo ""
echo "🍎 ========== TESTE FINALIZADO ==========" 