#!/bin/bash

echo "🍎 ========== VERIFICAÇÃO APPLE SIGN IN =========="
echo "🍎 Verificando configuração do projeto Ray Club"
echo ""

# 1. Verificar arquivos de configuração iOS
echo "1️⃣ VERIFICANDO CONFIGURAÇÃO iOS"
echo ""

if [ -f "ios/Runner/Runner.entitlements" ]; then
    echo "✅ Runner.entitlements encontrado"
    if grep -q "com.apple.developer.applesignin" ios/Runner/Runner.entitlements; then
        echo "✅ Apple Sign In entitlement configurado"
    else
        echo "❌ Apple Sign In entitlement NÃO encontrado"
    fi
else
    echo "❌ Runner.entitlements NÃO encontrado"
fi

if [ -f "ios/Runner/Info.plist" ]; then
    echo "✅ Info.plist encontrado"
    if grep -q "com.rayclub.app" ios/Runner/Info.plist; then
        echo "✅ Bundle ID configurado no Info.plist"
    else
        echo "❌ Bundle ID NÃO encontrado no Info.plist"
    fi
else
    echo "❌ Info.plist NÃO encontrado"
fi

echo ""

# 2. Verificar dependências
echo "2️⃣ VERIFICANDO DEPENDÊNCIAS"
echo ""

if grep -q "sign_in_with_apple" pubspec.yaml; then
    echo "✅ Dependência sign_in_with_apple encontrada"
else
    echo "❌ Dependência sign_in_with_apple NÃO encontrada"
fi

echo ""

# 3. Verificar implementação
echo "3️⃣ VERIFICANDO IMPLEMENTAÇÃO"
echo ""

if [ -f "lib/features/auth/repositories/auth_repository.dart" ]; then
    echo "✅ AuthRepository encontrado"
    if grep -q "signInWithApple" lib/features/auth/repositories/auth_repository.dart; then
        echo "✅ Método signInWithApple implementado"
    else
        echo "❌ Método signInWithApple NÃO encontrado"
    fi
else
    echo "❌ AuthRepository NÃO encontrado"
fi

echo ""

# 4. Próximos passos
echo "4️⃣ PRÓXIMOS PASSOS OBRIGATÓRIOS"
echo ""
echo "📋 CONFIGURAÇÃO SUPABASE:"
echo "   ☐ Acesse Supabase Dashboard"
echo "   ☐ Vá para Authentication > Providers > Apple"
echo "   ☐ Configure Client ID: com.rayclub.app"
echo "   ☐ Configure Team ID, Key ID e Private Key"
echo ""
echo "📋 APPLE DEVELOPER CONSOLE:"
echo "   ☐ Verifique se App ID tem Sign In with Apple habilitado"
echo "   ☐ Crie Service ID se necessário"
echo "   ☐ Crie Key para Sign In with Apple"
echo ""
echo "📋 TESTE:"
echo "   ☐ Execute: flutter run --device-id [DEVICE_ID]"
echo "   ☐ Teste em dispositivo físico (não simulador)"
echo "   ☐ Teste especificamente em iPad"
echo ""

echo "🍎 ========== VERIFICAÇÃO CONCLUÍDA ==========" 