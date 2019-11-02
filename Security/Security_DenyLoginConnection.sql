-- Deny connection to a server for one user.
-- Use this when someone has access via an SG, but they should not have access.
-- For example, when the app is under DFARS and the person is not a US citizen.


USE [master]
GO
CREATE LOGIN [NW\yh712d] FROM WINDOWS WITH DEFAULT_DATABASE=[master]
GO
DENY CONNECT SQL TO [NW\yh712d]
GO

USE [master]
GO
CREATE LOGIN [NW\yh712dADM01] FROM WINDOWS WITH DEFAULT_DATABASE=[master]
GO
DENY CONNECT SQL TO [NW\yh712dADM01]
GO

