DROP TRIGGER IF EXISTS when_delete ON activity;


CREATE OR REPLACE FUNCTION log_action_on_activities() RETURNS TRIGGER AS $$
	BEGIN
		INSERT INTO action_log
		VALUES (nextval('id_generator'),'delete', 'activity', OLD.id, user, now()); -- on utilise after donc on utilise OLD.
		
		RETURN NULL; -- trigger after donc le résultat est ignorer
	END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER when_delete AFTER DELETE ON activity
FOR EACH ROW EXECUTE PROCEDURE log_action_on_activities();
