# Instruções para Migração de Banco de Dados

Este diretório contém scripts SQL para migração do banco de dados do Ray Club App.

## Adicionando campo de duração aos treinos

O script `add_duration_field.sql` adiciona campos de duração aos treinos existentes no banco de dados Supabase.

### Para executar a migração:

1. Faça login no [Supabase Dashboard](https://app.supabase.io/)
2. Selecione o projeto do Ray Club App
3. No menu lateral, clique em "SQL Editor"
4. Crie um novo SQL query (botão "New Query")
5. Copie e cole o conteúdo do arquivo `add_duration_field.sql`
6. Clique em "Run" para executar o script

## Verificação

Após a execução do script, você pode verificar se os campos foram adicionados:

1. No menu lateral, clique em "Table Editor"
2. Selecione a tabela "workouts"
3. Verifique se as colunas `duration_minutes` e `duration` foram adicionadas
4. Verifique se os valores foram preenchidos adequadamente

## Resolução de Problemas

Se encontrar erros durante a execução:

1. Verifique a saída de erro no SQL Editor
2. Pode ser necessário ajustar o script dependendo da estrutura atual do banco de dados
3. Se a tabela `workouts` não existir, você precisará criá-la primeiro usando o script em `../supabase_schema.sql`

## Por que essa migração é necessária?

Esta migração adiciona suporte para filtrar treinos por duração, permitindo que os usuários encontrem treinos que se encaixem no tempo disponível para exercícios. O campo `duration_minutes` é um inteiro que permite comparações e filtros eficientes, enquanto o campo `duration` mantém compatibilidade com o formato de string para exibição. 