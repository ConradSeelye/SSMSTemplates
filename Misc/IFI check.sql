/*
Check for IFI status
source: https://www.sqlskills.com/blogs/paul/how-to-tell-if-you-have-instant-initialization-enabled/
date: 4/22/2019

*/

USE master
GO
EXEC sp_configure 'show advanced options', 1
GO
RECONFIGURE WITH OVERRIDE;
GO
EXEC sp_configure 'xp_cmdshell', 1;
GO
RECONFIGURE WITH OVERRIDE;
GO

CREATE TABLE #xp_cmdshell_output (Output VARCHAR (8000));
GO

INSERT INTO #xp_cmdshell_output EXEC ('xp_cmdshell ''whoami /priv''');
GO

IF EXISTS (SELECT * FROM #xp_cmdshell_output WHERE Output LIKE '%SeManageVolumePrivilege%')
PRINT 'Instant Initialization enabled'
ELSE
PRINT 'Instant Initialization disabled';
GO

DROP TABLE #xp_cmdshell_output;
GO

EXEC sp_configure 'xp_cmdshell', 0;
GO
RECONFIGURE WITH OVERRIDE;
GO
EXEC sp_configure 'show advanced options', 0
GO
RECONFIGURE WITH OVERRIDE;
GO

