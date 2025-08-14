#!/bin/bash

# =====================================================
# CRIAR SCHEDULERS VIA API REST - RAY CLUB
# Como o menu Scheduler não apareceu, vamos usar a API
# =====================================================

echo "🚀 Criando schedulers via API REST do Supabase..."
echo ""

# Configurações
PROJECT_REF="zsbbgchsjiuicwvtrldn"
SUPABASE_URL="https://${PROJECT_REF}.supabase.co"

# IMPORTANTE: Substitua pela sua Service Role Key
# Vá em Settings > API e copie a service_role key
SERVICE_ROLE_KEY="SUBSTITUA_PELA_SUA_SERVICE_ROLE_KEY"

if [ "$SERVICE_ROLE_KEY" = "SUBSTITUA_PELA_SUA_SERVICE_ROLE_KEY" ]; then
    echo "❌ ERRO: Você precisa substituir SERVICE_ROLE_KEY pela sua chave real!"
    echo ""
    echo "📋 PASSOS:"
    echo "1. Vá em Settings > API no Supabase Dashboard"
    echo "2. Copie a 'service_role' key (não a anon key)"
    echo "3. Substitua SERVICE_ROLE_KEY neste script pela chave real"
    echo "4. Execute o script novamente"
    exit 1
fi

echo "🔧 Configurando schedulers via API..."

# Função para criar scheduler
create_scheduler() {
    local name=$1
    local cron=$2
    local description=$3
    
    echo "📅 Criando scheduler: $name"
    
    curl -X POST "${SUPABASE_URL}/rest/v1/rpc/create_cron_job" \
        -H "Authorization: Bearer ${SERVICE_ROLE_KEY}" \
        -H "Content-Type: application/json" \
        -H "apikey: ${SERVICE_ROLE_KEY}" \
        -d "{
            \"job_name\": \"$name\",
            \"schedule\": \"$cron\",
            \"command\": \"SELECT net.http_post(url:='${SUPABASE_URL}/functions/v1/send_push_notifications', headers:='{\\\"Authorization\\\": \\\"Bearer ${SERVICE_ROLE_KEY}\\\", \\\"Content-Type\\\": \\\"application/json\\\"}'::jsonb);\",
            \"database\": \"postgres\",
            \"username\": \"postgres\"
        }"
    
    if [ $? -eq 0 ]; then
        echo "✅ Scheduler '$name' criado com sucesso"
    else
        echo "❌ Erro ao criar scheduler '$name'"
    fi
    echo ""
}

# Criar os 3 schedulers
create_scheduler "notificacoes_manha" "0 8 * * *" "Notificações da manhã (8h)"
create_scheduler "notificacoes_tarde" "0 15 * * *" "Notificações da tarde (15h)"  
create_scheduler "notificacoes_noite" "0 20 * * *" "Notificações da noite (20h)"

echo "🎉 Processo concluído!"
echo ""
echo "🔍 Para verificar se funcionou:"
echo "1. Vá em Database > SQL Editor"
echo "2. Execute: SELECT * FROM cron.job;"
echo "3. Deve mostrar os 3 jobs criados"
echo ""
