# 🛠️ Guia de Correção - Sign in with Apple (ERRO 1000)

## 🎯 Problema Identificado
**Erro 1000 (AuthorizationErrorCode.unknown)** = Problema de configuração entre Apple Developer Console e Supabase.

## ⚠️ **PROBLEMA PRINCIPAL: CLIENT ID INCORRETO**

Baseado nos seus prints, você tem:
- **Service ID no Apple Developer**: `com.rayclub.auth` 
- **App ID principal**: `com.rayclub.app`

**O Supabase precisa usar o App ID principal como Client ID, NÃO o Service ID!**

---

## 📋 **SOLUÇÃO RÁPIDA**

### Passo 1: Verificar/Corrigir no Supabase Dashboard

1. Acesse [Supabase Dashboard](https://supabase.com/dashboard)
2. Vá para **Authentication** > **Providers** > **Apple**
3. **ALTERE o Client ID para**: `com.rayclub.app` (App ID principal)
4. **NÃO use** `com.rayclub.auth` (Service ID)

### Passo 2: Configurações no Apple Developer Console

1. No **App ID** (`com.rayclub.app`):
   - ✅ Certifique que **Sign In with Apple** está habilitado
   - ✅ Configure como **Primary App ID**

2. **OPCIONAL**: Se você criou um Service ID (`com.rayclub.auth`):
   - Pode **DELETAR** este Service ID (não é necessário para apps mobile)
   - OU deixar, mas **não usar no Supabase**

### Passo 3: Verificar Team ID e Key ID no Supabase

No Supabase Dashboard, verifique se está configurado:
- ✅ **Team ID**: Seu Team ID da Apple (encontre em Membership do Apple Developer)
- ✅ **Key ID**: ID da chave privada que você criou
- ✅ **Private Key**: Conteúdo da chave .p8

---

## 🔧 **POR QUE ESSE ERRO ACONTECE?**

- **Service IDs** são para **aplicações web**, não mobile
- **Apps iOS nativos** devem usar o **App ID principal** diretamente
- O Supabase confunde quando você coloca Service ID no lugar do App ID

---

## ✅ **CONFIGURAÇÃO CORRETA FINAL**

**No Supabase:**
```
Client ID: com.rayclub.app          ← App ID principal
Team ID: [Seu Team ID]              ← Da sua conta Apple Developer  
Key ID: [ID da sua chave]           ← Da chave .p8 que você criou
Private Key: [Conteúdo da chave]    ← Conteúdo do arquivo .p8
```

**No Apple Developer Console:**
```
App ID: com.rayclub.app
├── Sign In with Apple: ✅ Enabled
└── Primary App ID: ✅ Configurado
```

---

## 🧪 **TESTAR APÓS MUDANÇA**

1. Faça a alteração no Supabase Dashboard
2. Execute o app no dispositivo físico
3. Teste o Sign in with Apple
4. Deve funcionar **100% nativo** sem páginas externas

---

## 🚨 **SE AINDA DER ERRO**

Verifique no Apple Developer Console se:
1. **Capabilities** do App ID tem Sign In with Apple habilitado
2. **Provisioning Profile** está atualizado com as novas configurações
3. **Bundle ID** do app confere exatamente com o App ID

Rebuilde o app após qualquer mudança no Provisioning Profile.

## 🎯 Objetivo
Corrigir o erro de login do Sign in with Apple no app Ray Club.

## 📋 Passo a Passo

### Passo 1: Acessar o Apple Developer Console

1. Acesse [developer.apple.com](https://developer.apple.com)
2. Faça login com sua conta de desenvolvedor
3. Vá para **Account** > **Certificates, Identifiers & Profiles**

### Passo 2: Verificar App ID

1. Clique em **Identifiers** na barra lateral
2. Encontre o App ID: `com.rayclub.app`
3. Verifique se **Sign In with Apple** está habilitado
4. Se não estiver, habilite e salve

### Passo 3: Criar Service ID (Se não existir)

1. Em **Identifiers**, clique no **+**
2. Selecione **Services IDs** e clique em **Continue**
3. Configure:
   - **Description**: `Ray Club Sign In`
   - **Identifier**: `com.rayclub.signin`
4. Clique em **Continue** e depois **Register**
5. Clique no Service ID criado
6. Marque **Sign In with Apple**
7. Clique em **Configure** ao lado de Sign In with Apple
8. Configure:
   - **Primary App ID**: `com.rayclub.app`
   - **Domains and Subdomains**: `zsbbgchsjiuicwvtrldn.supabase.co`
   - **Return URLs**: `https://zsbbgchsjiuicwvtrldn.supabase.co/auth/v1/callback`
9. Clique em **Next**, depois **Done**, e **Save**

### Passo 4: Criar Key para Sign In with Apple

1. Na barra lateral, clique em **Keys**
2. Clique no **+** para criar uma nova key
3. Configure:
   - **Key Name**: `Ray Club Sign In Key`
   - Marque **Sign In with Apple**
4. Clique em **Configure** ao lado de Sign In with Apple
5. Selecione o **Primary App ID**: `com.rayclub.app`
6. Clique em **Save**
7. Clique em **Continue** e depois **Register**
8. **IMPORTANTE**: Baixe o arquivo `.p8` agora (só pode ser baixado uma vez!)
9. Anote o **Key ID** mostrado na tela

### Passo 5: Configurar no Supabase

1. Acesse o [Supabase Dashboard](https://supabase.com/dashboard)
2. Selecione o projeto Ray Club
3. Vá para **Authentication** > **Providers**
4. Encontre **Apple** e clique em **Enable Apple**
5. Configure:
   - **Service ID**: `com.rayclub.signin` (do passo 3)
   - **Team ID**: `5X5AG58L34`
   - **Key ID**: (do passo 4)
   - **Private Key**: Abra o arquivo `.p8` baixado e copie TODO o conteúdo
6. Clique em **Save**

### Passo 6: Verificar URLs de Redirecionamento

1. Ainda no Supabase, vá para **Authentication** > **URL Configuration**
2. Em **Redirect URLs**, adicione (se não existirem):
   ```
   https://zsbbgchsjiuicwvtrldn.supabase.co/auth/v1/callback
   rayclub://login-callback/
   ```
3. Clique em **Save**

### Passo 7: Testar no App

1. Pare o app se estiver rodando
2. Execute novamente:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```
3. Tente fazer login com Apple
4. Observe os logs no console

## 🔍 Verificação de Erros Comuns

### Erro: "invalid_client"
- **Causa**: Service ID ou Key ID incorretos
- **Solução**: Verifique se copiou corretamente os IDs no Supabase

### Erro: "invalid_grant"
- **Causa**: Private Key incorreta ou expirada
- **Solução**: Verifique se copiou TODO o conteúdo do arquivo .p8, incluindo as linhas BEGIN/END

### Erro: "redirect_uri_mismatch"
- **Causa**: URL de callback não configurada
- **Solução**: Adicione as URLs no Supabase conforme passo 6

### Erro após autenticação bem-sucedida
- **Causa**: Deep link não funcionando
- **Solução**: Verificar se o Bundle ID está correto no Xcode

## 📱 Teste Final

1. Abra o app
2. Clique em "Continuar com Apple"
3. Deve aparecer a tela nativa do iOS para autenticação
4. Use Face ID/Touch ID ou senha
5. O app deve receber a sessão e fazer login

## 🆘 Se Ainda Não Funcionar

1. **Verifique os logs detalhados**:
   - Procure por mensagens iniciando com `🍎`
   - Anote o código e mensagem de erro específicos

2. **No Xcode**:
   - Abra o projeto iOS
   - Vá em **Signing & Capabilities**
   - Verifique se **Sign In with Apple** está listado
   - Se não, clique em **+ Capability** e adicione

3. **Teste em dispositivo real**:
   - O Sign in with Apple pode ter comportamento diferente no simulador
   - Teste em um iPhone real se possível

## ✅ Confirmação de Sucesso

Quando funcionar corretamente, você verá nos logs:
```
🍎 ========== INÍCIO APPLE OAUTH ==========
🔍 Platform: ios
🔍 Redirect URL escolhida: rayclub://login-callback/
✅ AuthRepository.signInWithApple(): Sessão obtida após XXXms
✅ User ID: [id do usuário]
✅ Email: [email do usuário]
🍎 ========== FIM APPLE OAUTH SUCCESS ==========
```

## 📝 Informações Importantes para Guardar

Após configurar, anote:
- **Service ID**: `com.rayclub.signin`
- **Team ID**: `5X5AG58L34`
- **Key ID**: [anotar o ID da key criada]
- **Bundle ID**: `com.rayclub.app`

Essas informações serão necessárias para manutenção futura. 