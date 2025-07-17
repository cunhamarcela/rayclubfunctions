-- Add formatted_date column to challenge_check_ins table
ALTER TABLE challenge_check_ins 
ADD COLUMN IF NOT EXISTS formatted_date VARCHAR(10);

-- Update existing records to fill the formatted_date value
UPDATE challenge_check_ins
SET formatted_date = TO_CHAR(check_in_date::date, 'YYYY-MM-DD')
WHERE formatted_date IS NULL;

-- Create an index on the formatted_date column for faster queries
CREATE INDEX IF NOT EXISTS idx_challenge_check_ins_formatted_date 
ON challenge_check_ins(formatted_date);

-- Create a composite index on user_id, challenge_id, and formatted_date
-- This will greatly speed up duplicate check-in verification
CREATE UNIQUE INDEX IF NOT EXISTS idx_challenge_check_ins_unique_daily 
ON challenge_check_ins(user_id, challenge_id, formatted_date);

-- Add a trigger to automatically fill formatted_date on insert
CREATE OR REPLACE FUNCTION set_formatted_date()
RETURNS TRIGGER AS $$
BEGIN
  NEW.formatted_date = TO_CHAR(NEW.check_in_date::date, 'YYYY-MM-DD');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trigger_set_formatted_date
BEFORE INSERT ON challenge_check_ins
FOR EACH ROW
WHEN (NEW.formatted_date IS NULL)
EXECUTE FUNCTION set_formatted_date(); 