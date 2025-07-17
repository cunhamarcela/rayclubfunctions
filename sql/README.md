# SQL Scripts para o Ray Club App

Este diretório contém scripts SQL para configuração e manutenção do banco de dados Supabase do Ray Club App.

## Arquivos e Suas Finalidades

### Funções e Triggers

- **`workout_ranking_updates.sql`**: Funções e triggers para permitir a edição e exclusão de treinos com atualização automática do ranking de desafios.
- **`workout_records.sql`**: Definição da tabela de registros de treinos e suas funções auxiliares.
- **`workout_records_fix.sql`**: Scripts para correção de problemas na estrutura ou dados da tabela de registros de treinos.

### Instruções de Uso

1. **Acesso ao Supabase**:
   - Entre no [Console Supabase](https://app.supabase.io)
   - Selecione o projeto do Ray Club App

2. **Execução dos Scripts**:
   - Navegue até "Database" > "SQL Editor"
   - Copie e cole o conteúdo do arquivo SQL desejado
   - Execute o script

3. **Verificação**:
   - Após executar, verifique se as funções, triggers e tabelas foram criadas corretamente
   - Teste as funções com dados de exemplo quando apropriado

## Notas Importantes

- **Backup**: Sempre faça um backup do banco de dados antes de executar scripts que modificam estruturas existentes.
- **Ambiente**: Execute primeiro em ambiente de desenvolvimento antes de aplicar em produção.
- **Permissões**: Alguns scripts podem exigir permissões específicas para serem executados.

## Documentação Relacionada

Para mais detalhes sobre a implementação de recursos específicos, consulte:

- [Documentação do Sistema de Edição de Treinos](/docs/workout_edit_system_implementation.md)
- [Documentação da Migração do Sistema de Registro de Treinos](/docs/workout_recording_system_migration.md) 