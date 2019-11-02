
/*
Get SQL license info
11/8/2018
Notes:
* This has to be run in SQLCMD mode.
* If you connect to multiple servers, include GO between :CONNECT statements.

*/

:CONNECT SQL-D-16P3082
SELECT @@SERVERNAME AS ServerName
	, SERVERPROPERTY('EDITION') AS SQL_Edition
	,cpu_count 
FROM [sys].[dm_os_sys_info]
GO

