#!/bin/bash

# Script para otimizar o tamanho do aplicativo Ray Club
# Executa todas as otimizações para reduzir o tamanho do aplicativo
# Uso: ./scripts/optimize_app_size.sh

# Cores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Ray Club App - Otimização de Tamanho ===${NC}"
echo -e "${BLUE}================================================${NC}"

# Verificar dependências
command -v convert >/dev/null 2>&1 || { echo -e "${RED}⚠️  ImageMagick não encontrado. Instale com 'brew install imagemagick'${NC}"; }
command -v pngquant >/dev/null 2>&1 || { echo -e "${RED}⚠️  pngquant não encontrado. Instale com 'brew install pngquant'${NC}"; }

# 1. Analisar dependências não utilizadas
echo -e "\n${YELLOW}1. Analisando dependências não utilizadas...${NC}"
flutter pub add yaml # Adicionar yaml se não estiver instalado
dart scripts/analyze_dependencies.dart

# 2. Otimizar assets
echo -e "\n${YELLOW}2. Otimizando imagens...${NC}"
dart scripts/optimize_images.dart

# 3. Identificar código não utilizado
echo -e "\n${YELLOW}3. Procurando código não utilizado...${NC}"
dart scripts/find_unused_code.dart

# 4. Remover arquivos temporários e de cache
echo -e "\n${YELLOW}4. Limpando arquivos temporários...${NC}"
echo -e "${GREEN}Removendo arquivos de build temporários...${NC}"
flutter clean
rm -rf build/
rm -rf .dart_tool/
echo -e "${GREEN}✓ Arquivos temporários removidos!${NC}"

# 5. Atualizar dependências para versões mais eficientes
echo -e "\n${YELLOW}5. Atualizando dependências...${NC}"
flutter pub upgrade --major-versions

# 6. Compilar com configurações de otimização
echo -e "\n${YELLOW}6. Compilando com otimizações...${NC}"

# iOS
echo -e "${GREEN}Configurando build otimizado para iOS...${NC}"
flutter build ios --release --obfuscate --split-debug-info=./debuginfo/ios

# Android
echo -e "${GREEN}Configurando build otimizado para Android...${NC}"
flutter build appbundle --obfuscate --split-debug-info=./debuginfo/android

echo -e "\n${BLUE}================================================${NC}"
echo -e "${GREEN}✅ Otimização concluída!${NC}"
echo -e "${BLUE}================================================${NC}"
echo -e "Próximos passos:"
echo -e "1. Analise os resultados dos scripts de análise"
echo -e "2. Verifique o tamanho final do aplicativo em 'build/ios/iphoneos/Runner.app'"
echo -e "3. Para iOS, use o Xcode para arquivar e enviar para TestFlight"
echo -e "4. Para Android, use o Google Play Console para enviar o AAB"
echo -e "${BLUE}================================================${NC}" 