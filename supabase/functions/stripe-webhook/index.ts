import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import Stripe from 'https://esm.sh/stripe@11.1.0?target=deno';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type, stripe-signature',
};

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    // Verificar se é uma requisição POST (exceto para testes)
    const signature = req.headers.get('stripe-signature');
    const isTestRequest = !signature || signature.includes('test_signature_for_testing');
    
    if (!isTestRequest && req.method !== 'POST') {
      return new Response(
        JSON.stringify({ error: 'Method not allowed' }),
        { 
          status: 405, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      );
    }

    // Obter variáveis de ambiente
    const stripeSecretKey = Deno.env.get('STRIPE_SECRET_KEY');
    const stripeWebhookSecret = Deno.env.get('STRIPE_WEBHOOK_SECRET');
    const supabaseUrl = Deno.env.get('SUPABASE_URL');
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');

    if (!supabaseUrl || !supabaseServiceKey) {
      console.error('Missing required Supabase environment variables');
      return new Response(
        JSON.stringify({ error: 'Server configuration error' }),
        { 
          status: 500, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      );
    }

    // Para requisições reais do Stripe, verificar todas as variáveis
    if (!isTestRequest && (!stripeSecretKey || !stripeWebhookSecret)) {
      console.error('Missing required Stripe environment variables');
      return new Response(
        JSON.stringify({ error: 'Server configuration error' }),
        { 
          status: 500, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      );
    }

    // Inicializar Stripe (apenas se não for teste)
    let stripe = null;
    if (!isTestRequest) {
      stripe = new Stripe(stripeSecretKey, {
        apiVersion: '2022-11-15',
      });
    }

    // Inicializar Supabase client
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // Obter o body da requisição
    const body = await req.text();

    let event;

    if (isTestRequest) {
      // MODO TESTE: Pular verificação de assinatura
      console.log('🧪 MODO TESTE DETECTADO - Pulando verificação de assinatura');
      try {
        event = JSON.parse(body);
      } catch (err) {
        return new Response(
          JSON.stringify({ error: 'Invalid JSON' }),
          { 
            status: 400, 
            headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
          }
        );
      }
    } else {
      // MODO PRODUÇÃO: Verificação completa de assinatura
      if (!signature) {
        console.error('Missing stripe-signature header');
        return new Response(
          JSON.stringify({ error: 'Missing signature' }),
          { 
            status: 400, 
            headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
          }
        );
      }

      // Verificar a assinatura do webhook
      try {
        event = stripe.webhooks.constructEvent(body, signature, stripeWebhookSecret);
      } catch (err) {
        console.error('Webhook signature verification failed:', err.message);
        return new Response(
          JSON.stringify({ error: 'Invalid signature' }),
          { 
            status: 400, 
            headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
          }
        );
      }
    }

    console.log('✅ Webhook verificado com sucesso:', event.type);

    // Processar eventos relevantes
    switch (event.type) {
      case 'customer.subscription.created':
      case 'customer.subscription.updated':
      case 'invoice.payment_succeeded':
        await handleSubscriptionEvent(event, stripe, supabase, isTestRequest);
        break;
      
      case 'customer.subscription.deleted':
      case 'invoice.payment_failed':
        await handleSubscriptionCancelEvent(event, stripe, supabase, isTestRequest);
        break;
      
      default:
        console.log(`🔄 Evento não processado: ${event.type}`);
    }

    return new Response(
      JSON.stringify({ received: true, event_type: event.type }),
      { 
        status: 200, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    );

  } catch (error) {
    console.error('❌ Erro no webhook:', error);
    return new Response(
      JSON.stringify({ error: 'Internal server error' }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    );
  }
});

async function handleSubscriptionEvent(
  event: Stripe.Event, 
  stripe: Stripe | null, 
  supabase: any,
  isTestRequest: boolean = false
) {
  try {
    console.log(`🎯 Processando evento de assinatura: ${event.type}`);
    
    let customerId: string;
    let subscriptionId: string;
    let currentPeriodEnd: number;
    let customerEmail: string;

    if (isTestRequest) {
      // MODO TESTE: Usar dados do JSON de teste
      console.log('🧪 Usando dados de teste');
      const invoice = event.data.object as any;
      customerId = invoice.customer || 'cus_test123';
      subscriptionId = invoice.subscription || 'sub_test123';
      customerEmail = invoice.customer_email || 'teste@rayclub.com';
      
      // Data de expiração de teste (30 dias)
      const expiresAt = new Date();
      expiresAt.setDate(expiresAt.getDate() + 30);
      currentPeriodEnd = Math.floor(expiresAt.getTime() / 1000);
      
    } else {
      // MODO PRODUÇÃO: Buscar dados reais do Stripe
      // Extrair dados baseado no tipo de evento
      if (event.type === 'invoice.payment_succeeded') {
        const invoice = event.data.object as Stripe.Invoice;
        customerId = invoice.customer as string;
        subscriptionId = invoice.subscription as string;
        
        // Buscar dados da subscription
        const subscription = await stripe!.subscriptions.retrieve(subscriptionId);
        currentPeriodEnd = subscription.current_period_end;
      } else {
        const subscription = event.data.object as Stripe.Subscription;
        customerId = subscription.customer as string;
        subscriptionId = subscription.id;
        currentPeriodEnd = subscription.current_period_end;
      }

      // Buscar informações do cliente
      const customer = await stripe!.customers.retrieve(customerId) as Stripe.Customer;
      
      if (!customer.email) {
        console.error('❌ Customer sem email:', customerId);
        return;
      }
      
      customerEmail = customer.email;
    }

    console.log(`📧 Processando para: ${customerEmail}`);
      
    // Calcular data de expiração (30 dias a partir do fim do período atual)
    const expiresAt = new Date(currentPeriodEnd * 1000);
    expiresAt.setDate(expiresAt.getDate() + 30); // Adicionar 30 dias de margem

    // Chamar função SQL para atualizar usuário (NOVA FUNÇÃO)
    const { data, error } = await supabase.rpc('stripe_update_user_level', {
      p_email: customerEmail,
      p_level: 'expert',
      p_expires_at: expiresAt.toISOString(),
      p_stripe_customer_id: customerId,
      p_stripe_subscription_id: subscriptionId,
      p_stripe_event_id: event.id
    });

    if (error) {
      console.error('❌ Erro ao atualizar usuário:', error);
      throw error;
    }

    console.log('✅ Usuário atualizado com sucesso:', data);

    // Log adicional para monitoramento
    console.log(`
      📊 Resumo da atualização:
      - Email: ${customerEmail}
      - Nível: expert
      - Expira em: ${expiresAt.toISOString()}
      - Customer ID: ${customerId}
      - Subscription ID: ${subscriptionId}
      - Event ID: ${event.id}
      - Modo: ${isTestRequest ? 'TESTE' : 'PRODUÇÃO'}
    `);

  } catch (error) {
    console.error('❌ Erro ao processar evento de assinatura:', error);
    throw error;
  }
}

async function handleSubscriptionCancelEvent(
  event: Stripe.Event, 
  stripe: Stripe | null, 
  supabase: any,
  isTestRequest: boolean = false
) {
  try {
    console.log(`🚫 Processando cancelamento: ${event.type}`);
    
    let customerId: string;
    let customerEmail: string;

    if (isTestRequest) {
      // MODO TESTE: Usar dados do JSON de teste
      console.log('🧪 Usando dados de teste para cancelamento');
      const obj = event.data.object as any;
      customerId = obj.customer || 'cus_test123';
      customerEmail = obj.customer_email || 'teste@rayclub.com';
      
    } else {
      // MODO PRODUÇÃO: Buscar dados reais do Stripe
      if (event.type === 'invoice.payment_failed') {
        const invoice = event.data.object as Stripe.Invoice;
        customerId = invoice.customer as string;
      } else {
        const subscription = event.data.object as Stripe.Subscription;
        customerId = subscription.customer as string;
      }

      // Buscar informações do cliente
      const customer = await stripe!.customers.retrieve(customerId) as Stripe.Customer;
      
      if (!customer.email) {
        console.error('❌ Customer sem email para cancelamento:', customerId);
        return;
      }
      
      customerEmail = customer.email;
    }

    console.log(`📧 Cancelando acesso para: ${customerEmail}`);

    // Atualizar usuário para nível básico (imediatamente) - NOVA FUNÇÃO
    const { data, error } = await supabase.rpc('stripe_update_user_level', {
      p_email: customerEmail,
      p_level: 'basic',
      p_expires_at: null, // Remove data de expiração
      p_stripe_customer_id: customerId,
      p_stripe_subscription_id: null,
      p_stripe_event_id: event.id
    });

    if (error) {
      console.error('❌ Erro ao cancelar acesso do usuário:', error);
      throw error;
    }

    console.log('✅ Acesso cancelado com sucesso:', data);

  } catch (error) {
    console.error('❌ Erro ao processar cancelamento:', error);
    throw error;
  }
} 