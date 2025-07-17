# 📱 Guia de Archive e Upload do Ray Club App

## ✅ Status Atual
- **Versão**: 1.0.15
- **Build Number**: 24
- **Bundle ID**: com.rayclub.app
- **Team ID**: 5X5AG58L34

## 🔧 Processo de Archive no Xcode

### 1. Preparação
- [x] Flutter build concluído com sucesso
- [x] Xcode workspace aberto (`ios/Runner.xcworkspace`)
- [x] Versão atualizada para 1.0.15+24

### 2. Configuração no Xcode

1. **Selecionar Destino**:
   - No topo do Xcode, ao lado do botão "Run"
   - Selecione: `Any iOS Device (arm64)`
   - **NÃO** selecione um simulador

2. **Verificar Configurações**:
   - Scheme: `Runner`
   - Configuration: `Release`
   - Team: `5X5AG58L34`

### 3. Processo de Archive

1. **Iniciar Archive**:
   ```
   Menu: Product > Archive
   ```

2. **Aguardar Processo**:
   - O processo pode levar 5-10 minutos
   - Aguarde até aparecer "Archive succeeded"

3. **Organizer Window**:
   - Automaticamente abrirá o Organizer
   - Você verá o archive recém-criado

### 4. Distribuição para App Store

1. **Distribute App**:
   - Clique no botão "Distribute App"

2. **Método de Distribuição**:
   - Selecione: `App Store Connect`
   - Clique "Next"

3. **Destination**:
   - Selecione: `Upload`
   - Clique "Next"

4. **App Store Connect Options**:
   - ✅ Upload your app's symbols
   - ✅ Manage Version and Build Number
   - Clique "Next"

5. **Signing**:
   - Selecione: `Automatically manage signing`
   - Clique "Next"

6. **Review**:
   - Revise as informações
   - Clique "Upload"

### 5. Verificação no App Store Connect

1. **Acesse**: [App Store Connect](https://appstoreconnect.apple.com)

2. **Navegue para**:
   - My Apps > Ray Club App
   - TestFlight > iOS Builds

3. **Aguarde Processamento**:
   - O build aparecerá como "Processing"
   - Pode levar 10-30 minutos para processar

## 🚨 Possíveis Problemas e Soluções

### Erro de Code Signing
```bash
# Se houver erro de signing, execute:
flutter clean
flutter pub get
flutter build ios --release --no-codesign
```

### Erro de Provisioning Profile
1. Vá em Xcode > Preferences > Accounts
2. Selecione sua conta Apple Developer
3. Clique "Download Manual Profiles"

### Erro de Bundle ID
- Verifique se o Bundle ID `com.rayclub.app` está correto
- Confirme no Apple Developer Portal

## 📋 Checklist Final

- [ ] Archive criado com sucesso
- [ ] Upload para App Store Connect concluído
- [ ] Build aparece no TestFlight
- [ ] Versão 1.0.15 (24) confirmada
- [ ] Pronto para submissão para review

## 🎯 Próximos Passos

Após o upload bem-sucedido:
1. Aguardar processamento no App Store Connect
2. Configurar informações da versão
3. Submeter para App Store Review
4. Aguardar aprovação da Apple

---

**Data do Build**: $(date)
**Versão**: 1.0.15+24 