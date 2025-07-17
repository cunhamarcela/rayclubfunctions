#!/bin/bash

# Este script aplica a nova função SQL para recalcular o progresso dos desafios
# Certifique-se de ter o Supabase CLI instalado e configurado

echo "Aplicando função SQL recalculate_user_challenge_progress ao banco de dados..."

# Caminho para o arquivo SQL
SQL_FILE="recalculate_user_challenge_progress.sql"

if [ ! -f "$SQL_FILE" ]; then
    echo "Erro: Arquivo $SQL_FILE não encontrado!"
    exit 1
fi

# Obter a URL e chave do Supabase das variáveis de ambiente
SUPABASE_URL=$(grep SUPABASE_URL .env | cut -d '=' -f2)
SUPABASE_KEY=$(grep SUPABASE_SERVICE_KEY .env | cut -d '=' -f2)

if [ -z "$SUPABASE_URL" ] || [ -z "$SUPABASE_KEY" ]; then
    echo "Erro: Variáveis de ambiente SUPABASE_URL e SUPABASE_SERVICE_KEY não encontradas!"
    echo "Certifique-se de que elas estão definidas no arquivo .env"
    exit 1
fi

# Executar o comando curl para aplicar a função SQL
echo "Executando SQL..."
curl -X POST \
  "$SUPABASE_URL/rest/v1/rpc/exec_sql" \
  -H "apikey: $SUPABASE_KEY" \
  -H "Authorization: Bearer $SUPABASE_KEY" \
  -H "Content-Type: application/json" \
  -d @- << EOF
{
  "query": "$(cat $SQL_FILE)"
}
EOF

echo ""
echo "Função SQL aplicada com sucesso!"
echo "Reinicie o aplicativo para que as alterações tenham efeito." 