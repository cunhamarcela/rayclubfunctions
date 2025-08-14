#!/bin/bash

# =====================================================
# SCRIPT PARA CONFIGURAR SCHEDULERS DE NOTIFICAÇÕES
# Ray Club - Sistema de Notificações Automáticas
# =====================================================

echo "🚀 Configurando schedulers de notificações para Ray Club..."

# Verificar se o Supabase CLI está instalado
if ! command -v supabase &> /dev/null; then
    echo "❌ Supabase CLI não encontrado. Instale com: npm install -g supabase"
    exit 1
fi

# Verificar se estamos logados no Supabase
if ! supabase projects list &> /dev/null; then
    echo "❌ Não está logado no Supabase. Execute: supabase login"
    exit 1
fi

echo "✅ Supabase CLI encontrado e usuário logado"

# Configurar scheduler para notificações da manhã (8h)
echo "📅 Configurando scheduler para notificações da manhã (8h)..."
supabase functions schedule create notificacoes_manha \
  --function send_push_notifications \
  --cron "0 8 * * *" \
  --project-ref zsbbgchsjiuicwvtrldn

if [ $? -eq 0 ]; then
    echo "✅ Scheduler da manhã configurado com sucesso"
else
    echo "❌ Erro ao configurar scheduler da manhã"
fi

# Configurar scheduler para notificações da tarde (15h)
echo "📅 Configurando scheduler para notificações da tarde (15h)..."
supabase functions schedule create notificacoes_tarde \
  --function send_push_notifications \
  --cron "0 15 * * *" \
  --project-ref zsbbgchsjiuicwvtrldn

if [ $? -eq 0 ]; then
    echo "✅ Scheduler da tarde configurado com sucesso"
else
    echo "❌ Erro ao configurar scheduler da tarde"
fi

# Configurar scheduler para notificações da noite (20h)
echo "📅 Configurando scheduler para notificações da noite (20h)..."
supabase functions schedule create notificacoes_noite \
  --function send_push_notifications \
  --cron "0 20 * * *" \
  --project-ref zsbbgchsjiuicwvtrldn

if [ $? -eq 0 ]; then
    echo "✅ Scheduler da noite configurado com sucesso"
else
    echo "❌ Erro ao configurar scheduler da noite"
fi

# Configurar scheduler para verificação de usuários inativos (12h)
echo "📅 Configurando scheduler para verificação de usuários inativos (12h)..."
supabase functions schedule create verificacao_inatividade \
  --function send_push_notifications \
  --cron "0 12 * * *" \
  --project-ref zsbbgchsjiuicwvtrldn

if [ $? -eq 0 ]; then
    echo "✅ Scheduler de verificação de inatividade configurado com sucesso"
else
    echo "❌ Erro ao configurar scheduler de verificação de inatividade"
fi

echo ""
echo "🎉 Configuração de schedulers concluída!"
echo ""
echo "📋 Resumo dos schedulers configurados:"
echo "   • Manhã: 8h (notificações motivacionais e receitas)"
echo "   • Tarde: 15h (lembretes de treino e desafios)"
echo "   • Noite: 20h (reflexões e receitas de jantar)"
echo "   • Inatividade: 12h (verificação de usuários sem treino)"
echo ""
echo "🔧 Para verificar os schedulers ativos, execute:"
echo "   supabase functions schedule list --project-ref zsbbgchsjiuicwvtrldn"
echo ""
echo "🗑️  Para remover um scheduler, execute:"
echo "   supabase functions schedule delete <nome_do_scheduler> --project-ref zsbbgchsjiuicwvtrldn"
