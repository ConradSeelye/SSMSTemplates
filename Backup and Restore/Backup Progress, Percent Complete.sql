SELECT command, percent_complete 
FROM sys.dm_exec_requests
WHERE command = 'BACKUP DATABASE'
