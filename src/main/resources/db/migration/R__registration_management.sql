DROP TRIGGER IF EXISTS when_delete ON registration;

DROP TRIGGER IF EXISTS when_insert ON registration;

CREATE OR REPLACE FUNCTION register_user_on_activity(userId bigint, activityId bigint) RETURNS registration AS $$
	DECLARE
		enregistrement registration%rowtype;
	BEGIN
		
		SELECT * INTO enregistrement FROM registration WHERE user_id = userId AND activity_id = activityId;
		
		IF FOUND THEN 
			RAISE EXCEPTION 'registration_already_exists';		
		ELSE 
			INSERT INTO registration 
			VALUES (nextval('id_generator'), now(), userId, activityId);
		END IF;
		
		SELECT * INTO enregistrement FROM registration
	    WHERE user_id = userId and activity_id = activityId;
		RETURN enregistrement; -- retourne la ligne créée
		
	END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION unregister_user_on_activity(userId bigint, activityId bigint) RETURNS void AS $$
	DECLARE
		enregistrement registration%rowtype;
	BEGIN
		
		SELECT * INTO enregistrement FROM registration WHERE user_id = userId AND activity_id = activityId;
		
		IF NOT FOUND THEN 
			RAISE EXCEPTION 'registration_not_found';
		END IF;
	
		DELETE FROM registration WHERE user_id = userId AND activity_id = activityId;

		
	END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION log_delete_on_registration() RETURNS TRIGGER AS $$
	BEGIN
		INSERT INTO action_log (id, action_name, entity_name, entity_id, author, action_date)
		VALUES (nextval('id_generator'),'delete', 'registration', OLD.id, user, now()); -- on utilise after donc on utilise OLD.
		
		RETURN NULL; -- trigger after donc le résultat est ignorer
	END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION log_insert_on_activities() RETURNS TRIGGER AS $$
	BEGIN
		INSERT INTO action_log (id,action_name, entity_name, entity_id, author, action_date)
		VALUES (nextval('id_generator'),'insert', 'registration', NEW.id, USER, now()); -- on utilise after donc on utilise NEW.
		
		RETURN NULL; -- trigger after donc le résultat est ignoré
	END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER when_delete AFTER DELETE ON registration
FOR EACH ROW EXECUTE PROCEDURE log_delete_on_registration();

CREATE TRIGGER when_insert AFTER INSERT ON registration
FOR EACH ROW EXECUTE PROCEDURE log_insert_on_activities();

