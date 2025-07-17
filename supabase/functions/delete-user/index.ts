// Follow this setup guide to integrate the Deno runtime into your application:
// https://deno.land/manual/examples/supabase

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

interface DeleteUserRequest {
  userId: string;
}

serve(async (req) => {
  try {
    // Verificar se o método é POST
    if (req.method !== "POST") {
      return new Response(
        JSON.stringify({ error: "Método não permitido" }),
        { 
          status: 405,
          headers: { "Content-Type": "application/json" }
        }
      );
    }

    // Obter o token de autorização
    const authHeader = req.headers.get("authorization") || "";
    
    // Verificar se o Bearer token está presente
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      return new Response(
        JSON.stringify({ error: "Autorização inválida" }),
        { 
          status: 401,
          headers: { "Content-Type": "application/json" }
        }
      );
    }

    // Extrair o token
    const token = authHeader.split(" ")[1];
    
    // Verificar se o token é o service_role correto (em produção, deve-se usar uma comparação segura)
    // O padrão supabase_admin em uma aplicação real deve ser substituído pelo token real
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") || "";
    
    if (token !== serviceRoleKey) {
      return new Response(
        JSON.stringify({ error: "Token inválido" }),
        { 
          status: 403,
          headers: { "Content-Type": "application/json" }
        }
      );
    }

    // Obter o corpo da requisição
    const { userId } = await req.json() as DeleteUserRequest;
    
    if (!userId) {
      return new Response(
        JSON.stringify({ error: "ID do usuário não fornecido" }),
        { 
          status: 400,
          headers: { "Content-Type": "application/json" }
        }
      );
    }

    // Criar cliente Supabase com service_role para operações privilegiadas
    const supabaseAdmin = createClient(
      Deno.env.get("SUPABASE_URL") || "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") || "",
      {
        auth: {
          persistSession: false,
        }
      }
    );

    // Iniciar uma transação para excluir os dados do usuário de várias tabelas
    // Aqui deve-se listar todas as tabelas relacionadas ao usuário
    
    // 1. Excluir registros do usuário de todas as tabelas relacionadas
    // Listar todas as tabelas de interesse aqui
    const relatedTables = [
      'profiles',
      'user_workouts',
      'user_challenges',
      'workout_history',
      'water_intake',
      'user_notifications',
      'user_goals',
      'checkins',
      // Adicionar outras tabelas conforme necessário
    ];
    
    // Excluir em paralelo para melhor desempenho
    const deletionPromises = relatedTables.map(async (table) => {
      try {
        const { error } = await supabaseAdmin
          .from(table)
          .delete()
          .eq('user_id', userId);
        
        if (error) {
          console.error(`Erro ao excluir dados da tabela ${table}:`, error);
          return { table, success: false, error };
        }
        
        return { table, success: true };
      } catch (error) {
        console.error(`Exceção ao excluir dados da tabela ${table}:`, error);
        return { table, success: false, error };
      }
    });
    
    const results = await Promise.all(deletionPromises);
    
    // 2. Finalmente, excluir o próprio usuário
    const { error: userDeletionError } = await supabaseAdmin.auth.admin.deleteUser(userId);
    
    if (userDeletionError) {
      console.error("Erro ao excluir usuário da auth:", userDeletionError);
      return new Response(
        JSON.stringify({ 
          error: "Erro ao excluir usuário", 
          details: userDeletionError,
          tableResults: results 
        }),
        { 
          status: 500,
          headers: { "Content-Type": "application/json" }
        }
      );
    }

    // Retornar sucesso
    return new Response(
      JSON.stringify({ 
        success: true, 
        message: "Usuário excluído com sucesso",
        results 
      }),
      { 
        status: 200,
        headers: { "Content-Type": "application/json" }
      }
    );
  } catch (error) {
    // Log do erro (irá para os logs do Supabase)
    console.error("Erro ao processar requisição:", error);

    // Retornar erro
    return new Response(
      JSON.stringify({ 
        error: "Erro interno do servidor", 
        details: error.message 
      }),
      { 
        status: 500,
        headers: { "Content-Type": "application/json" }
      }
    );
  }
}); 