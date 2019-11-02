/*
sp_who2 as a table

date: 3/30/2015
Notes:
* adjust Order By

*/
-- SELECT * FROM [dbo].[daxko_hist_usage]


CREATE TABLE #sp_who3 
( 
    SPID INT, 
    [Status] SYSNAME NULL, 
    [Login] SYSNAME NULL, 
    HostName SYSNAME NULL, 
    BlkBy SYSNAME NULL, 
    DBName SYSNAME NULL, 
    Command SYSNAME NULL, 
    CPUTime INT NULL, 
    DiskIO INT NULL, 
    LastBatch varchar(400) NULL, 
    ProgramName SYSNAME NULL, 
    SPID2 INT null,
    RequestID int null  
) 
 
INSERT #sp_who3 EXEC sp_who2 --'active' 

SELECT * 
FROM #sp_who3
-- WHERE Login = 'TableauUser'
WHERE Login <> 'sa'
	--and login = 'TableauUser'
ORDER BY 
-- CPUTime Desc
LastBatch Desc

DROP TABLE #sp_who3





