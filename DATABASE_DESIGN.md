# Ray Club Database Design

## Main Tables

### challenges
Stores information about challenges available in the app.
- **id**: Unique challenge identifier (UUID)
- **title**: Challenge title (text)
- **description**: Detailed challenge description (text)
- **image_url**: URL of the challenge image (text)
- **start_date**: Challenge start date (timestamp)
- **end_date**: Challenge end date (timestamp)
- **type**: Challenge type (text - e.g., "daily", "weekly", "custom")
- **points**: Base points awarded for each check-in (integer)
- **requirements**: Challenge requirements in JSON format (jsonb)
- **participants**: Participant counter (integer)
- **active**: Flag to enable/disable the challenge (boolean)
- **creator_id**: ID of the user who created the challenge (UUID)
- **is_official**: Indicates if it's an official Ray challenge (boolean)
- **created_at**: Record creation date (timestamp)
- **updated_at**: Last record update date (timestamp)

### challenge_participants
Records the relationship between users and challenges.
- **id**: Unique participation identifier (UUID)
- **challenge_id**: Reference to the challenge (UUID)
- **user_id**: Reference to the user (UUID)
- **joined_at**: Date when the user joined the challenge (timestamp)
- **status**: Participation status (text - e.g., "active", "completed", "abandoned")
- **created_at**: Record creation date (timestamp)

### challenge_check_ins
Records activity check-ins for challenges.
- **id**: Unique check-in identifier (UUID)
- **user_id**: Reference to the user (UUID)
- **challenge_id**: Reference to the challenge (UUID)
- **check_in_date**: Check-in date and time (timestamp)
- **points**: Points earned with the check-in (integer)
- **created_at**: Record creation date (timestamp)
- **user_name**: User's name at the time of check-in (text)
- **user_photo_url**: URL of the user's photo at the time of check-in (text)

### challenge_progress
Stores user progress metrics in challenges.
- **id**: Unique progress record identifier (UUID)
- **challenge_id**: Reference to the challenge (UUID)
- **user_id**: Reference to the user (UUID)
- **points**: Total accumulated points (integer)
- **position**: Ranking position (integer)
- **completion_percentage**: Completion percentage (numeric)
- **user_name**: User's name (text)
- **user_photo_url**: URL of the user's photo (text)
- **last_updated**: Last update date (timestamp)
- **check_ins_count**: Total number of check-ins (integer)
- **last_check_in**: Last check-in date (timestamp)
- **consecutive_days**: Number of consecutive check-in days (integer)
- **completed**: Indicates if the challenge was completed (boolean)

### user_challenges
Complementary relationship between users and challenges (history, status).
- **id**: Unique identifier (text)
- **user_id**: Reference to the user (UUID)
- **challenge_id**: Reference to the challenge (UUID)
- **joined_at**: Date when the user joined the challenge (timestamp)
- **completed_at**: Date when the user completed the challenge (timestamp)
- **progress**: Numerical progress (numeric)
- **status**: Participation status (text)

### user_workouts
Records of workouts performed by users.
- **id**: Unique workout record identifier (text)
- **user_id**: Reference to the user (UUID)
- **workout_id**: Reference to the workout (UUID)
- **started_at**: Workout start date/time (timestamp)
- **completed_at**: Workout completion date/time (timestamp)
- **progress**: Numerical progress (numeric)
- **notes**: User notes (text)
- **feedback**: Feedback in JSON format (jsonb)
- **exercises_completed**: Record of completed exercises (jsonb)
- **user_name**: User's name (text)
- **user_photo_url**: URL of the user's photo (text)
- **workout_type**: Workout type (text)
- **duration**: Duration in seconds (integer)
- **calories_burned**: Estimated calories burned (integer)

## Data Flow

1. **Workout Registration:**
   - User logs a workout → user_workouts
   - sync_workout_to_challenges trigger is activated
   - New check-ins inserted in challenge_check_ins
   - Trigger in challenge_check_ins updates challenge_progress
   - Ranking positions are recalculated

2. **Challenge Participation:**
   - User joins a challenge → challenge_participants
   - Trigger updates participant counter
   - Record created in user_challenges for additional tracking

3. **Ranking View:**
   - Data read from challenge_progress table
   - Ordered by points in descending order
   - Position automatically calculated by triggers

## Triggers and Functions

### sync_workout_to_challenges
- **When:** After insertion in user_workouts
- **Action:** Creates check-ins for all active challenges the user is participating in

### update_challenge_progress_on_check_in
- **When:** After insertion in challenge_check_ins
- **Action:** Updates metrics in challenge_progress and recalculates positions

### update_challenge_participants_count
- **When:** After insertion/deletion in challenge_participants
- **Action:** Updates participant counter in the challenges table

## Performance Considerations

- **Critical Indexes:**
  - (challenge_id, user_id) in challenge_participants and challenge_progress
  - user_id in user_workouts
  - (challenge_id, check_in_date) in challenge_check_ins

- **Optimized Frequent Queries:**
  - Challenge rankings (ordered by points)
  - Recent user check-ins
  - Active challenges a user is participating in

- **Limitations:**
  - Ranking recalculation can be expensive for challenges with many participants
  - Consider using materialization for popular challenge rankings 