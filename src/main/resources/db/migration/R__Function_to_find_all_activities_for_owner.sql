CREATE OR REPLACE FUNCTION find_all_activities_for_owner(ownername varchar(500)) RETURNS SETOF activity AS $$
   
	SELECT a.*
	FROM activity a
	WHERE a.owner_id = (SELECT id
			    		FROM "user"
			    	    WHERE username = ownername);
   
$$ LANGUAGE SQL;