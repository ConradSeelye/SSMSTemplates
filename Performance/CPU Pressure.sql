/*
Identifying high signal waits (CPU pressure)
Returns the TotalSignalWait and PercentageWaitsOfTotalTime
date: 3/4/2019
source: PDF book "SQL Server Performance Tuning Using Wait Statistics"
	SQL Server Performance Tuning Using Wait Statistics Whitepaper.pdf
	by RedGate


*/

-- Clear wait stats
-- DBCC SQLPERF ('sys.dm_os_wait_stats', CLEAR);


SELECT SUM(signal_wait_time_ms) AS TotalSignalWaitTime ,
( SUM(CAST(signal_wait_time_ms AS NUMERIC(20, 2)))
/ SUM(CAST(wait_time_ms AS NUMERIC(20, 2))) * 100 )
AS PercentageSignalWaitsOfTotalTime
FROM sys.dm_os_wait_stats



/*
If signal waits analysis indicates CPU pressure, then the sys.dm_os_schedulers DMV
can help verify whether a SQL Server instance is currently CPU-bound. This DMV returns
one row for each of the SQL Server schedulers and it lists the total number of tasks that
are assigned to each scheduler, as well as the number that are runnable.

source: https://docs.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-os-schedulers-transact-sql?view=sql-server-2017
date: 3/26/2019

*/

SELECT  
    scheduler_id,  
    cpu_id,
	status,  
	is_idle,
    current_tasks_count,  
    runnable_tasks_count,  
    current_workers_count,  
    active_workers_count,  
    work_queue_count,
	pending_disk_io_count
  FROM sys.dm_os_schedulers  
  WHERE scheduler_id < 255; 



  /*
Finding the TOP N queries
source: https://docs.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-exec-query-stats-transact-sql?view=sql-server-2017
date: 4/30/2019
How to get the sp name, or the source?
*/

SELECT TOP 5 query_stats.query_hash AS "Query Hash",   
    SUM(query_stats.total_worker_time) / SUM(query_stats.execution_count) AS "Avg CPU Time",  
    MIN(query_stats.statement_text) AS "Statement Text"  
FROM   
    (SELECT QS.*,   
    SUBSTRING(ST.text, (QS.statement_start_offset/2) + 1,  
    ((CASE statement_end_offset   
        WHEN -1 THEN DATALENGTH(ST.text)  
        ELSE QS.statement_end_offset END   
            - QS.statement_start_offset)/2) + 1) AS statement_text  
     FROM sys.dm_exec_query_stats AS QS  
     CROSS APPLY sys.dm_exec_sql_text(QS.sql_handle) as ST) as query_stats  
GROUP BY query_stats.query_hash  
ORDER BY 2 DESC;  

