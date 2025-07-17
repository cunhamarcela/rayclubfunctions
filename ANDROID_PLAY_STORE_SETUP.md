# Configuração Android para Play Store

## ✅ O que já foi feito:

1. **Application ID corrigido**
   - Alterado de `com.example.ray_club_app` para `com.rayclub.app`

2. **Nome do app corrigido**
   - Alterado de `ray_club_app` para `Ray Club`

## ❌ O que ainda falta fazer:

### 1. **Criar Keystore para Assinatura**

Você precisa criar um keystore para assinar o app. Execute no terminal:

```bash
keytool -genkey -v -keystore ~/ray-club-release.keystore -keyalg RSA -keysize 2048 -validity 10000 -alias ray-club
```

**IMPORTANTE**: Guarde bem a senha e o arquivo keystore! Você precisará deles para todas as atualizações futuras.

### 2. **Criar arquivo key.properties**

Crie o arquivo `android/key.properties` com:

```properties
storePassword=SUA_SENHA_DO_KEYSTORE
keyPassword=SUA_SENHA_DO_KEYSTORE
keyAlias=ray-club
storeFile=/Users/SEU_USUARIO/ray-club-release.keystore
```

### 3. **Atualizar build.gradle.kts**

Adicione antes do bloco `android`:

```kotlin
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
```

E no bloco `signingConfigs`:

```kotlin
signingConfigs {
    release {
        keyAlias keystoreProperties['keyAlias']
        keyPassword keystoreProperties['keyPassword']
        storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
        storePassword keystoreProperties['storePassword']
    }
}
```

### 4. **Adicionar Permissões Necessárias**

No `AndroidManifest.xml`, adicione antes de `<application>`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

### 5. **Gerar o AAB (Android App Bundle)**

Após configurar tudo acima:

```bash
flutter build appbundle --release
```

O arquivo será gerado em: `build/app/outputs/bundle/release/app-release.aab`

## 📱 Ícones do App

Os ícones já devem estar configurados pelo `flutter_launcher_icons`, mas verifique se estão corretos em:
- `android/app/src/main/res/mipmap-*`

## 🔐 Configurações de Segurança

1. **Adicione ao .gitignore**:
```
android/key.properties
*.keystore
*.jks
```

2. **ProGuard** (se necessário):
Crie `android/app/proguard-rules.pro` se precisar de regras específicas.

## 📋 Checklist Final:

- [ ] Keystore criado e seguro
- [ ] key.properties configurado
- [ ] build.gradle.kts atualizado com signing config
- [ ] Permissões adicionadas ao AndroidManifest.xml
- [ ] AAB gerado com sucesso
- [ ] Ícones verificados
- [ ] .gitignore atualizado

## 🚀 Comando para Build Final:

```bash
flutter clean
flutter pub get
flutter build appbundle --release
```

O arquivo AAB estará em: `build/app/outputs/bundle/release/app-release.aab` 