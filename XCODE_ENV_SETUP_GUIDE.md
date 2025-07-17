# Guia de Configuração do .env no Xcode para Produção

## 🎯 Objetivo
Configurar o Xcode para automaticamente usar o arquivo `.env` de produção durante o build, garantindo que a Apple e os usuários recebam o app com as configurações corretas.

## 📋 Pré-requisitos

1. Certifique-se de que o arquivo `env.production.example` existe na raiz do projeto
2. Tenha o Xcode instalado e atualizado
3. O projeto Flutter deve estar funcionando corretamente

## 🔧 Configuração do Xcode - Passo a Passo

### 1. Abrir o projeto no Xcode
```bash
cd /Users/marcelacunha/ray_club_app
open ios/Runner.xcworkspace
```

### 2. Adicionar Script de Build Phase

1. No Xcode, selecione o projeto **Runner** no navegador lateral
2. Selecione o target **Runner**
3. Vá para a aba **Build Phases**
4. Clique no **+** e selecione **New Run Script Phase**
5. Arraste o novo script para **ANTES** de **Compile Sources**
6. Renomeie para "Copy Environment File"

### 3. Configurar o Script

Cole o seguinte script na área de texto:

```bash
# Configurar arquivo .env para o build
echo "🔧 Configurando arquivo .env para o build..."

# Diretório raiz do projeto Flutter
PROJECT_ROOT="$SRCROOT/.."

# Para builds de Release (produção)
if [ "${CONFIGURATION}" = "Release" ]; then
    echo "📱 Build de produção detectado"
    
    if [ -f "$PROJECT_ROOT/env.production.example" ]; then
        cp "$PROJECT_ROOT/env.production.example" "$PROJECT_ROOT/.env"
        echo "✅ Arquivo de produção copiado para .env"
    else
        echo "❌ ERRO: env.production.example não encontrado!"
        exit 1
    fi
else
    echo "🔧 Build de desenvolvimento"
fi

# Verificar se o .env foi criado
if [ -f "$PROJECT_ROOT/.env" ]; then
    echo "✅ Arquivo .env pronto"
else
    echo "❌ ERRO: Falha ao criar .env"
    exit 1
fi
```

### 4. Configurar Build Settings

1. Ainda no target **Runner**, vá para **Build Settings**
2. Procure por **Build Configuration**
3. Certifique-se de que:
   - **Debug** está configurado para desenvolvimento
   - **Release** está configurado para produção

### 5. Adicionar o .env aos recursos (Opcional)

Se você quiser garantir que o .env seja incluído no bundle:

1. No Xcode, clique com botão direito em **Runner**
2. Selecione **Add Files to "Runner"...**
3. NÃO adicione o .env diretamente
4. Em vez disso, o script acima cuidará disso durante o build

## 🚀 Executar Build de Produção

### Opção 1: Via Terminal (Recomendado)
```bash
# Tornar o script executável
chmod +x build_production_ios.sh

# Executar o script
./build_production_ios.sh
```

### Opção 2: Via Xcode
1. No Xcode, selecione **Product** → **Scheme** → **Edit Scheme**
2. Selecione **Run** → **Info**
3. Mude **Build Configuration** para **Release**
4. Selecione **Product** → **Archive**

## 🔍 Verificação

### Durante o Build
Você verá no log de build:
```
🔧 Configurando arquivo .env para o build...
📱 Build de produção detectado
✅ Arquivo de produção copiado para .env
✅ Arquivo .env pronto
```

### Após o Build
Para verificar se as configurações foram aplicadas:

1. Abra o arquivo gerado `.env` e confirme que tem as configurações de produção
2. No app compilado, as variáveis de ambiente estarão disponíveis

## 🛡️ Segurança

### Importante:
1. **NUNCA** commite o arquivo `.env` no Git
2. O arquivo `env.production.example` pode ser commitado (sem dados sensíveis)
3. Use o `.gitignore` para excluir `.env`

### Verificar .gitignore:
```bash
# Deve conter:
.env
.env.*
!.env.example
!env.production.example
```

## 🐛 Troubleshooting

### Erro: "env.production.example não encontrado"
```bash
# Verificar se o arquivo existe
ls -la env.production.example

# Se não existir, crie a partir do template
cp CONFIGURACAO_ENV_PRODUCAO.md env.production.example
# Edite e adicione as variáveis corretas
```

### Erro: "Variáveis de ambiente não carregadas"
1. Verifique se o Flutter está carregando o .env:
   ```dart
   // Em main.dart
   await dotenv.load(fileName: '.env');
   ```

2. Verifique o fallback em `ProductionConfig`

### Build falha no Xcode
1. Limpe o build: **Product** → **Clean Build Folder**
2. Delete a pasta DerivedData:
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData
   ```

## 📱 Upload para App Store

Após o build bem-sucedido:

1. No Xcode: **Product** → **Archive**
2. Quando concluir, abrirá o **Organizer**
3. Clique em **Distribute App**
4. Selecione **App Store Connect**
5. Siga as instruções para upload

## ✅ Checklist Final

- [ ] Arquivo `env.production.example` existe e está correto
- [ ] Script de Build Phase adicionado no Xcode
- [ ] Build Configuration está em Release para produção
- [ ] `.env` está no `.gitignore`
- [ ] Build number foi incrementado
- [ ] Archive criado com sucesso
- [ ] Upload para App Store Connect concluído

## 🎉 Pronto!

Com essa configuração, sempre que você fizer um build de Release no Xcode, o arquivo de produção será automaticamente usado, garantindo que a Apple e os usuários finais recebam o app com as configurações corretas de produção. 