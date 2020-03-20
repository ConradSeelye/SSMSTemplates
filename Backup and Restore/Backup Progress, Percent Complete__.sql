SELECT command, percent_complete 
FROM sys.dm_exec_requests
WHERE command IN ('BACKUP DATABASE','RESTORE DATABASE')
