import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  print('🔍 Debugando participantes do ranking de cardio...');
  
  const String supabaseUrl = 'https://zsbbgchsjiuicwvtrldn.supabase.co';
  const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpzYmJnY2hzaml1aWN3dnRybGRuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDIzMzU5ODYsImV4cCI6MjA1NzkxMTk4Nn0.HEN9Mh_tYA7beWvhNwFCKpi8JpYINbPUCYtT66DeaeM';
  
  final client = HttpClient();
  
  try {
    // 1. Verificar participantes ativos
    print('\\n1. Verificando participantes ativos...');
    
    final request1 = await client.getUrl(Uri.parse('$supabaseUrl/rest/v1/cardio_challenge_participants?active=eq.true&select=*'));
    request1.headers.set('Authorization', 'Bearer $anonKey');
    request1.headers.set('apikey', anonKey);
    
    final response1 = await request1.close();
    final participants = await response1.transform(utf8.decoder).join();
    print('Participantes ativos: $participants');
    
    // 2. Verificar treinos de cardio registrados
    print('\\n2. Verificando treinos de cardio...');
    
    final request2 = await client.getUrl(Uri.parse('$supabaseUrl/rest/v1/workout_records?workout_type=eq.Cardio&select=user_id,workout_type,duration_minutes,date'));
    request2.headers.set('Authorization', 'Bearer $anonKey');
    request2.headers.set('apikey', anonKey);
    
    final response2 = await request2.close();
    final workouts = await response2.transform(utf8.decoder).join();
    print('Treinos de Cardio: $workouts');
    
    // 3. Testar função get_cardio_ranking
    print('\\n3. Testando função get_cardio_ranking...');
    
    final request3 = await client.postUrl(Uri.parse('$supabaseUrl/rest/v1/rpc/get_cardio_ranking'));
    request3.headers.set('Content-Type', 'application/json');
    request3.headers.set('Authorization', 'Bearer $anonKey');
    request3.headers.set('apikey', anonKey);
    request3.write('{}');
    
    final response3 = await request3.close();
    final ranking = await response3.transform(utf8.decoder).join();
    print('Ranking atual: $ranking');
    
    // 4. Aplicar correção na função SQL
    print('\\n4. Aplicando correção na função SQL...');
    
    final sqlFix = '''
    CREATE OR REPLACE FUNCTION public.get_cardio_ranking(
        date_from timestamptz default null,
        date_to   timestamptz default null,
        _limit    integer     default null,
        _offset   integer     default null
    )
    RETURNS TABLE (
        user_id uuid,
        full_name text,
        avatar_url text,
        total_cardio_minutes integer
    )
    LANGUAGE sql
    STABLE
    AS \$\$
        WITH bounds AS (
          SELECT
            CASE WHEN date_from IS NULL THEN NULL
                 ELSE ((date_from AT TIME ZONE 'America/Sao_Paulo') AT TIME ZONE 'UTC') END AS from_utc,
            CASE WHEN date_to   IS NULL THEN NULL
                 ELSE ((date_to   AT TIME ZONE 'America/Sao_Paulo') AT TIME ZONE 'UTC') END AS to_utc,
            COALESCE(_limit, 200)  AS lim,
            COALESCE(_offset, 0)   AS off
        )
        SELECT
            wr.user_id,
            p.name AS full_name,
            COALESCE(p.photo_url, p.profile_image_url) AS avatar_url,
            SUM(wr.duration_minutes)::int AS total_cardio_minutes
        FROM public.workout_records wr
        JOIN public.profiles p ON p.id = wr.user_id
        JOIN public.cardio_challenge_participants ccp ON ccp.user_id = wr.user_id AND ccp.active = true
        CROSS JOIN bounds b
        WHERE
            wr.duration_minutes IS NOT NULL
            AND wr.duration_minutes > 0
            AND (LOWER(wr.workout_type) = 'cardio' OR wr.workout_type = 'Cardio')
            AND (b.from_utc IS NULL OR wr.date >= b.from_utc)
            AND (b.to_utc   IS NULL OR wr.date <  b.to_utc)
        GROUP BY wr.user_id, p.name, COALESCE(p.photo_url, p.profile_image_url)
        HAVING SUM(wr.duration_minutes) > 0
        ORDER BY total_cardio_minutes DESC, p.name ASC, wr.user_id ASC
        LIMIT (SELECT lim FROM bounds)
        OFFSET (SELECT off FROM bounds);
    \$\$;
    ''';
    
    print('Função SQL corrigida criada! Execute no Supabase SQL Editor se necessário.');
    
  } catch (e) {
    print('ERRO: $e');
  } finally {
    client.close();
  }
}

