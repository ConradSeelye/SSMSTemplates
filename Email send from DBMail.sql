
EXEC msdb.dbo.sp_send_dbmail 
@profile_name = 'DBMail', 
@recipients = 'conrad.b.seelye@boeing.com', 
@body = 'test 1', 
@subject = 'test 1'