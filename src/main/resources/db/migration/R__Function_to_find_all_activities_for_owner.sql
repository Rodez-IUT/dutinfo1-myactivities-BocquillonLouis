CREATE OR REPLACE FUNCTION find_all_activities_for_owner(ownername varchar(500)) RETURNS SETOF activity AS $$
   
	SELECT a.*
	FROM activity a
	JOIN "user" owner
	ON a.owner_id = owner.id
	WHERE owner.username = ownername;
   
$$ LANGUAGE SQL;