# Sistema de Autenticação em Camadas

O Ray Club App implementa um sistema de autenticação em camadas que otimiza a experiência do usuário e a performance, mantendo altos padrões de segurança. Esta abordagem foi desenvolvida para reduzir verificações desnecessárias durante a navegação entre telas.

## Principais Componentes

### 1. LayeredAuthGuard

O guarda principal que protege a maioria das rotas do aplicativo, utilizando uma abordagem em camadas:

- **Verificação em Cache**: Para transições rápidas, verifica primeiro o estado em memória
- **Verificação Periódica**: Faz verificações completas em intervalos de tempo (15 minutos)
- **Verificação Forçada**: Para estados iniciais ou indefinidos, realiza verificação completa

```dart
// Exemplo de uso nas rotas
AutoRoute(
  path: AppRoutes.home,
  page: HomeRoute.page,
  guards: [LayeredAuthGuard(_ref)],
),
```

### 2. CriticalRouteGuard

Guarda especial para rotas sensíveis que sempre força uma verificação completa com o servidor:

- **Verificação Rigorosa**: Sempre verifica a validade do token com o servidor
- **Renovação de Sessão**: Renova automaticamente tokens próximos da expiração
- **Uso Seletivo**: Aplicado apenas a rotas críticas como pagamentos e alteração de senha

```dart
// Exemplo de uso em rotas críticas
AutoRoute(
  path: AppRoutes.paymentSettings,
  page: PaymentSettingsRoute.page,
  guards: [CriticalRouteGuard(_ref)],
),
```

### 3. Verificação em Segundo Plano

O `AuthViewModel` implementa um mecanismo de verificação periódica em segundo plano:

- **Timer Automático**: Verifica a validade da sessão a cada 30 minutos em segundo plano
- **Renovação Silenciosa**: Renova tokens sem interromper a experiência do usuário
- **Degradação Suave**: Em caso de falha, permite continuar usando o app até a próxima verificação

## Benefícios

- **Performance Otimizada**: Reduz consultas ao servidor durante navegação comum
- **Experiência Fluida**: Elimina flickering de telas de carregamento durante a navegação
- **Segurança Adaptativa**: Diferentes níveis de verificação baseados na sensibilidade da rota
- **Resiliência**: Melhor tratamento de erros transitórios de conectividade

## Fluxo de Verificação

1. Usuário inicia o app → Verificação completa na inicialização
2. Navegação entre telas comuns → Verificação em cache (rápida)
3. A cada 15 minutos → Verificação completa com o servidor
4. Acesso a rotas críticas → Verificação rigorosa imediata
5. Em segundo plano a cada 30 min → Renovação de sessão silenciosa

## Configuração

Os intervalos de verificação podem ser ajustados através das constantes:

- `AUTH_CHECK_INTERVAL_MINUTES`: Define o intervalo entre verificações completas (padrão: 15 min)
- `BACKGROUND_AUTH_CHECK_INTERVAL_MINUTES`: Define o intervalo de verificação em segundo plano (padrão: 30 min)

## Implementação Técnica

O sistema utiliza:

- **Riverpod**: Para gerenciamento de estado global
- **auto_route**: Para sistema de navegação e guardas de rota
- **Timer**: Para verificações periódicas em segundo plano
- **Supabase Auth**: Para gerenciamento de sessão e tokens 