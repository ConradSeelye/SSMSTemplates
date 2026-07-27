/*
Create xEvent to record logins
status : ok
3/7/2025

*/



CREATE EVENT SESSION [LoginTracking_WebToolUser] ON SERVER 
ADD EVENT sqlserver.login(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.nt_username,sqlserver.session_id,sqlserver.session_nt_username,sqlserver.username)
    WHERE ([sqlserver].[username]=N'testtesttest' OR [sqlserver].[username]=N'WebToolUser'))
ADD TARGET package0.event_file(SET filename=N'S:\XEvents\LoginTracking_WebToolUser.xel')
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=ON)
GO



