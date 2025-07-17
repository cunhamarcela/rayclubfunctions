# Configuração de Deep Links no Ray Club

Este documento descreve as configurações necessárias para funcionamento correto dos deep links no aplicativo Ray Club.

## URLs de Redirecionamento

O aplicativo possui três principais URLs de redirecionamento:

1. **Confirmação de cadastro**:
   - URL no Supabase: `https://rayclub.com.br/confirm/`
   - Deep Link: `rayclub://login`

2. **Redefinição de senha**:
   - URL no Supabase: `https://rayclub.com.br/reset-password/`
   - Deep Link: `rayclub://reset-password`

3. **Login via OAuth (Google, Apple)**:
   - URL no Supabase: `https://rayclub.com.br/auth/callback/`
   - Deep Link: `rayclub://login`

## Configuração no Supabase

Na seção Authentication > URL Configuration, as seguintes URLs devem estar configuradas:

- `https://rayclub.com.br/confirm/`
- `https://rayclub.com.br/reset-password/`
- `https://rayclub.com.br/auth/callback/`

## Configuração no HTML (Servidor Web)

Os arquivos HTML estão configurados para redirecionar para o app:

### public/confirm/index.html:
```html
<meta http-equiv="refresh" content="2;url=rayclub://login" />
```

### public/reset-password/index.html:
```html
<meta http-equiv="refresh" content="2;url=rayclub://reset-password" />
```

### public/auth/callback/index.html:
```html
<meta http-equiv="refresh" content="2;url=rayclub://login" />
```

## Configuração no Android

O AndroidManifest.xml foi configurado para aceitar links com o esquema `rayclub`:

```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="rayclub" />
</intent-filter>
```

## Configuração no iOS

O Info.plist foi configurado com:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>rayclub</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>rayclub</string>
        </array>
    </dict>
</array>
<key>FlutterDeepLinkingEnabled</key>
<true/>
```

## Manipulação de Deep Links no App

Os deep links são tratados pelo `DeepLinkHandler` que redireciona o usuário para as telas apropriadas:

- `rayclub://login` → Tela de login
- `rayclub://reset-password` → Tela de redefinição de senha

## Fluxo Completo

1. **Confirmação de email**:
   - Usuário clica no link no email
   - O navegador abre `https://rayclub.com.br/confirm/` 
   - O HTML redireciona para `rayclub://login`
   - O app abre na tela de login

2. **Redefinição de senha**:
   - Usuário clica no link no email
   - O navegador abre `https://rayclub.com.br/reset-password/`
   - O HTML redireciona para `rayclub://reset-password`
   - O app abre na tela de redefinição de senha

3. **OAuth (Google, Apple)**:
   - Usuário faz login com provedor social
   - Após autenticação, redireciona para `https://rayclub.com.br/auth/callback/`
   - O HTML redireciona para `rayclub://login`
   - O app abre na tela de login com a autenticação já finalizada 