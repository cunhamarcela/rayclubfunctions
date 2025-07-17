#!/bin/bash

# Script para executar todos os testes e gerar relatório de cobertura

# Cores para output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}========== Executando testes unitários e de widget com cobertura de código ==========${NC}"

# Gerar arquivos mock necessários para testes
echo -e "${YELLOW}Gerando arquivos mock...${NC}"
flutter pub run build_runner build --delete-conflicting-outputs

# Executar testes com cobertura
echo -e "${YELLOW}Executando testes...${NC}"
flutter test --coverage

# Verificar resultado dos testes
if [ $? -eq 0 ]; then
  echo -e "${GREEN}✅ Todos os testes passaram!${NC}"
else
  echo -e "${RED}❌ Alguns testes falharam!${NC}"
  exit 1
fi

# Gerar e abrir o relatório de cobertura HTML (apenas em macOS e Linux)
if [[ "$OSTYPE" == "darwin"* || "$OSTYPE" == "linux-gnu"* ]]; then
  echo -e "${YELLOW}Gerando relatório de cobertura HTML...${NC}"
  
  # Verificar se o lcov está instalado
  if ! command -v lcov &> /dev/null; then
    echo -e "${RED}lcov não está instalado. Instale com:${NC}"
    if [[ "$OSTYPE" == "darwin"* ]]; then
      echo "brew install lcov"
    else
      echo "sudo apt-get install lcov"
    fi
    exit 1
  fi
  
  # Gerar o relatório HTML
  genhtml coverage/lcov.info -o coverage/html
  
  # Abrir o relatório no navegador padrão
  if [[ "$OSTYPE" == "darwin"* ]]; then
    open coverage/html/index.html
  else
    xdg-open coverage/html/index.html
  fi
  
  echo -e "${GREEN}✅ Relatório de cobertura gerado em coverage/html/index.html${NC}"
else
  echo -e "${YELLOW}Relatório HTML não gerado - suportado apenas em macOS e Linux${NC}"
fi

# Exibir resumo da cobertura
echo -e "${YELLOW}=== Resumo da cobertura ===${NC}"
lcov --summary coverage/lcov.info

echo -e "${GREEN}✅ Testes completos!${NC}" 