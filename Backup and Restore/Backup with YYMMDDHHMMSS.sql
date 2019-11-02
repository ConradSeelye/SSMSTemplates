

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[DBBackup_YYMMDDHHMMSS]
AS
--Script 1: Backup specific database

-- 1. Variable declaration

DECLARE @path VARCHAR(500)
DECLARE @name VARCHAR(500)
DECLARE @pathwithname VARCHAR(500)
DECLARE @time DATETIME
DECLARE @year VARCHAR(4)
DECLARE @month VARCHAR(2)
DECLARE @day VARCHAR(2)
DECLARE @hour VARCHAR(2)
DECLARE @minute VARCHAR(2)
DECLARE @second VARCHAR(2)

-- 2. Setting the backup path

SET @path = 'C:\MyBackups\'

-- 3. Getting the time values

SELECT @time   = GETDATE()
SELECT @year   = (SELECT CONVERT(VARCHAR(4), DATEPART(yy, @time)))
SELECT @month  = (SELECT CONVERT(VARCHAR(2), FORMAT(DATEPART(mm,@time),'00')))
SELECT @day    = (SELECT CONVERT(VARCHAR(2), FORMAT(DATEPART(dd,@time),'00')))
SELECT @hour   = (SELECT CONVERT(VARCHAR(2), FORMAT(DATEPART(hh,@time),'00')))
SELECT @minute = (SELECT CONVERT(VARCHAR(2), FORMAT(DATEPART(mi,@time),'00')))
SELECT @second = (SELECT CONVERT(VARCHAR(2), FORMAT(DATEPART(ss,@time),'00')))

-- 4. Defining the filename format

SELECT @name ='MyDatabase' + @year + @month + @day + @hour + @minute + @second

SET @pathwithname = @path + @namE + '.bak'

--5. Executing the backup command

BACKUP DATABASE MyDatabase 
TO DISK = @pathwithname WITH COMPRESSION,NOFORMAT, INIT, SKIP, NOREWIND, NOUNLOAD, STATS = 10
GO


