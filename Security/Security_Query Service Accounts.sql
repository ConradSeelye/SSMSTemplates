
/*
Query the SQL service accounts
source: https://www.sqlservercentral.com/Forums/Topic354182-8-1.aspx
dat: 1/29/2019

*/


SET NOCOUNT ON
DECLARE @SQLService     VARCHAR(60)
DECLARE @AgentService     VARCHAR(60)
EXEC xp_regread @root_key     = 'HKEY_LOCAL_MACHINE',
         @key         = 'SYSTEM\ControlSet001\Services\MSSQLServer',
         @valuename     = 'ObjectName',
         @value      = @SQLService output

EXEC xp_regread @root_key     = 'HKEY_LOCAL_MACHINE',
      @key         = 'SYSTEM\ControlSet001\Services\SQLSERVERAGENT',
         @valuename     = 'ObjectName',
         @value      = @AgentService output
SELECT 
    @SQLService                             AS 'SQL Service Account',
     @AgentService                             AS 'SQL Agent Account',
    (SELECT TOP 1 phyname FROM master..sysdevices WHERE phyname LIKE '\\%') AS 'Backup Device'

