# Guia de Upload pelo Xcode - Ray Club App

## 📱 Passo a Passo para Upload no Xcode

### 1. Abrir o Projeto no Xcode

```bash
open ios/Runner.xcworkspace
```

### 2. Configurar a Versão

No Xcode:
1. Selecione o projeto "Runner" no navegador lateral
2. Na aba "General":
   - **Version**: 1.0.11 (ou a versão atual)
   - **Build**: 22 (ou o número atual + 1)

### 3. Selecionar o Dispositivo

1. Na barra superior do Xcode
2. Selecione: **Any iOS Device (arm64)**

### 4. Criar o Archive

1. Menu: **Product → Archive**
2. Aguarde o processo completar (5-10 minutos)
3. O Organizer abrirá automaticamente

### 5. Fazer o Upload

No Organizer:
1. Selecione o archive recém-criado
2. Clique em **Distribute App**
3. Escolha **App Store Connect**
4. Escolha **Upload**
5. Siga os passos:
   - **Distribution certificate**: Usar o padrão
   - **App Store Connect API**: Usar o padrão
   - **Re-sign**: Automatically manage signing
6. Clique em **Upload**

### 6. Configurar no App Store Connect

Após o upload (10-30 minutos para processar):

1. Acesse [App Store Connect](https://appstoreconnect.apple.com)
2. Selecione seu app
3. Vá para a versão atual
4. Em "Build", selecione o build que você acabou de enviar

### 7. Adicionar Informações de Teste

**Demo Account:**
```
Email: review@rayclub.com
Password: Test1234!
```

**Notes for Reviewer:**
```
Thank you for reviewing our app update.

Key improvements in this version:
- Fixed Apple Sign In database error
- Updated Google OAuth configuration
- Enhanced user authentication flow

Test account provided has expert level access to all features.

The app uses Supabase for backend services with the following configuration:
- Production URL: https://zsbbgchsjiuicwvtrldn.supabase.co
- All authentication providers are properly configured
```

### 8. Submeter para Revisão

1. Preencha "What's New in This Version"
2. Confirme todas as informações
3. Clique em **Submit for Review**

## ⚠️ Checklist Antes do Upload

- [ ] Scripts SQL executados no Supabase
- [ ] Arquivo .env configurado corretamente
- [ ] Build number incrementado
- [ ] Teste em dispositivo físico (se possível)

## 🔧 Solução de Problemas

### Erro de Certificado
- Verifique em **Xcode → Preferences → Accounts**
- Baixe os certificados manualmente se necessário

### Build Falhou
- Limpe o projeto: **Product → Clean Build Folder**
- Delete a pasta DerivedData
- Tente novamente

### Upload Falhou
- Verifique sua conexão com a internet
- Verifique se você tem permissão no App Store Connect
- Tente fazer logout e login novamente no Xcode

## 📊 Tempo Estimado

- Build: 5-10 minutos
- Archive: 5-10 minutos
- Upload: 5-15 minutos
- Processamento no App Store Connect: 10-30 minutos
- Revisão da Apple: 24-48 horas

## 🎯 Resultado Esperado

Após seguir todos os passos:
1. Seu app estará em revisão pela Apple
2. Login com Apple funcionará corretamente
3. Login com Google usará as URLs corretas
4. Usuário de teste terá acesso expert 