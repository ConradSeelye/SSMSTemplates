-- Add Login and RO User

:CONNECT server-name


USE [master]
GO
CREATE LOGIN [MyLogin] 
FROM WINDOWS WITH DEFAULT_DATABASE=[master]
GO


USE MyDATABASE
GO
CREATE USER [MyLogin] FOR LOGIN [MyLogin]
GO
ALTER ROLE [db_datareader] ADD MEMBER [MyLogin]
GO
