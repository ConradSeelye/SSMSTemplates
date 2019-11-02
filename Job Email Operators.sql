/*
Get the list of Operators that receive an email for an Agent Job.
date: 11/12/2018

*/

SELECT j.NAME AS JobName
	, o.email_address AS OperatorEmails
	, j.notify_email_operator_id AS JobOperatorID
	, o.name AS OperatorName
FROM msdb.dbo.sysjobs j
JOIN msdb.dbo.sysoperators o
ON j.notify_email_operator_id = o.id
WHERE j.name LIKE '%SND%'


/*
SELECT * FROM msdb.dbo.sysjobs WHERE NAME LIKE '%SND2-SSIS_BDS_ELS%'
SELECT * FROM msdb.dbo.sysjobsteps
SELECT * FROM msdb.dbo.sysnotifications
SELECT * FROM msdb.dbo.sysalerts
SELECT * FROM msdb.dbo.sysjobactivity
SELECT * FROM msdb.dbo.sysoperators

SELECT * FROM msdb.dbo.sysoperators 
WHERE NAME LIKE '%SND%'
ORDER BY id 


*/




