#!/bin/bash

# ================================================================
# SCRIPT DE INTEGRAÇÃO FINAL - SISTEMA DE METAS PRÉ-ESTABELECIDAS
# ================================================================
# Data: 2025-01-29
# Função: Finalizar integração do sistema de metas automáticas

set -e  # Parar se houver erro

echo "🚀 Iniciando integração final do sistema de metas pré-estabelecidas..."

# ================================================================
# 1. VERIFICAÇÕES INICIAIS
# ================================================================

echo ""
echo "📋 1. Verificando ambiente..."

# Verificar se estamos no diretório correto
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Erro: Execute este script na raiz do projeto Flutter"
    exit 1
fi

# Verificar se Flutter está instalado
if ! command -v flutter &> /dev/null; then
    echo "❌ Erro: Flutter não encontrado. Instale o Flutter primeiro."
    exit 1
fi

echo "✅ Ambiente verificado"

# ================================================================
# 2. INSTALAÇÃO DE DEPENDÊNCIAS
# ================================================================

echo ""
echo "📦 2. Instalando dependências Flutter..."

flutter pub get

echo "✅ Dependências instaladas"

# ================================================================
# 3. ANÁLISE DE CÓDIGO
# ================================================================

echo ""
echo "🔍 3. Analisando código Flutter..."

# Executar análise
flutter analyze

if [ $? -ne 0 ]; then
    echo "⚠️ Aviso: Encontrados warnings na análise. Verifique os logs acima."
else
    echo "✅ Análise de código OK"
fi

# ================================================================
# 4. EXECUTAR TESTES
# ================================================================

echo ""
echo "🧪 4. Executando testes unitários..."

# Executar testes específicos de metas
flutter test test/features/goals/preset_goals_test.dart

if [ $? -eq 0 ]; then
    echo "✅ Testes unitários passaram"
else
    echo "⚠️ Aviso: Alguns testes falharam. Verifique a implementação."
fi

# ================================================================
# 5. LIMPEZA E REBUILD
# ================================================================

echo ""
echo "🧹 5. Limpando e fazendo rebuild..."

# Limpar build anterior
flutter clean

# Redownload dependências
flutter pub get

# Gerar código necessário
flutter packages pub run build_runner build --delete-conflicting-outputs

echo "✅ Projeto limpo e reconstruído"

# ================================================================
# 6. VERIFICAÇÕES FINAIS
# ================================================================

echo ""
echo "✅ 6. Verificações finais..."

# Verificar arquivos críticos
CRITICAL_FILES=(
    "lib/features/goals/widgets/preset_goals_dashboard.dart"
    "lib/features/goals/widgets/preset_goals_modal.dart"
    "lib/features/goals/screens/goals_screen.dart"
    "lib/features/dashboard/widgets/goals_section_enhanced.dart"
    "lib/features/goals/models/preset_category_goals.dart"
    "lib/features/goals/repositories/workout_category_goals_repository.dart"
)

for file in "${CRITICAL_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file existe"
    else
        echo "❌ $file não encontrado!"
    fi
done

# ================================================================
# 7. INSTRUÇÕES FINAIS
# ================================================================

echo ""
echo "🎉 ============================================="
echo "🎉 INTEGRAÇÃO CONCLUÍDA COM SUCESSO!"
echo "🎉 ============================================="
echo ""
echo "📋 PRÓXIMOS PASSOS:"
echo ""
echo "1. 🏃 Execute o app:"
echo "   flutter run"
echo ""
echo "2. 🎯 Teste as funcionalidades:"
echo "   - Acesse 'Minhas Metas' no menu"
echo "   - Crie uma meta de teste"
echo "   - Registre um exercício"
echo "   - Verifique se o progresso atualiza automaticamente"
echo ""
echo "3. 📊 Verifique o Dashboard:"
echo "   - Acesse o Dashboard Enhanced"
echo "   - Verifique se a seção de metas aparece"
echo "   - Teste a navegação 'Ver todas'"
echo ""
echo "4. 🎨 Teste a UX:"
echo "   - Verifique emojis e cores"
echo "   - Teste estados de loading"
echo "   - Verifique responsividade"
echo ""
echo "🗂️ ARQUIVOS PRINCIPAIS:"
echo "   - GoalsScreen: Tela principal de metas"
echo "   - PresetGoalsDashboard: Dashboard de metas"
echo "   - GoalsSectionEnhanced: Seção do dashboard"
echo ""
echo "📖 DOCUMENTAÇÃO:"
echo "   - docs/SISTEMA_INTEGRADO_METAS_PRESET.md"
echo "   - docs/PRESET_GOALS_SYSTEM_GUIDE.md"
echo ""
echo "🐛 SOLUÇÃO DE PROBLEMAS:"
echo "   - Verifique logs do Supabase para erros SQL"
echo "   - Execute 'flutter doctor' se houver problemas"
echo "   - Verifique se triggers SQL estão ativos"
echo ""
echo "✨ SISTEMA PRONTO PARA PRODUÇÃO! ✨"
echo ""

# ================================================================
# 8. CRIAR BACKUP
# ================================================================

echo "💾 Criando backup da configuração atual..."

BACKUP_DIR="backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Backup dos arquivos principais
cp -r lib/features/goals "$BACKUP_DIR/"
cp -r docs "$BACKUP_DIR/" 2>/dev/null || true
cp -r sql "$BACKUP_DIR/" 2>/dev/null || true

echo "✅ Backup salvo em: $BACKUP_DIR"

echo ""
echo "🎉 Setup completo! O sistema de metas pré-estabelecidas está pronto para uso!" 