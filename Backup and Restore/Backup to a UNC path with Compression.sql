

BACKUP DATABASE [database_name] 
TO  DISK = N'\\(server_path)\_20210913_0932.bak' 
WITH NOFORMAT, NOINIT,  
NAME = N'MyDatabase-Full Database Backup', 
SKIP, NOREWIND, NOUNLOAD, COMPRESSION,  STATS = 1
GO

-- If this shows 'LOG_BACKUP', then I think the log file won't shrink.  (why is that?)
-- SELECT name, log_reuse_wait_desc FROM sys.databases;

-- You might be doing the remote backup so backup drive storage can be freed up. 
-- Do the shrink immediately after the trans log backup.
/*
USE [MyDatabase]
GO
DBCC SHRINKFILE (N'MyDatabase_log2' , 419)
GO
*/


