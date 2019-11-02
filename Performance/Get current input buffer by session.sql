
/*
Get current input buffer by session.

source: https://docs.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-exec-input-buffer-transact-sql?view=sql-server-2017
date: 3/27/2019


*/

SELECT es.session_id, ib.event_info   
FROM sys.dm_exec_sessions AS es  
CROSS APPLY sys.dm_exec_input_buffer(es.session_id, NULL) AS ib  
WHERE es.is_user_process = 1
GO

