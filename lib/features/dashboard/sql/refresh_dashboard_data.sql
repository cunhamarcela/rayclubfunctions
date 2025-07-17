-- Function to explicitly refresh dashboard data for a user
CREATE OR REPLACE FUNCTION refresh_dashboard_data(p_user_id UUID)
RETURNS JSONB LANGUAGE plpgsql AS $$
DECLARE
  result JSONB;
  current_workout_count INT;
  current_streak INT;
  longest_streak INT;
  total_points INT;
  workout_types_map JSONB;
  days_trained_this_month INT;
BEGIN
  -- Get current workout count
  SELECT COUNT(*) INTO current_workout_count
  FROM workout_records 
  WHERE user_id = p_user_id;
  
  -- Calculate current streak (consecutive days with workout)
  WITH workout_dates AS (
    SELECT DISTINCT DATE(date) as workout_date
    FROM workout_records 
    WHERE user_id = p_user_id
    ORDER BY workout_date DESC
  ),
  date_diffs AS (
    SELECT 
      workout_date,
      workout_date - LAG(workout_date) OVER (ORDER BY workout_date DESC) AS diff
    FROM workout_dates
  ),
  streak_groups AS (
    SELECT
      workout_date,
      SUM(CASE WHEN diff = -1 OR diff IS NULL THEN 0 ELSE 1 END) 
        OVER (ORDER BY workout_date DESC) AS streak_group
    FROM date_diffs
  ),
  streaks AS (
    SELECT
      streak_group,
      COUNT(*) AS streak_length
    FROM streak_groups
    GROUP BY streak_group
    ORDER BY streak_group
  )
  SELECT 
    COALESCE((SELECT streak_length FROM streaks LIMIT 1), 0) INTO current_streak;
  
  -- Get longest streak
  SELECT 
    COALESCE(MAX(streak_length), 0) INTO longest_streak
  FROM streaks;
  
  -- Calculate total points
  SELECT COALESCE(SUM(points), 0) INTO total_points
  FROM workout_records
  WHERE user_id = p_user_id;
  
  -- Get workout types distribution (by minutes)
  SELECT 
    jsonb_object_agg(
      workout_type, 
      total_minutes
    ) INTO workout_types_map
  FROM (
    SELECT 
      workout_type, 
      SUM(duration_minutes) as total_minutes
    FROM workout_records
    WHERE user_id = p_user_id
    GROUP BY workout_type
  ) as workout_types;
  
  -- Count days trained this month
  SELECT COUNT(DISTINCT DATE(date)) INTO days_trained_this_month
  FROM workout_records
  WHERE 
    user_id = p_user_id AND
    DATE_TRUNC('month', date) = DATE_TRUNC('month', CURRENT_DATE);
  
  -- Update or insert into user_progress
  INSERT INTO user_progress (
    user_id,
    workout_count,
    current_streak,
    longest_streak,
    total_points,
    workout_types,
    days_trained_this_month,
    updated_at
  ) VALUES (
    p_user_id,
    current_workout_count,
    current_streak,
    longest_streak,
    total_points,
    COALESCE(workout_types_map, '{}'::jsonb),
    days_trained_this_month,
    NOW()
  )
  ON CONFLICT (user_id) 
  DO UPDATE SET
    workout_count = EXCLUDED.workout_count,
    current_streak = EXCLUDED.current_streak,
    longest_streak = EXCLUDED.longest_streak,
    total_points = EXCLUDED.total_points,
    workout_types = EXCLUDED.workout_types,
    days_trained_this_month = EXCLUDED.days_trained_this_month,
    updated_at = NOW();
  
  -- Return the refreshed data
  SELECT to_jsonb(p) INTO result
  FROM user_progress p
  WHERE p.user_id = p_user_id;
  
  -- Notify about dashboard update
  PERFORM pg_notify('dashboard_updates', json_build_object('user_id', p_user_id, 'action', 'refresh')::text);
  
  RETURN result;
END;
$$; 