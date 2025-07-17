CREATE OR REPLACE FUNCTION deploy_dashboard_fixes() RETURNS void AS $$ BEGIN NOTIFY dashboard_data_update; END; $$ LANGUAGE plpgsql;
