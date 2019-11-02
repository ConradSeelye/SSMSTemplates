

:CONNECT SQL-D-16P3082

--USE [msdb]
--GO
--/****** Object:  Operator [App DBA]    Script Date: 2/12/2019 2:40:16 PM ******/
--EXEC msdb.dbo.sp_add_operator @name=N'App DBA', 
--		@enabled=1, 
--		@weekday_pager_start_time=90000, 
--		@weekday_pager_end_time=180000, 
--		@saturday_pager_start_time=90000, 
--		@saturday_pager_end_time=180000, 
--		@sunday_pager_start_time=90000, 
--		@sunday_pager_end_time=180000, 
--		@pager_days=0, 
--		@email_address=N'conrad.b.seelye@boeing.com; 4253011157@txt.att.net; 8055919118@text.republicwireless.com', 
--		@category_name=N'[Uncategorized]'
--GO

USE [msdb]
GO

/****** Object:  Operator [PowerPickGlobalITSupport]    Script Date: 2/12/2019 4:02:58 PM ******/
EXEC msdb.dbo.sp_add_operator @name=N'PowerPickGlobalITSupport', 
		@enabled=1, 
		@weekday_pager_start_time=90000, 
		@weekday_pager_end_time=180000, 
		@saturday_pager_start_time=90000, 
		@saturday_pager_end_time=180000, 
		@sunday_pager_start_time=90000, 
		@sunday_pager_end_time=180000, 
		@pager_days=0, 
		@email_address=N'5868020887@txt.att.net', 
		@category_name=N'[Uncategorized]'
GO



USE [msdb]
GO
/****** Object:  Alert [AG Failover]    Script Date: 2/12/2019 2:40:30 PM ******/
EXEC msdb.dbo.sp_add_alert @name=N'AG Failover', 
		@message_id=41075, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1, 
		@notification_message=N'AG Failover', 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

USE [msdb]
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'AG Failover', @operator_name=N'App DBA', @notification_method = 1
GO

EXEC msdb.dbo.sp_add_notification @alert_name=N'AG Failover', @operator_name=N'PowerPickGlobalITSupport', @notification_method = 1
GO



