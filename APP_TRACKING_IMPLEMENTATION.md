# Implementação do App Tracking Transparency

## 📋 Resumo

Implementação do App Tracking Transparency (ATT) para atender aos requisitos da Apple App Store.

## 🔧 Alterações Realizadas

### 1. **Criado AppTrackingService** (`lib/core/services/app_tracking_service.dart`)
- Serviço responsável por gerenciar a solicitação de permissão de tracking
- Solicita permissão apenas uma vez por instalação
- Funciona apenas em iOS
- Salva o estado da solicitação em SharedPreferences

### 2. **Atualizado app_startup.dart**
- Adicionada chamada para `AppTrackingService.requestTrackingPermissionIfNeeded()` 
- A solicitação é feita após o app estar totalmente inicializado
- Não bloqueia o fluxo do app

### 3. **Atualizado AnalyticsService**
- Analytics agora verifica se o tracking está autorizado
- Eventos só são registrados se o usuário autorizar o tracking
- Respeita a escolha do usuário

### 4. **Habilitado o pacote no pubspec.yaml**
- Descomentada a linha: `app_tracking_transparency: ^2.0.4`

## ✅ Funcionalidades Mantidas

- **Nenhuma funcionalidade existente foi afetada**
- O app continua funcionando normalmente mesmo se o usuário negar a permissão
- A solicitação é não-intrusiva e aparece apenas uma vez

## 🧪 Como Testar

1. **Em dispositivo físico iOS:**
   - Desinstale o app se já estiver instalado
   - Instale a nova versão
   - Abra o app
   - Aguarde alguns segundos após a tela inicial
   - O popup de permissão deve aparecer

2. **Verificar logs:**
   ```
   📱 AppTracking: Status atual = notDetermined
   📱 AppTracking: Solicitando permissão...
   📱 AppTracking: Nova permissão = [authorized/denied/restricted]
   ```

## ⚠️ Notas Importantes

- **Não funciona no simulador** - sempre retornará `notSupported`
- A permissão é solicitada **apenas uma vez** por instalação
- O Info.plist já contém `NSUserTrackingUsageDescription`
- O app funciona normalmente independente da resposta do usuário

## 📱 Resposta para a Apple

O app agora solicita corretamente a permissão de App Tracking Transparency quando:
- É executado em um dispositivo iOS
- É a primeira vez que o app é aberto após a instalação
- O usuário ainda não respondeu à solicitação

A implementação respeita as diretrizes da Apple e a privacidade do usuário. 