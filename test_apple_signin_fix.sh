#!/bin/bash

echo "🍎 ========== TESTE CORREÇÃO APPLE SIGN IN - IPAD =========="
echo "🍎 Testando correção para erro 'Nonces mismatch'"
echo "🍎 Dispositivo alvo: iPad Air (5th generation)"
echo ""

# Verificar se há iPad conectado
echo "1️⃣ VERIFICANDO DISPOSITIVOS IPAD"
echo ""

DEVICES=$(flutter devices)
IPAD_FOUND=false

# Procurar por iPad (físico ou simulador)
if echo "$DEVICES" | grep -i "ipad" > /dev/null; then
    IPAD_ID=$(echo "$DEVICES" | grep -i "ipad" | head -1 | awk '{print $NF}')
    IPAD_NAME=$(echo "$DEVICES" | grep -i "ipad" | head -1 | sed 's/•.*//' | xargs)
    echo "✅ iPad encontrado: $IPAD_NAME"
    echo "🔍 Device ID: $IPAD_ID"
    DEVICE_ID="$IPAD_ID"
    IPAD_FOUND=true
    
    # Verificar se é simulador ou físico
    if [[ "$IPAD_ID" == *"simulator"* ]]; then
        echo "⚠️ AVISO: iPad Simulador detectado"
        echo "⚠️ Apple Sign In pode não funcionar completamente no simulador"
        echo "⚠️ Para teste definitivo, use iPad físico"
    else
        echo "✅ iPad físico detectado - ideal para teste"
    fi
else
    echo "❌ Nenhum iPad encontrado"
    echo ""
    echo "📋 PARA CONECTAR IPAD FÍSICO:"
    echo "   1. Conecte iPad via USB ao Mac"
    echo "   2. Desbloqueie o iPad e confie no computador"
    echo "   3. Habilite Developer Mode se necessário"
    echo ""
    echo "📋 PARA USAR SIMULADOR:"
    echo "   1. Abra Xcode"
    echo "   2. Window > Devices and Simulators"
    echo "   3. Simulators > Create a new simulator"
    echo "   4. Escolha iPad Air (5th generation)"
    echo ""
    exit 1
fi

echo ""
echo "2️⃣ PREPARANDO TESTE"
echo ""

# Limpar build anterior
echo "🧹 Limpando build anterior..."
flutter clean > /dev/null 2>&1
flutter pub get > /dev/null 2>&1

echo "🔨 Compilando versão corrigida..."
echo ""

echo "3️⃣ EXECUTANDO APP NO IPAD"
echo ""
echo "📱 Dispositivo: $IPAD_NAME"
echo "🔍 Device ID: $DEVICE_ID"
echo ""
echo "🧪 INSTRUÇÕES DE TESTE:"
echo "   1. Aguarde o app abrir no iPad"
echo "   2. Navegue até a tela de login"
echo "   3. Toque no botão 'Continuar com Apple'"
echo "   4. Observe os logs abaixo"
echo "   5. Verifique se NÃO aparece mais 'Nonces mismatch'"
echo ""
echo "✅ LOGS ESPERADOS DE SUCESSO:"
echo "   - ✅ Sign in with Apple está disponível"
echo "   - ✅ Credenciais Apple obtidas com sucesso"
echo "   - ✅ Identity token obtido"
echo "   - ✅ Autenticação Apple concluída com sucesso!"
echo ""
echo "❌ ERROS QUE DEVEM ESTAR CORRIGIDOS:"
echo "   - ❌ Nonces mismatch (CORRIGIDO)"
echo "   - ❌ Error 1000 (MELHORADO)"
echo ""
echo "📊 LOGS EM TEMPO REAL:"
echo "=========================================="

# Executar no iPad com filtro para Apple Sign In
flutter run --device-id "$DEVICE_ID" --verbose 2>&1 | grep -E "(🍎|Apple|apple|signin|SignIn|auth|Auth|error|Error|Exception|exception|nonce|Nonce)" --line-buffered || {
    echo ""
    echo "❌ Erro ao executar o app"
    echo "💡 Possíveis soluções:"
    echo "   - Verificar se o iPad está desbloqueado"
    echo "   - Verificar se o desenvolvimento está habilitado"
    echo "   - Tentar reconectar o iPad"
    echo ""
    exit 1
}

echo ""
echo "🍎 ========== TESTE FINALIZADO =========="
echo ""
echo "📝 PRÓXIMOS PASSOS:"
echo "   1. Se Apple Sign In funcionou: ✅ Correção bem-sucedida!"
echo "   2. Se ainda há erros: Analisar logs específicos"
echo "   3. Testar em iPad físico se usou simulador"
echo "   4. Documentar resultados para resubmissão Apple Store" 