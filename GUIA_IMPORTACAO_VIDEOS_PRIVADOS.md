# 🔐 Guia: Importação de Vídeos Privados do YouTube

Como você é **manager do canal**, este guia te ajudará a importar os vídeos privados usando autenticação OAuth.

## 📋 Pré-requisitos

### 1. Configurar Credenciais OAuth no Google Console

1. **Acesse**: https://console.developers.google.com/
2. **Crie um projeto** ou selecione um existente
3. **Habilite a YouTube Data API v3**:
   - Vá em "APIs & Services" > "Library"
   - Busque "YouTube Data API v3"
   - Clique em "Enable"

4. **Crie credenciais OAuth 2.0**:
   - Vá em "APIs & Services" > "Credentials"
   - Clique em "Create Credentials" > "OAuth 2.0 Client IDs"
   - Escolha "Desktop application"
   - Dê um nome (ex: "Ray Club Video Importer")
   - **Anote o Client ID e Client Secret**

### 2. Configurar Arquivo .env

Crie um arquivo `.env` na raiz do projeto com:

```env
# Configurações do YouTube Data API
YOUTUBE_API_KEY=AIzaSyB7ABH_EMd3kg2DGRh3SXMJaKBSNsotPNs

# Configurações OAuth (substitua pelos seus valores)
GOOGLE_OAUTH_CLIENT_ID=seu_client_id_aqui
GOOGLE_OAUTH_CLIENT_SECRET=seu_client_secret_aqui

# Configurações do Supabase
SUPABASE_URL=https://ggrjepkyhwlfbhyqrzgg.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdncmplcGt5aHdsZmJoeXFyemdnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQ1MzAzNzksImV4cCI6MjA1MDEwNjM3OX0.j8u5cQOdKHiafkzC1lgOK3PpGUQEYRtAM8StyQqLNzw
```

## 🚀 Como Executar a Importação

### Passo 1: Execute o Script
```bash
cd /Users/marcelacunha/ray_club_app
dart run scripts/oauth_youtube_manager.dart
```

### Passo 2: Autenticação OAuth
O script irá:

1. **Gerar um link de autorização**
2. **Você deve**:
   - Copiar o link e abrir no navegador
   - **Fazer login com sua conta de manager do canal**
   - Autorizar o acesso aos dados do YouTube
   - Copiar o código de autorização que aparece

3. **Colar o código** no terminal quando solicitado

### Passo 3: Importação Automática
Após a autenticação, o script irá:

- ✅ Buscar **todos os vídeos privados** do canal
- ✅ **Categorizar automaticamente** baseado no título:
  - "Pilates"/"Goyá" → Categoria Pilates + Instrutor "Goya Health Club"
  - "FightFit"/"Fight Fit" → Categoria Funcional + Instrutor "Fight Fit"
  - "Treino A/B/C/D/E" → Categoria Musculação + Instrutor "Treinos de Musculação"
  - Outros → Categoria Musculação + Instrutor "Ray Club"
- ✅ **Excluir vídeos "The Unit"** automaticamente
- ✅ **Verificar duplicatas** antes de inserir
- ✅ **Inserir no banco Supabase** com todos os metadados

## 📊 Categorização Automática

O sistema categoriza os vídeos automaticamente:

| Palavras-chave no Título | Categoria | Instrutor |
|---------------------------|-----------|-----------|
| "pilates", "goyá", "goya" | Pilates | Goya Health Club |
| "fightfit", "fight fit" | Funcional | Fight Fit |
| "treino a/b/c/d/e" | Musculação | Treinos de Musculação |
| "corrida", "running" | Corrida | Ray Club |
| "hiit" | HIIT | Ray Club |
| "fisioterapia" | Fisioterapia | Ray Club |
| **Outros** | Musculação | Ray Club |

## ⚠️ Exclusões Automáticas

- **Vídeos "The Unit"**: Automaticamente excluídos conforme solicitado
- **Vídeos duplicados**: Verificação automática antes da inserção

## 🔍 Verificação de Resultados

Após a execução, você verá um resumo:
- ✅ **Inseridos**: Quantos vídeos foram adicionados
- ⏭️ **Ignorados**: Duplicatas ou vídeos excluídos  
- ❌ **Erros**: Problemas na inserção (se houver)

## 🔧 Troubleshooting

### Erro: "Canal não encontrado ou sem acesso"
- Certifique-se de que você fez login com a conta **manager do canal**
- Verifique se suas permissões de manager ainda estão ativas

### Erro: "OAuth access token required"
- As credenciais OAuth não foram configuradas corretamente
- Verifique o arquivo `.env` com Client ID e Client Secret

### Erro: "Quota exceeded"
- A API do YouTube tem limites diários
- Tente novamente no dia seguinte

### Erro de conexão com Supabase
- Verifique se as configurações do Supabase estão corretas no `.env`
- Teste a conexão com um dos scripts de diagnóstico

## 📈 Vantagens desta Solução

✅ **Acesso completo** aos vídeos privados como manager  
✅ **Categorização inteligente** automática  
✅ **Prevenção de duplicatas**  
✅ **Exclusões automáticas** ("The Unit")  
✅ **Processamento em lote** eficiente  
✅ **Logs detalhados** do processo  
✅ **Integração direta** com Supabase  

## 📞 Suporte

Se encontrar problemas:
1. Verifique se as credenciais OAuth estão corretas
2. Confirme suas permissões de manager no canal
3. Execute um dos scripts de diagnóstico para verificar a conectividade

A solução está pronta para importar todos os vídeos privados do seu canal automaticamente! 🎉 