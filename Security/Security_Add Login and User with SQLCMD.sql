/*
Add Login
Add DB Users

Steps:
* un-comment
* adjust :connect
* set SQLCMD 
* run
* validate

Notes:
* database User gets added to the users, but that perm doesn't appear when viewinng the Login. 
It does appear when viewing the User.


*/

-- :connect (server name)
-- :connect ....


--CREATE ROLE db_executor
-- -- Grant execute rights to the new role
--GRANT EXECUTE TO db_executor


--USE [master]
--GO
-- CREATE LOGIN MyLogin WITH PASSWORD=N'LK***d', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=ON, CHECK_POLICY=ON
--GO


--USE PowerPick
--GO
--CREATE USER MyLogin FOR LOGIN MyLogin
--GO
--ALTER ROLE [db_datareader] ADD MEMBER [NW\MyGroup]
--GO

--ALTER ROLE [db_datawriter] ADD MEMBER [NW\MyGroup]
--GO

--ALTER ROLE [db_executor] ADD MEMBER [NW\MyGroup]
--GO

