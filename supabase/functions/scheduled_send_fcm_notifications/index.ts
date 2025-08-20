// Edge Function: send_fcm_notifications.ts
import { serve } from "https://deno.land/std/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

serve(async (req) => {
  const supabase = createClient(
    Deno.env.get("SUPABASE_URL"),
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")
  );

  const { trigger_type: forcedTrigger, test_mode } = await req.json().catch(() => ({}));

  const now = new Date();
  const hour = now.getHours();
  const dayOfWeek = now.getDay();
  const dayOfMonth = now.getDate();
  const month = now.getMonth() + 1;

  let triggerTypes: string[] = [];

  if (forcedTrigger) {
    triggerTypes = [forcedTrigger];
  } else {
    if (hour >= 6 && hour < 10) triggerTypes.push("manha");
    else if (hour >= 12 && hour < 16) triggerTypes.push("tarde");
    else if (hour >= 18 && hour < 21) triggerTypes.push("noite");

    if (dayOfWeek === 1) triggerTypes.push("inicio_semana");
    if (dayOfWeek === 4 && hour === 18) triggerTypes.push("meta_semanal_risco");

    if (month >= 6 && month <= 8) triggerTypes.push("ebook_sazonal_inverno");
    else if (month >= 12 || month <= 2) triggerTypes.push("ebook_sazonal_verao");
  }

  if (triggerTypes.length === 0) {
    return new Response(JSON.stringify({ message: "Nenhum trigger ativo para este horário" }), { status: 200 });
  }

  const { data: templates, error: templatesError } = await supabase
    .from("notification_templates")
    .select("*")
    .in("trigger_type", triggerTypes);

  if (templatesError) {
    return new Response(JSON.stringify({ error: "Erro ao buscar templates" }), { status: 500 });
  }

  if (!templates || templates.length === 0) {
    return new Response(JSON.stringify({ message: "Nenhum template encontrado" }), { status: 200 });
  }

  const { data: users, error: usersError } = await supabase
    .from("profiles")
    .select("id, fcm_token, name")
    .not("fcm_token", "is", null)
    .neq("fcm_token", "");

  if (usersError) {
    return new Response(JSON.stringify({ error: "Erro ao buscar usuários" }), { status: 500 });
  }

  let successCount = 0, errorCount = 0, skippedCount = 0;

  for (const user of users) {
    for (const template of templates) {
      try {
        const title = (template.title || "Ray Club").replace("[nome]", user.name || "");
        const body = (template.body || "").replace("[nome]", user.name || "");

        const fcmPayload = {
          to: user.fcm_token,
          notification: {
            title,
            body,
            icon: "ic_notification",
            sound: "default"
          },
          data: {
            category: template.category,
            trigger_type: template.trigger_type,
            template_id: template.id,
            click_action: "FLUTTER_NOTIFICATION_CLICK"
          }
        };

        const fcmResponse = await fetch("https://fcm.googleapis.com/fcm/send", {
          method: "POST",
          headers: {
            Authorization: `key=${Deno.env.get("FCM_SERVER_KEY")}`,
            "Content-Type": "application/json"
          },
          body: JSON.stringify(fcmPayload)
        });

        if (fcmResponse.ok) {
          successCount++;
        } else {
          errorCount++;
        }

        await supabase.from("notifications").insert({
          user_id: user.id,
          title,
          message: body,
          type: template.category,
          data: {
            trigger_type: template.trigger_type,
            template_id: template.id,
            sent_via: "fcm"
          }
        });
      } catch (_) {
        errorCount++;
      }
    }
  }

  return new Response(JSON.stringify({
    message: "Notificações processadas",
    successCount,
    errorCount,
    skippedCount
  }), { status: 200 });
});
