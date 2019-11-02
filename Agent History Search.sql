SELECT 
	j.name,
	h.*
FROM msdb.dbo.sysjobhistory h
JOIN msdb.dbo.sysjobs j
ON h.job_id = j.job_id
WHERE message LIKE '%%'