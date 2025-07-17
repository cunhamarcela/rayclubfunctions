# Instruções Completas para Correção da Autenticação - Ray Club App

## Problemas Identificados

Baseado na análise do código e das configurações mostradas nas imagens do Supabase e Google Cloud Console, foram identificados os seguintes problemas:

1. **Inconsistência nas URLs de redirecionamento** entre código, Supabase e Google Cloud Console
2. **Configuração incorreta dos provedores OAuth** no Supabase
3. **Falta de tratamento adequado de erros** de autenticação
4. **URLs de redirecionamento não funcionais** para reset de senha e confirmação de email
5. **Configuração incompleta dos deep links** no app mobile

## Soluções Implementadas

### 1. Centralização das Configurações de URL

Foi criado o arquivo `lib/core/config/auth_config.dart` que centraliza todas as URLs:

- **OAuth Callback**: `https://rayclub.com.br/auth/callback`
- **Reset Password**: `https://rayclub.com.br/reset-password`
- **Confirm Email**: `https://rayclub.com.br/confirm`

### 2. Correções no AuthRepository

- Unificação das URLs de redirecionamento para todas as plataformas
- Melhor tratamento de erros com mensagens mais específicas
- Aumento do tempo de espera para sessões OAuth (20 tentativas)
- Logs mais informativos para debug

## Configurações Necessárias no Supabase

### 1. Authentication > URL Configuration

Você precisa atualizar as URLs no Supabase para corresponder às configurações do código:

**Site URL:**
```
https://rayclub.com.br
```

**Redirect URLs (adicionar todas estas):**
```
https://rayclub.com.br/auth/callback
https://rayclub.com.br/reset-password
https://rayclub.com.br/confirm
rayclub://login-callback
rayclub://reset-password  
rayclub://confirm
```

### 2. Authentication > Providers

**Google OAuth:**
- Habilitar o provedor Google
- Client ID: `187648853060-1dcptn3rmjh1unvpa9segd6o9bdnnqt.apps.googleusercontent.com`
- Client Secret: (obter do Google Cloud Console)
- Authorized redirect URIs: `https://rayclub.com.br/auth/callback`

**Apple OAuth:**
- Habilitar o provedor Apple
- Service ID: (do Apple Developer Console)
- Team ID: `5X5AG58L34`
- Key ID: (do Apple Developer Console)
- Private Key: (do Apple Developer Console)

## Configurações Necessárias no Google Cloud Console

### 1. OAuth 2.0 Client IDs

**Web Application:**
- Authorized JavaScript origins: `https://rayclub.com.br`
- Authorized redirect URIs: 
  ```
  https://rayclub.com.br/auth/callback
  https://zsbbgchsjuicwtrldn.supabase.co/auth/v1/callback
  ```

**iOS Application:**
- Bundle ID: `com.rayclub.app`
- No need for redirect URIs (handled by deep links)

### 2. Apple Developer Console

Configure o Sign In with Apple:

**Service ID:** `com.rayclub.app.signin`
**Return URLs:** `https://rayclub.com.br/auth/callback`

## Páginas Web de Redirecionamento

Você precisa criar as seguintes páginas no domínio `https://rayclub.com.br`:

### 1. `/auth/callback` (OAuth Callback)
```html
<!DOCTYPE html>
<html>
<head>
    <title>Ray Club - Autenticação</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
</head>
<body>
    <div style="text-align: center; padding: 50px; font-family: Arial, sans-serif;">
        <h2>Redirecionando...</h2>
        <p>Você será redirecionado para o aplicativo em instantes.</p>
    </div>
    
    <script>
        // Extrair parâmetros da URL
        const urlParams = new URLSearchParams(window.location.search);
        const fragment = new URLSearchParams(window.location.hash.substring(1));
        
        // Combinar parâmetros
        const allParams = new URLSearchParams();
        urlParams.forEach((value, key) => allParams.set(key, value));
        fragment.forEach((value, key) => allParams.set(key, value));
        
        // Construir URL de deep link
        const deepLinkUrl = `rayclub://login-callback/?${allParams.toString()}`;
        
        // Tentar redirecionar para o app
        window.location.href = deepLinkUrl;
        
        // Fallback após 3 segundos
        setTimeout(() => {
            document.body.innerHTML = `
                <div style="text-align: center; padding: 50px; font-family: Arial, sans-serif;">
                    <h2>Abrir Ray Club App</h2>
                    <p>Se o app não abriu automaticamente, clique no link abaixo:</p>
                    <a href="${deepLinkUrl}" style="background: #007AFF; color: white; padding: 15px 30px; text-decoration: none; border-radius: 8px;">
                        Abrir App
                    </a>
                </div>
            `;
        }, 3000);
    </script>
</body>
</html>
```

### 2. `/reset-password` (Reset de Senha)
```html
<!DOCTYPE html>
<html>
<head>
    <title>Ray Club - Redefinir Senha</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
</head>
<body>
    <div style="text-align: center; padding: 50px; font-family: Arial, sans-serif;">
        <h2>Redefinir Senha</h2>
        <p>Redirecionando para o aplicativo...</p>
    </div>
    
    <script>
        const urlParams = new URLSearchParams(window.location.search);
        const fragment = new URLSearchParams(window.location.hash.substring(1));
        
        const allParams = new URLSearchParams();
        urlParams.forEach((value, key) => allParams.set(key, value));
        fragment.forEach((value, key) => allParams.set(key, value));
        
        const deepLinkUrl = `rayclub://reset-password/?${allParams.toString()}`;
        window.location.href = deepLinkUrl;
        
        setTimeout(() => {
            document.body.innerHTML = `
                <div style="text-align: center; padding: 50px; font-family: Arial, sans-serif;">
                    <h2>Abrir Ray Club App</h2>
                    <p>Para redefinir sua senha, abra o app:</p>
                    <a href="${deepLinkUrl}" style="background: #007AFF; color: white; padding: 15px 30px; text-decoration: none; border-radius: 8px;">
                        Abrir App
                    </a>
                </div>
            `;
        }, 3000);
    </script>
</body>
</html>
```

### 3. `/confirm` (Confirmação de Email)
```html
<!DOCTYPE html>
<html>
<head>
    <title>Ray Club - Confirmar Email</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
</head>
<body>
    <div style="text-align: center; padding: 50px; font-family: Arial, sans-serif;">
        <h2>Email Confirmado!</h2>
        <p>Redirecionando para o aplicativo...</p>
    </div>
    
    <script>
        const urlParams = new URLSearchParams(window.location.search);
        const fragment = new URLSearchParams(window.location.hash.substring(1));
        
        const allParams = new URLSearchParams();
        urlParams.forEach((value, key) => allParams.set(key, value));
        fragment.forEach((value, key) => allParams.set(key, value));
        
        const deepLinkUrl = `rayclub://confirm/?${allParams.toString()}`;
        window.location.href = deepLinkUrl;
        
        setTimeout(() => {
            document.body.innerHTML = `
                <div style="text-align: center; padding: 50px; font-family: Arial, sans-serif;">
                    <h2>Abrir Ray Club App</h2>
                    <p>Seu email foi confirmado! Abra o app para continuar:</p>
                    <a href="${deepLinkUrl}" style="background: #007AFF; color: white; padding: 15px 30px; text-decoration: none; border-radius: 8px;">
                        Abrir App
                    </a>
                </div>
            `;
        }, 3000);
    </script>
</body>
</html>
```

## Configurações de Deep Links

### Android (`android/app/src/main/AndroidManifest.xml`)

Adicione dentro da tag `<activity>` principal:

```xml
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="rayclub" />
</intent-filter>
```

### iOS

O iOS já está configurado corretamente no `Info.plist` com o URL scheme `rayclub`.

## Verificação das Configurações

### 1. Teste no Simulador/Dispositivo

Execute o app e teste:

```bash
flutter clean
flutter pub get
flutter run
```

### 2. Teste de Deep Links

No iOS Simulator:
```bash
xcrun simctl openurl booted "rayclub://login-callback/?access_token=test"
```

No Android:
```bash
adb shell am start -W -a android.intent.action.VIEW -d "rayclub://login-callback/?access_token=test" com.rayclub.app
```

### 3. Logs de Debug

Monitore os logs para verificar se as URLs estão sendo usadas corretamente:

```
🔍 AuthRepository: Iniciando login com Google. Plataforma: ios, URL: https://rayclub.com.br/auth/callback
```

## Checklist de Verificação

- [ ] URLs atualizadas no Supabase Authentication > URL Configuration
- [ ] Provedores Google e Apple configurados no Supabase
- [ ] URLs atualizadas no Google Cloud Console
- [ ] Apple Sign In configurado no Apple Developer Console  
- [ ] Páginas web criadas em `rayclub.com.br`
- [ ] Deep links testados no dispositivo/simulador
- [ ] Logs de debug verificados

## Solução de Problemas Comuns

### Erro: "redirect_uri_mismatch"
- Verifique se todas as URLs estão exatamente iguais no Supabase, Google Cloud Console e Apple Developer Console

### Erro: "Tempo esgotado aguardando pela sessão"
- Verifique se as páginas web de redirecionamento estão funcionando
- Teste os deep links manualmente

### Login funciona mas não retorna ao app
- Verifique se os deep links estão configurados corretamente
- Teste as páginas web de redirecionamento

## Resultado Esperado

Após implementar todas essas correções:

1. ✅ Login com Google funcionará
2. ✅ Login com Apple funcionará  
3. ✅ Reset de senha funcionará
4. ✅ Confirmação de email funcionará
5. ✅ Criação de novos usuários funcionará
6. ✅ Deep links redirecionarão corretamente para o app 