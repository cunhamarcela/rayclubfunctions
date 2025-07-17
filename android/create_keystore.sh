#!/bin/bash

echo "🔐 Criando keystore para Ray Club..."
echo ""
echo "Este script criará um keystore para assinar o app Android."
echo "IMPORTANTE: Guarde a senha em um local seguro!"
echo ""

# Verificar se Java está instalado
if ! command -v keytool &> /dev/null; then
    echo "❌ Java não encontrado!"
    echo ""
    echo "Por favor, instale o Java primeiro:"
    echo "1. Baixe e instale o Android Studio: https://developer.android.com/studio"
    echo "2. Ou instale o Java: https://www.java.com/download/"
    echo ""
    exit 1
fi

# Solicitar informações
read -p "Digite a senha do keystore (mínimo 6 caracteres): " -s STORE_PASS
echo ""
read -p "Digite novamente a senha: " -s STORE_PASS_CONFIRM
echo ""

if [ "$STORE_PASS" != "$STORE_PASS_CONFIRM" ]; then
    echo "❌ As senhas não coincidem!"
    exit 1
fi

if [ ${#STORE_PASS} -lt 6 ]; then
    echo "❌ A senha deve ter pelo menos 6 caracteres!"
    exit 1
fi

# Criar keystore
keytool -genkey -v \
    -keystore ~/ray-club-release.keystore \
    -keyalg RSA \
    -keysize 2048 \
    -validity 10000 \
    -alias ray-club \
    -storepass "$STORE_PASS" \
    -keypass "$STORE_PASS" \
    -dname "CN=Ray Club, OU=Mobile Development, O=Ray Club, L=Sao Paulo, ST=SP, C=BR"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Keystore criado com sucesso em: ~/ray-club-release.keystore"
    echo ""
    echo "📝 Agora crie o arquivo android/key.properties com o seguinte conteúdo:"
    echo ""
    echo "storePassword=$STORE_PASS"
    echo "keyPassword=$STORE_PASS"
    echo "keyAlias=ray-club"
    echo "storeFile=$HOME/ray-club-release.keystore"
    echo ""
    echo "⚠️  IMPORTANTE:"
    echo "1. Faça backup do keystore em um local seguro"
    echo "2. Nunca perca a senha ou o arquivo keystore"
    echo "3. Você precisará deles para todas as atualizações futuras"
else
    echo "❌ Erro ao criar keystore"
    exit 1
fi 