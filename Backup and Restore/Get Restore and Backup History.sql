/*
Get Backup and Restore History
source: https://www.mssqltips.com/sqlservertip/6042/sql-server-backup-and-restore-history-queries/
date: 2/20/2020

*/
 
SELECT
  backupset.[name]
, backupset.[description]
, [type]
, expiration_date
, is_compressed
, Device_Type
, [user_name]
, server_name
, [database_name]
, is_copy_only
, backup_start_date
, backup_finish_date
, backup_size
, compressed_backup_size
, physical_device_name
, [backup_set_id]
, backupset.media_set_id
FROM msdb.dbo.backupset
  INNER JOIN msdb.dbo.backupmediaset ON backupset.media_set_id = backupmediaset.media_set_id
  INNER JOIN msdb.dbo.backupmediafamily ON backupset.media_set_id = backupmediafamily.media_set_id
WHERE 1=1
	-- AND database_name = 'msdb'
  AND backup_start_date > DATEADD(n, -20, GETDATE());

   
SELECT
  logical_name
, physical_name
, file_type
, [filegroup_name]
, file_size
, backup_set_id
FROM msdb.dbo.backupfile

-- restore history
SELECT * 
FROM msdb.dbo.restorehistory 
ORDER BY restore_date DESC







