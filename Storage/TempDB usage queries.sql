/*
TempDB
source: https://thesqldude.com/tag/tempdb-is-full/
date: 5/8/2019

*/


-- Identify which type of tempdb objects are consuming  space
SELECT
SUM (user_object_reserved_page_count)*8 as user_obj_kb,
SUM (internal_object_reserved_page_count)*8 as internal_obj_kb,
SUM (version_store_reserved_page_count)*8  as version_store_kb,
SUM (unallocated_extent_page_count)*8 as freespace_kb,
SUM (mixed_extent_page_count)*8 as mixedextent_kb
FROM sys.dm_db_file_space_usage



-- Query that identifies the currently active T-SQL query, it’s text and the Application that is consuming a lot of tempdb space
SELECT es.host_name , es.login_name , es.program_name,
	st.dbid as QueryExecContextDBID, DB_NAME(st.dbid) as QueryExecContextDBNAME, st.objectid as ModuleObjectId,
	SUBSTRING(st.text, er.statement_start_offset/2 + 1,(CASE WHEN er.statement_end_offset = -1 THEN LEN(CONVERT(nvarchar(max),st.text)) * 2 ELSE er.statement_end_offset 
	END - er.statement_start_offset)/2) as Query_Text,
	tsu.session_id ,tsu.request_id, tsu.exec_context_id, 
	(tsu.user_objects_alloc_page_count - tsu.user_objects_dealloc_page_count) as OutStanding_user_objects_page_counts,
	(tsu.internal_objects_alloc_page_count - tsu.internal_objects_dealloc_page_count) as OutStanding_internal_objects_page_counts,
	er.start_time, er.command, er.open_transaction_count, er.percent_complete, er.estimated_completion_time, er.cpu_time, er.total_elapsed_time, er.reads,er.writes, 
	er.logical_reads, er.granted_query_memory
FROM sys.dm_db_task_space_usage tsu inner join sys.dm_exec_requests er 
	 ON ( tsu.session_id = er.session_id and tsu.request_id = er.request_id) 
	inner join sys.dm_exec_sessions es ON ( tsu.session_id = es.session_id ) 
	CROSS APPLY sys.dm_exec_sql_text(er.sql_handle) st
WHERE (tsu.internal_objects_alloc_page_count+tsu.user_objects_alloc_page_count) > 0
ORDER BY (tsu.user_objects_alloc_page_count - tsu.user_objects_dealloc_page_count)+(tsu.internal_objects_alloc_page_count - tsu.internal_objects_dealloc_page_count) 
DESC




/*
current tempdb size and growth parameters
source: https://docs.microsoft.com/en-us/sql/relational-databases/databases/tempdb-database?view=sql-server-2017
date: 5/13/2019

*/

SELECT name AS FileName,
    size*1.0/128 AS FileSizeInMB,
    CASE max_size
        WHEN 0 THEN 'Autogrowth is off.'
        WHEN -1 THEN 'Autogrowth is on.'
        ELSE 'Log file grows to a maximum size of 2 TB.'
    END,
    growth AS 'GrowthValue',
    'GrowthIncrement' =
        CASE
            WHEN growth = 0 THEN 'Size is fixed.'
            WHEN growth > 0 AND is_percent_growth = 0
                THEN 'Growth value is in 8-KB pages.'
            ELSE 'Growth value is a percentage.'
        END
FROM tempdb.sys.database_files;
GO


-- Determining the Amount of Free Space in tempdb
SELECT SUM(unallocated_extent_page_count) AS [free pages],
  (SUM(unallocated_extent_page_count)*1.0/128) AS [free space in MB]
FROM sys.dm_db_file_space_usage;

-- Determining the Amount Space Used by the Version Store
SELECT SUM(version_store_reserved_page_count) AS [version store pages used],
  (SUM(version_store_reserved_page_count)*1.0/128) AS [version store space in MB]
FROM sys.dm_db_file_space_usage;

-- Determining the Amount of Space Used by Internal Objects
SELECT SUM(internal_object_reserved_page_count) AS [internal object pages used],
  (SUM(internal_object_reserved_page_count)*1.0/128) AS [internal object space in MB]
FROM sys.dm_db_file_space_usage;

-- Determining the Amount of Space Used by User Objects
SELECT SUM(user_object_reserved_page_count) AS [user object pages used],
  (SUM(user_object_reserved_page_count)*1.0/128) AS [user object space in MB]
FROM sys.dm_db_file_space_usage;




