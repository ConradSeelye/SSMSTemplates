/*
Get backup history
source: https://www.mssqltips.com/sqlservertip/1601/script-to-retrieve-sql-server-database-backup-history-and-no-backups/
date: 4/12/2019

notes:
* change the Where clause for database_name

to do:
* create a query for listing the most recent full backups for each database; to be a quick confirmation that regular backups are occuring

*/


SELECT 
	CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS Server, 
	msdb.dbo.backupset.database_name, 
	msdb.dbo.backupset.backup_start_date, 
	msdb.dbo.backupset.backup_finish_date, 
	msdb.dbo.backupset.expiration_date, 
	CASE msdb..backupset.type 
		WHEN 'D' THEN 'Database' 
		WHEN 'L' THEN 'Log' 
	END AS backup_type, 
	msdb.dbo.backupset.backup_size, 
	msdb.dbo.backupmediafamily.logical_device_name, 
	msdb.dbo.backupmediafamily.physical_device_name, 
	msdb.dbo.backupset.name AS backupset_name, 
	msdb.dbo.backupset.description 
FROM msdb.dbo.backupmediafamily 
	INNER JOIN msdb.dbo.backupset ON msdb.dbo.backupmediafamily.media_set_id = msdb.dbo.backupset.media_set_id 
WHERE (CONVERT(datetime, msdb.dbo.backupset.backup_start_date, 102) >= GETDATE() - 7) 
	AND msdb..backupset.type = 'D' -- get only full backups
	-- AND database_name = 'TestAG2'
ORDER BY 
	msdb.dbo.backupset.database_name, 
	msdb.dbo.backupset.backup_finish_date 

RETURN


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

