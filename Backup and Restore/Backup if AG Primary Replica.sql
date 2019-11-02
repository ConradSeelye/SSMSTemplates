
IF sys.fn_hadr_is_primary_replica ('PowerPick') = 1
BEGIN
	Exec USP_IMDB_Backup_Full [PowerPick], 5
END


IF sys.fn_hadr_is_primary_replica ('PowerPick') = 1
BEGIN
	Exec USP_IMDB_Backup_TranLog [PowerPick], 5
END


IF sys.fn_hadr_is_primary_replica ('TestAG') = 1
BEGIN
	SELECT 'YES'
END


select SERVERPROPERTY('IsHadrEnabled')


/*

source: https://www.c-sharpcorner.com/blogs/sql-server-check-always-on-availability-groups-is-enabled-or-disabled
date: 5/9/2019

*/
:CONNECT SQL-D-16P1092
SELECT DISTINCT
dbcs.database_name AS [DatabaseName]
FROM master.sys.availability_groups AS AG
LEFT OUTER JOIN master.sys.dm_hadr_availability_group_states as agstates
   ON AG.group_id = agstates.group_id
INNER JOIN master.sys.availability_replicas AS AR
   ON AG.group_id = AR.group_id
INNER JOIN master.sys.dm_hadr_availability_replica_states AS arstates
   ON AR.replica_id = arstates.replica_id AND arstates.is_local = 1
INNER JOIN master.sys.dm_hadr_database_replica_cluster_states AS dbcs
   ON arstates.replica_id = dbcs.replica_id
LEFT OUTER JOIN master.sys.dm_hadr_database_replica_states AS dbrs
   ON dbcs.replica_id = dbrs.replica_id AND dbcs.group_database_id = dbrs.group_database_id
WHERE ISNULL(arstates.role, 3) = 2 AND ISNULL(dbcs.is_database_joined, 0) = 1
ORDER BY  dbcs.database_name
