
USE SQL_IMDB
GO

IF 
	-- This is in case the AG doesn't exist, but the databases are still set up as Restoring
	(SELECT state_desc FROM sys.databases WHERE name = 'MyDatabase') <> 'RESTORING' 
	-- This is for when the AG exists
	AND (sys.fn_hadr_is_primary_replica ('MyDatabase') = 1
		OR sys.fn_hadr_is_primary_replica ('MyDatabase') IS NULL)
BEGIN
	Exec USP_IMDB_Backup_TranLog [MyDatabase]
END



