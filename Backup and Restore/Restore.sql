/*

Restore a database.
Edit the path and DB name.


*/

USE [master]
RESTORE DATABASE <databasename,,>
FROM  DISK = N'S:\MSSQLSERVER\RESTORE\SND20181026023430.Bak' 
WITH  FILE = 1,  NOUNLOAD,  REPLACE,  STATS = 1

GO

