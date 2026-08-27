/*
Restore only log file
10/30/2024

*/


RESTORE LOG MyDatabase
FROM 
    DISK = 'S:\restore\MyDatabase_1.Trn',
	DISK = 'S:\restore\MyDatabase_2.Trn',
	DISK = 'S:\restore\MyDatabase_3.Trn',
	DISK = 'S:\restore\MyDatabase_4.Trn'

WITH NORECOVERY;  


