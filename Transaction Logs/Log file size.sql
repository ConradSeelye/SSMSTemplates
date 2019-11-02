

/* 
Get the size and max size of the individual .ldf files.
This is only the file size. It is not the % filled. 

ToDo:
* adjust to comma formatted integers
* find and add the % filled
*/

SELECT 
	name,
	(size * 8.0)/1024.0 AS size_in_mb
     , CASE
		WHEN max_size                                 = -1 
		THEN 9999999                  -- Unlimited growth, so handle this how you want
		ELSE (max_size * 8.0)/1024.0                  END AS max_size_in_mb
 
FROM IPQM.sys.database_files
WHERE data_space_id                            = 0           

--  SELECT * FROM IPQM.sys.database_files

