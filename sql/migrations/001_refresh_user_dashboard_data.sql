-- Migration to add refresh_user_dashboard_data function
-- Function to force refresh of user dashboard data
CREATE OR REPLACE FUNCTION refresh_user_dashboard_data(p_user_id UUID)
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
  days_with_gaps AS (
    SELECT 
      workout_date,
      EXTRACT(DAY FROM (workout_date - LAG(workout_date) OVER (ORDER BY workout_date DESC))) as day_diff
    FROM workout_dates
  ),
  streak_counter AS (
    SELECT
      workout_date,
      SUM(CASE WHEN day_diff IS NULL OR day_diff = 1 THEN 0 ELSE 1 END) 
        OVER (ORDER BY workout_date DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as streak_group
    FROM days_with_gaps
  )
  SELECT COUNT(*) INTO current_streak
  FROM streak_counter
  WHERE streak_group = 0;

  -- Get the longest streak
  WITH workout_dates AS (
    SELECT DISTINCT DATE(date) as workout_date
    FROM workout_records
    WHERE user_id = p_user_id
    ORDER BY workout_date
  ),
  days_with_gaps AS (
    SELECT 
      workout_date,
      EXTRACT(DAY FROM (workout_date - LAG(workout_date) OVER (ORDER BY workout_date))) as day_diff
    FROM workout_dates
  ),
  streak_groups AS (
    SELECT
      workout_date,
      SUM(CASE WHEN day_diff IS NULL OR day_diff = 1 THEN 0 ELSE 1 END) 
        OVER (ORDER BY workout_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as streak_group
    FROM days_with_gaps
  ),
  streaks AS (
    SELECT 
      streak_group,
      COUNT(*) as streak_length
    FROM streak_groups
    GROUP BY streak_group
  )
  SELECT MAX(streak_length) INTO longest_streak
  FROM streaks;

  -- Calculate total points
  SELECT COALESCE(SUM(points), 0) INTO total_points
  FROM workout_records
  WHERE user_id = p_user_id;

  -- Get workout type distribution
  SELECT jsonb_object_agg(workout_type, count) INTO workout_types_map
  FROM (
    SELECT 
      workout_type, 
      COUNT(*) as count
    FROM workout_records
    WHERE user_id = p_user_id
    GROUP BY workout_type
  ) as workout_counts;

  -- Calculate days trained this month
  SELECT COUNT(DISTINCT DATE(date)) INTO days_trained_this_month
  FROM workout_records
  WHERE 
    user_id = p_user_id AND
    DATE_PART('month', date) = DATE_PART('month', CURRENT_DATE) AND
    DATE_PART('year', date) = DATE_PART('year', CURRENT_DATE);

  -- Update user_progress table
  INSERT INTO user_progress (
    user_id, 
    workouts, 
    current_streak, 
    longest_streak, 
    points, 
    days_trained_this_month, 
    workout_types,
    updated_at
  ) VALUES (
    p_user_id,
    current_workout_count,
    current_streak,
    longest_streak,
    total_points,
    days_trained_this_month,
    workout_types_map,
    NOW()
  )
  ON CONFLICT (user_id) 
  DO UPDATE SET
    workouts = EXCLUDED.workouts,
    current_streak = EXCLUDED.current_streak,
    longest_streak = EXCLUDED.longest_streak,
    points = EXCLUDED.points,
    days_trained_this_month = EXCLUDED.days_trained_this_month,
    workout_types = EXCLUDED.workout_types,
    updated_at = EXCLUDED.updated_at;

  -- Return success response
  result := jsonb_build_object(
    'success', true,
    'message', 'User dashboard data refreshed successfully',
    'workout_count', current_workout_count,
    'current_streak', current_streak,
    'total_points', total_points,
    'updated_at', NOW()
  );

  RETURN result;
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Error refreshing user dashboard data: ' || SQLERRM,
      'error', SQLERRM
    );
END;
$$; 