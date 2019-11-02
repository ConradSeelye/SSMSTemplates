/*
Enable Query Store with non-default parameters
source: Scripting from UI
date: 4/18/2019

Steps:
1. update database name x 2
2. review parameters



*/

USE [master]
GO
ALTER DATABASE Shield_Database_Users SET QUERY_STORE = ON
GO
ALTER DATABASE Shield_Database_Users 
SET QUERY_STORE (OPERATION_MODE = READ_WRITE, INTERVAL_LENGTH_MINUTES = 10, 
MAX_STORAGE_SIZE_MB = 1000)
GO




