
/*
Get blocker for a backup

*/



-- SELECT r.session_id, r.status, r.wait_type, r.wait_time, r.blocking_session_id, r.command
SELECT * 
FROM sys.dm_exec_requests r
-- WHERE r.command LIKE 'BACKUP%';

SELECT session_id, login_name, host_name, program_name, status, last_request_start_time, last_request_end_time
FROM sys.dm_exec_sessions
WHERE program_name LIKE '%VDI%' OR program_name LIKE '%VDI_CLIENT_WORKER%' OR program_name LIKE '%VSS%';



-- KILL 59





