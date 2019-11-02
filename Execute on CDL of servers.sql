/*
This script will create a TSQL script that you can run separately in SQLCMD mode. 

Steps:
1. Edit @Servers with a comma delimted list of your servers.
2. Edit @SearchVariable1 and @SearchVariable2 with the search variables. 
	If you want to search for only 1 string, then make both variables that string.
	For example 'kanjana', which is part of the name of the DBA who had this set of servers before me. 
	You can add more SearchVariableN variables. Edit the dynamic SQL statement. 
3.  Edit the dynamic SQL to do whatever you need.
4. Copy and paste the result into a new window, specify Query | SQLCMD mode, and execute.
	Remove any non-TSQL lines, such as '(1 row affected)'
5. If logical, you can re-run the script to check the results.

	
*/

USE MSDB
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'SplitString')
	AND xtype IN (N'TF'))
DROP FUNCTION SplitString
-- SELECT * FROM sysobjects WHERE id = object_id(N'SplitString')
GO

CREATE FUNCTION [dbo].[SplitString]
(      
      @Input NVARCHAR(MAX),  
      @Character CHAR(1)=','  
)  
RETURNS @Output TABLE (  
      Item NVARCHAR(1000)  
)  
AS  
BEGIN  
      DECLARE @StartIndex INT, @EndIndex INT  
   
      SET @StartIndex = 1  
      IF SUBSTRING(@Input, LEN(@Input) - 1, LEN(@Input)) <> @Character  
      BEGIN  
            SET @Input = @Input + @Character  
      END  
   
      WHILE CHARINDEX(@Character, @Input) > 0  
      BEGIN  
            SET @EndIndex = CHARINDEX(@Character, @Input)  
             
            INSERT INTO @Output(Item)  
            SELECT SUBSTRING(@Input, @StartIndex, @EndIndex - 1)  
             
            SET @Input = SUBSTRING(@Input, @EndIndex + 1, LEN(@Input))  
      END  
   
      RETURN  
END
GO


-- User configuration variables:
DECLARE @Servers VARCHAR(MAX) = ''

-- ************ Edit these variables:
SET @Servers = @Servers +
	'SQL-D-16P3125,AG-Airplane,SQL-D-16P3125,AG-Bit,SQL-D-16P3125,AG-CheckInRecords,SQL-D-16P3125,AG-Loto'
	-- 'SQL-D-16P1137,AG-Airplane,SQL-D-16P1137,AG-Bit,SQL-D-16P1137,AG-CheckInRecords,SQL-D-16P1137,AG-Loto'  
	-- 'SQL-D-16P3125,AG-Airplane,SQL-D-16P1132,AG-D-16P1132' 
	-- 'SQL-D-16P1137,AG-Airplane,SQL-D-16P1133,AG-D-16P1132' 


-- ************ 

-- other variables:
DECLARE @ThisServer VARCHAR(100)
DECLARE @ThisL VARCHAR(100)
DECLARE @SQL VARCHAR(MAX) = ''
DECLARE @B CHAR(2) = CHAR(13) + CHAR(10) 


DECLARE MyCursor CURSOR
	FOR SELECT * FROM dbo.SplitString(@Servers,',')
OPEN MyCursor 

FETCH NEXT FROM MyCursor INTO @ThisServer
FETCH NEXT FROM MyCursor INTO @ThisL

WHILE @@FETCH_STATUS = 0
BEGIN
	-- PRINT @ThisServer
	SET @SQL = @SQL + ':CONNECT ' + @ThisServer + @B
	SET @SQL = @SQL + 'ALTER AVAILABILITY GROUP [' + @ThisL + '] FAILOVER;'
	SET @SQL = @SQL + @B + 'GO' + @B + @B

	FETCH NEXT FROM MyCursor INTO @ThisServer
	FETCH NEXT FROM MyCursor INTO @ThisL
END

PRINT @SQL

CLOSE MyCursor
DEALLOCATE MyCursor



IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'SplitString')
	AND xtype IN (N'TF'))
DROP FUNCTION SplitString




/*
-- Create this function before running the script above:


CREATE FUNCTION [dbo].[SplitString]
(      
      @Input NVARCHAR(MAX),  
      @Character CHAR(1)=','  
)  
RETURNS @Output TABLE (  
      Item NVARCHAR(1000)  
)  
AS  
BEGIN  
      DECLARE @StartIndex INT, @EndIndex INT  
   
      SET @StartIndex = 1  
      IF SUBSTRING(@Input, LEN(@Input) - 1, LEN(@Input)) <> @Character  
      BEGIN  
            SET @Input = @Input + @Character  
      END  
   
      WHILE CHARINDEX(@Character, @Input) > 0  
      BEGIN  
            SET @EndIndex = CHARINDEX(@Character, @Input)  
             
            INSERT INTO @Output(Item)  
            SELECT SUBSTRING(@Input, @StartIndex, @EndIndex - 1)  
             
            SET @Input = SUBSTRING(@Input, @EndIndex + 1, LEN(@Input))  
      END  
   
      RETURN  
END

*/