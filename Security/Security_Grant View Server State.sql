-- Grant View Server State
-- https://support.microsoft.com/en-us/help/938602/how-to-grant-the-view-server-state-permission-in-microsoft-forecaster
-- 4/19/2019

:CONNECT SQL-S-16T101P 
use [master]
GO
GRANT VIEW SERVER STATE TO [NW\ny700a]
GO

:CONNECT SQL-S-16P301P 
use [master]
GO
GRANT VIEW SERVER STATE TO [NW\ny700a]
GO

:CONNECT SQL-S-16T101P 
use [master]
GO
GRANT VIEW SERVER STATE TO [NW\ny700a]
GO

:CONNECT SQL-S-16T301P 
use [master]
GO
GRANT VIEW SERVER STATE TO [NW\ny700a]
GO

:CONNECT SQL-S-16T301P 
use [master]
GO
GRANT VIEW SERVER STATE TO [NW\ny700a]
GO


:CONNECT SQL-S-16D301P 
use [master]
GO
GRANT VIEW SERVER STATE TO [NW\ny700a]
GO
