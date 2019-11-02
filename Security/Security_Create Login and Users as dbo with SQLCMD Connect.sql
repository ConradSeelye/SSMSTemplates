
-- Use SQLCMD mode

:CONNECT MyServer1

USE [master]
GO
CREATE LOGIN MyLogin FROM WINDOWS WITH DEFAULT_DATABASE=[master]
GO
USE MyDatabase
GO
CREATE USER MyLogin FOR LOGIN MyLogin
GO
USE MyDatabase
GO
ALTER ROLE [db_owner] ADD MEMBER MyLogin
GO

:CONNECT MyServer2

USE [master]
GO
CREATE LOGIN MyLogin FROM WINDOWS WITH DEFAULT_DATABASE=[master]
GO
USE MyDatabase
GO
CREATE USER MyLogin FOR LOGIN MyLogin
GO
USE MyDatabase
GO
ALTER ROLE [db_owner] ADD MEMBER MyLogin
GO



:CONNECT MyServer3

USE [master]
GO
CREATE LOGIN MyLogin FROM WINDOWS WITH DEFAULT_DATABASE=[master]
GO
USE MyDatabase
GO
CREATE USER MyLogin FOR LOGIN MyLogin
GO
USE MyDatabase
GO
ALTER ROLE [db_owner] ADD MEMBER MyLogin
GO



:CONNECT MyServer4

USE [master]
GO
CREATE LOGIN MyLogin FROM WINDOWS WITH DEFAULT_DATABASE=[master]
GO
USE MyDatabase
GO
CREATE USER MyLogin FOR LOGIN MyLogin
GO
USE MyDatabase
GO
ALTER ROLE [db_owner] ADD MEMBER MyLogin
GO

:CONNECT MyServer5
USE MyDatabase
GO

CREATE USER MyLogin FOR LOGIN MyLogin
GO

ALTER ROLE [db_owner] ADD MEMBER MyLogin
GO

USE MyDatabase
GO
ALTER ROLE [db_owner] ADD MEMBER MyLogin
GO





