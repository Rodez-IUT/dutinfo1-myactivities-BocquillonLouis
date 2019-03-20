CREATE OR REPLACE FUNCTION get_default_owner() RETURNS "user" AS $$
DECLARE
	defaultOwner "user"%rowtype;
	defaultOwnerUsername varchar(500) := 'Default Owner';

BEGIN
	SELECT * INTO defaultOwner FROM "user" WHERE username = defaultOwnerUsername;
	IF NOT found THEN
		INSERT INTO "user" (id,username) VALUES (nextval('id_generator'), defaultOwnerUsername);
		SELECT * INTO defaultOwner FROM "user" WHERE username = defaultOwnerUsername;
	END IF;
RETURN defaultOwner;
END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION fix_activities_without_owner() RETURNS SETOF activity AS $$
DECLARE
	
	defaultOwner "user"%rowtype;

BEGIN
	
	defaultOwner := get_default_owner();
	RETURN query
	UPDATE activity
	SET owner_id = defaultOwner.id
	WHERE owner_id IS NULL 
	returning *;
	
END
$$ LANGUAGE plpgsql;