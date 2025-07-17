# Supabase Database Schema

This document provides an overview of all tables and their columns in the Supabase database.

## Tables

### banners
| Column Name | Data Type |
|-------------|-----------|
| id | uuid |
| title | text |
| subtitle | text |
| image_url | text |
| action_url | text |
| is_active | boolean |
| created_at | timestamp with time zone |
| updated_at | timestamp with time zone |

### benefit_redemption_codes
| Column Name | Data Type |
|-------------|-----------|
| id | uuid |
| code | text |
| user_id | uuid |
| benefit_id | uuid |
| created_at | timestamp with time zone |
| used_at | timestamp with time zone |
| is_used | boolean |
| expires_at | timestamp with time zone |
| device_info | jsonb |
| ip_address | text |
| location_data | jsonb |

### benefits
| Column Name | Data Type |
|-------------|-----------|
| id | uuid |
| title | text |
| description | text |
| image_url | text |
| points_cost | integer |
| partner | text |
| expiration_date | timestamp with time zone |
| available | boolean |
| quantity | integer |
| terms_conditions | text |
| created_at | timestamp with time zone |
| updated_at | timestamp with time zone |

### cache_tracking
| Column Name | Data Type |
|-------------|-----------|
| id | uuid |
| resource_type | text |
| resource_id | text |
| last_updated | timestamp with time zone |
| version | integer |
| metadata | jsonb |

### challenge_bonuses
| Column Name | Data Type |
|-------------|-----------|
| id | uuid |
| user_id | uuid |
| challenge_id | uuid |
| bonus_points | integer |
| reason | text |
| awarded_at | timestamp with time zone |
| created_at | timestamp with time zone |
| updated_at | timestamp with time zone |

### challenge_check_in_errors
| Column Name | Data Type |
|-------------|-----------|
| id | uuid |
| user_id | uuid |
| challenge_id | uuid |
| error_message | text |
| error_detail | text |
| error_context | text |
| created_at | timestamp with time zone |

### challenge_check_ins
| Column Name | Data Type |
|-------------|-----------|
| id | uuid |
| user_id | uuid |
| challenge_id | uuid |
| check_in_date | timestamp with time zone |
| points | integer |
| created_at | timestamp with time zone |
| user_name | text |
| user_photo_url | text |
| formatted_date | character varying |
| workout_id | text |
| workout_name | text |
| workout_type | text |
| duration_minutes | integer |
| updated_at | timestamp with time zone |

### challenge_group_invites
| Column Name | Data Type |
|-------------|-----------|
| id | uuid |
| group_id | uuid |
| group_name | text |
| inviter_id | uuid |
| inviter_name | text |
| invitee_id | uuid |
| status | integer |
| created_at | timestamp with time zone |
| responded_at | timestamp with time zone |
| updated_at | timestamp with time zone |

### challenge_group_members
| Column Name | Data Type |
|-------------|-----------|
| id | uuid |
| group_id | uuid |
| user_id | uuid |
| joined_at | timestamp with time zone |
| created_at | timestamp with time zone |
| updated_at | timestamp with time zone |

### challenge_groups
| Column Name | Data Type |
|-------------|-----------|
| id | uuid |
| challenge_id | uuid |
| creator_id | uuid |
| name | text |
| description | text |
| pending_invite_ids | ARRAY |
| created_at | timestamp with time zone |
| updated_at | timestamp with time zone |

### challenge_invites
| Column Name | Data Type |
|-------------|-----------|
| id | uuid |
| challenge_id | uuid |
| challenge_title | text |
| inviter_id | uuid |
| inviter_name | text |
| invitee_id | uuid |
| status | integer |
| created_at | timestamp with time zone |
| responded_at | timestamp with time zone |
| updated_at | timestamp with time zone |

### challenge_participants
| Column Name | Data Type |
|-------------|-----------|
| id | uuid |
| challenge_id | uuid |
| user_id | uuid |
| joined_at | timestamp with time zone |
| status | text |
| created_at | timestamp with time zone |
| updated_at | timestamp with time zone |
| is_completed | boolean |

### challenge_progress
| Column Name | Data Type |
|-------------|-----------|
| id | uuid |
| challenge_id | uuid |
| user_id | uuid |
| points | integer |
| position | integer |
| completion_percentage | numeric |
| user_name | text |
| user_photo_url | text |
| last_updated | timestamp with time zone |
| check_ins_count | integer |
| last_check_in | timestamp with time zone |
| consecutive_days | integer |
| completed | boolean |
| created_at | timestamp with time zone |
| updated_at | timestamp with time zone |
| total_check_ins | integer |

### challenges
| Column Name | Data Type |
|-------------|-----------|
| id | uuid |
| title | text |
| description | text |
| image_url | text |
| start_date | timestamp with time zone |
| end_date | timestamp with time zone |
| type | text |
| points | integer |
| requirements | jsonb |
| participants | integer |
| active | boolean |
| creator_id | uuid |
| is_official | boolean |
| created_at | timestamp with time zone |
| updated_at | timestamp with time zone |
| invited_users | ARRAY |
| local_image_path | text |

### check_in_error_logs
| Column Name | Data Type |
|-------------|-----------|
| id | uuid |
| challenge_id | uuid |
| user_id | uuid |
| error_message | text |
| error_detail | text |
| stack_trace | text |
| created_at | timestamp with time zone |
| status | text |
| workout_id | uuid |
| request_data | jsonb |

### contact_messages
| Column Name | Data Type |
|-------------|-----------|
| id | uuid |
| user_id | uuid |
| name | text |
| email | text |
| subject | text |
| message | text |
| status | text |
| created_at | timestamp with time zone |
| updated_at | timestamp with time zone |
| admin_notes | text |

### debug_log
| Column Name | Data Type |
|-------------|-----------|
| id | integer |
| trigger_name | text |
| table_name | text |
| event_time | timestamp with time zone |
| operation | text |
| details | jsonb |

### diet_plans
| Column Name | Data Type |
|-------------|-----------|
| id | uuid |
| title | text |
| description | text |
| image_url | text |
| category | text |
| target_goal | text |
| meals | jsonb |
| created_at | timestamp with time zone |
| updated_at | timestamp with time zone |

### faqs
| Column Name | Data Type |
|-------------|-----------|
| id | uuid |
| question | text |
| answer | text |
| category | text |
| order_index | integer |
| is_active | boolean |
| created_at | timestamp with time zone |
| updated_at | timestamp with time zone |
| updated_by | uuid |
| last_updated | timestamp with time zone |

### global_user_ranking
| Column Name | Data Type |
|-------------|-----------|
| user_id | uuid |
| username | text |
| avatar_url | text |
| points | integer |
| total_workouts | integer |
| rank | bigint |

### health_data
| Column Name | Data Type |
|-------------|-----------|
| id | uuid |
| user_id | uuid |
| type | text |
| value | numeric |
| unit | text |
| date_from | timestamp with time zone |
| date_to | timestamp with time zone |
| platform | text |
| device_id | text |
| source_id | text |
| source_name | text |
| created_at | timestamp with time zone |

### health_summaries
| Column Name | Data Type |
|-------------|-----------|
| id | uuid |
| user_id | uuid |
| date | date |
| steps | integer |
| calories_burned | numeric |
| weight | numeric |
| height | numeric |
| bmi | numeric |
| last_updated | timestamp with time zone |

### health_sync_status
| Column Name | Data Type |
|-------------|-----------|
| id | uuid |
| user_id | uuid |
| last_sync | timestamp with time zone |
| sync_status | text |
| data_types | ARRAY |
| device_info | jsonb |
| error_message | text |
| created_at | timestamp with time zone |

### notifications
| Column Name | Data Type |
|-------------|-----------|
| id | uuid |
| user_id | uuid |
| title | text |
| message | text |
| type | text |
| related_id | uuid |
| is_read | boolean |
| created_at | timestamp with time zone |
| read_at | timestamp with time zone |
| data | jsonb |

### partner_contents
| Column Name | Data Type |
|-------------|-----------|
| id | uuid |
| studio_id | uuid |
| title | text |
| duration | text |
| difficulty | text |
| image_url | text |
| order_number | integer |
| created_at | timestamp with time zone |
| updated_at | timestamp with time zone |

### partner_studios
| Column Name | Data Type |
|-------------|-----------|
| id | uuid |
| name | text |
| tagline | text |
| logo_url | text |
| active | boolean |
| created_at | timestamp with time zone |
| updated_at | timestamp with time zone |

### profiles
| Column Name | Data Type |
|-------------|-----------|
| id | uuid |
| email | text |
| name | text |
| profile_image_url | text |
| created_at | timestamp with time zone |
| last_login_at | timestamp with time zone |
| role | text |
| settings | jsonb |
| stats | jsonb |
| bio | text |
| phone | text |
| gender | text |
| birth_date | timestamp with time zone |
| instagram | text |
| favorite_workout_ids | ARRAY |
| goals | ARRAY |
| streak | integer |
| completed_workouts | integer |
| points | integer |
| updated_at | timestamp with time zone |
| photo_url | text |
| daily_water_goal | integer |
| daily_workout_goal | integer |
| weekly_workout_goal | integer |
| weight_goal | numeric |
| height | numeric |
| current_weight | numeric |
| preferred_workout_types | ARRAY |
| is_admin | boolean |
| onboarding_seen | boolean |

### redeemed_benefits
| Column Name | Data Type |
|-------------|-----------|
| id | uuid |
| user_id | uuid |
| benefit_id | uuid |
| title | text |
| description | text |
| code | text |
| status | text |
| redeemed_at | timestamp with time zone |
| expiration_date | timestamp with time zone |
| used_at | timestamp with time zone |
| created_at | timestamp with time zone |
| updated_at | timestamp with time zone |
| redemption_code | text |

### system_changes_log
| Column Name | Data Type |
|-------------|-----------|
| id | integer |
| change_type | text |
| target_object | text |
| details | text |
| executed_at | timestamp with time zone |

### system_scheduled_tasks
| Column Name | Data Type |
|-------------|-----------|
| id | uuid |
| task_name | text |
| last_run | timestamp with time zone |
| next_run | timestamp with time zone |
| status | text |
| result | jsonb |
| created_at | timestamp with time zone |

### tutorials
| Column Name | Data Type |
|-------------|-----------|
| id | uuid |
| title | text |
| description | text |
| content | text |
| image_url | text |
| video_url | text |
| category | text |
| order_index | integer |
| is_active | boolean |
| created_at | timestamp with time zone |
| updated_at | timestamp with time zone |
| is_featured | boolean |
| updated_by | uuid |
| last_updated | timestamp with time zone |
| related_content | jsonb |

### usage_analytics
| Column Name | Data Type |
|-------------|-----------|
| id | uuid |
| user_id | uuid |
| event_type | text |
| resource_type | text |
| resource_id | text |
| device_info | jsonb |
| performance_metrics | jsonb |
| error_info | jsonb |
| created_at | timestamp with time zone |
| session_id | text |
| app_version | text |

### user_benefits
| Column Name | Data Type |
|-------------|-----------|
| id | text |
| user_id | uuid |
| benefit_id | uuid |
| redeemed_at | timestamp with time zone |
| redemption_code | text |
| used | boolean |
| used_at | timestamp with time zone |
| created_at | timestamp with time zone |
| updated_at | timestamp with time zone |

### user_challenges
| Column Name | Data Type |
|-------------|-----------|
| id | text |
| user_id | uuid |
| challenge_id | uuid |
| joined_at | timestamp with time zone |
| completed_at | timestamp with time zone |
| progress | numeric |
| status | text |
| created_at | timestamp with time zone |
| updated_at | timestamp with time zone |

### user_goals
| Column Name | Data Type |
|-------------|-----------|
| id | uuid |
| user_id | uuid |
| title | text |
| target_value | numeric |
| current_value | numeric |
| unit | text |
| progress_percentage | numeric |
| goal_type | text |
| start_date | timestamp with time zone |
| target_date | timestamp with time zone |
| is_completed | boolean |
| created_at | timestamp with time zone |
| updated_at | timestamp with time zone |

### user_progress
| Column Name | Data Type |
|-------------|-----------|
| id | uuid |
| user_id | uuid |
| points | integer |
| level | integer |
| workouts_completed | integer |
| challenges_completed | integer |
| created_at | timestamp with time zone |
| updated_at | timestamp with time zone |
| workouts | integer |
| streaks | integer |
| achievements | jsonb |
| total_check_ins | integer |
| current_streak | integer |
| longest_streak | integer |
| total_duration | integer |
| days_trained_this_month | integer |
| workout_types | jsonb |
| workouts_by_type | jsonb |
| last_updated | timestamp with time zone |

### user_settings
| Column Name | Data Type |
|-------------|-----------|
| id | uuid |
| user_id | uuid |
| language_code | text |
| theme_mode | integer |
| privacy_settings | jsonb |
| notification_settings | jsonb |
| created_at | timestamp with time zone |
| updated_at | timestamp with time zone |

### user_workouts
| Column Name | Data Type |
|-------------|-----------|
| id | text |
| user_id | uuid |
| workout_id | uuid |
| started_at | timestamp with time zone |
| completed_at | timestamp with time zone |
| progress | numeric |
| notes | text |
| feedback | jsonb |
| exercises_completed | jsonb |
| user_name | text |
| user_photo_url | text |
| workout_type | text |
| duration | integer |
| calories_burned | integer |
| created_at | timestamp with time zone |
| updated_at | timestamp with time zone |

### video_contents
| Column Name | Data Type |
|-------------|-----------|
| id | uuid |
| title | text |
| description | text |
| category | text |
| url | text |
| thumbnail_url | text |
| duration_seconds | integer |
| is_premium | boolean |
| created_at | timestamp with time zone |

### water_intake
| Column Name | Data Type |
|-------------|-----------|
| id | uuid |
| user_id | uuid |
| date | date |
| cups | integer |
| goal | integer |
| created_at | timestamp with time zone |
| updated_at | timestamp with time zone |
| notes | text |
| glass_size | integer |

### workout_categories
| Column Name | Data Type |
|-------------|-----------|
| id | uuid |
| name | text |
| description | text |
| imageUrl | text |
| workoutsCount | integer |
| order | integer |
| colorHex | text |
| created_at | timestamp with time zone |
| updated_at | timestamp with time zone |

### workout_processing_queue
| Column Name | Data Type |
|-------------|-----------|
| id | uuid |
| workout_id | uuid |
| user_id | uuid |
| challenge_id | uuid |
| processed_for_ranking | boolean |
| processed_for_dashboard | boolean |
| processing_error | text |
| created_at | timestamp with time zone |
| processed_at | timestamp with time zone |

### workout_records
| Column Name | Data Type |
|-------------|-----------|
| id | uuid |
| user_id | uuid |
| workout_id | uuid |
| workout_name | text |
| workout_type | text |
| date | timestamp with time zone |
| duration_minutes | integer |
| is_completed | boolean |
| notes | text |
| created_at | timestamp with time zone |
| updated_at | timestamp with time zone |
| completion_status | text |
| image_urls | ARRAY |
| challenge_id | uuid |
| points | integer |
| group_id | uuid |

### workouts
| Column Name | Data Type |
|-------------|-----------|
| id | uuid |
| title | text |
| description | text |
| image_url | text |
| category | text |
| level | text |
| duration | integer |
| calories | integer |
| featured | boolean |
| created_at | timestamp with time zone |
| updated_at | timestamp with time zone |
| exercises | jsonb |
| duration_minutes | integer |
| sections | jsonb |
| equipment | jsonb |
| is_public | boolean | 