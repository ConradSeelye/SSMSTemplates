USE [master]
GO
CREATE LOGIN MyLogin WITH PASSWORD=N'..........................' MUST_CHANGE, DEFAULT_DATABASE=[master], CHECK_EXPIRATION=ON, CHECK_POLICY=ON
GO

USE MyDatabase
GO
CREATE USER MyLogin FOR LOGIN MyLogin
GO

ALTER ROLE [db_datareader] ADD MEMBER MyLogin
GO

ALTER ROLE [db_datawriter] ADD MEMBER MyLogin
GO

ALTER ROLE [db_executor] ADD MEMBER MyLogin
GO
