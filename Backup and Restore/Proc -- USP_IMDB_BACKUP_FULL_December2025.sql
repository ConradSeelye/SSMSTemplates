USE [SQL_IMDB]
GO
/****** Object:  StoredProcedure [dbo].[USP_IMDB_BACKUP_FULL]    Script Date: 8/27/2026 3:57:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [dbo].[USP_IMDB_BACKUP_FULL]  (@DBNAME SYSNAME, @Retention INT = 2,@DBSIZELIMIT NUMERIC(20,5)=5.0,@FILECOUNT TINYINT=1,
@MAXTSIZE INT=2097152,@mailid varchar(5000) = 'dposqlserversupp@boeing.com',@multidrive tinyint=0,
@sendmail tinyint=1)  
AS  
BEGIN 
SET NOCOUNT ON 
SET ANSI_WARNINGS OFF

/* 

Version-202204
--------------------------------------------------------------------------------------------------------------------------------------------------
|The stored procedure has the below parameters 
|	@DBNAME - Database name for the backup
|	@Retention - Backup file retention in days. Default is 2
|	
|	------ Below parameters were added in version 032020 ------------------------
|	@DBSIZELIMIT Database used size limit to take striped backup. Default is 5.0. ***(GB)***
|		If the used size is > this value then it takes striped backup. 
|		If the backup runs on secondary replica then it takes the database total size. Value is in GB.
|		If the multi-drive parameter value is 1, then stripe backup will take to multiple drives provided all drive details there in the IMDB_Backupdrive table  ***(Huh?)***		
|		If filecount parameter provided is > 1, then then it use filecount value to set the number of files. 	
|		Example: if filecount value is 4 then it will stripe to 4.  	
|		
|	@FILECOUNT- number of striped file. Default is 1. valid values 1,2,4,8
|	@MAXTSIZE - maxtransfer size in bytes. Default is 2097152 
|	Valid values are 
|		65536   for 64 K
|		1048576  for 1 MB 
|		2097152  for 2 MB
|		4194304  for  4 MB
|	@multidrive - whether stripe backup needs to take to multiple drive. Default is 0. Valid valued 0 and 1.   
|		When the value is 1 it then look for the presence of IMDB_Backupdrive table and its
records in the database where script resides and use the result set to get backup drive details  
|	@mailid - mail id to send the skip message. Default is 'dposqlserversupp@boeing.com'. 
|             The code will also check job operator and send mail to email id of the operator.
|	
|Functionalities
|	Create backup path if it does not exist
|	Delete the backup files older than the retention period. Default is 2 days
|	Execute the backup
|
|	----------------- Below functionalities added in the version 032020-------------------
|       varaible @cmd data type changed to varchar
|	If the database is tempdb, then cancel the execution and disable the job
|	Fail the execution if the DB does not exist
|	Check the DB state and cancel the execution, if the state is below
|		RESTORING,RECOVERING,COPYING,OFFLINE_SECONDARY(AZURE GEO)
|	Check the DB state and cancel the execution and send email with reason to @mailid and operator address, if the state is below
|		RECOVERY_PENDING,SUSPECT,EMERGENCY,OFFLINE and NOT in MULTIUSER ACCESS
|	Check for any active database manipulation operation - if yes, then cancel the execution
|	Check the database mirror role - if mirror, cancel the execution
|	If SQL Server 2012 or newer, then check for Availability group role - if secondary, then cancel the execution
|	If SQL Server 2016 or newer, then check for Distributed Availability group role - if secondary, then cancel the execution
|	Take striped backup if the database used size is greater than @DBSIZELIMIT. The default value is 5 GB.
|		If the backup runs on secondary replica, then use database total size.
|		If filecount parameter provided is > 1 ,then use filecount value to set the number of files. 
|			Example if filecount value is 4 then it will stripe to 4 files.
|			If the filecount parameter value is = 1, then the file count calculation below:
|				<=100GB               1 file 
|				> 100GB and <= 200GB  2 files
|				> 200GB and <= 400GB  3 files
|				> 400GB               4 files
|		Option to take the striped backup to multiple drives if the @multidrive parameter value = 1
|			In order to take multiple drive backup, it then required backup drive records in IMDB_BACKUPDRIVE table.   
|			If IMDB_BACKUPDRIVE not available or record not available in the table, then it take single drive striped backup using the backup drive details from loadparms table  
|
|	----------------- Below functionalities Changed/added in the version 122020-------------------
|	For the striped backup(both single or mult drive),If the filecount parameter value is = 1, then the file count calculation chnaged as below: 
|
|				<=5GB               1 file 
|				> 5GB and <= 10GB  2 files
|				> 10GB and <=50GB  4 files
|				> 50GB               8 files	
|	If the @mailid paramater value is dposqlserversupp@boeing.com then check the associated Login has access to the instance. If login exist 
|	then add the mail id to the emeil recipient.
|	EXAMPLES
|	-- execute with default values
|		exec USP_IMDB_BACKUP_FULL @dbname='TEST'  
|	-- take striped backup with 4 files when the db used size is >5 GB
|		exec USP_IMDB_BACKUP_FULL @dbname='TEST',@DBSIZELIMIT=5.0,@FILECOUNT=2
|	-- take striped backup with 4 files when the db used size is >10 GB and with max transfer size 1MB
|		exec USP_IMDB_BACKUP_FULL @dbname='TEST',@DBSIZELIMIT=20.0,@FILECOUNT=4 ,@MAXTSIZE=1048576 
|	-- multi drive backup
|		exec USP_IMDB_BACKUP_FULL  @dbname='TEST',@DBSIZELIMIT=1.0,@FILECOUNT=4,@multidrive=1 
----------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
  
DECLARE @Now CHAR(14)      -- current date in the form of yyyymmddhhmmss  
DECLARE @cmd varchar(800)       -- stores the dynamically created DOS command  
DECLARE @Result INT        -- stores the result of the dir DOS command  
DECLARE @RowCnt INT        -- stores @@ROWCOUNT  
DECLARE @desc VARCHAR(200) -- stores the description of the backup  
--------- stores the path and file name of the bkp file---------------------------
DECLARE @file_path VARCHAR(500),@filename VARCHAR(8000)
DECLARE @Path VARCHAR(200)   
DECLARE @db4Path varchar(200)
------------------------------------------- 
DECLARE @n int=1,@bkpdrivecount int=0,@dn int=1,@file_string VARCHAR(MAX)='' 
-------- Stores jobname, mail send flag and mail subject & body and print message -------------
DECLARE  @ToEmail varchar(5000),@Jobname varchar(5000), @Timestamp char(100) ,@pg varchar(max),@opname varchar(255)
DECLARE @jobid varchar(max),@mailflag CHAR(1),@subject varchar(5000)
DECLARE @mailbody varchar(5000),@print1 varchar(5000)
------------------------------------------------------------------------
DECLARE @proceedbkp CHAR(1) -- used for backup proceed condition set
DECLARE @filelen int -- get backup file length
DECLARE @dbstatedesc varchar(30),@dbstate tinyint -- Store DB state
DECLARE @lastlsn numeric(25,0) -- store last lsn 
DECLARE @RECOVERY_MODEL varchar(30)-- Recovery model of database
DECLARE @dbsize NUMERIC(20,0) -- store DB used size
DECLARE @useraccess tinyint,@access_desc varchar(50),@version int; -- store db access, instance version info
DECLARE @dbid int,@islocal int,@synchealth tinyint,@role tinyint,@syncstate tinyint --store AG detail
DECLARE @msynchealth tinyint,@mrole tinyint,@agdagrole tinyint,@agname varchar(256) --store AG detail
DECLARE @execsql varchar(1000) ,@sqlcmd Nvarchar(1000) -- construct dynamic sql command
-- store restore status if the db in restoring stage and restore commdn running
DECLARE @restore_Count int,@ETA NUMERIC(10,2),@percent_complete NUMERIC(5,2),@WaitForTime varchar(8) 
DECLARE @iscopyonly tinyint
--------------------------------------------------------------------

--Set the default values
SET @proceedbkp='Y'
SET @ToEmail=''
SET @mailflag='N'
SET @mailbody=''
SET @iscopyonly=0
SET @opname='';

--- Get the SPID of the procedure execution --------------------
select @pg=program_name from master..sysprocesses where spid=@@spid


---------------------------------------------Get Job Id -----------------------------------------------------------
IF  @pg NOT like '%SQLAGENT%' 
              SET @ToEmail = NULL
ELSE
BEGIN

	select @jobId = j.job_id
	from master..sysprocesses s (nolock)   
	join msdb..sysjobs j (nolock)  
	on (j.job_id = SUBSTRING(s.program_name,38,2) + SUBSTRING(s.program_name,36,2) + SUBSTRING(s.program_name,34,2) + SUBSTRING(s.program_name,32,2) + '-' + SUBSTRING(s.program_name,42,2) + SUBSTRING		(s.program_name,40,2) + '-' + SUBSTRING(s.program_name,46,2) + SUBSTRING(s.program_name,44,2) + '-' + SUBSTRING(s.program_name,48,4) + '-' + SUBSTRING(s.program_name,52,12) )
	where s.spid = @@spid  ;

	---------------------------------------------Get Job Name-----------------------------------------------------------

	IF(@jobId IS NULL)
	BEGIN
		SET @jobname='Not a job. Manual Backup Execution'
	END
	ELSE
	BEGIN
		select @Jobname= name from msdb.dbo.sysjobs_view  where job_id=@jobid;
				
	END
---------------------------------------------Get mail addreess of operator -----------------------------------------------------------
            
	select @opname=o.name,@ToEmail=o.email_address from msdb.dbo.sysjobs_view j join msdb.dbo.sysoperators o  
	on j.notify_email_operator_id = o.id where j.job_id=@jobid and  j.enabled = 1
	and j.notify_email_operator_id <> 0;
	
END -- end of sqlagent process check

-------Set Email address if job operator has no email address AND add mail id in the @mailid param------------------------------------		     
			  
IF (@ToEmail IS NULL or @ToEmail='')
BEGIN 
	SET @ToEmail = @mailid
END
ELSE IF (@Toemail Not LIKE '%'+@mailid+'%')
BEGIN
	IF(@mailid='dposqlserversupp@boeing.com')
	BEGIN
		IF EXISTS(select name from sys.server_principals where upper(name)='NOS\ITI-ADM-DPO-SQL SERVER TEAM')
		BEGIN
			SET @ToEmail = @ToEmail+';'+@mailid
		END
		END
	ELSE
	BEGIN
		SET @ToEmail = @ToEmail+';'+@mailid
	END
END


---------------------------------------------Get CURRENT_TIMESTAMP -----------------------------------------------------------

	select @Timestamp = CURRENT_TIMESTAMP  
			 

--------------------------------------------SET Initial details for Email--------------------------------------
Set @mailbody='<b><u>SQL Backup Execution Notification</u></b><br>'
Set @mailbody=@mailbody + '<br>You have been identified as a member of the support staff to be notified for the database listed below. '
set @mailbody=@mailbody+'The execution of the BACKUP for the below job was cancelled to avoid job failure. <br><br> <B> Details:</B>'
set @mailbody=@mailbody + '<br><br>Server	:  '+@@SERVERNAME +'<br>Database	:  '+@DBNAME+'<br>SQL Job	: '+ @Jobname
select @subject = 'ATTENTION - '+@@SERVERNAME + ' - FULL BACKUP execution cancelled for database ['+@DBNAME+'] '

-------------------------------------------- Get always on data-------------------------------------------------------

select @version=cast(serverproperty('ProductVersion')as varchar(2))

SELECT @dbid=DB_ID(@DBNAME)
print 'db id: ' +convert(varchar(3),@dbid)+CHAR(13)

if(@dbid=2)
BEGIN
	IF(@jobId IS NULL)
	BEGIN
		Print 'Skip the backup execution, since the database is tempdb'
		return 1;
	END
	ELSE
	BEGIN
		Print 'Disabling the job, since the database tempdb does not require backup'
		exec msdb.dbo.sp_update_job @job_id=@jobid,@enabled=0
	END
END

-------------- Check the database existence. If not exist failed the job -----------------------------
IF not exists(select name from sys.databases where database_id=@dbid)
BEGIN
	RAISERROR('The database [%s] does not exist. Make sure that the name is entered correctly',16,1,@DBNAME)
	return 1;
END

-----------------------------------------------Validating the database states and take action--------------------------------------------------------
-- get the database state and get the recovery model	
	SELECT @dbstatedesc=upper(state_desc),@dbstate=[state],@useraccess=user_access,
	@access_desc=user_access_desc from sys.databases where database_id=@dbid 
	
	----------- Validate the user access mode--------------------
	IF @useraccess>0
	BEGIN
		SET @proceedbkp='N'
		SET @print1='The execution of FULL BACKUP cancelled due to database ['+@DBNAME+'] being in '+@access_desc+' mode.' +CHAR(13)
		SET @print1=@print1+'If this is not intended, investigate further.'		
		SET @mailflag='N'
		print @print1
		
		
	END --end of useraccess check
	-----------------------------------------------Validating the STATE of database--------------------------------------------------------
	ELSE IF @dbstate IN(1,2,7,10)  -- RESTORING,RECOVERING,COPYING,OFFLINE_SECONDARY(AZURE GEO)
	BEGIN
	-- if the database is in these states then the backup execution will skip
		SET @proceedbkp='N'
		SET @mailflag='N'
		SET @print1='The execution of the FULL BACKUP cancelled due to database [ '+@DBNAME+']  being in '+@dbstatedesc+' state.'
		IF(@dbstate=1) -- checking for mirror status
		BEGIN
			SET @msynchealth=NULL
			SET @mrole=NULL
			select @msynchealth=mirroring_state,@mrole=mirroring_role from sys.database_mirroring where database_id=@dbid
			IF(@mrole=2) 
			begin
				SET @print1= 'The execution of the FULL BACKUP cancelled due to database [' +@DBNAME+'] is a Mirror'
			end
		END -- end of mirror status check
		print @print1		
	
	END -- end of check for DB state for restoring,recovering and copying
	ELSE IF(@dbstate IN(3,4,5,6))    -- RECOVERY_PENDING,SUSPECT,EMERGENCY,OFFLINE
	BEGIN
	-- If the database is in these states then the backup execution will skip and send an email to the operator email address & DPO team
		SET @proceedbkp='N'
		SET @mailflag='Y'
		set @mailbody=@mailbody + '<br>Reason	: State of the database is '+@dbstatedesc+'<br>Time		: '+@Timestamp+'<br><br><b>Suggested Fix:</b>'
		set @mailbody=@mailbody +'<br><br>If this is intended, disable the job to avoid receiving job failure alerts. Otherwise take steps to resolve this issue.'
		SET @print1='The execution of the FULL BACKUP was cancelled due to database ['+@DBNAME+'] being in '+@dbstatedesc+' state.'	
		SET @print1=@print1+CHAR(13)+'If this is intended, disable the job to avoid receiving job failure alerts. Otherwise take steps to resolve this issue.'
		print @print1
	
	END -- end of check for DB state recovery_pending,suspect,offline,emergency
	
--------------------------------------------- AG check ----------------------------------------------------------
	if(@proceedbkp='Y') -- proceed backup check for AG
	BEGIN
		if(@version >=11) -- version check for AG
		BEGIN
			-- create temp table to get AG data
			IF OBJECT_ID('tempdb.dbo.#agdata', 'U') IS NOT NULL 
			Begin
				Drop table #agdata
			End
			create table #agdata(databaseid int,agname varchar(50),islocal tinyint,role tinyint,synchealth tinyint,syncstate tinyint,
			dbstate tinyint, agdagrole tinyint);
			SET @sqlcmd='Insert into #agdata(databaseid,agname,islocal,role,synchealth,syncstate,dbstate) select '+convert(nvarchar(10),@dbid)+' as databaseid,ag.name,ars.is_local,
			ars.role,drs.synchronization_health,drs.synchronization_state,
			drs.database_state 	from sys.dm_hadr_availability_replica_states  ars
			join sys.dm_hadr_database_replica_states drs on ars.group_id=drs.group_id and ars.replica_id=drs.replica_id
			join sys.availability_groups_cluster agc on drs.group_id=agc.group_id 
			join sys.availability_groups ag on ars.group_id=ag.group_id and drs.group_id=ag.group_id and agc.group_id=ag.group_id
			where ars.is_local=1 and drs.is_local=1 and drs.database_id='+convert(nvarchar(10),@dbid)
		
			IF(@version >=13)
			BEGIN
				SET @sqlcmd=@sqlcmd+' and ag.is_distributed=0'
			END
			EXEC(@sqlcmd)
			select @agname=agname,@islocal=islocal,@role=role,@synchealth=synchealth,@syncstate=syncstate,@dbstate =dbstate from #agdata
	
			IF(@islocal is not null) -- Checikng that DB is Local in AG
			BEGIN
			---------------------------------------------Vaidating DB role in AG-------------------------------------------------------		
			
				IF(@role=2)  -- secondary
				begin
					-- if the database is in secondary role in the AG then the backup execution will skip
					SET @proceedbkp='N';
					SET @mailflag='N'
					SET @Print1= 'FULL Backup execution cancelled. Database ['+@DBNAME+ '] is in SECONDARY role for Availability Group ['+@agname+']'
					print @print1
				end --end of agrole and role check
				
				IF(@proceedbkp='Y') -- proceed backup check 2
				BEGIN
					-------- Get distributed ag role if the version is 2016 and greater
					IF(@version >=13) -- version check for DAG
					BEGIN
						SET @agdagrole=0
						SET @sqlcmd='Update #agdata set agdagrole=b.role from #agdata a join 
						(select ar.replica_server_name as agname,ARS.role
						from sys.dm_hadr_availability_replica_states AS ARS 
     						INNER JOIN sys.availability_replicas AS AR
								ON ARS.replica_id = AR.replica_id AND ARS.group_id = AR.group_id
     						INNER JOIN sys.availability_groups AS AG
								ON AR.group_id = Ag.group_id
						where AG.is_distributed=1 and ARS.is_local=1 and ar.replica_server_name='''+@agname+''') b
						on a.agname=b.agname'
				
						EXEC(@sqlcmd)
						select @agdagrole=agdagrole from #agdata where databaseid=@dbid
		
					END -- end of version check for DAG check
					IF OBJECT_ID('tempdb.dbo.#agdata', 'U') IS NOT NULL 
					Begin
						Drop table #agdata
					End
					
					IF(@role=1 and @agdagrole=2)
					BEGIN
						-- if the database is in secondary role in DAG then the backup execution will skip
						SET @proceedbkp='N'
						SET @mailflag='N'
						Print 'FULL Backup execution cancelled. Database ['+@DBNAME+ '] is in Distributed Availability Group for AG ['+@agname +'] '
						SET @print1=@print1+' and the database role in DAG is SECONDARY'
						print @print1
					END
				END -- end of proceed backup check 2
			END -- end of checking DB part of AG
		END -- end of version check for AG
	END -- end of proceed backup check for AG

----------------PROCEED BACKUP IF PROCEED CONDITION TRUE ---------------------
	if(@proceedbkp='Y')
	BEGIN
		----------------------------------GET USED SIZE OF DATABASE-------------------------------------------
		print 'getting db size/used size for calculating the striped file'
	
		create table #dbsize(db sysname,usedsize NUMERIC(20,2));
	
		if(@role=2)
		BEGIN
		--- collect used size data from master_file since the db is not readable
		SET @execsql='select DB_NAME(database_id),(sum(size)/128.0)/1024 size from sys.master_files where database_id='+convert(varchar(20),@dbid)+ ' group by database_id'
		print @role
		END
		ELSE
		BEGIN
		SET @execsql='USE ['+@DBNAME+'];'
		SET @execsql=@execsql+'SELECT DB_NAME() db,(SUM(CAST(FILEPROPERTY(name, ''SpaceUsed'') AS INT))/128.0)/1024  size FROM sys.database_files;'
		END
		insert into #dbsize exec(@execsql)
		select @dbsize=usedsize from #dbsize where db=@DBNAME
		drop table  #dbsize
	
--------------------------------SETTING BACKUP PATH----------------------------------------------------------------------
   print 'setting backup path'
   
 	--Remove spaces from DB name for path   
 	SELECT @db4Path = Replace(@dbname,' ','_')   
   
 	-- Get the current date using style 120, remove all dashes, spaces, and colons  
 	SELECT @Now = REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR(50), GETDATE(), 120), '-', ''), ' ', ''), ':', '')  

	-- Build the .bak path and file name 
			
	IF (@dbsize <= @DBSIZELIMIT OR @dbsize IS NULL)
	BEGIN
		 
		SET @FILECOUNT=1 
	END
	ELSE
	BEGIN
	-- Modified according to new condition---
		IF(@dbsize >5 and @dbsize <=10 and @FILECOUNT=1)
		BEGIN
			SET @FILECOUNT=2
		END
		ELSE IF(@dbsize >10 and @dbsize <=50 and @FILECOUNT=1)
		BEGIN
			SET @FILECOUNT=4
		END
		ELSE IF(@dbsize >50 and @FILECOUNT=1)
		BEGIN
			SET @FILECOUNT=8
		END
	END
	------ set the backup path for multi drive backup if chosen -------------------------
	IF(@multidrive=1)
	BEGIN
	-- IMDB_Backupdrive table contains the drive details to take multi drive backup
	-- if the table not present or table does not contain drive records then use default backup path from loadparms table 
		IF EXISTS(select name from sys.tables where name='IMDB_Backupdrive')
		BEGIN
			select @bkpdrivecount=count(*) from IMDB_Backupdrive;
			print 'getting backup drive details from IMDB_Backupdrive table'
		END
		ELSE
		BEGIN
			SET @bkpdrivecount=0
			Print 'Could not find table IMDB_Backupdrive to determine backup directory to be used for multi-drive striped backup. Using values from loadparms tables, instead.'
		END
	END
	select @file_path=backupfile from loadparms

	WHILE @n <= @FILECOUNT
	BEGIN  
		IF(@multidrive =1 and @bkpdrivecount >0)
		BEGIN 
			select @file_path=backupfile from IMDB_Backupdrive where driveno=@dn
			IF(@bkpdrivecount<@FILECOUNT and @bkpdrivecount=@dn)
			BEGIN
				SET @dn=1
			END
			ELSE
			BEGIN
				SELECT @dn = @dn + 1
			END
		END
		IF(SUBSTRING(@file_path,LEN(@file_path),1) <> '\')
		BEGIN
			SET @file_path=@file_path+'\'
		END
		if(@FILECOUNT=1)
		BEGIN
		select @filename = @file_path + @DB4Path + '\' + @DB4Path + @Now +'.Bak' 
		END
		ELSE
		BEGIN
		select @filename = @file_path + @DB4Path + '\' + @DB4Path + @Now +'_'+CONVERT(CHAR(1),@n)+'.Bak' 
		END
		set @file_string = @file_string + 'DISK = N''' + @filename + ''','
		SELECT @n = @n + 1
	END

select @filelen=(LEN(@file_string)-1);
select @file_string=SUBSTRING(@file_string,1,@filelen)

--------------------------------------------------------------------------------------------------------------------------
   	-- Build the description of the backup  
 	SELECT @desc = 'FULL COMPRESSED BACKUP OF DB ' + @DBName    
   
	-- create Backup Path
	   
	IF(@multidrive =1 and @bkpdrivecount >0)
	BEGIN
		DECLARE bpath CURSOR FOR SELECT backupfile FROM IMDB_Backupdrive
	END
	ELSE
	BEGIN
		DECLARE bpath CURSOR FOR SELECT backupfile FROM loadparms
	END
	open  bpath
	fetch bpath into @Path
	
 	while (@@fetch_status = 0) 
	BEGIN
		-- Build the dir command that will check to see if the directory exists  
		IF(SUBSTRING(@path,LEN(@Path),1) <>'\')
		BEGIN
			SET @Path=@Path+'\'
		END
 		SELECT @cmd = 'dir "' + @Path + @db4Path+'"'  
  
 		-- Run the dir command, put output of xp_cmdshell into @result  
 		EXEC @result = master.dbo.xp_cmdshell @cmd, NO_OUTPUT  
  
 		-- If the directory does not exist, we must create it  
 		IF @result <> 0  
 		BEGIN  
			-- Build the mkdir command    
  			SELECT @cmd = 'mkdir "' + @Path + @db4Path+'"'  
	
			-- Create the directory  
  			EXEC master.dbo.xp_cmdshell @cmd, NO_OUTPUT  
  
 		END  
 		-- The directory exists, so let's delete files older than two days  
 		ELSE  
 		BEGIN  
  			-- Stores the name of the file to be deleted  
  			DECLARE @WhichFile VARCHAR(1000)  
  
  			CREATE TABLE #DeleteOldFiles   (  DirInfo VARCHAR(7900)  )  
  
  			-- Build the command that will list out all of the files in a directory  
  			SELECT @cmd = 'dir "' + @Path + @db4Path + '\*.Bak" /OD'  
  
  			-- Run the dir command and put the results into a temp table  
  			INSERT INTO #DeleteOldFiles EXEC master.dbo.xp_cmdshell @cmd  
  
  			-- Delete all rows from the temp table except the ones that correspond to the files to be deleted  
  			DELETE FROM #DeleteOldFiles  
  			WHERE ISDATE(SUBSTRING(DirInfo, 1, 10)) = 0 OR DirInfo LIKE '%<DIR>%' OR SUBSTRING(DirInfo, 1, 10) >= GETDATE() - @Retention  
    
  			-- Get the file name portion of the row that corresponds to the file to be deleted  
  			SELECT TOP 1 @WhichFile = SUBSTRING(DirInfo, LEN(DirInfo) -  PATINDEX('% %', REVERSE(DirInfo)) + 2, LEN(DirInfo))   
  			FROM #DeleteOldFiles  
    
  			SET @RowCnt = @@ROWCOUNT  
    
  			-- Process the temp table until there are no more files to delete  
  			WHILE @RowCnt <> 0  
  			BEGIN  
    
   				-- Build the del command  
   				SELECT @cmd = 'del "' + @Path + @db4Path + '\' + @WhichFile + '" /Q /F'  
     
   				-- Delete the file  
   				EXEC master.dbo.xp_cmdshell @cmd, NO_OUTPUT  
     
   				-- To move to the next file, the current file name needs to be deleted from the temp table  
 				DELETE FROM #DeleteOldFiles 
				WHERE SUBSTRING(DirInfo, LEN(DirInfo) -  PATINDEX('% %', REVERSE(DirInfo)) + 2, LEN(DirInfo))  = @WhichFile  
  
   				-- Get the file name portion of the row that corresponds to the file to be deleted  
   				SELECT TOP 1 @WhichFile = SUBSTRING(DirInfo, LEN(DirInfo) -  PATINDEX('% %', REVERSE(DirInfo)) + 2, LEN(DirInfo))   
   				FROM #DeleteOldFiles  
    
   				SET @RowCnt = @@ROWCOUNT  
    
  			END  
    
  			DROP TABLE #DeleteOldFiles  
 			
 		END  
		fetch bpath into @Path
  END
  close bpath 
deallocate bpath   
 	------------------------------------------ BACKUP THE DATABASE -----------------------------------------------------------
	print @file_string
  	set @execsql = 'BACKUP DATABASE ['  + @DBNAME + '] TO ' + @file_string  + ' WITH COMPRESSION, NOFORMAT, INIT, NAME = N''' + @desc + ''', 
SKIP, NOREWIND, NOUNLOAD, STATS = 20, MAXTRANSFERSIZE='+CONVERT(NVARCHAR(8),@MAXTSIZE)
  	
  
		----------If the backup preference has kept as secondary, take COPY_ONLY backup-----------
	IF(@iscopyonly=1) 
	BEGIN
		set @execsql = @execsql+ ',COPY_ONLY' 
		print 'setting copy_only backup'
	END
	
	Declare @backup_Count int
				--- check any alter database, backup or restore command running against the current database. proceed if the count is 0
	SELECT @backup_Count=count(*) FROM sys.dm_exec_requests AS r CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) AS t
	WHERE (upper(r.command) like '%RESTORE DATABASE%' ) and 
	(UPPER(replace(t.text,'[','')) like '%RESTORE DATABASE '+@DBNAME+'%' OR UPPER(replace(t.text,'[','')) like '%RESTORE LOG '+@DBNAME+'%' or 
	UPPER(replace(t.text,'[','')) like '%ALTER DATABASE '+@DBNAME+'%' OR
	UPPER(replace(t.text,'[','')) like '%BACKUP DATABASE '+@DBNAME+'%' OR UPPER(replace(t.text,'[','')) like '%BACKUP LOG '+@DBNAME+'%')	

	if @backup_Count = 0
	Begin
		exec (@execsql)  
		SET NOCOUNT OFF  
		   
	End   
	ELSE 
	BEGIN 
	-- if the there is any database manipulation operation running then backup execution will skip
		PRINT 'The FULL backup execution cancelled for database ['+@DBName+'], since a Restore/Backup/Alter database command is currently running'
		SET @mailflag='N'
		SET @proceedbkp='N'
	END
	 
	SET NOCOUNT OFF  
	  
END
------------------------------- SEND EMAIL IF EMAIL FLAG IS TRUE ----------------------------------------------------------

	if(@ToEmail<>'' and @mailflag='Y' and @proceedbkp='N' and @sendmail=1 and @jobid IS NOT NULL)
	BEGIN
		print 'Sending mail to: '+@ToEmail;
		exec msdb..sp_send_dbmail 
		@profile_name = 'DBMail',
		@recipients =  @ToEmail, 
		@subject = @subject, 
		@body = @mailbody, 
		@body_format='HTML', 
		@execute_query_database = 'master'
	END
		
END





