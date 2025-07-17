#!/usr/bin/env node

// Script para implantar triggers SQL no banco de dados Supabase

const fs = require('fs');
const path = require('path');
const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

// Argumentos da linha de comando
const args = process.argv.slice(2);
const isDryRun = args.includes('--dry-run');

// Carregando variáveis de ambiente
const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_KEY;

if (!supabaseUrl || !supabaseKey) {
  console.error('Erro: SUPABASE_URL e SUPABASE_SERVICE_KEY são obrigatórios.');
  console.error('Defina essas variáveis no arquivo .env');
  process.exit(1);
}

// Caminho do arquivo SQL
const sqlFilePath = path.resolve(__dirname, '../lib/db/supabase_triggers.sql');

async function main() {
  try {
    console.log('Iniciando implantação de triggers SQL...');
    
    // Lê o conteúdo do arquivo SQL
    const sqlContent = fs.readFileSync(sqlFilePath, 'utf8');
    
    // Divide o conteúdo em instruções individuais
    // Assume que cada instrução termina com ';'
    const statements = sqlContent
      .split(';')
      .map(stmt => stmt.trim())
      .filter(stmt => stmt.length > 0);
    
    console.log(`Encontradas ${statements.length} instruções SQL para aplicar`);
    
    if (isDryRun) {
      console.log('Modo de simulação (--dry-run). As instruções não serão aplicadas.');
      statements.forEach((stmt, i) => {
        console.log(`\n--- Instrução #${i + 1} ---`);
        console.log(stmt + ';');
      });
      return;
    }
    
    // Cria cliente Supabase
    const supabase = createClient(supabaseUrl, supabaseKey);
    
    // Aplica cada instrução SQL
    for (let i = 0; i < statements.length; i++) {
      const statement = statements[i] + ';';
      console.log(`Aplicando instrução #${i + 1}...`);
      
      try {
        // Executa a instrução SQL diretamente
        const { data, error } = await supabase.rpc('pgtle_admin.install_extension_if_not_exists', {
          ext_name: 'pg_exec_sql',
          ext_version: '1.0',
          schema_name: 'public',
        });
        
        if (error) throw error;
        
        const { error: execError } = await supabase.rpc('exec_sql', {
          sql_query: statement
        });
        
        if (execError) throw execError;
        
        console.log(`✅ Instrução #${i + 1} aplicada com sucesso.`);
      } catch (error) {
        console.error(`❌ Erro ao aplicar instrução #${i + 1}:`, error.message);
        console.error('Instrução:', statement);
        
        // Perguntar ao usuário se deseja continuar
        if (i < statements.length - 1) {
          const readline = require('readline').createInterface({
            input: process.stdin,
            output: process.stdout
          });
          
          const answer = await new Promise(resolve => {
            readline.question('Continuar com as próximas instruções? (s/N): ', resolve);
          });
          
          readline.close();
          
          if (answer.toLowerCase() !== 's') {
            console.log('Operação cancelada pelo usuário.');
            process.exit(1);
          }
        }
      }
    }
    
    console.log('\n✅ Todas as instruções SQL foram processadas.');
    
  } catch (error) {
    console.error('❌ Erro ao processar o arquivo SQL:', error.message);
    process.exit(1);
  }
}

main(); 