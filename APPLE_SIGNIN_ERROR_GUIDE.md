# Guia de Solução - Erro Apple Sign In (Error 1000 / AK-7026)

## Problema Identificado
- **Erro Principal**: Error Domain=com.apple.AuthenticationServices.AuthorizationError Code=1000
- **Erro Secundário**: Error Domain=AKAuthenticationError Code=-7026
- **Erro de Sistema**: Error Domain=NSOSStatusErrorDomain Code=-54 "process may not map database"
- **Bundle ID**: com.rayclub.app

## Causa Raiz Identificada
Os erros indicam problemas de configuração entre o Apple Developer Console e o projeto iOS, especificamente relacionados a:

1. **Configuração de Capabilities**
2. **Problemas de Bundle ID**
3. **Configuração de Entitlements**
4. **Sincronização com Apple Developer Console**

## Soluções Ordenadas por Prioridade

### 🔥 Solução 1: Verificar e Reconfigurar Apple Developer Console
**Tempo estimado: 15-20 minutos**

1. **Acesse Apple Developer Console**:
   - Vá para https://developer.apple.com/account/
   - Entre com sua conta de desenvolvedor

2. **Verificar App ID**:
   - Vá para "Certificates, Identifiers & Profiles"
   - Clique em "Identifiers"
   - Procure por `com.rayclub.app`
   - Certifique-se que "Sign In with Apple" está habilitado

3. **Configurar Sign In with Apple**:
   - Se não estiver habilitado, marque a checkbox
   - Clique em "Configure" ao lado de "Sign In with Apple"
   - Selecione "Enable as a primary App ID"
   - Salve as configurações

### 🔥 Solução 2: Corrigir Configurações do Xcode
**Tempo estimado: 10-15 minutos**

1. **Abrir o projeto no Xcode**:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **Verificar Signing & Capabilities**:
   - Selecione o target "Runner"
   - Vá para a aba "Signing & Capabilities"
   - Certifique-se que o Team está selecionado corretamente
   - Verifique se o Bundle Identifier está como `com.rayclub.app`

3. **Adicionar/Verificar Sign In with Apple Capability**:
   - Clique no botão "+" para adicionar capability
   - Procure por "Sign In with Apple"
   - Adicione se não estiver presente
   - Se já estiver presente, remova e adicione novamente

### 🔥 Solução 3: Limpar e Reconstruir Configurações
**Tempo estimado: 20-25 minutos**

1. **Limpar cache do iOS**:
   ```bash
   cd ios
   rm -rf Pods
   rm -rf .symlinks
   rm Podfile.lock
   pod cache clean --all
   pod install
   ```

2. **Limpar projeto Flutter**:
   ```bash
   flutter clean
   flutter pub get
   cd ios
   pod install
   ```

3. **Reconstruir o projeto**:
   ```bash
   flutter build ios --no-codesign
   ```

### 🔥 Solução 4: Verificar e Atualizar Entitlements
**Tempo estimado: 5-10 minutos**

O arquivo `ios/Runner/Runner.entitlements` parece estar correto, mas vamos verificar:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>com.apple.developer.applesignin</key>
	<array>
		<string>Default</string>
	</array>
	<key>com.apple.developer.associated-domains</key>
	<array>
		<string>applinks:rayclub.app</string>
		<string>applinks:zsbbgchsjiuicwvtrldn.supabase.co</string>
	</array>
</dict>
</plist>
```

### ⚠️ Solução 5: Reset Completo de Configurações Apple
**Tempo estimado: 30-40 minutos (mais demorada)**

1. **Revogar certificados atuais**:
   - No Apple Developer Console
   - Vá para "Certificates"
   - Revogue certificados de desenvolvimento relacionados ao app

2. **Criar novos certificados**:
   - Crie novos certificados de desenvolvimento
   - Baixe e instale os novos certificados

3. **Recriar provisioning profiles**:
   - Delete os profiles existentes
   - Crie novos profiles de desenvolvimento
   - Baixe e instale os novos profiles

### 🛠️ Solução 6: Implementação de Workaround Temporário

Se nada funcionar, implementar um fallback usando Google Sign In:

1. **No código, adicionar try-catch mais robusto**
2. **Implementar fallback para Google Sign In**
3. **Adicionar logs detalhados para debug**

## Verificações Adicionais

### Verificar Info.plist
O seu `Info.plist` parece estar configurado corretamente com:
- CFBundleURLSchemes incluindo "com.rayclub.app"
- FlutterDeepLinkingEnabled = true

### Verificar Supabase
Certifique-se que no Supabase Dashboard:
- O redirect URL está configurado como `com.rayclub.app://login-callback/`
- As configurações do Apple OAuth estão corretas

### Teste em Dispositivo Real
- Esse erro é comum no simulador
- Teste sempre em dispositivo físico
- Certifique-se que está logado com Apple ID no dispositivo

## Scripts de Diagnóstico

### Script 1: Verificar Configurações
```bash
# Verificar se o projeto tem as configurações corretas
cd ios
grep -r "com.rayclub.app" .
grep -r "applesignin" .
```

### Script 2: Limpar Cache Completo
```bash
# Limpar tudo relacionado ao build
flutter clean
cd ios
rm -rf build/
rm -rf Pods/
rm -rf .symlinks/
rm Podfile.lock
pod cache clean --all
pod deintegrate
pod install
cd ..
flutter pub get
```

## Próximos Passos

1. **Comece pela Solução 1** (Apple Developer Console)
2. **Continue com Solução 2** (Xcode)
3. **Se não funcionar, aplique Solução 3** (Limpar e reconstruir)
4. **Como último recurso, use Solução 5** (Reset completo)

## Logs para Monitorar

Após implementar as soluções, monitore estes logs:
- ✅ Ausência de "Authorization failed: Error Domain=AKAuthenticationError Code=-7026"
- ✅ Ausência de "ASAuthorizationController credential request failed with error: Error Domain=com.apple.AuthenticationServices.AuthorizationError Code=1000"
- ✅ Sucesso com logs do tipo "Apple Sign In successful"

---

**Nota**: Este erro é extremamente comum e geralmente é resolvido com as primeiras 3 soluções. A Solução 1 (reconfigurar no Apple Developer Console) resolve 80% dos casos. 