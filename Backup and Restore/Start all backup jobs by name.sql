/*
Start all backup jobs by name
https://chatgpt.com/c/675c7187-90fc-8001-aabc-e15076763ec8
https://claude.ai/chat/08eb4105-0653-40cd-b11d-7362a5c4a96e
1/29/2025
Status : this works

*** Adjust the WHERE clause for job type

*/

--:CONNECT 

USE msdb;

DECLARE @JobName NVARCHAR(128);

-- Cursor to iterate over jobs with names ending in '_DBBackup'
DECLARE job_cursor CURSOR FOR
SELECT name
FROM sysjobs
-- WHERE name LIKE '%BLIS%_DBBackup';
WHERE name LIKE '%BLIS%_Trans_Backup';


OPEN job_cursor;

FETCH NEXT FROM job_cursor INTO @JobName;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT 'Starting job: ' + @JobName;
    
    -- Start the job
    EXEC sp_start_job @job_name = @JobName;

    FETCH NEXT FROM job_cursor INTO @JobName;
END;

CLOSE job_cursor;
DEALLOCATE job_cursor;


-- Query to monitor job status
SELECT 
    j.name AS 'Job Name',
    h.run_date,
    h.run_time,
    CASE h.run_status
        WHEN 0 THEN 'Failed'
        WHEN 1 THEN 'Succeeded'
        WHEN 2 THEN 'Retry'
        WHEN 3 THEN 'Canceled'
        WHEN 4 THEN 'In Progress'
    END AS 'Status'
FROM msdb.dbo.sysjobs j
JOIN msdb.dbo.sysjobhistory h 
    ON j.job_id = h.job_id
WHERE j.name LIKE '%Trans_Backup%'
    AND h.step_id = 0
ORDER BY h.run_date DESC, h.run_time DESC


