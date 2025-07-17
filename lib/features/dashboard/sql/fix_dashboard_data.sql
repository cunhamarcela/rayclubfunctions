CREATE OR REPLACE FUNCTION fix_dashboard_data() RETURNS void AS $$ BEGIN NOTIFY dashboard_data_fixed; END; $$ LANGUAGE plpgsql;
