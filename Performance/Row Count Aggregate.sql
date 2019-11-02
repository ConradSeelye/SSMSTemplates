/*
Row Count Aggregate
source: https://docs.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-exec-query-stats-transact-sql?view=sql-server-2017
date: 4/30/2019

Edited by CBS:  added ObjectName column.

How to get proc or source name?  Use objectid column?
Add CDL of databases that contain table names.
	https://stackoverflow.com/questions/18870326/comma-separated-results-in-sql
	How to extract the table names?
	Get first 100 characers and search the modules (procs, etc) for that text, looping through all dbs.
*/


SELECT qs.execution_count,  
    SUBSTRING(qt.text,qs.statement_start_offset/2 +1,   
                 (CASE WHEN qs.statement_end_offset = -1   
                       THEN LEN(CONVERT(nvarchar(max), qt.text)) * 2   
                       ELSE qs.statement_end_offset end -  
                            qs.statement_start_offset  
                 )/2  
             ) AS query_text,   
     qt.dbid, dbname= DB_NAME (qt.dbid), qt.objectid, o.name AS ObjectName,
     qs.total_rows, qs.last_rows, qs.min_rows, qs.max_rows  
FROM sys.dm_exec_query_stats AS qs   
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS qt   
LEFT JOIN sys.objects o ON qt.objectid = o.object_id 
WHERE qt.text like '%SELECT%'   
ORDER BY qs.execution_count DESC;  

