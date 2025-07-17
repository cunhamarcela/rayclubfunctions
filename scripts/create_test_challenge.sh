#!/bin/bash

# Script para criar um desafio de teste
# Este script executa o script Dart CLI para criar um desafio de teste

echo "======================================================"
echo "    SCRIPT PARA CRIAÇÃO DE DESAFIO DE TESTE"
echo "======================================================"

# Verificar se o Flutter está instalado
if ! command -v flutter &> /dev/null; then
    echo "Flutter não encontrado. Certifique-se de que o Flutter está instalado e no PATH."
    exit 1
fi

# Verificar se o Dart está instalado
if ! command -v dart &> /dev/null; then
    echo "Dart não encontrado. Certifique-se de que o Dart está instalado e no PATH."
    exit 1
fi

# Diretório do projeto
PROJECT_DIR="$(pwd)"

# Executar o script Dart
echo "Executando script Dart para criar desafio de teste..."
dart "$PROJECT_DIR/lib/scripts/create_challenge_cli.dart"

exit_code=$?

if [ $exit_code -ne 0 ]; then
    echo "ERRO: O script Dart falhou com código de saída $exit_code"
    exit $exit_code
fi

echo "Script concluído com sucesso!"
exit 0 