
SELECT 
  bs.database_name,
  bs.type AS backup_type,               -- D = full, L = log, I = diff
  bs.backup_start_date,
  bs.backup_finish_date,
  bs.user_name,                         -- login that performed the backup
  bs.server_name,                       -- server name recorded in msdb
  bs.name,                              -- name (often maintenance plan name)
  bs.description,
  bmf.physical_device_name
FROM msdb.dbo.backupset bs
JOIN msdb.dbo.backupmediafamily bmf 
  ON bs.media_set_id = bmf.media_set_id
WHERE bs.backup_finish_date >= DATEADD(day, -7, GETDATE()) -- last 7 days
	AND bs.type = 'D'
	--AND  bs.database_name = 'DMDT777F_PROD_PROJECT'
ORDER BY bs.backup_finish_date DESC;


