# Guia para Testes com Supabase

Este guia explica como configurar e utilizar o Supabase para os testes do Ray Club App, permitindo a execução dos testes com dados reais em vez de dados mockados.

## Configuração do Supabase

### 1. Crie um projeto no Supabase

1. Acesse [supabase.com](https://supabase.com/) e crie uma conta ou faça login
2. Crie um novo projeto para testes
3. Anote o URL do projeto e a `anon key` (chave pública)

### 2. Configure o banco de dados

Execute o script SQL fornecido para atualizar as tabelas existentes:

1. No painel do Supabase, vá para **SQL Editor**
2. Copie e cole o conteúdo do arquivo `sql/update_workout_tables.sql` 
3. Execute o script

Este script:
- Adiciona colunas necessárias às tabelas existentes
- Mantém os dados existentes
- Configura as políticas de segurança para os testes
- Atualiza os treinos existentes com seções e exercícios detalhados

## Configuração do Projeto

### 1. Configure as variáveis de ambiente para testes

Crie o arquivo `.env.test` no diretório raiz do projeto (baseado no arquivo `.env.test.example`):

```
# Credenciais do Supabase para testes
SUPABASE_URL=https://seu-projeto-id.supabase.co
SUPABASE_ANON_KEY=sua-anon-key-aqui

# Configurações adicionais
DEBUG_MODE=true
```

### 2. Dependências para testes

Certifique-se de que a dependência `flutter_dotenv` está em seu `pubspec.yaml`:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_dotenv: ^4.1.0  # Ou versão mais recente
```

## Executando Testes

### Testes de Integração

Para executar os testes com o Supabase real:

```bash
flutter test test/features/workout/screens/workout_list_screen_test.dart
```

### Testes Mockados

Os testes mockados continuarão funcionando independentemente da conexão com o Supabase.

### Como os testes funcionam

1. O teste tenta inicializar o Supabase usando as credenciais de `.env.test` ou `.env`.
2. Se as credenciais forem válidas, o teste se conecta ao Supabase real.
3. Se as credenciais não forem válidas ou ocorrer erro, o teste apenas ignora a parte que usa Supabase real.
4. Os testes mockados continuam funcionando normalmente.

## Benefícios de Testar com Dados Reais

1. **Fidelidade:** Os testes refletem melhor a experiência real do usuário
2. **Menos mock:** Reduz a quantidade de código de mock complexo nos testes
3. **Problemas reais:** Encontra problemas de integração/serialização que não seriam detectados com mocks
4. **Facilidade de manutenção:** Quando o modelo de dados muda, você não precisa atualizar todos os mocks

## Considerações

- **Ambiente isolado:** Use um projeto Supabase separado para testes
- **Dados consistentes:** O script SQL atualiza as tabelas existentes preservando seus dados
- **CI/CD:** Para ambientes de integração contínua, você pode configurar as variáveis de ambiente no sistema de CI

## Troubleshooting

### Problemas de conexão

Se houver problemas de conexão com o Supabase:

1. Verifique as credenciais no arquivo `.env.test`
2. Verifique se o projeto no Supabase está ativo
3. Certifique-se de que as políticas RLS estão configuradas corretamente

### Falhas nos testes

Se os testes falharem devido a problemas de dados:

1. Verifique se o script SQL foi executado corretamente
2. Verifique se as tabelas têm as colunas necessárias como `sections` e `equipment`
3. Verifique se o mapeamento no `_mapToWorkout` está correto para seus dados 