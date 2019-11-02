
/*
Get log file usage.
ref:  https://docs.microsoft.com/en-us/sql/t-sql/database-console-commands/dbcc-sqlperf-transact-sql?view=sql-server-2017
date: 11/19/2018
notes:
-- This matches the sum of multiple .ldf files. 
-- DBCC SQLPERF(LOGSPACE)
-- The percent column is not compared to the total size limit of the files.

*/

CREATE TABLE #TmpLOGSPACE(
  DatabaseName varchar(100)
  , LOGSIZE_MB decimal(18, 9)
  , LogSpace_Used_Percent decimal(18, 9)
  ,  LOGSTATUS decimal(18, 9)) 

INSERT #TmpLOGSPACE(DatabaseName, LOGSIZE_MB, LogSpace_Used_Percent, LOGSTATUS) 
EXEC('DBCC SQLPERF(LOGSPACE);')

SELECT * FROM #TmpLOGSPACE
WHERE DatabaseName = 'IPQM'

DROP TABLE #TmpLOGSPACE



