# 🍎 Diagnóstico Completo - Sign in with Apple

## 📋 Resumo do Problema
O Sign in with Apple não está funcionando corretamente. Quando o usuário tenta fazer login e insere a senha, ocorre um erro.

## 🔍 Análise da Implementação Atual

### 1. **Configuração no iOS** 

#### ✅ Info.plist
```xml
<!-- URL Schemes configurados corretamente -->
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>rayclub</string>
        </array>
    </dict>
</array>
```

#### ✅ Runner.entitlements
```xml
<!-- Sign in with Apple habilitado -->
<key>com.apple.developer.applesignin</key>
<array>
    <string>Default</string>
</array>
<!-- Associated Domains configurado -->
<key>com.apple.developer.associated-domains</key>
<array>
    <string>applinks:rayclub.app</string>
</array>
```

### 2. **Implementação no Flutter**

#### AuthRepository (`lib/features/auth/repositories/auth_repository.dart`)
```dart
Future<supabase.Session?> signInWithApple() async {
    // Usa mesma estratégia do Google OAuth que está funcionando
    final String redirectUrl = (platform == 'ios' || platform == 'android')
        ? 'rayclub://login-callback/'
        : 'https://zsbbgchsjiuicwvtrldn.supabase.co/auth/v1/callback';
    
    // OAuth sem especificar authScreenLaunchMode
    final response = await _supabaseClient.auth.signInWithOAuth(
      supabase.OAuthProvider.apple,
      redirectTo: redirectUrl,
      scopes: 'name email',
    );
    
    // Aguarda sessão com timeout de 30 segundos
    const maxAttempts = 30;
    // ... código de espera pela sessão ...
}
```

### 3. **Análise de Problemas Identificados**

## ❌ Problemas Encontrados

### 1. **Configuração no Supabase**
- ⚠️ **Service ID**: Precisa estar configurado no Supabase Dashboard
- ⚠️ **Team ID**: Já configurado como `5X5AG58L34`
- ⚠️ **Key ID**: Precisa estar configurado
- ⚠️ **Private Key**: Precisa estar configurada

### 2. **URLs de Redirecionamento**
As seguintes URLs devem estar configuradas no Supabase:
- `https://zsbbgchsjiuicwvtrldn.supabase.co/auth/v1/callback`
- `rayclub://login-callback/`

### 3. **Apple Developer Console**
Verificar se:
- ✅ App ID tem Sign In with Apple habilitado
- ⚠️ Service ID criado e configurado corretamente
- ⚠️ Key para Sign In with Apple criada
- ✅ Associated Domains configurado

## 🔧 Ações Necessárias

### 1. **No Supabase Dashboard**
1. Acessar **Authentication > Providers > Apple**
2. Configurar:
   - **Service ID**: (obter do Apple Developer)
   - **Team ID**: `5X5AG58L34` ✅
   - **Key ID**: (obter do Apple Developer)
   - **Private Key**: (copiar do Apple Developer)
3. Adicionar URLs de redirecionamento:
   - `https://zsbbgchsjiuicwvtrldn.supabase.co/auth/v1/callback`
   - `rayclub://login-callback/`

### 2. **No Apple Developer Console**

#### Criar Service ID:
1. Acessar **Certificates, Identifiers & Profiles**
2. Clicar em **Identifiers** > **+**
3. Selecionar **Services IDs** e continuar
4. Configurar:
   - **Description**: Ray Club Sign In
   - **Identifier**: `com.rayclub.signin` (ou similar)
5. Habilitar **Sign In with Apple**
6. Configurar **Return URLs**:
   - Primary: `https://zsbbgchsjiuicwvtrldn.supabase.co/auth/v1/callback`

#### Criar Key:
1. Acessar **Keys** > **+**
2. Nome: "Ray Club Sign In Key"
3. Habilitar **Sign In with Apple**
4. Configurar e fazer download da key (arquivo .p8)

### 3. **No Xcode**
Verificar se:
- ✅ Capability "Sign In with Apple" está adicionada
- ✅ Associated Domains está configurado
- ✅ Bundle ID correto: `com.rayclub.app`
- ✅ Team selecionado corretamente

## 🐛 Possíveis Causas do Erro

### 1. **"Invalid_client" ou "Invalid request"**
- **Causa**: Service ID ou Key ID incorretos no Supabase
- **Solução**: Verificar e corrigir as credenciais no Supabase Dashboard

### 2. **"Redirect URL mismatch"**
- **Causa**: URLs não configuradas corretamente
- **Solução**: Adicionar todas as URLs necessárias no Supabase

### 3. **Erro após autenticação**
- **Causa**: Bundle ID ou configuração de Associated Domains incorreta
- **Solução**: Verificar configurações no Xcode e Apple Developer

## 📝 Checklist de Verificação

### Supabase Dashboard
- [ ] Apple Provider está habilitado
- [ ] Service ID configurado corretamente
- [ ] Team ID: `5X5AG58L34`
- [ ] Key ID configurado
- [ ] Private Key (.p8) configurada
- [ ] URLs de redirecionamento adicionadas

### Apple Developer Console
- [ ] App ID com Sign In with Apple habilitado
- [ ] Service ID criado com Return URLs corretas
- [ ] Key criada e baixada (.p8)
- [ ] Associated Domains verificado

### Xcode/iOS
- [x] Info.plist com URL Schemes
- [x] Runner.entitlements com capabilities
- [x] Bundle ID: `com.rayclub.app`
- [x] Associated Domains: `applinks:rayclub.app`

### Código Flutter
- [x] Implementação segue padrão do Google OAuth
- [x] URLs dinâmicas por plataforma
- [x] Timeout de 30 segundos
- [x] Tratamento de erros adequado

## 🚀 Próximos Passos

1. **Verificar configurações no Supabase Dashboard**
   - Acessar Authentication > Providers > Apple
   - Confirmar todas as credenciais

2. **Obter credenciais do Apple Developer**
   - Service ID
   - Key ID
   - Private Key (.p8)

3. **Testar novamente**
   - Executar o app
   - Tentar login com Apple
   - Verificar logs no console

## 📊 Logs para Monitorar

Ao testar, procurar por:
```
🍎 ========== INÍCIO APPLE OAUTH ==========
🔍 Platform: ios
🔍 Redirect URL escolhida: rayclub://login-callback/
❌ AuthRepository.signInWithApple(): AuthException capturada
❌ Code: [código do erro]
❌ Message: [mensagem do erro]
```

## 💡 Observações Importantes

1. O código já está padronizado para seguir o mesmo padrão do Google OAuth que está funcionando
2. As URLs de redirecionamento são dinâmicas (deep link para mobile, HTTPS para web)
3. O plugin `sign_in_with_apple` está instalado e configurado
4. O problema provavelmente está na configuração do Supabase ou nas credenciais do Apple Developer

## 🎯 Conclusão

O problema do Sign in with Apple está relacionado à **configuração no Supabase Dashboard** e/ou **credenciais do Apple Developer**. O código e as configurações do iOS estão corretas. É necessário:

1. Verificar e configurar corretamente o Apple Provider no Supabase
2. Obter e configurar as credenciais corretas do Apple Developer
3. Garantir que todas as URLs de redirecionamento estejam configuradas

Após essas configurações, o Sign in with Apple deve funcionar corretamente. 