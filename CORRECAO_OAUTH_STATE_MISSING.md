# 🔧 Correção do Erro "OAuth state parameter missing" - Ray Club App

## 🚨 Problema Identificado

**Erro:** `OAuth state parameter missing`

**Causa:** O app estava usando a URL HTTPS do Supabase (`https://zsbbgchsjiuicwvtrldn.supabase.co/auth/v1/callback`) ao invés do deep link nativo (`rayclub://login-callback/`) no iOS.

## ✅ Solução Implementada

### 1. **Código Atualizado**

O arquivo `lib/features/auth/repositories/auth_repository.dart` foi atualizado para usar deep links nativos no iOS/Android:

```dart
// IMPORTANTE: Usar deep link nativo para iOS/Android
final String redirectUrl = (platform == 'ios' || platform == 'android')
    ? 'rayclub://login-callback/'
    : 'https://zsbbgchsjiuicwvtrldn.supabase.co/auth/v1/callback';
```

### 2. **Verificações Necessárias**

#### ✅ **Supabase Dashboard**

1. Acesse: **Authentication > URL Configuration**
2. Em **Redirect URLs**, confirme que tem:
   ```
   rayclub://login-callback/
   rayclub://login-callback
   https://zsbbgchsjiuicwvtrldn.supabase.co/auth/v1/callback
   https://rayclub.com.br/auth/callback
   ```

#### ✅ **Google Cloud Console** 

1. Acesse: **APIs & Services > Credentials**
2. No OAuth 2.0 Client ID (Web Application)
3. Em **Authorized redirect URIs**, confirme que tem:
   ```
   https://zsbbgchsjiuicwvtrldn.supabase.co/auth/v1/callback
   ```
   
**Nota:** Não precisa adicionar `rayclub://` no Google Cloud, pois o Google redireciona primeiro para o Supabase, que então redireciona para o app.

#### ✅ **iOS Info.plist**

Confirme que o arquivo `ios/Runner/Info.plist` tem:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>rayclub</string>
        </array>
    </dict>
</array>

<key>FlutterDeepLinkingEnabled</key>
<true/>
```

## 📱 Como Testar

### 1. **Limpar e Reconstruir**
```bash
flutter clean
flutter pub get
cd ios && pod install && cd ..
flutter run
```

### 2. **Monitorar Logs**
```bash
flutter run --debug | grep "🔍\|🔐\|✅\|❌"
```

### 3. **Verificar nos Logs**

Você deve ver:
```
🔍 Platform: ios
🔍 Redirect URL escolhida: rayclub://login-callback/
🔍 Tipo de redirect: Deep Link Nativo
```

### 4. **Fluxo Esperado**

1. Usuário clica em "Login com Google"
2. Browser/WebView abre com tela do Google
3. Usuário faz login
4. Google redireciona para Supabase
5. Supabase processa e redireciona para `rayclub://login-callback/`
6. App captura o deep link
7. Login completo! ✅

## 🔍 Troubleshooting

### Se ainda receber "OAuth state parameter missing"

1. **Verificar a barra final (`/`)**
   - Teste com `rayclub://login-callback/` (com barra)
   - Teste com `rayclub://login-callback` (sem barra)
   - Use a mesma versão em todos os lugares

2. **Verificar múltiplos apps**
   - Certifique-se de que não há outro app com o mesmo scheme `rayclub` instalado
   - Desinstale versões antigas do app

3. **Forçar modo de autenticação**
   ```dart
   final response = await _supabaseClient.auth.signInWithOAuth(
     supabase.OAuthProvider.google,
     redirectTo: redirectUrl,
     authScreenLaunchMode: supabase.LaunchMode.inAppWebView, // ou platformDefault
   );
   ```

4. **Limpar cache do dispositivo**
   - No simulador: Device > Erase All Content and Settings
   - No dispositivo real: Desinstalar e reinstalar o app

## 📊 Logs de Diagnóstico

### ✅ Sucesso
```
🔍 Platform: ios
🔍 Redirect URL escolhida: rayclub://login-callback/
🔍 Tipo de redirect: Deep Link Nativo
🔍 OAuth response: true
✅ Sessão obtida após X segundos
```

### ❌ Erro
```
Deep link received: rayclub:?error=invalid_request&error_code=bad_oauth_callback
```

## 🎯 Resultado Esperado

Com essas mudanças, o erro "OAuth state parameter missing" deve ser resolvido, pois:

1. ✅ O app usa deep links nativos no iOS
2. ✅ O Supabase está configurado para aceitar esses deep links
3. ✅ O fluxo OAuth preserva o estado corretamente
4. ✅ O app captura o callback corretamente

## 📝 Notas Importantes

- **Não misture** URLs HTTPS com deep links no mesmo fluxo
- **Use sempre** o mesmo formato de URL (com ou sem barra final)
- **Aguarde** alguns minutos após mudanças no Supabase/Google para propagação
- **Teste** em dispositivo real quando possível (simulador pode ter comportamentos diferentes) 