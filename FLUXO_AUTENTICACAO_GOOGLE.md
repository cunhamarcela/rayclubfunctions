# Fluxo de Autenticação Google - Ray Club App

## Mudanças Realizadas

### 1. **WebView Interna ao invés de Browser Externo**
   - **Arquivo:** `lib/features/auth/repositories/auth_repository.dart`
   - **Mudança:** 
     ```dart
     // ANTES:
     authScreenLaunchMode: supabase.LaunchMode.externalApplication,
     
     // DEPOIS:
     authScreenLaunchMode: supabase.LaunchMode.inAppWebView,
     ```
   - **Aplicado em:** `signInWithGoogle()` e `signInWithApple()`

### 2. **Benefícios da Mudança**
   - ✅ Login ocorre dentro do app (sem abrir Safari)
   - ✅ Melhor experiência do usuário
   - ✅ Controle total sobre o fluxo de autenticação
   - ✅ Redirecionamento automático após login

## Fluxo Ideal de Autenticação

1. **Usuário clica em "Continuar com Google"**
   - Botão chama `_handleGoogleLogin()` no LoginScreen
   - Que chama `signInWithGoogle()` no AuthViewModel

2. **WebView Interna Abre**
   - Mostra a tela de login do Google
   - Usuário insere suas credenciais
   - Google redireciona para a URL de callback do Supabase

3. **Processamento do OAuth**
   - Supabase processa o token
   - Cria/atualiza a sessão do usuário
   - WebView fecha automaticamente

4. **Detecção da Sessão**
   - AuthRepository aguarda a criação da sessão
   - Retorna a sessão para o AuthViewModel

5. **Navegação para Home**
   - AuthViewModel atualiza o estado para `authenticated`
   - LoginScreen detecta a mudança de estado
   - Navega automaticamente para a home

## URLs Configuradas

- **OAuth Callback:** `https://zsbbgchsjuicwtrldn.supabase.co/auth/v1/callback`
- **Deep Link Scheme:** `rayclub://`
- **Google Client IDs:** Configurados no Info.plist e variáveis de ambiente

## Verificação e Testes

### Para testar o novo fluxo:

1. **No Simulator/Device:**
   ```bash
   flutter run
   ```

2. **Passos de Teste:**
   - Abrir o app
   - Ir para tela de login
   - Clicar em "Continuar com Google"
   - Verificar se abre WebView interna (não Safari)
   - Fazer login com conta Google
   - Verificar redirecionamento automático para home

3. **Logs para Monitorar:**
   ```
   🔐 ========== INICIANDO OAUTH COM WEBVIEW INTERNA ==========
   🔍 AuthRepository.signInWithGoogle(): OAuth response: true
   ✅ AuthRepository.signInWithGoogle(): Sessão obtida após XXXms
   ✅ AuthViewModel: Usuário autenticado
   🔄 LoginScreen: Navegando para home
   ```

## Possíveis Problemas e Soluções

### Problema 1: WebView não abre
- **Causa:** Falta de configuração no iOS
- **Solução:** Verificar Info.plist tem as URLs schemes configuradas

### Problema 2: Login sucesso mas não navega
- **Causa:** Estado não sendo detectado corretamente
- **Solução:** Verificar logs do AuthViewModel e LoginScreen

### Problema 3: Erro de redirecionamento
- **Causa:** URL de callback incorreta
- **Solução:** Verificar configuração no Supabase Dashboard

## Configurações Necessárias

### Supabase Dashboard
1. Authentication > URL Configuration
2. Adicionar às Redirect URLs:
   - `https://zsbbgchsjuicwtrldn.supabase.co/auth/v1/callback`
   - `rayclub://login-callback/`

### Google Cloud Console
1. OAuth 2.0 Client IDs
2. Authorized redirect URIs:
   - `https://zsbbgchsjuicwtrldn.supabase.co/auth/v1/callback`

### iOS Info.plist
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>rayclub</string>
        </array>
    </dict>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.187648853060-aub6vfna1dmvb4ihb5o7ir3re3bn0c0i</string>
        </array>
    </dict>
</array>
```

## Conclusão

Com essas mudanças, o fluxo de autenticação agora:
- Mantém o usuário dentro do app durante todo o processo
- Fornece uma experiência mais fluida e profissional
- Elimina a necessidade de voltar manualmente do Safari
- Permite melhor controle sobre erros e estado da autenticação 