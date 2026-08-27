/*
Verify backup file integrity.
5/10/2022

https://docs.microsoft.com/en-us/sql/t-sql/statements/restore-statements-verifyonly-transact-sql?view=sql-server-ver15

https://solutioncenter.apexsql.com/verifying-sql-database-backups-automatically/#:~:text=The%20following%20SQL%20database%20backup%20verification%20methods%20can,restored%20database%2C%20to%20confirm%20everything%20is%20OK.%20


*/

USE [master]
RESTORE VERIFYONLY  
FROM  DISK = N'L:\L_mnt_backup1\PROD06\SQLBACKUPS\OpsAdmin\OpsAdmin20220509234931_1.Bak',  
DISK = N'L:\L_mnt_backup1\PROD06\SQLBACKUPS\OpsAdmin\OpsAdmin20220509234931_2.Bak',  
DISK = N'L:\L_mnt_backup1\PROD06\SQLBACKUPS\OpsAdmin\OpsAdmin20220509234931_3.Bak',  
DISK = N'L:\L_mnt_backup1\PROD06\SQLBACKUPS\OpsAdmin\OpsAdmin20220509234931_4.Bak' 
WITH  FILE = 1,  MOVE N'OpsAdmin3' TO N'L:\L_mnt_data1\PROD06\SQLDATA\OpsAdmin3.ndf',   
MOVE N'OpsAdmin4' TO N'L:\L_mnt_data1\PROD06\SQLDATA\OpsAdmin4_TEST.ndf',  
NOUNLOAD,  STATS = 1

GO



