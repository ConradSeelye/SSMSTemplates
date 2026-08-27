

BACKUP DATABASE [DatabaseBackup] 
TO  
DISK = N'S:\MSSQLSERVER\SQLBACKUPS\DatabaseBackupFiles\PROD_Database_Backup_1.bak',  
DISK = N'S:\MSSQLSERVER\SQLBACKUPS\DatabaseBackupFiles\PROD_Database_Backup_2.bak',
DISK = N'S:\MSSQLSERVER\SQLBACKUPS\DatabaseBackupFiles\PROD_Database_Backup_3.bak',
DISK = N'S:\MSSQLSERVER\SQLBACKUPS\DatabaseBackupFiles\PROD_Database_Backup_4.bak',
DISK = N'S:\MSSQLSERVER\SQLBACKUPS\DatabaseBackupFiles\PROD_Database_Backup_5.bak',

DISK = N'S:\MSSQLSERVER\SQLBACKUPS\DatabaseBackupFiles\PROD_Database_Backup_6.bak',
DISK = N'S:\MSSQLSERVER\SQLBACKUPS\DatabaseBackupFiles\PROD_Database_Backup_7.bak',
DISK = N'S:\MSSQLSERVER\SQLBACKUPS\DatabaseBackupFiles\PROD_Database_Backup_8.bak',
DISK = N'S:\MSSQLSERVER\SQLBACKUPS\DatabaseBackupFiles\PROD_Database_Backup_9.bak',
DISK = N'S:\MSSQLSERVER\SQLBACKUPS\DatabaseBackupFiles\PROD_Database_Backup_10.bak'

--DISK = N'S:\MSSQLSERVER\SQLBACKUPS\PROD_Database_Backup\PROD_Database_Backup_6.bak',
--DISK = N'S:\MSSQLSERVER\SQLBACKUPS\PROD_Database_Backup\PROD_Database_Backup_7.bak',
--DISK = N'S:\MSSQLSERVER\SQLBACKUPS\PROD_Database_Backup\PROD_Database_Backup_8.bak',
--DISK = N'S:\MSSQLSERVER\SQLBACKUPS\PROD_Database_Backup\PROD_Database_Backup_9.bak',
--DISK = N'S:\MSSQLSERVER\SQLBACKUPS\PROD_Database_Backup\PROD_Database_Backup_10.bak'
--DISK = N'S:\MSSQLSERVER\SQLBACKUPS\PROD_Database_Backup\PROD_Database_Backup_11.bak',
--DISK = N'S:\MSSQLSERVER\SQLBACKUPS\PROD_Database_Backup\PROD_Database_Backup_12.bak',
--DISK = N'S:\MSSQLSERVER\SQLBACKUPS\PROD_Database_Backup\PROD_Database_Backup_13.bak',
--DISK = N'S:\MSSQLSERVER\SQLBACKUPS\PROD_Database_Backup\PROD_Database_Backup_14.bak',
--DISK = N'S:\MSSQLSERVER\SQLBACKUPS\PROD_Database_Backup\PROD_Database_Backup_15.bak'

WITH NOFORMAT, NOINIT,  NAME = N'PROD_Database_Backup-Full Database Backup', 
SKIP, NOREWIND, NOUNLOAD, COMPRESSION,  STATS = 1
GO








