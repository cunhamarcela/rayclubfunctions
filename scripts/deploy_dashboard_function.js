#!/usr/bin/env node

// Script para implantar função get_dashboard_fitness no banco de dados Supabase

const fs = require('fs');
const path = require('path');
const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

// Argumentos da linha de comando
const args = process.argv.slice(2);
const isDryRun = args.includes('--dry-run');

// Carregando variáveis de ambiente
const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!supabaseUrl || !supabaseKey) {
  console.error('Erro: SUPABASE_URL e SUPABASE_SERVICE_ROLE_KEY são obrigatórios.');
  console.error('Defina essas variáveis no arquivo .env');
  process.exit(1);
}

// Caminho do arquivo SQL
const sqlFilePath = path.resolve(__dirname, '../lib/features/dashboard/sql/get_dashboard_fitness.sql');

async function main() {
  try {
    console.log('Iniciando implantação da função get_dashboard_fitness...');
    
    // Verificar se o arquivo SQL existe
    if (!fs.existsSync(sqlFilePath)) {
      console.error(`Erro: Arquivo SQL não encontrado em ${sqlFilePath}`);
      process.exit(1);
    }

    // Ler o conteúdo do arquivo SQL
    const sqlContent = fs.readFileSync(sqlFilePath, 'utf8');
    
    if (isDryRun) {
      console.log('Modo dry-run: Não executando SQL. Conteúdo:');
      console.log(sqlContent);
      return;
    }

    // Criar cliente Supabase
    const supabase = createClient(supabaseUrl, supabaseKey);
    
    console.log('Conectando ao Supabase...');
    
    // Executar o SQL
    const { data, error } = await supabase.rpc('exec_sql', {
      sql: sqlContent
    });

    if (error) {
      console.error('Erro ao executar SQL:', error);
      
      // Tentar executar SQL diretamente
      console.log('Tentando executar SQL diretamente...');
      
      // Dividir o SQL em comandos separados
      const commands = sqlContent.split(';').filter(cmd => cmd.trim());
      
      for (const command of commands) {
        if (command.trim()) {
          console.log(`Executando: ${command.trim().substring(0, 50)}...`);
          const { error: cmdError } = await supabase.rpc('exec_sql', {
            sql: command.trim() + ';'
          });
          
          if (cmdError) {
            console.error('Erro no comando:', cmdError);
          } else {
            console.log('✅ Comando executado com sucesso');
          }
        }
      }
    } else {
      console.log('✅ SQL executado com sucesso!');
      if (data) {
        console.log('Resultado:', data);
      }
    }

    // Testar a função
    console.log('\nTestando função get_dashboard_fitness...');
    const testResult = await supabase.rpc('get_dashboard_fitness', {
      user_id_param: '01d4a292-1873-4af6-948b-a55eed56d6b9',
      month_param: 7,
      year_param: 2025
    });

    if (testResult.error) {
      console.error('Erro ao testar função:', testResult.error);
    } else {
      console.log('✅ Função testada com sucesso!');
      console.log('Resultado do teste:', JSON.stringify(testResult.data, null, 2));
    }

  } catch (error) {
    console.error('Erro inesperado:', error);
    process.exit(1);
  }
}

main(); 