


DECLARE @MyDatabases NVARCHAR(MAX) = 'BLIS62,BLIS63,BLIS66,BLIS67,BLIS68,BLIS70,BLIS71,BLIS72,BLIS75,BLIS78,BLIS79'; -- Comma-delimited list of database names
DECLARE @MyDateTime NVARCHAR(14) = '20250129154908'; -- Timestamp for backup file names
DECLARE @RestorePath NVARCHAR(255) = 'S:\_restore'; -- Path to the backup files
DECLARE @GeneratedSQL NVARCHAR(MAX) = '';
DECLARE @DatabaseName NVARCHAR(128);

-- Split the comma-delimited list into individual database names
DECLARE @Databases TABLE (DatabaseName NVARCHAR(128));
INSERT INTO @Databases (DatabaseName)
SELECT LTRIM(RTRIM(value))
FROM STRING_SPLIT(@MyDatabases, ',');

-- Generate RESTORE DATABASE statements
SELECT @GeneratedSQL = @GeneratedSQL + 
    'RESTORE DATABASE [' + DatabaseName + '] FROM DISK = N''' + 
    @RestorePath + '\' + DatabaseName + @MyDateTime + '.Bak'' WITH FILE = 1, NOUNLOAD, REPLACE, STATS = 5;' + CHAR(13) + CHAR(10)
FROM @Databases;

-- Output the generated SQL
PRINT @GeneratedSQL;

-- Optionally, execute the generated SQL (uncomment to enable execution)
-- EXEC sp_executesql @GeneratedSQL;



