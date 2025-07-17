#!/bin/bash

# Ray Club App - Script de Build para Produção iOS
# Este script prepara e executa o build de produção para iOS

set -e  # Parar em caso de erro

echo "🚀 Ray Club - Build de Produção iOS"
echo "===================================="

# Cores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Diretório do projeto
PROJECT_DIR="/Users/marcelacunha/ray_club_app"
cd "$PROJECT_DIR"

# 1. Verificar se estamos no diretório correto
if [ ! -f "pubspec.yaml" ]; then
    echo -e "${RED}❌ Erro: pubspec.yaml não encontrado. Certifique-se de estar no diretório correto.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Diretório do projeto verificado${NC}"

# 2. Fazer backup do .env atual (se existir)
if [ -f ".env" ]; then
    BACKUP_NAME=".env.backup_$(date +%Y%m%d_%H%M%S)"
    cp .env "$BACKUP_NAME"
    echo -e "${YELLOW}📦 Backup do .env criado: $BACKUP_NAME${NC}"
fi

# 3. Copiar o arquivo de produção para .env
if [ -f "env.production.example" ]; then
    cp env.production.example .env
    echo -e "${GREEN}✅ Arquivo .env de produção copiado${NC}"
else
    echo -e "${RED}❌ Erro: env.production.example não encontrado${NC}"
    exit 1
fi

# 4. Incrementar o build number automaticamente
CURRENT_BUILD=$(grep "APP_BUILD_NUMBER=" .env | cut -d'=' -f2)
NEW_BUILD=$((CURRENT_BUILD + 1))
sed -i '' "s/APP_BUILD_NUMBER=$CURRENT_BUILD/APP_BUILD_NUMBER=$NEW_BUILD/" .env
echo -e "${GREEN}✅ Build number incrementado: $CURRENT_BUILD → $NEW_BUILD${NC}"

# 5. Limpar caches e builds anteriores
echo -e "${YELLOW}🧹 Limpando caches e builds anteriores...${NC}"
flutter clean
rm -rf ios/Pods
rm -rf ios/.symlinks
rm -f ios/Podfile.lock
rm -rf build/

# 6. Obter dependências
echo -e "${YELLOW}📦 Obtendo dependências do Flutter...${NC}"
flutter pub get

# 7. Instalar CocoaPods
echo -e "${YELLOW}📦 Instalando CocoaPods...${NC}"
cd ios
pod install
cd ..

# 8. Executar o build de produção
echo -e "${YELLOW}🔨 Executando build de produção...${NC}"
flutter build ios --release --build-number=$NEW_BUILD

# 9. Verificar se o build foi bem-sucedido
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Build concluído com sucesso!${NC}"
    echo ""
    echo "📱 Próximos passos:"
    echo "1. Abra o Xcode: open ios/Runner.xcworkspace"
    echo "2. Selecione 'Product' → 'Archive'"
    echo "3. Após o archive, clique em 'Distribute App'"
    echo "4. Siga as instruções para upload na App Store Connect"
    echo ""
    echo "Build Number: $NEW_BUILD"
else
    echo -e "${RED}❌ Erro durante o build${NC}"
    exit 1
fi 