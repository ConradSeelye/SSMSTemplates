/*
Backup Progress, Percent Complete__

status 7/25/2026
*/


SELECT @@SERVERNAME

SELECT 
	r.command
	--, cast (r.percent_complete AS DECIMAL (3,1)) AS Percent_Complete
		-- note: this breaks if value is 0
	,  FORMAT(r.percent_complete, '###,###', 'en-us') AS [Percent Complete]
	, r.estimated_completion_time / 1000/60 AS [Estimated remaining minutes]
	, r.estimated_completion_time AS [Milliseconds]
	, t.text
FROM sys.dm_exec_requests r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) t
WHERE r.command IN ('BACKUP DATABASE','RESTORE DATABASE', 'BACKUP LOG', 'RESTORE LOG')
	OR command LIKE '%DBCC TABLE CHECK%'
	OR command LIKE '%UPDATE STATISTICS%' -- does not update percent_complete
	OR command LIKE '%CREATE INDEX%'
	OR command LIKE '%DbccFilesCompact%'

