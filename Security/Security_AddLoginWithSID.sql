
-- On server 1
CREATE LOGIN MyLogin WITH  PASSWORD=N'MyPassword'

SELECT name, sid FROM dbo.syslogins WHERE name IN ('MyLogin','a')

-- On server 2
CREATE LOGIN MyLogin
WITH  PASSWORD=N'MyPassword', 
sid = SIDFrom syslogins

