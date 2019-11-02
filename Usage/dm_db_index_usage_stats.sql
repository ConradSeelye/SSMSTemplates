USE MyDatabase
GO

SELECT����[TableName] = OBJECT_NAME(object_id),
last_user_update, last_user_seek, last_user_scan, last_user_lookup
FROM����sys.dm_db_index_usage_stats
WHERE����database_id = DB_ID('MyDatabase')
	AND��������OBJECT_NAME(object_id) =�'TransactionHistoryArchive'
GO 
