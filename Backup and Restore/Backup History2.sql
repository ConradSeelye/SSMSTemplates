/*
Get backup history.
date: 11/12/2018

*/

SELECT ms.media_set_id
	, ms.name
	, s.backup_start_date
	, CASE 
		WHEN s.type = 'L' THEN 'Log'
		WHEN s.type = 'D' THEN 'Database'
		END
	, s.type
	, s.database_name
	, s.server_name
	, s.machine_name
	, s.recovery_model
FROM msdb.dbo.backupmediaset ms
JOIN msdb.dbo.backupset s
ON ms.media_set_id = s.media_set_id
ORDER BY s.backup_start_date DESC


