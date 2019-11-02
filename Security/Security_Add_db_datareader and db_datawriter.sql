
USE MyDatabase
GO

CREATE USER [MyLogin] FOR LOGIN [MyLogin]
GO

ALTER ROLE [db_datareader] ADD MEMBER [MyLogin]
GO

ALTER ROLE [db_datawriter] ADD MEMBER [MyLogin]
GO


