#!/bin/bash

# Define cores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Função para executar testes com cobertura
run_tests_with_coverage() {
  echo -e "${YELLOW}Executando testes com cobertura...${NC}"
  flutter test --coverage $1
  
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}Testes completados com sucesso!${NC}"
    
    # Verificar se o lcov está instalado
    if command -v lcov >/dev/null 2>&1; then
      echo -e "${YELLOW}Processando relatório de cobertura...${NC}"
      # Remove arquivos gerados e arquivos que não queremos na cobertura
      lcov --remove coverage/lcov.info \
        'lib/generated/*' \
        'lib/**.g.dart' \
        'lib/**.freezed.dart' \
        -o coverage/filtered_lcov.info
        
      # Gera relatório HTML
      genhtml coverage/filtered_lcov.info -o coverage/html
      
      echo -e "${GREEN}Relatório de cobertura gerado em coverage/html/index.html${NC}"
      
      # Abre o relatório no navegador se estiver em um ambiente de desktop
      if [ -n "$DISPLAY" ]; then
        if command -v open >/dev/null 2>&1; then
          open coverage/html/index.html
        elif command -v xdg-open >/dev/null 2>&1; then
          xdg-open coverage/html/index.html
        fi
      fi
    else
      echo -e "${YELLOW}lcov não está instalado. Relatório HTML não gerado.${NC}"
      echo -e "${YELLOW}Instale lcov para gerar relatórios HTML de cobertura:${NC}"
      echo -e "${YELLOW}  - MacOS: brew install lcov${NC}"
      echo -e "${YELLOW}  - Linux: sudo apt-get install lcov${NC}"
    fi
  else
    echo -e "${RED}Testes falharam.${NC}"
    exit 1
  fi
}

# Função para executar testes de integração
run_integration_tests() {
  echo -e "${YELLOW}Executando testes de integração...${NC}"
  
  # Verificar se um emulador está disponível
  if [ -z "$(flutter devices | grep emulator)" ]; then
    echo -e "${RED}Nenhum emulador disponível para testes de integração.${NC}"
    echo -e "${YELLOW}Por favor, inicie um emulador e tente novamente.${NC}"
    exit 1
  fi
  
  flutter test integration_test/app_test.dart
  
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}Testes de integração completados com sucesso!${NC}"
  else
    echo -e "${RED}Testes de integração falharam.${NC}"
    exit 1
  fi
}

# Menu principal
echo -e "${GREEN}Ray Club App - Runner de Testes${NC}"
echo "1. Executar todos os testes unitários com cobertura"
echo "2. Executar testes de integração"
echo "3. Executar testes específicos (com filtro)"
echo "4. Executar todos os testes (unitários e integração)"
echo "5. Sair"

read -p "Escolha uma opção (1-5): " option

case $option in
  1)
    run_tests_with_coverage
    ;;
  2)
    run_integration_tests
    ;;
  3)
    read -p "Digite o padrão para filtrar testes (ex: settings): " filter
    run_tests_with_coverage "--name=$filter"
    ;;
  4)
    run_tests_with_coverage
    run_integration_tests
    ;;
  5)
    echo -e "${GREEN}Saindo...${NC}"
    exit 0
    ;;
  *)
    echo -e "${RED}Opção inválida.${NC}"
    exit 1
    ;;
esac 