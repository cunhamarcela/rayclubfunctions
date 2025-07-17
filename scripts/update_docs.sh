#!/bin/bash

# Script para facilitar a atualização da documentação
# Uso: ./scripts/update_docs.sh "Descrição da alteração"

# Verificar se foi fornecida uma descrição
if [ -z "$1" ]; then
  echo "Uso: ./scripts/update_docs.sh \"Descrição da alteração\""
  exit 1
fi

# Obter a data atual no formato DD/MM/YYYY
DATE=$(date +"%d/%m/%Y")

# Obter o nome do usuário atual
USER=$(git config user.name || echo "Desenvolvedor")

# A descrição fornecida como argumento
DESCRIPTION="$1"

# Caminho para o arquivo de documentação
DOC_FILE="TECHNICAL_DOCUMENTATION.md"

# Verificar se o arquivo de documentação existe
if [ ! -f "$DOC_FILE" ]; then
  echo "ERRO: Arquivo $DOC_FILE não encontrado."
  exit 1
fi

# Procurar a linha do cabeçalho da tabela de changelog
CHANGELOG_LINE=$(grep -n "| Data | Desenvolvedor | Descrição da Alteração |" "$DOC_FILE" | cut -d ":" -f 1)

if [ -z "$CHANGELOG_LINE" ]; then
  echo "ERRO: Não foi possível encontrar a tabela de changelog."
  exit 1
fi

# Linha onde inserir a nova entrada (após o cabeçalho e a linha separadora)
INSERT_LINE=$((CHANGELOG_LINE + 2))

# Criar a nova linha para o changelog
NEW_LINE="| $DATE | $USER | $DESCRIPTION |"

# Inserir a nova linha no arquivo
sed -i.bak "${INSERT_LINE}i\\
$NEW_LINE
" "$DOC_FILE"

# Remover o arquivo de backup criado pelo sed
rm "${DOC_FILE}.bak"

echo "Documentação atualizada com sucesso!"
echo "Nova entrada adicionada ao changelog: $NEW_LINE"
echo ""
echo "Não se esqueça de:"
echo "1. Verificar e atualizar as seções relevantes do documento"
echo "2. Fazer commit das alterações"
echo ""
echo "Comando sugerido:"
echo "git add $DOC_FILE && git commit -m \"docs: $DESCRIPTION\"" 