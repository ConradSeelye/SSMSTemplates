/*
Connection count
date: 4/1/2019

share status: sql@ 2/6/2019


*/

-- **** sys.sysprocesses
SELECT 
    DB_NAME(dbid) as DBName, 
    COUNT(dbid) as NumberOfConnections,
    loginame as LoginName
FROM
    sys.sysprocesses
WHERE 
    dbid > 0
GROUP BY 
    dbid, loginame

SELECT 
    COUNT(dbid) as TotalConnections
FROM
    sys.sysprocesses
WHERE 
    dbid > 0

SELECT * FROM sys.sysprocesses


-- **** sp_who2
exec sp_who2 'Active'


-- **** sys.dm_exec_sessions
-- source:   http://sqlserverplanet.com/dmvs/find-user-connection-count
SELECT login_name, session_count, last_batch_time, DatabaseName, is_user_process
FROM(
SELECT login_name ,COUNT(session_id) AS session_count, MAX(last_request_end_time) AS last_batch_time, DB_NAME(database_id) AS DatabaseName, is_user_process
FROM sys.dm_exec_sessions
GROUP BY login_name, DB_NAME(database_id), is_user_process
) t
WHERE DatabaseName IN ('Shield_Database_Airplane','Shield_Database_Loto')
ORDER BY session_count DESC

-- source: https://www.itprotoday.com/sql-server/4-methods-identifying-connections-count-sql-server
SELECT DB_NAME(eS.database_id) AS the_database
	, eS.is_user_process
	, COUNT(eS.session_id) AS total_database_connections
FROM sys.dm_exec_sessions eS 
WHERE DB_NAME(eS.database_id) IN ('Shield_Database_Airplane','Shield_Database_Loto')
GROUP BY DB_NAME(eS.database_id)
	, eS.is_user_process
ORDER BY 1, 2;

SELECT DB_NAME(database_id) AS DB_Name, * 
FROM sys.dm_exec_sessions
WHERE DB_NAME(database_id) = 'Shield_Database_Airplane'


-- **** Performance Counters
SELECT *
FROM sys.dm_os_performance_counters
WHERE counter_name = 'User Connections';


-- **** dm_exec_connections
SELECT * FROM sys.dm_exec_connections








