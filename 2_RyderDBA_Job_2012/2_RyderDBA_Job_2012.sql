-- Script generated on 9/20/2007 8:21 PM
-- By: PEROTSYSTEMS\KumarM26
-- Server: (local)

BEGIN TRANSACTION            
  DECLARE @JobID BINARY(16)  
  DECLARE @ReturnCode INT    
  SELECT @ReturnCode = 0     
IF (SELECT COUNT(*) FROM msdb.dbo.syscategories WHERE name = N'[Uncategorized (Local)]') < 1 
  EXECUTE msdb.dbo.sp_add_category @name = N'[Uncategorized (Local)]'

  -- Delete the job with the same name (if it exists)
  SELECT @JobID = job_id     
  FROM   msdb.dbo.sysjobs    
  WHERE (name = N'-- RyderDBA - Stop Trace (On Demand)')       
  IF (@JobID IS NOT NULL)    
  BEGIN  
  -- Check if the job is a multi-server job  
  IF (EXISTS (SELECT  * 
              FROM    msdb.dbo.sysjobservers 
              WHERE   (job_id = @JobID) AND (server_id <> 0))) 
  BEGIN 
    -- There is, so abort the script 
    RAISERROR (N'Unable to import job ''-- RyderDBA - Stop Trace (On Demand)'' since there is already a multi-server job with this name.', 16, 1) 
    GOTO QuitWithRollback  
  END 
  ELSE 
    -- Delete the [local] job 
    EXECUTE msdb.dbo.sp_delete_job @job_name = N'-- RyderDBA - Stop Trace (On Demand)' 
    SELECT @JobID = NULL
  END 

BEGIN 

  -- Add the job
  EXECUTE @ReturnCode = msdb.dbo.sp_add_job @job_id = @JobID OUTPUT , 
  @job_name = N'-- RyderDBA - Stop Trace (On Demand)', 
  @owner_login_name = N'sa', @description = N'No description available.', @category_name = N'[Uncategorized (Local)]', @enabled = 1, @notify_level_email = 0, @notify_level_page = 0, @notify_level_netsend = 0, 
  @notify_level_eventlog = 0, @delete_level= 0
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

  -- Add the job steps
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @JobID, @step_id = 1, @step_name = N'Stop Trace', @command = N'exec DBA..usp_dba_StopTrace', @database_name = N'DBA', @server = N'', @database_user_name = N'', @subsystem = N'TSQL', @cmdexec_success_code = 0, @flags = 0, @retry_attempts = 0, @retry_interval = 0, @output_file_name = N'', @on_success_step_id = 0, @on_success_action = 1, @on_fail_step_id = 0, @on_fail_action = 3
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @JobID, @step_id = 2, @step_name = N'Failure Notification', @command = N'declare @Subject varchar(50), @Body varchar(100)

set  @Subject = ''Low - Failed - Stop Trace''
select @Body = ''Failed at '' + convert(varchar,getdate())

exec DBA..usp_dba_SendMail ''Trace'', @Subject, @Body', @database_name = N'DBA', @server = N'', @database_user_name = N'', @subsystem = N'TSQL', @cmdexec_success_code = 0, @flags = 0, @retry_attempts = 0, @retry_interval = 0, @output_file_name = N'', @on_success_step_id = 0, @on_success_action = 2, @on_fail_step_id = 0, @on_fail_action = 2
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
  EXECUTE @ReturnCode = msdb.dbo.sp_update_job @job_id = @JobID, @start_step_id = 1 

  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

  -- Add the Target Servers
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @JobID, @server_name = N'(local)' 
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

END
COMMIT TRANSACTION          
GOTO   EndSave              
QuitWithRollback:
  IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION 
EndSave: 


GO
BEGIN TRANSACTION            
  DECLARE @JobID BINARY(16)  
  DECLARE @ReturnCode INT    
  SELECT @ReturnCode = 0     
IF (SELECT COUNT(*) FROM msdb.dbo.syscategories WHERE name = N'[Uncategorized (Local)]') < 1 
  EXECUTE msdb.dbo.sp_add_category @name = N'[Uncategorized (Local)]'

  -- Delete the job with the same name (if it exists)
  SELECT @JobID = job_id     
  FROM   msdb.dbo.sysjobs    
  WHERE (name = N'-- RyderDBA - Track Blocking SPID (On Demand)')       
  IF (@JobID IS NOT NULL)    
  BEGIN  
  -- Check if the job is a multi-server job  
  IF (EXISTS (SELECT  * 
              FROM    msdb.dbo.sysjobservers 
              WHERE   (job_id = @JobID) AND (server_id <> 0))) 
  BEGIN 
    -- There is, so abort the script 
    RAISERROR (N'Unable to import job ''-- RyderDBA - Track Blocking SPID (On Demand)'' since there is already a multi-server job with this name.', 16, 1) 
    GOTO QuitWithRollback  
  END 
  ELSE 
    -- Delete the [local] job 
    EXECUTE msdb.dbo.sp_delete_job @job_name = N'-- RyderDBA - Track Blocking SPID (On Demand)' 
    SELECT @JobID = NULL
  END 

BEGIN 

  -- Add the job
  EXECUTE @ReturnCode = msdb.dbo.sp_add_job @job_id = @JobID OUTPUT , @job_name = N'-- RyderDBA - Track Blocking SPID (On Demand)', @owner_login_name = N'sa', @description = N'This is recommeded to be continuous on Server where blocking is reported very high. Hence Schedule for this should be continuous.', @category_name = N'[Uncategorized (Local)]', @enabled = 1, @notify_level_email = 0, @notify_level_page = 0, @notify_level_netsend = 0, 
  @notify_level_eventlog = 0, @delete_level= 0
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

  -- Add the job steps
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @JobID, @step_id = 1, @step_name = N'Start Tracking', @command = N'	exec DBA..usp_tbl_dba_block_main
', @database_name = N'DBA', @server = N'', @database_user_name = N'', @subsystem = N'TSQL', @cmdexec_success_code = 0, @flags = 0, @retry_attempts = 0, @retry_interval = 0, @output_file_name = N'', @on_success_step_id = 0, @on_success_action = 1, @on_fail_step_id = 0, @on_fail_action = 3
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @JobID, @step_id = 2, @step_name = N'Failure Notification', @command = N'--', @database_name = N'DBA', @server = N'', @database_user_name = N'', @subsystem = N'TSQL', @cmdexec_success_code = 0, @flags = 0, @retry_attempts = 0, @retry_interval = 0, @output_file_name = N'', @on_success_step_id = 0, @on_success_action = 2, @on_fail_step_id = 0, @on_fail_action = 2
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
  EXECUTE @ReturnCode = msdb.dbo.sp_update_job @job_id = @JobID, @start_step_id = 1 

  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

  -- Add the Target Servers
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @JobID, @server_name = N'(local)' 
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

END
COMMIT TRANSACTION          
GOTO   EndSave              
QuitWithRollback:
  IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION 
EndSave: 


GO

/****** Object:  Job [-- RyderDBA - DBCC CHECKDB (Weekly)]    Script Date: 08/28/2009 16:06:07 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]]    Script Date: 08/28/2009 16:06:07 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

--Updated, check for job, if exists, delete:
DECLARE @JobID BINARY(16)
-- Delete the job with the same name (if it exists)
  SELECT @JobID = job_id     
  FROM   msdb.dbo.sysjobs    
  WHERE (name = N'-- RyderDBA - DBCC CHECKDB (Weekly)')       
  IF (@JobID IS NOT NULL)    
  BEGIN  
  -- Check if the job is a multi-server job  
  IF (EXISTS (SELECT  * 
              FROM    msdb.dbo.sysjobservers 
              WHERE   (job_id = @JobID) AND (server_id <> 0))) 
  BEGIN 
    -- There is, so abort the script 
    RAISERROR (N'Unable to import job ''-- RyderDBA - DBCC CHECKDB (Weekly)'' since there is already a multi-server job with this name.', 16, 1) 
    GOTO QuitWithRollback  
  END 
  ELSE 
    -- Delete the [local] job 
    EXECUTE msdb.dbo.sp_delete_job @job_name = N'-- RyderDBA - DBCC CHECKDB (Weekly)' 
    SELECT @JobID = NULL
  END 

EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'-- RyderDBA - DBCC CHECKDB (Weekly)', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'DBCC CHECKDB run using setting in config table', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Start DBCC CHECKDB]    Script Date: 08/28/2009 16:06:07 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Start DBCC CHECKDB', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=3, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'-- Disable Transaction log backup
	exec msdb..sp_update_job @job_name = ''-- RyderDBA - Trans. Log Backup'',@enabled=0
	--========================

	truncate table DBA..tbl_dba_CHECKDB_Output
	insert into DBA..tbl_dba_CHECKDB_Output(OutputText) exec (''master..xp_cmdshell  ''''osql -S'' + @@ServerName + '' -E -Q"DBA..usp_tbl_dba_checkdb @check=''''''''Y'''''''', @execute=''''''''Y''''''''" -n -h-1 -w1000'''''')  
	if exists (select 1 from DBA..tbl_dba_CHECKDB_Output where OutputText like ''%Msg%,%Level%'')
	begin
		
		declare @Subject varchar(50), @Body varchar(300)

		set  @Subject = ''Reported Error - DBCC CHECKDB''
		select @Body = ''CHECKDB found error in one or more database(s)......... Run following query for detail:'' + char(13) + char(13)
		select @Body = @Body + ''select * from DBA..tbl_dba_CHECKDB_Output''
		select @Body = @Body + char(13) + char(13) + ''Note: REINDEXing Job is currently running.... Hence, please run DBCC CHECKDB again on database that reported error to find latest status''
		exec DBA..usp_dba_SendMail ''DBCC'', @Subject, @Body	
	end', 
		@database_name=N'DBA', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Run ALTERINDEX Job]    Script Date: 08/28/2009 16:06:07 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Run ALTERINDEX Job', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=4, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'msdb..sp_start_job ''-- RyderDBA - DBCC ALTERINDEX (Weekly)''', 
		@database_name=N'msdb', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Checkdb Failure Notification]    Script Date: 08/28/2009 16:06:07 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Checkdb Failure Notification', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=2, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'-- Enable Transaction log backup
	exec msdb..sp_update_job @job_name = ''-- RyderDBA - Trans. Log Backup'',@enabled=1
	--========================
	declare @Subject varchar(50), @Body varchar(100)

	set  @Subject = ''Medium - Failed - DBCC CHECKDB''
	select @Body = ''Failed at '' + convert(varchar,getdate())

	exec DBA..usp_dba_SendMail ''DBCC'', @Subject, @Body', 
		@database_name=N'DBA', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Reindex Job Failure Notification]    Script Date: 08/28/2009 16:06:08 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Reindex Job Failure Notification', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=2, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'-- Enable Transaction log backup
	exec msdb..sp_update_job @job_name = ''-- RyderDBA - Trans. Log Backup'',@enabled=1
	--========================
	declare @Subject varchar(50), @Body varchar(100)

	set  @Subject = ''Medium - Failed - To run dbcc reindex job''
	select @Body = ''Failed at '' + convert(varchar,getdate())

	exec DBA..usp_dba_SendMail ''DBCC'', @Subject, @Body', 
		@database_name=N'DBA', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:


GO
BEGIN TRANSACTION            
  DECLARE @JobID BINARY(16)  
  DECLARE @ReturnCode INT    
  SELECT @ReturnCode = 0     
IF (SELECT COUNT(*) FROM msdb.dbo.syscategories WHERE name = N'[Uncategorized (Local)]') < 1 
  EXECUTE msdb.dbo.sp_add_category @name = N'[Uncategorized (Local)]'

  -- Delete the job with the same name (if it exists)
  SELECT @JobID = job_id     
  FROM   msdb.dbo.sysjobs    
  WHERE (name = N'-- RyderDBA - Check Drive Space (@ Every 2 Hour)')       
  IF (@JobID IS NOT NULL)    
  BEGIN  
  -- Check if the job is a multi-server job  
  IF (EXISTS (SELECT  * 
              FROM    msdb.dbo.sysjobservers 
              WHERE   (job_id = @JobID) AND (server_id <> 0))) 
  BEGIN 
    -- There is, so abort the script 
    RAISERROR (N'Unable to import job ''-- RyderDBA - Check Drive Space (@ Every 2 Hour)'' since there is already a multi-server job with this name.', 16, 1) 
    GOTO QuitWithRollback  
  END 
  ELSE 
    -- Delete the [local] job 
    EXECUTE msdb.dbo.sp_delete_job @job_name = N'-- RyderDBA - Check Drive Space (@ Every 2 Hour)' 
    SELECT @JobID = NULL
  END 

BEGIN 

  -- Add the job
  EXECUTE @ReturnCode = msdb.dbo.sp_add_job @job_id = @JobID OUTPUT , 
  @job_name = N'-- RyderDBA - Check Drive Space (@ Every 2 Hour)', 
  @owner_login_name = N'sa', 
  @description = N'No description available.', 
  @category_name = N'[Uncategorized (Local)]', 
  @enabled = 1, 
  @notify_level_email = 0, 
  @notify_level_page = 0, 
  @notify_level_netsend = 0, 
  @notify_level_eventlog = 0, 
  @delete_level= 0
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

  -- Add the job steps
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @JobID, @step_id = 1, @step_name = N'Start Drive Space Check', @command = N'DBA..usp_dba_Drive_Space', @database_name = N'DBA', @server = N'', @database_user_name = N'', @subsystem = N'TSQL', @cmdexec_success_code = 0, @flags = 0, @retry_attempts = 0, @retry_interval = 0, @output_file_name = N'', @on_success_step_id = 0, @on_success_action = 1, @on_fail_step_id = 0, @on_fail_action = 3
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @JobID, @step_id = 2, @step_name = N'Failure Notification', @command = N'declare @Subject varchar(50), @Body varchar(100)

set  @Subject = ''Medium - Failed - Check Drive Space''
select @Body = ''Failed at '' + convert(varchar,getdate())

exec DBA..usp_dba_SendMail ''DiskSpace'', @Subject, @Body', @database_name = N'DBA', @server = N'', @database_user_name = N'', @subsystem = N'TSQL', @cmdexec_success_code = 0, @flags = 0, @retry_attempts = 0, @retry_interval = 0, @output_file_name = N'', @on_success_step_id = 0, @on_success_action = 2, @on_fail_step_id = 0, @on_fail_action = 2
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
  EXECUTE @ReturnCode = msdb.dbo.sp_update_job @job_id = @JobID, @start_step_id = 1 

  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

  -- Add the job schedules
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id = @JobID, @name = N'Schedule 1', @enabled = 1, @freq_type = 4, @active_start_date = 20061027, @active_start_time = 0, @freq_interval = 1, @freq_subday_type = 8, @freq_subday_interval = 2, @freq_relative_interval = 0, @freq_recurrence_factor = 0, @active_end_date = 99991231, @active_end_time = 235959
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

  -- Add the Target Servers
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @JobID, @server_name = N'(local)' 
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

END
COMMIT TRANSACTION          
GOTO   EndSave              
QuitWithRollback:
  IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION 
EndSave: 


GO
BEGIN TRANSACTION            
  DECLARE @JobID BINARY(16)  
  DECLARE @ReturnCode INT    
  SELECT @ReturnCode = 0     
IF (SELECT COUNT(*) FROM msdb.dbo.syscategories WHERE name = N'[Uncategorized (Local)]') < 1 
  EXECUTE msdb.dbo.sp_add_category @name = N'[Uncategorized (Local)]'

  -- Delete the job with the same name (if it exists)
  SELECT @JobID = job_id     
  FROM   msdb.dbo.sysjobs    
  WHERE (name = N'-- RyderDBA - Start Trace (On Demand)')       
  IF (@JobID IS NOT NULL)    
  BEGIN  
  -- Check if the job is a multi-server job  
  IF (EXISTS (SELECT  * 
              FROM    msdb.dbo.sysjobservers 
              WHERE   (job_id = @JobID) AND (server_id <> 0))) 
  BEGIN 
    -- There is, so abort the script 
    RAISERROR (N'Unable to import job ''-- RyderDBA - Start Trace (On Demand)'' since there is already a multi-server job with this name.', 16, 1) 
    GOTO QuitWithRollback  
  END 
  ELSE 
    -- Delete the [local] job 
    EXECUTE msdb.dbo.sp_delete_job @job_name = N'-- RyderDBA - Start Trace (On Demand)' 
    SELECT @JobID = NULL
  END 

BEGIN 

  -- Add the job
  EXECUTE @ReturnCode = msdb.dbo.sp_add_job @job_id = @JobID OUTPUT , @job_name = N'-- RyderDBA - Start Trace (On Demand)', 
  @owner_login_name = N'sa', @description = N'Pass parameters as shown here -  DBA..usp_dba_StartTrace ''<databasename>'', ''<file path/directory>'' , <maxfilesize>', @category_name = N'[Uncategorized (Local)]', @enabled = 1, @notify_level_email = 0, @notify_level_page = 0, @notify_level_netsend = 0, 
  @notify_level_eventlog = 0, @delete_level= 0
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

  -- Add the job steps
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @JobID, @step_id = 1, @step_name = N'Start Trace', @command = N'exec DBA..usp_dba_StartTrace', @database_name = N'DBA', @server = N'', @database_user_name = N'', @subsystem = N'TSQL', @cmdexec_success_code = 0, @flags = 0, @retry_attempts = 0, @retry_interval = 0, @output_file_name = N'', @on_success_step_id = 0, @on_success_action = 1, @on_fail_step_id = 0, @on_fail_action = 3
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @JobID, @step_id = 2, @step_name = N'Failure Notification', @command = N'declare @Subject varchar(50), @Body varchar(100)

set  @Subject = ''Low - Failed - Trace''
select @Body = ''Failed at '' + convert(varchar,getdate())

exec DBA..usp_dba_SendMail ''Trace'', @Subject, @Body', @database_name = N'DBA', @server = N'', @database_user_name = N'', @subsystem = N'TSQL', @cmdexec_success_code = 0, @flags = 0, @retry_attempts = 0, @retry_interval = 0, @output_file_name = N'', @on_success_step_id = 0, @on_success_action = 2, @on_fail_step_id = 0, @on_fail_action = 2
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
  EXECUTE @ReturnCode = msdb.dbo.sp_update_job @job_id = @JobID, @start_step_id = 1 

  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

  -- Add the Target Servers
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @JobID, @server_name = N'(local)' 
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

END
COMMIT TRANSACTION          
GOTO   EndSave              
QuitWithRollback:
  IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION 
EndSave: 


GO
BEGIN TRANSACTION            
  DECLARE @JobID BINARY(16)  
  DECLARE @ReturnCode INT    
  SELECT @ReturnCode = 0     
IF (SELECT COUNT(*) FROM msdb.dbo.syscategories WHERE name = N'[Uncategorized (Local)]') < 1 
  EXECUTE msdb.dbo.sp_add_category @name = N'[Uncategorized (Local)]'

  -- Delete the job with the same name (if it exists)
  SELECT @JobID = job_id     
  FROM   msdb.dbo.sysjobs    
  WHERE (name = N'-- RyderDBA - DBCC UPDATEUSAGE  (Weekly)')       
  IF (@JobID IS NOT NULL)    
  BEGIN  
  -- Check if the job is a multi-server job  
  IF (EXISTS (SELECT  * 
              FROM    msdb.dbo.sysjobservers 
              WHERE   (job_id = @JobID) AND (server_id <> 0))) 
  BEGIN 
    -- There is, so abort the script 
    RAISERROR (N'Unable to import job ''-- RyderDBA - DBCC UPDATEUSAGE  (Weekly)'' since there is already a multi-server job with this name.', 16, 1) 
    GOTO QuitWithRollback  
  END 
  ELSE 
    -- Delete the [local] job 
    EXECUTE msdb.dbo.sp_delete_job @job_name = N'-- RyderDBA - DBCC UPDATEUSAGE  (Weekly)' 
    SELECT @JobID = NULL
  END 

BEGIN 

  -- Add the job
  EXECUTE @ReturnCode = msdb.dbo.sp_add_job @job_id = @JobID OUTPUT , @job_name = N'-- RyderDBA - DBCC UPDATEUSAGE  (Weekly)', @owner_login_name = N'sa', @description = N'No description available.', @category_name = N'[Uncategorized (Local)]', @enabled = 1, @notify_level_email = 0, @notify_level_page = 0, @notify_level_netsend = 0, 
  @notify_level_eventlog = 2, @delete_level= 0
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

  -- Add the job steps
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @JobID, @step_id = 1, @step_name = N'Start UPDATEUSAGE', @command = N'-- Disable Transaction log backup
exec msdb..sp_update_job @job_name = ''-- RyderDBA - Trans. Log Backup'',@enabled=0

-- Start DBCC
exec DBA..usp_tbl_dba_updateusage @check=''Y'', @execute = ''Y''
', @database_name = N'DBA', @server = N'', @database_user_name = N'', @subsystem = N'TSQL', @cmdexec_success_code = 0, @flags = 0, @retry_attempts = 0, @retry_interval = 0, @output_file_name = N'', @on_success_step_id = 0, @on_success_action = 3, @on_fail_step_id = 3, @on_fail_action = 4
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @JobID, @step_id = 2, @step_name = N'Run DBCC CHECKDB Job', @command = N'msdb..sp_start_job ''-- RyderDBA - DBCC CHECKDB (Weekly)''', @database_name = N'msdb', @server = N'', @database_user_name = N'', @subsystem = N'TSQL', @cmdexec_success_code = 0, @flags = 0, @retry_attempts = 0, @retry_interval = 0, @output_file_name = N'', @on_success_step_id = 0, @on_success_action = 1, @on_fail_step_id = 4, @on_fail_action = 4
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @JobID, @step_id = 3, @step_name = N'UPDATEUSAGE Failure Notification', @command = N'-- Enable Transaction log backup
exec msdb..sp_update_job @job_name = ''-- RyderDBA - Trans. Log Backup'',@enabled=1
--========================
declare @Subject varchar(50), @Body varchar(100)

set  @Subject = ''Medium - Failed - DBCC UPDATEUSAGE''
select @Body = ''Failed at '' + convert(varchar,getdate())

exec DBA..usp_dba_SendMail ''DBCC'', @Subject, @Body', @database_name = N'DBA', @server = N'', @database_user_name = N'', @subsystem = N'TSQL', @cmdexec_success_code = 0, @flags = 0, @retry_attempts = 0, @retry_interval = 0, @output_file_name = N'', @on_success_step_id = 0, @on_success_action = 2, @on_fail_step_id = 0, @on_fail_action = 2
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @JobID, @step_id = 4, @step_name = N'CHECKDB Job Failure Notification', @command = N'-- Enable Transaction log backup
exec msdb..sp_update_job @job_name = ''-- RyderDBA - Trans. Log Backup'',@enabled=1
--========================
declare @Subject varchar(50), @Body varchar(100)

set  @Subject = ''Failed - To run CHECKDB job''
select @Body = ''Failed at '' + convert(varchar,getdate())

exec DBA..usp_dba_SendMail ''DBCC'', @Subject, @Body', @database_name = N'DBA', @server = N'', @database_user_name = N'', @subsystem = N'TSQL', @cmdexec_success_code = 0, @flags = 0, @retry_attempts = 0, @retry_interval = 0, @output_file_name = N'', @on_success_step_id = 0, @on_success_action = 2, @on_fail_step_id = 0, @on_fail_action = 2
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
  EXECUTE @ReturnCode = msdb.dbo.sp_update_job @job_id = @JobID, @start_step_id = 1 

  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

  -- Add the job schedules
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id = @JobID, @name = N'Schedule 1', @enabled = 1, @freq_type = 8, @active_start_date = 20061027, @active_start_time = 13000, @freq_interval = 64, @freq_subday_type = 1, @freq_subday_interval = 0, @freq_relative_interval = 0, @freq_recurrence_factor = 1, @active_end_date = 99991231, @active_end_time = 235959
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

  -- Add the Target Servers
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @JobID, @server_name = N'(local)' 
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

END
COMMIT TRANSACTION          
GOTO   EndSave              
QuitWithRollback:
  IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION 
EndSave: 


GO
BEGIN TRANSACTION            
  DECLARE @JobID BINARY(16)  
  DECLARE @ReturnCode INT    
  SELECT @ReturnCode = 0     
IF (SELECT COUNT(*) FROM msdb.dbo.syscategories WHERE name = N'[Uncategorized (Local)]') < 1 
  EXECUTE msdb.dbo.sp_add_category @name = N'[Uncategorized (Local)]'

  -- Delete the job with the same name (if it exists)
  SELECT @JobID = job_id     
  FROM   msdb.dbo.sysjobs    
  WHERE (name = N'-- RyderDBA - Trans. Log Backup')       
  IF (@JobID IS NOT NULL)    
  BEGIN  
  -- Check if the job is a multi-server job  
  IF (EXISTS (SELECT  * 
              FROM    msdb.dbo.sysjobservers 
              WHERE   (job_id = @JobID) AND (server_id <> 0))) 
  BEGIN 
    -- There is, so abort the script 
    RAISERROR (N'Unable to import job ''-- RyderDBA - Trans. Log Backup'' since there is already a multi-server job with this name.', 16, 1) 
    GOTO QuitWithRollback  
  END 
  ELSE 
    -- Delete the [local] job 
    EXECUTE msdb.dbo.sp_delete_job @job_name = N'-- RyderDBA - Trans. Log Backup' 
    SELECT @JobID = NULL
  END 

BEGIN 

  -- Add the job
  EXECUTE @ReturnCode = msdb.dbo.sp_add_job @job_id = @JobID OUTPUT , @job_name = N'-- RyderDBA - Trans. Log Backup', @owner_login_name = N'sa', @description = N'No description available.', @category_name = N'[Uncategorized (Local)]', @enabled = 1, @notify_level_email = 0, @notify_level_page = 0, @notify_level_netsend = 0, 
  @notify_level_eventlog = 2, @delete_level= 0
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

  -- Add the job steps
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @JobID, @step_id = 1, @step_name = N'Log Backup', @command = N'exec DBA..usp_tbl_dba_log_backup @check = ''Y'', @execute = ''Y''	', @database_name = N'DBA', @server = N'', @database_user_name = N'', @subsystem = N'TSQL', @cmdexec_success_code = 0, @flags = 0, @retry_attempts = 0, @retry_interval = 0, @output_file_name = N'', @on_success_step_id = 0, @on_success_action = 1, @on_fail_step_id = 0, @on_fail_action = 3
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @JobID, @step_id = 2, @step_name = N'Failure Notification', @command = N'declare @Subject varchar(50), @Body varchar(100)

set  @Subject = ''Medium - Failed - Log Backup''
select @Body = ''Failed at '' + convert(varchar,getdate())

exec DBA..usp_dba_SendMail ''Backup'', @Subject, @Body', @database_name = N'DBA', @server = N'', @database_user_name = N'', @subsystem = N'TSQL', @cmdexec_success_code = 0, @flags = 0, @retry_attempts = 0, @retry_interval = 0, @output_file_name = N'', @on_success_step_id = 0, @on_success_action = 2, @on_fail_step_id = 0, @on_fail_action = 2
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
  EXECUTE @ReturnCode = msdb.dbo.sp_update_job @job_id = @JobID, @start_step_id = 1 

  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

  -- Add the job schedules
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id = @JobID, @name = N'Every 1 Hrs', @enabled = 1, @freq_type = 4, @active_start_date = 20061027, @active_start_time = 0, @freq_interval = 1, @freq_subday_type = 8, @freq_subday_interval = 1, @freq_relative_interval = 0, @freq_recurrence_factor = 0, @active_end_date = 99991231, @active_end_time = 235959
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

  -- Add the Target Servers
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @JobID, @server_name = N'(local)' 
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

END
COMMIT TRANSACTION          
GOTO   EndSave              
QuitWithRollback:
  IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION 
EndSave: 

GO
BEGIN TRANSACTION            
  DECLARE @JobID BINARY(16)  
  DECLARE @ReturnCode INT    
  SELECT @ReturnCode = 0     
IF (SELECT COUNT(*) FROM msdb.dbo.syscategories WHERE name = N'[Uncategorized (Local)]') < 1 
  EXECUTE msdb.dbo.sp_add_category @name = N'[Uncategorized (Local)]'

  -- Delete the job with the same name (if it exists)
  SELECT @JobID = job_id     
  FROM   msdb.dbo.sysjobs    
  WHERE (name = N'-- RyderDBA - Diff Backup (Daily)')       
  IF (@JobID IS NOT NULL)    
  BEGIN  
  -- Check if the job is a multi-server job  
  IF (EXISTS (SELECT  * 
              FROM    msdb.dbo.sysjobservers 
              WHERE   (job_id = @JobID) AND (server_id <> 0))) 
  BEGIN 
    -- There is, so abort the script 
    RAISERROR (N'Unable to import job ''-- RyderDBA - Diff Backup (Daily)'' since there is already a multi-server job with this name.', 16, 1) 
    GOTO QuitWithRollback  
  END 
  ELSE 
    -- Delete the [local] job 
    EXECUTE msdb.dbo.sp_delete_job @job_name = N'-- RyderDBA - Diff Backup (Daily)' 
    SELECT @JobID = NULL
  END 

BEGIN 

  -- Add the job
  EXECUTE @ReturnCode = msdb.dbo.sp_add_job @job_id = @JobID OUTPUT , @job_name = N'-- RyderDBA - Diff Backup (Daily)', @owner_login_name = N'sa', @description = N'Diff Backup of all databases as per configuration table (tbl_dba_maintenance_config)', @category_name = N'[Uncategorized (Local)]', @enabled = 0, @notify_level_email = 0, @notify_level_page = 0, @notify_level_netsend = 0, 
  @notify_level_eventlog = 2, @delete_level= 0
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

  -- Add the job steps
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @JobID, @step_id = 1, @step_name = N'Start Backup', @command = N'exec DBA..usp_tbl_dba_Start_DiffBackup
', @database_name = N'DBA', @server = N'', @database_user_name = N'', @subsystem = N'TSQL', @cmdexec_success_code = 0, @flags = 0, @retry_attempts = 1, @retry_interval = 1, @output_file_name = N'', @on_success_step_id = 0, @on_success_action = 1, @on_fail_step_id = 3, @on_fail_action = 4
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @JobID, @step_id = 2, @step_name = N'Success Notification', @command = N'declare @Subject varchar(50), @Body varchar(100)

set  @Subject = ''Success - Diff Backup''
select @Body = ''Completed  Successfully at '' + convert(varchar,getdate())

exec DBA..usp_dba_SendMail ''Backup'', @Subject, @Body 
', @database_name = N'DBA', @server = N'', @database_user_name = N'', @subsystem = N'TSQL', @cmdexec_success_code = 0, @flags = 0, @retry_attempts = 0, @retry_interval = 0, @output_file_name = N'', @on_success_step_id = 0, @on_success_action = 1, @on_fail_step_id = 0, @on_fail_action = 2
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @JobID, @step_id = 3, @step_name = N'Backup Failure Notification', @command = N'
declare @Subject varchar(50), @Body varchar(100)

set  @Subject = ''Critical - Failed - Diff. Backup''
select @Body = ''Failed at '' + convert(varchar,getdate())

exec DBA..usp_dba_SendMail ''Backup'', @Subject, @Body', @database_name = N'DBA', @server = N'', @database_user_name = N'', @subsystem = N'TSQL', @cmdexec_success_code = 0, @flags = 0, @retry_attempts = 0, @retry_interval = 0, @output_file_name = N'', @on_success_step_id = 0, @on_success_action = 2, @on_fail_step_id = 0, @on_fail_action = 2
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
  EXECUTE @ReturnCode = msdb.dbo.sp_update_job @job_id = @JobID, @start_step_id = 1 

  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

  -- Add the job schedules
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id = @JobID, @name = N'Daily @ 8 AM', @enabled = 1, @freq_type = 4, @active_start_date = 20061027, @active_start_time = 80000, @freq_interval = 1, @freq_subday_type = 1, @freq_subday_interval = 0, @freq_relative_interval = 0, @freq_recurrence_factor = 0, @active_end_date = 99991231, @active_end_time = 235959
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

  -- Add the Target Servers
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @JobID, @server_name = N'(local)' 
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

END
COMMIT TRANSACTION          
GOTO   EndSave              
QuitWithRollback:
  IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION 
EndSave: 


GO
BEGIN TRANSACTION            
  DECLARE @JobID BINARY(16)  
  DECLARE @ReturnCode INT    
  SELECT @ReturnCode = 0     
IF (SELECT COUNT(*) FROM msdb.dbo.syscategories WHERE name = N'[Uncategorized (Local)]') < 1 
  EXECUTE msdb.dbo.sp_add_category @name = N'[Uncategorized (Local)]'

  -- Delete the job with the same name (if it exists)
  SELECT @JobID = job_id     
  FROM   msdb.dbo.sysjobs    
  WHERE (name = N'-- RyderDBA - Generate Login Script (Daily)')       
  IF (@JobID IS NOT NULL)    
  BEGIN  
  -- Check if the job is a multi-server job  
  IF (EXISTS (SELECT  * 
              FROM    msdb.dbo.sysjobservers 
              WHERE   (job_id = @JobID) AND (server_id <> 0))) 
  BEGIN 
    -- There is, so abort the script 
    RAISERROR (N'Unable to import job ''-- RyderDBA - Generate Login Script (Daily)'' since there is already a multi-server job with this name.', 16, 1) 
    GOTO QuitWithRollback  
  END 
  ELSE 
    -- Delete the [local] job 
    EXECUTE msdb.dbo.sp_delete_job @job_name = N'-- RyderDBA - Generate Login Script (Daily)' 
    SELECT @JobID = NULL
  END 

BEGIN 

  -- Add the job
  EXECUTE @ReturnCode = msdb.dbo.sp_add_job @job_id = @JobID OUTPUT , @job_name = N'-- RyderDBA - Generate Login Script (Daily)', @owner_login_name = N'sa', @description = N'Generate login script with existing password', @category_name = N'[Uncategorized (Local)]', @enabled = 1, @notify_level_email = 0, @notify_level_page = 0, @notify_level_netsend = 0, 
  @notify_level_eventlog = 0, @delete_level= 0
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

  -- Add the job steps
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @JobID, @step_id = 1, @step_name = N'Generate Login Detail', @command = N'exec DBA..usp_dba_generate_login_defDB', @database_name = N'DBA', @server = N'', @database_user_name = N'', @subsystem = N'TSQL', @cmdexec_success_code = 0, @flags = 0, @retry_attempts = 0, @retry_interval = 0, @output_file_name = N'', @on_success_step_id = 0, @on_success_action = 1, @on_fail_step_id = 3, @on_fail_action = 4
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @JobID, @step_id = 2, @step_name = N'Success Notification', @command = N'declare @Subject varchar(50), @Body varchar(100)

set  @Subject = ''Success - Generate Login Script''
select @Body = ''Completed Successfully at '' + convert(varchar,getdate())

exec DBA..usp_dba_SendMail ''LoginScript'', @Subject, @Body', @database_name = N'DBA', @server = N'', @database_user_name = N'', @subsystem = N'TSQL', @cmdexec_success_code = 0, @flags = 0, @retry_attempts = 0, @retry_interval = 0, @output_file_name = N'', @on_success_step_id = 0, @on_success_action = 1, @on_fail_step_id = 0, @on_fail_action = 2
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @JobID, @step_id = 3, @step_name = N'Failure Notification', @command = N'declare @Subject varchar(50), @Body varchar(100)

set  @Subject = ''Low - Failed - Generate Login Script''
select @Body = ''Failed at '' + convert(varchar,getdate())

exec DBA..usp_dba_SendMail ''LoginScript'', @Subject, @Body', @database_name = N'DBA', @server = N'', @database_user_name = N'', @subsystem = N'TSQL', @cmdexec_success_code = 0, @flags = 0, @retry_attempts = 0, @retry_interval = 0, @output_file_name = N'', @on_success_step_id = 0, @on_success_action = 2, @on_fail_step_id = 0, @on_fail_action = 2
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
  EXECUTE @ReturnCode = msdb.dbo.sp_update_job @job_id = @JobID, @start_step_id = 1 

  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

  -- Add the job schedules
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id = @JobID, @name = N'Schedule 1', @enabled = 1, @freq_type = 4, @active_start_date = 20061027, @active_start_time = 213000, @freq_interval = 1, @freq_subday_type = 1, @freq_subday_interval = 0, @freq_relative_interval = 0, @freq_recurrence_factor = 0, @active_end_date = 99991231, @active_end_time = 235959
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

  -- Add the Target Servers
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @JobID, @server_name = N'(local)' 
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

END
COMMIT TRANSACTION          
GOTO   EndSave              
QuitWithRollback:
  IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION 
EndSave: 


GO
BEGIN TRANSACTION            
  DECLARE @JobID BINARY(16)  
  DECLARE @ReturnCode INT    
  SELECT @ReturnCode = 0     
IF (SELECT COUNT(*) FROM msdb.dbo.syscategories WHERE name = N'[Uncategorized (Local)]') < 1 
  EXECUTE msdb.dbo.sp_add_category @name = N'[Uncategorized (Local)]'

  -- Delete the job with the same name (if it exists)
  SELECT @JobID = job_id     
  FROM   msdb.dbo.sysjobs    
  WHERE (name = N'-- RyderDBA - Filegroup Backup')       
  IF (@JobID IS NOT NULL)    
  BEGIN  
  -- Check if the job is a multi-server job  
  IF (EXISTS (SELECT  * 
              FROM    msdb.dbo.sysjobservers 
              WHERE   (job_id = @JobID) AND (server_id <> 0))) 
  BEGIN 
    -- There is, so abort the script 
    RAISERROR (N'Unable to import job ''-- RyderDBA - Filegroup Backup'' since there is already a multi-server job with this name.', 16, 1) 
    GOTO QuitWithRollback  
  END 
  ELSE 
    -- Delete the [local] job 
    EXECUTE msdb.dbo.sp_delete_job @job_name = N'-- RyderDBA - Filegroup Backup' 
    SELECT @JobID = NULL
  END 

BEGIN 

  -- Add the job
  EXECUTE @ReturnCode = msdb.dbo.sp_add_job @job_id = @JobID OUTPUT , @job_name = N'-- RyderDBA - Filegroup Backup', @owner_login_name = N'sa', @description = N'No description available.', @category_name = N'[Uncategorized (Local)]', @enabled = 0, @notify_level_email = 0, @notify_level_page = 0, @notify_level_netsend = 0, 
  @notify_level_eventlog = 2, @delete_level= 0
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

  -- Add the job steps
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @JobID, @step_id = 1, @step_name = N'Start Backup', @command = N'exec DBA..usp_tbl_dba_Initiate_FGBackup', @database_name = N'DBA', @server = N'', @database_user_name = N'', @subsystem = N'TSQL', @cmdexec_success_code = 0, @flags = 0, @retry_attempts = 0, @retry_interval = 1, @output_file_name = N'', @on_success_step_id = 0, @on_success_action = 3, @on_fail_step_id = 3, @on_fail_action = 4
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @JobID, @step_id = 2, @step_name = N'Send Report', @command = N'exec DBA..usp_dba_FileGroupReport', @database_name = N'DBA', @server = N'', @database_user_name = N'', @subsystem = N'TSQL', @cmdexec_success_code = 0, @flags = 0, @retry_attempts = 0, @retry_interval = 1, @output_file_name = N'', @on_success_step_id = 0, @on_success_action = 1, @on_fail_step_id = 0, @on_fail_action = 3
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @JobID, @step_id = 3, @step_name = N'Failure Notification', @command = N'declare @Subject varchar(50), @Body varchar(100)

set  @Subject = ''Critical - Failed - Filegroup Backup''
select @Body = ''Failed at '' + convert(varchar,getdate())

exec DBA..usp_dba_SendMail ''Backup'', @Subject, @Body', @database_name = N'DBA', @server = N'', @database_user_name = N'', @subsystem = N'TSQL', @cmdexec_success_code = 0, @flags = 0, @retry_attempts = 0, @retry_interval = 1, @output_file_name = N'', @on_success_step_id = 0, @on_success_action = 1, @on_fail_step_id = 0, @on_fail_action = 2
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
  EXECUTE @ReturnCode = msdb.dbo.sp_update_job @job_id = @JobID, @start_step_id = 1 

  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

  -- Add the job schedules
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id = @JobID, @name = N'Every day@ 11:00 PM', @enabled = 0, @freq_type = 4, @active_start_date = 20070211, @active_start_time = 230000, @freq_interval = 1, @freq_subday_type = 1, @freq_subday_interval = 0, @freq_relative_interval = 0, @freq_recurrence_factor = 0, @active_end_date = 99991231, @active_end_time = 235959
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

  -- Add the Target Servers
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @JobID, @server_name = N'(local)' 
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

END
COMMIT TRANSACTION          
GOTO   EndSave              
QuitWithRollback:
  IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION 
EndSave: 


GO
BEGIN TRANSACTION            
  DECLARE @JobID BINARY(16)  
  DECLARE @ReturnCode INT    
  SELECT @ReturnCode = 0     
IF (SELECT COUNT(*) FROM msdb.dbo.syscategories WHERE name = N'[Uncategorized (Local)]') < 1 
  EXECUTE msdb.dbo.sp_add_category @name = N'[Uncategorized (Local)]'

  -- Delete the job with the same name (if it exists)
  SELECT @JobID = job_id     
  FROM   msdb.dbo.sysjobs    
  WHERE (name = N'-- RyderDBA - Check Log Space (@ Every 19 Minutes)')       
  IF (@JobID IS NOT NULL)    
  BEGIN  
  -- Check if the job is a multi-server job  
  IF (EXISTS (SELECT  * 
              FROM    msdb.dbo.sysjobservers 
              WHERE   (job_id = @JobID) AND (server_id <> 0))) 
  BEGIN 
    -- There is, so abort the script 
    RAISERROR (N'Unable to import job ''-- RyderDBA - Check Log Space (@ Every 19 Minutes)'' since there is already a multi-server job with this name.', 16, 1) 
    GOTO QuitWithRollback  
  END 
  ELSE 
    -- Delete the [local] job 
    EXECUTE msdb.dbo.sp_delete_job @job_name = N'-- RyderDBA - Check Log Space (@ Every 19 Minutes)' 
    SELECT @JobID = NULL
  END 

BEGIN 

  -- Add the job
  EXECUTE @ReturnCode = msdb.dbo.sp_add_job @job_id = @JobID OUTPUT , @job_name = N'-- RyderDBA - Check Log Space (@ Every 19 Minutes)', @owner_login_name = N'sa', @description = N'No description available.', @category_name = N'[Uncategorized (Local)]', @enabled = 1, @notify_level_email = 0, @notify_level_page = 0, @notify_level_netsend = 0, 
  @notify_level_eventlog = 2, @delete_level= 0
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

  -- Add the job steps
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @JobID, @step_id = 1, @step_name = N'Check Log Space', @command = N'exec DBA..usp_dba_CheckLogSpace', @database_name = N'DBA', @server = N'', @database_user_name = N'', @subsystem = N'TSQL', @cmdexec_success_code = 0, @flags = 0, @retry_attempts = 0, @retry_interval = 1, @output_file_name = N'', @on_success_step_id = 0, @on_success_action = 1, @on_fail_step_id = 0, @on_fail_action = 3
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @JobID, @step_id = 2, @step_name = N'Failure Notification', @command = N'declare @Subject varchar(50), @Body varchar(100)

set  @Subject = ''Medium - Failed - Check Trans. Log Space''
select @Body = ''Failed at '' + convert(varchar,getdate())

exec DBA..usp_dba_SendMail ''LogSpace'', @Subject, @Body', @database_name = N'DBA', @server = N'', @database_user_name = N'', @subsystem = N'TSQL', @cmdexec_success_code = 0, @flags = 0, @retry_attempts = 0, @retry_interval = 1, @output_file_name = N'', @on_success_step_id = 0, @on_success_action = 2, @on_fail_step_id = 0, @on_fail_action = 2
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
  EXECUTE @ReturnCode = msdb.dbo.sp_update_job @job_id = @JobID, @start_step_id = 1 

  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

  -- Add the job schedules
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id = @JobID, @name = N'Every 19 Minutes', @enabled = 1, @freq_type = 8, @active_start_date = 20061212, @active_start_time = 0, @freq_interval = 62, @freq_subday_type = 4, @freq_subday_interval = 19, @freq_relative_interval = 0, @freq_recurrence_factor = 1, @active_end_date = 99991231, @active_end_time = 235959
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

  -- Add the Target Servers
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @JobID, @server_name = N'(local)' 
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

END
COMMIT TRANSACTION          
GOTO   EndSave              
QuitWithRollback:
  IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION 
EndSave: 


GO
BEGIN TRANSACTION            
  DECLARE @JobID BINARY(16)  
  DECLARE @ReturnCode INT    
  SELECT @ReturnCode = 0     
IF (SELECT COUNT(*) FROM msdb.dbo.syscategories WHERE name = N'[Uncategorized (Local)]') < 1 
  EXECUTE msdb.dbo.sp_add_category @name = N'[Uncategorized (Local)]'

  -- Delete the job with the same name (if it exists)
  SELECT @JobID = job_id     
  FROM   msdb.dbo.sysjobs    
  WHERE (name = N'-- RyderDBA - DBCC UPDATESTATS  (Weekly)')       
  IF (@JobID IS NOT NULL)    
  BEGIN  
  -- Check if the job is a multi-server job  
  IF (EXISTS (SELECT  * 
              FROM    msdb.dbo.sysjobservers 
              WHERE   (job_id = @JobID) AND (server_id <> 0))) 
  BEGIN 
    -- There is, so abort the script 
    RAISERROR (N'Unable to import job ''-- RyderDBA - DBCC UPDATESTATS  (Weekly)'' since there is already a multi-server job with this name.', 16, 1) 
    GOTO QuitWithRollback  
  END 
  ELSE 
    -- Delete the [local] job 
    EXECUTE msdb.dbo.sp_delete_job @job_name = N'-- RyderDBA - DBCC UPDATESTATS  (Weekly)' 
    SELECT @JobID = NULL
  END 

BEGIN 

  -- Add the job
  EXECUTE @ReturnCode = msdb.dbo.sp_add_job @job_id = @JobID OUTPUT , @job_name = N'-- RyderDBA - DBCC UPDATESTATS  (Weekly)', @owner_login_name = N'sa', @description = N'No description available.', @category_name = N'[Uncategorized (Local)]', @enabled = 1, @notify_level_email = 0, @notify_level_page = 0, @notify_level_netsend = 0, 
  @notify_level_eventlog = 2, @delete_level= 0
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

  -- Add the job steps
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @JobID, @step_id = 1, @step_name = N'Start UPDATESTATS', @command = N'-- Disable Transaction log backup
exec msdb..sp_update_job @job_name = ''-- RyderDBA - Trans. Log Backup'',@enabled=0
--========================
exec DBA..usp_tbl_dba_updatestats @check=''Y'', @execute = ''Y''

-- Enable Transaction log backup
exec msdb..sp_update_job @job_name = ''-- RyderDBA - Trans. Log Backup'',@enabled=1
', @database_name = N'DBA', @server = N'', @database_user_name = N'', @subsystem = N'TSQL', @cmdexec_success_code = 0, @flags = 0, @retry_attempts = 0, @retry_interval = 0, @output_file_name = N'', @on_success_step_id = 0, @on_success_action = 3, @on_fail_step_id = 3, @on_fail_action = 4
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @JobID, @step_id = 2, @step_name = N'DBCC Success Notification', @command = N'declare @Subject varchar(50), @Body varchar(100)

set  @Subject = ''Success - All DBCC''
select @Body = ''Completed Successfully at '' + convert(varchar,getdate())

exec DBA..usp_dba_SendMail ''DBCC'', @Subject, @Body', @database_name = N'DBA', @server = N'', @database_user_name = N'', @subsystem = N'TSQL', @cmdexec_success_code = 0, @flags = 0, @retry_attempts = 0, @retry_interval = 0, @output_file_name = N'', @on_success_step_id = 0, @on_success_action = 1, @on_fail_step_id = 0, @on_fail_action = 2
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @JobID, @step_id = 3, @step_name = N'UPDATESTATS Failure Notification', @command = N'-- Enable Transaction log backup
exec msdb..sp_update_job @job_name = ''-- RyderDBA - Trans. Log Backup'',@enabled=1
--========================
declare @Subject varchar(50), @Body varchar(100)

set  @Subject = ''Medium - Failed - DBCC UPDATESTATS''
select @Body = ''Failed at '' + convert(varchar,getdate())

exec DBA..usp_dba_SendMail ''DBCC'', @Subject, @Body', @database_name = N'DBA', @server = N'', @database_user_name = N'', @subsystem = N'TSQL', @cmdexec_success_code = 0, @flags = 0, @retry_attempts = 0, @retry_interval = 0, @output_file_name = N'', @on_success_step_id = 0, @on_success_action = 2, @on_fail_step_id = 0, @on_fail_action = 2
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
  EXECUTE @ReturnCode = msdb.dbo.sp_update_job @job_id = @JobID, @start_step_id = 1 

  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

  -- Add the Target Servers
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @JobID, @server_name = N'(local)' 
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

END
COMMIT TRANSACTION          
GOTO   EndSave              
QuitWithRollback:
  IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION 
EndSave: 


GO
BEGIN TRANSACTION            
  DECLARE @JobID BINARY(16)  
  DECLARE @ReturnCode INT    
  SELECT @ReturnCode = 0     
IF (SELECT COUNT(*) FROM msdb.dbo.syscategories WHERE name = N'[Uncategorized (Local)]') < 1 
  EXECUTE msdb.dbo.sp_add_category @name = N'[Uncategorized (Local)]'

  -- Delete the job with the same name (if it exists)
  SELECT @JobID = job_id     
  FROM   msdb.dbo.sysjobs    
  WHERE (name = N'-- RyderDBA - Full Backup (Daily)')       
  IF (@JobID IS NOT NULL)    
  BEGIN  
  -- Check if the job is a multi-server job  
  IF (EXISTS (SELECT  * 
              FROM    msdb.dbo.sysjobservers 
              WHERE   (job_id = @JobID) AND (server_id <> 0))) 
  BEGIN 
    -- There is, so abort the script 
    RAISERROR (N'Unable to import job ''-- RyderDBA - Full Backup (Daily)'' since there is already a multi-server job with this name.', 16, 1) 
    GOTO QuitWithRollback  
  END 
  ELSE 
    -- Delete the [local] job 
    EXECUTE msdb.dbo.sp_delete_job @job_name = N'-- RyderDBA - Full Backup (Daily)' 
    SELECT @JobID = NULL
  END 

BEGIN 

  -- Add the job
  EXECUTE @ReturnCode = msdb.dbo.sp_add_job @job_id = @JobID OUTPUT , @job_name = N'-- RyderDBA - Full Backup (Daily)', @owner_login_name = N'sa', @description = N'Full Backup of all databases as per configuration table (tbl_dba_maintenance_config)', @category_name = N'[Uncategorized (Local)]', @enabled = 1, @notify_level_email = 0, @notify_level_page = 0, @notify_level_netsend = 0, 
  @notify_level_eventlog = 2, @delete_level= 0
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

  -- Add the job steps
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @JobID, @step_id = 1, @step_name = N'Archive Backup', @command = N'exec DBA..usp_tbl_dba_full_backup_archive
exec DBA..usp_tbl_dba_delete_backup @execute = ''Y''
', @database_name = N'DBA', @server = N'', @database_user_name = N'', @subsystem = N'TSQL', @cmdexec_success_code = 0, @flags = 0, @retry_attempts = 0, @retry_interval = 0, @output_file_name = N'', @on_success_step_id = 0, @on_success_action = 3, @on_fail_step_id = 4, @on_fail_action = 4
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @JobID, @step_id = 2, @step_name = N'Start Backup', @command = N'exec DBA..usp_tbl_dba_Start_FullBackup', @database_name = N'DBA', @server = N'', @database_user_name = N'', @subsystem = N'TSQL', @cmdexec_success_code = 0, @flags = 0, @retry_attempts = 1, @retry_interval = 1, @output_file_name = N'', @on_success_step_id = 0, @on_success_action = 1, @on_fail_step_id = 5, @on_fail_action = 4
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @JobID, @step_id = 3, @step_name = N'Success Notification', @command = N'declare @Subject varchar(50), @Body varchar(100)

set  @Subject = ''Success - Full Backup''
select @Body = ''Completed  Successfully at '' + convert(varchar,getdate())

exec DBA..usp_dba_SendMail ''Backup'', @Subject, @Body 
', @database_name = N'DBA', @server = N'', @database_user_name = N'', @subsystem = N'TSQL', @cmdexec_success_code = 0, @flags = 0, @retry_attempts = 0, @retry_interval = 0, @output_file_name = N'', @on_success_step_id = 0, @on_success_action = 1, @on_fail_step_id = 0, @on_fail_action = 2
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @JobID, @step_id = 4, @step_name = N'File Delete Failure Notification', @command = N'declare @Subject varchar(50), @Body varchar(100)

set  @Subject = ''Medium - Failed - Backup File Deletion''
select @Body = ''Failed at '' + convert(varchar,getdate())

exec DBA..usp_dba_SendMail ''Backup'', @Subject, @Body 
', @database_name = N'DBA', @server = N'', @database_user_name = N'', @subsystem = N'TSQL', @cmdexec_success_code = 0, @flags = 0, @retry_attempts = 0, @retry_interval = 0, @output_file_name = N'', @on_success_step_id = 0, @on_success_action = 2, @on_fail_step_id = 0, @on_fail_action = 2
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @JobID, @step_id = 5, @step_name = N'Backup Failure Notification', @command = N'update DBA..tbl_dba_full_backup_completed
set Failed = ''Y''
where succeeded IS Null

declare @Subject varchar(50), @Body varchar(100)

set  @Subject = ''Critical - Failed - Full Backup''
select @Body = ''Failed at '' + convert(varchar,getdate())

exec DBA..usp_dba_SendMail ''Backup'', @Subject, @Body', @database_name = N'DBA', @server = N'', @database_user_name = N'', @subsystem = N'TSQL', @cmdexec_success_code = 0, @flags = 0, @retry_attempts = 0, @retry_interval = 0, @output_file_name = N'', @on_success_step_id = 0, @on_success_action = 2, @on_fail_step_id = 0, @on_fail_action = 2
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
  EXECUTE @ReturnCode = msdb.dbo.sp_update_job @job_id = @JobID, @start_step_id = 1 

  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

  -- Add the job schedules
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id = @JobID, @name = N'Daily @ 1 AM', @enabled = 1, @freq_type = 4, @active_start_date = 20061027, @active_start_time = 10000, @freq_interval = 1, @freq_subday_type = 1, @freq_subday_interval = 0, @freq_relative_interval = 0, @freq_recurrence_factor = 0, @active_end_date = 99991231, @active_end_time = 235959
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

  -- Add the Target Servers
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @JobID, @server_name = N'(local)' 
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

END
COMMIT TRANSACTION          
GOTO   EndSave              
QuitWithRollback:
  IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION 
EndSave: 


GO
BEGIN TRANSACTION            
  DECLARE @JobID BINARY(16)  
  DECLARE @ReturnCode INT    
  SELECT @ReturnCode = 0     
IF (SELECT COUNT(*) FROM msdb.dbo.syscategories WHERE name = N'[Uncategorized (Local)]') < 1 
  EXECUTE msdb.dbo.sp_add_category @name = N'[Uncategorized (Local)]'

  -- Delete the job with the same name (if it exists)
  SELECT @JobID = job_id     
  FROM   msdb.dbo.sysjobs    
  WHERE (name = N'-- RyderDBA - DBCC ALTERINDEX (Weekly)')       
  IF (@JobID IS NOT NULL)    
  BEGIN  
  -- Check if the job is a multi-server job  
  IF (EXISTS (SELECT  * 
              FROM    msdb.dbo.sysjobservers 
              WHERE   (job_id = @JobID) AND (server_id <> 0))) 
  BEGIN 
    -- There is, so abort the script 
    RAISERROR (N'Unable to import job ''-- RyderDBA - DBCC ALTERINDEX (Weekly)'' since there is already a multi-server job with this name.', 16, 1) 
    GOTO QuitWithRollback  
  END 
  ELSE 
    -- Delete the [local] job 
    EXECUTE msdb.dbo.sp_delete_job @job_name = N'-- RyderDBA - DBCC ALTERINDEX (Weekly)' 
    SELECT @JobID = NULL
  END 

BEGIN 

  -- Add the job
  EXECUTE @ReturnCode = msdb.dbo.sp_add_job @job_id = @JobID OUTPUT , @job_name = N'-- RyderDBA - DBCC ALTERINDEX (Weekly)', @owner_login_name = N'sa', @description = N'No description available.', @category_name = N'[Uncategorized (Local)]', @enabled = 1, @notify_level_email = 0, @notify_level_page = 0, @notify_level_netsend = 0, 
  @notify_level_eventlog = 2, @delete_level= 0
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

  -- Add the job steps
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @JobID, @step_id = 1, @step_name = N'Start ALTERINDEX', @command = N'--Disable Transaction log backup
	exec msdb..sp_update_job @job_name = ''-- RyderDBA - Trans. Log Backup'',@enabled=0
	--========================

	truncate table DBA..tbl_dba_AlterIndex_Output
	insert into DBA..tbl_dba_AlterIndex_Output(OutputText) exec (''master..xp_cmdshell  ''''osql -S'' + @@ServerName + '' -E -Q"DBA..usp_tbl_dba_AlterIndex @check=''''''''Y'''''''', @execute=''''''''Y''''''''" -n -h-1 -w1000'''''')  
	if exists (select 1 from DBA..tbl_dba_AlterIndex_Output where OutputText like ''%Msg%,%Level%'')
	begin
		
		declare @Subject varchar(50), @Body varchar(200)

		set  @Subject = ''Reported Error - DBCC ALTERINDEX''
		select @Body = ''ALTERINDEX found error in one or more database(s)......... Run following query for detail:'' + char(13) + char(13)
		select @Body = @Body + ''select * from DBA..tbl_dba_AlterIndex_Output''

		exec DBA..usp_dba_SendMail ''DBCC'', @Subject, @Body	
	end
	', @database_name = N'DBA', @server = N'', @database_user_name = N'', @subsystem = N'TSQL', @cmdexec_success_code = 0, @flags = 0, @retry_attempts = 0, @retry_interval = 0, @output_file_name = N'', @on_success_step_id = 0, @on_success_action = 3, @on_fail_step_id = 3, @on_fail_action = 4
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @JobID, @step_id = 2, @step_name = N'Run DBCC UPDATESTATS Job', @command = N'msdb..sp_start_job ''-- RyderDBA - DBCC UPDATESTATS  (Weekly)''', @database_name = N'msdb', @server = N'', @database_user_name = N'', @subsystem = N'TSQL', @cmdexec_success_code = 0, @flags = 0, @retry_attempts = 0, @retry_interval = 0, @output_file_name = N'', @on_success_step_id = 0, @on_success_action = 1, @on_fail_step_id = 4, @on_fail_action = 4
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @JobID, @step_id = 3, @step_name = N'ALTERINDEX Failure Notification', @command = N'-- Enable Transaction log backup
	exec msdb..sp_update_job @job_name = ''-- RyderDBA - Trans. Log Backup'',@enabled=1
	--========================
	declare @Subject varchar(50), @Body varchar(100)

	set  @Subject = ''Critical - Failed - DBCC ALTERINDEX''
	select @Body = ''Failed at '' + convert(varchar,getdate())

	exec DBA..usp_dba_SendMail ''DBCC'', @Subject, @Body', @database_name = N'DBA', @server = N'', @database_user_name = N'', @subsystem = N'TSQL', @cmdexec_success_code = 0, @flags = 0, @retry_attempts = 0, @retry_interval = 0, @output_file_name = N'', @on_success_step_id = 0, @on_success_action = 2, @on_fail_step_id = 0, @on_fail_action = 2
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @JobID, @step_id = 4, @step_name = N'UPDATESTATS Job Failure Notification', @command = N'-- Enable Transaction log backup
	exec msdb..sp_update_job @job_name = ''-- RyderDBA - Trans. Log Backup'',@enabled=1
	--========================
	declare @Subject varchar(50), @Body varchar(100)

	set  @Subject = ''Critical - Failed - To run UPDATESTATS job''
	select @Body = ''Failed at '' + convert(varchar,getdate())

	exec DBA..usp_dba_SendMail ''DBCC'', @Subject, @Body', @database_name = N'DBA', @server = N'', @database_user_name = N'', @subsystem = N'TSQL', @cmdexec_success_code = 0, @flags = 0, @retry_attempts = 0, @retry_interval = 0, @output_file_name = N'', @on_success_step_id = 0, @on_success_action = 2, @on_fail_step_id = 0, @on_fail_action = 2
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
  EXECUTE @ReturnCode = msdb.dbo.sp_update_job @job_id = @JobID, @start_step_id = 1 

  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

  -- Add the Target Servers
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @JobID, @server_name = N'(local)' 
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

END
COMMIT TRANSACTION          
GOTO   EndSave              
QuitWithRollback:
  IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION 
EndSave: 
GO
--******************************************
/*-------------------------------------------------------------------------------------------------------------------------------------------------------------------
Purpose		:	To check SQL Version and if it is SQL 2005, the script will update the xupdateusage column to "N" on the [dbo].[tbl_dba_maintenance_config] table. In addition we need to this this will remove the command to update usage in the PSDBA updateusage job . 
Created on	: 	11/02/2008
Version		:	1.0
dependencies	: Table					
		  tbl_dba_maintenance_config			
-----------------------------------------------------------------------------------------------------*/

USE DBA
GO
ALTER TABLE [tbl_dba_maintenance_config] DROP CONSTRAINT [DF_tbl_dba_maintenance_xupdateusage] ;
ALTER TABLE [tbl_dba_maintenance_config] ADD CONSTRAINT [DF_tbl_dba_maintenance_xupdateusage]  DEFAULT ('N') FOR [xupdateusage] ;
Update [tbl_dba_maintenance_config] Set [xupdateusage] = 'N';
exec msdb..sp_update_jobstep @job_name = '-- RyderDBA - DBCC UPDATEUSAGE  (Weekly)' ,	@step_id =1,@step_name = 'Start UPDATEUSAGE',@command=N'print '' Update Usage is not being required in SQL Server 2008. So this Step is no More Required. Just to minimise the chnages PSDBA Team has just removed the command from this Step.'''

GO
BEGIN TRANSACTION            
  DECLARE @JobID BINARY(16)  
  DECLARE @ReturnCode INT    
  SELECT @ReturnCode = 0     
IF (SELECT COUNT(*) FROM msdb.dbo.syscategories WHERE name = N'[Uncategorized (Local)]') < 1 
  EXECUTE msdb.dbo.sp_add_category @name = N'[Uncategorized (Local)]'

  -- Delete the job with the same name (if it exists)
  SELECT @JobID = job_id     
  FROM   msdb.dbo.sysjobs    
  WHERE (name = N'-- RyderDBA - TempDB Monitoring Space Usage (On Demand)')
  IF (@JobID IS NOT NULL)    
  BEGIN  
  -- Check if the job is a multi-server job  
  IF (EXISTS (SELECT  * 
              FROM    msdb.dbo.sysjobservers 
              WHERE   (job_id = @JobID) AND (server_id <> 0))) 
  BEGIN 
    -- There is, so abort the script 
    RAISERROR (N'Unable to import job ''-- RyderDBA - TempDB Monitoring Space Usage (On Demand)'' since there is already a multi-server job with this name.', 16, 1) 
    GOTO QuitWithRollback  
  END 
  ELSE 
    -- Delete the [local] job 
    EXECUTE msdb.dbo.sp_delete_job @job_name = N'-- RyderDBA - TempDB Monitoring Space Usage (On Demand)' 
    SELECT @JobID = NULL
  END 

BEGIN 

  -- Add the job
  EXECUTE @ReturnCode = msdb.dbo.sp_add_job  
  @job_id = @JobID OUTPUT , 
  @job_name = N'-- RyderDBA - TempDB Monitoring Space Usage (On Demand)', 
  @owner_login_name = N'sa', 
  @description = N'No description available.', 
  @category_name = N'[Uncategorized (Local)]', 
  @enabled = 0,
  @notify_level_email = 0, 
  @notify_level_page = 0, 
  @notify_level_netsend = 0, 
  @notify_level_eventlog = 2, 
  @delete_level= 0
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

  -- Add the job steps
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep 
  @job_id = @JobID, 
  @step_id = 1, 
  @step_name = N'Start monitor', 
  @command = N'-- Start monitor
exec DBA..usp_dba_TempDB_Monitor_Space_Usage;',
  @database_name = N'DBA', 
  @server = N'', 
  @database_user_name = N'', 
  @subsystem = N'TSQL', 
  @cmdexec_success_code = 0, 
  @flags = 0, 
  @retry_attempts = 0, 
  @retry_interval = 0, 
  @output_file_name = N'', 
  @on_success_step_id = 0, 
  @on_success_action = 1, 
  @on_fail_step_id = 0, 
  @on_fail_action = 3
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
  
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep 
  @job_id = @JobID, 
  @step_id = 2, 
  @step_name = N'Failure Notification', 
  @command = N'declare @Subject varchar(50), @Body varchar(100)
set  @Subject = ''Low - Failed - TempDB Monitoring Space Usage''
select @Body = ''Failed at '' + convert(varchar,getdate())
exec DBA..usp_dba_SendMail ''TEMPDB MONITOR'', @Subject, @Body', 
  @database_name = N'DBA', 
  @server = N'', 
  @database_user_name = N'', 
  @subsystem = N'TSQL', 
  @cmdexec_success_code = 0, 
  @flags = 0, 
  @retry_attempts = 0, 
  @retry_interval = 0, 
  @output_file_name = N'', 
  @on_success_step_id = 0, 
  @on_success_action = 2, 
  @on_fail_step_id = 0, 
  @on_fail_action = 2
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
  
  EXECUTE @ReturnCode = msdb.dbo.sp_update_job 
  @job_id = @JobID, 
  @start_step_id = 1,
  @owner_login_name = N'sa';

  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

  -- Add the job schedules
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobschedule 
  @job_id = @JobID, 
  @name = N'Schedule 1', 
  @enabled = 1, 
  @freq_type = 4, 
  @freq_interval = 1, 
  @freq_subday_type = 4, 
  @freq_subday_interval = 3, 
  @freq_relative_interval = 2, 
  @freq_recurrence_factor = 0, 
  @active_start_date = 20101209, 
  @active_end_date = 99991231, 
  @active_start_time = 0, 
  @active_end_time = 235959

 
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

  -- Add the Target Servers
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobserver 
  @job_id = @JobID, 
  @server_name = N'(local)' 
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

END
COMMIT TRANSACTION          
GOTO   EndSave              
QuitWithRollback:
  IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION 
EndSave: 
GO
--------------------------------------------------------------
--------------------------------------------------------------
GO
BEGIN TRANSACTION            
  DECLARE @JobID BINARY(16)  
  DECLARE @ReturnCode INT    
  SELECT @ReturnCode = 0     
IF (SELECT COUNT(*) FROM msdb.dbo.syscategories WHERE name = N'[Uncategorized (Local)]') < 1 
  EXECUTE msdb.dbo.sp_add_category @name = N'[Uncategorized (Local)]'

  -- Delete the job with the same name (if it exists)
  SELECT @JobID = job_id     
  FROM   msdb.dbo.sysjobs    
  WHERE (name = N'-- RyderDBA - TempDB Monitoring Version Store (On Demand)')
  IF (@JobID IS NOT NULL)    
  BEGIN  
  -- Check if the job is a multi-server job  
  IF (EXISTS (SELECT  * 
              FROM    msdb.dbo.sysjobservers 
              WHERE   (job_id = @JobID) AND (server_id <> 0))) 
  BEGIN 
    -- There is, so abort the script 
    RAISERROR (N'Unable to import job ''-- RyderDBA - TempDB Monitoring Version Store (On Demand)'' since there is already a multi-server job with this name.', 16, 1) 
    GOTO QuitWithRollback  
  END 
  ELSE 
    -- Delete the [local] job 
    EXECUTE msdb.dbo.sp_delete_job @job_name = N'-- RyderDBA - TempDB Monitoring Version Store (On Demand)' 
    SELECT @JobID = NULL
  END 

BEGIN 

  -- Add the job
  EXECUTE @ReturnCode = msdb.dbo.sp_add_job  
  @job_id = @JobID OUTPUT , 
  @job_name = N'-- RyderDBA - TempDB Monitoring Version Store (On Demand)', 
  @owner_login_name = N'sa', 
  @description = N'No description available.', 
  @category_name = N'[Uncategorized (Local)]', 
  @enabled = 0,
  @notify_level_email = 0, 
  @notify_level_page = 0, 
  @notify_level_netsend = 0, 
  @notify_level_eventlog = 2, 
  @delete_level= 0
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

  -- Add the job steps
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep 
  @job_id = @JobID, 
  @step_id = 1, 
  @step_name = N'Start monitor', 
  @command = N'-- Start monitor
exec DBA..usp_dba_TempDB_Monitor_Version_Store;',
  @database_name = N'DBA', 
  @server = N'', 
  @database_user_name = N'', 
  @subsystem = N'TSQL', 
  @cmdexec_success_code = 0, 
  @flags = 0, 
  @retry_attempts = 0, 
  @retry_interval = 0, 
  @output_file_name = N'', 
  @on_success_step_id = 0, 
  @on_success_action = 1, 
  @on_fail_step_id = 0, 
  @on_fail_action = 3
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
  
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep 
  @job_id = @JobID, 
  @step_id = 2, 
  @step_name = N'Failure Notification', 
  @command = N'declare @Subject varchar(50), @Body varchar(100)
set  @Subject = ''Low - Failed - TempDB Monitoring Version Store''
select @Body = ''Failed at '' + convert(varchar,getdate())
exec DBA..usp_dba_SendMail ''TEMPDB MONITOR'', @Subject, @Body', 
  @database_name = N'DBA', 
  @server = N'', 
  @database_user_name = N'', 
  @subsystem = N'TSQL', 
  @cmdexec_success_code = 0, 
  @flags = 0, 
  @retry_attempts = 0, 
  @retry_interval = 0, 
  @output_file_name = N'', 
  @on_success_step_id = 0, 
  @on_success_action = 2, 
  @on_fail_step_id = 0, 
  @on_fail_action = 2
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
  
  EXECUTE @ReturnCode = msdb.dbo.sp_update_job 
  @job_id = @JobID, 
  @start_step_id = 1,
  @owner_login_name = N'sa';

  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

  -- Add the job schedules
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobschedule 
  @job_id = @JobID, 
  @name = N'Schedule 1', 
  @enabled = 1, 
  @freq_type = 4, 
  @freq_interval = 1, 
  @freq_subday_type = 4, 
  @freq_subday_interval = 3, 
  @freq_relative_interval = 2, 
  @freq_recurrence_factor = 0, 
  @active_start_date = 20101209, 
  @active_end_date = 99991231, 
  @active_start_time = 0, 
  @active_end_time = 235959

  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

  -- Add the Target Servers
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobserver 
  @job_id = @JobID, 
  @server_name = N'(local)' 
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

END
COMMIT TRANSACTION          
GOTO   EndSave              
QuitWithRollback:
  IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION 
EndSave: 
GO
-----------------------------------------------
-----------------------------------------------
GO
BEGIN TRANSACTION            
  DECLARE @JobID BINARY(16)  
  DECLARE @ReturnCode INT    
  SELECT @ReturnCode = 0     
IF (SELECT COUNT(*) FROM msdb.dbo.syscategories WHERE name = N'[Uncategorized (Local)]') < 1 
  EXECUTE msdb.dbo.sp_add_category @name = N'[Uncategorized (Local)]'

  -- Delete the job with the same name (if it exists)
  SELECT @JobID = job_id     
  FROM   msdb.dbo.sysjobs    
  WHERE (name = N'-- RyderDBA - TempDB Monitoring Objects (On Demand)')
  IF (@JobID IS NOT NULL)    
  BEGIN  
  -- Check if the job is a multi-server job  
  IF (EXISTS (SELECT  * 
              FROM    msdb.dbo.sysjobservers 
              WHERE   (job_id = @JobID) AND (server_id <> 0))) 
  BEGIN 
    -- There is, so abort the script 
    RAISERROR (N'Unable to import job ''-- RyderDBA - TempDB Monitoring Objects (On Demand)'' since there is already a multi-server job with this name.', 16, 1) 
    GOTO QuitWithRollback  
  END 
  ELSE 
    -- Delete the [local] job 
    EXECUTE msdb.dbo.sp_delete_job @job_name = N'-- RyderDBA - TempDB Monitoring Objects (On Demand)' 
    SELECT @JobID = NULL
  END 

BEGIN 

  -- Add the job
  EXECUTE @ReturnCode = msdb.dbo.sp_add_job  
  @job_id = @JobID OUTPUT , 
  @job_name = N'-- RyderDBA - TempDB Monitoring Objects (On Demand)', 
  @owner_login_name = N'sa', 
  @description = N'No description available.', 
  @category_name = N'[Uncategorized (Local)]', 
  @enabled = 0,
  @notify_level_email = 0, 
  @notify_level_page = 0, 
  @notify_level_netsend = 0, 
  @notify_level_eventlog = 2, 
  @delete_level= 0
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

  -- Add the job steps
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep 
  @job_id = @JobID, 
  @step_id = 1, 
  @step_name = N'Start monitor', 
  @command = N'-- Start monitor
exec DBA..usp_dba_TempDB_Monitor_Objects;',
  @database_name = N'DBA', 
  @server = N'', 
  @database_user_name = N'', 
  @subsystem = N'TSQL', 
  @cmdexec_success_code = 0, 
  @flags = 0, 
  @retry_attempts = 0, 
  @retry_interval = 0, 
  @output_file_name = N'', 
  @on_success_step_id = 0, 
  @on_success_action = 1, 
  @on_fail_step_id = 0, 
  @on_fail_action = 3
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
  
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep 
  @job_id = @JobID, 
  @step_id = 2, 
  @step_name = N'Failure Notification', 
  @command = N'declare @Subject varchar(50), @Body varchar(100)
set  @Subject = ''Low - Failed - TempDB Monitoring Objects''
select @Body = ''Failed at '' + convert(varchar,getdate())
exec DBA..usp_dba_SendMail ''TEMPDB MONITOR'', @Subject, @Body', 
  @database_name = N'DBA', 
  @server = N'', 
  @database_user_name = N'', 
  @subsystem = N'TSQL', 
  @cmdexec_success_code = 0, 
  @flags = 0, 
  @retry_attempts = 0, 
  @retry_interval = 0, 
  @output_file_name = N'', 
  @on_success_step_id = 0, 
  @on_success_action = 2, 
  @on_fail_step_id = 0, 
  @on_fail_action = 2
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
  
  EXECUTE @ReturnCode = msdb.dbo.sp_update_job 
  @job_id = @JobID, 
  @start_step_id = 1,
  @owner_login_name = N'sa';

  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

  -- Add the job schedules
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobschedule 
  @job_id = @JobID, 
  @name = N'Schedule 1', 
  @enabled = 1, 
  @freq_type = 4, 
  @freq_interval = 1, 
  @freq_subday_type = 4, 
  @freq_subday_interval = 3, 
  @freq_relative_interval = 2, 
  @freq_recurrence_factor = 0, 
  @active_start_date = 20101209, 
  @active_end_date = 99991231, 
  @active_start_time = 0, 
  @active_end_time = 235959
  
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

  -- Add the Target Servers
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobserver 
  @job_id = @JobID, 
  @server_name = N'(local)' 
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

END
COMMIT TRANSACTION          
GOTO   EndSave              
QuitWithRollback:
  IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION 
EndSave: 
GO
/****** Object:  Job [--- RyderDBA - Recycle SQL error logs (@ two weeks)]    Script Date: 12/07/2010 17:25:06 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]]    Script Date: 12/07/2010 17:25:06 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
-- Delete the job with the same name (if it exists)
  SELECT @JobID = job_id     
  FROM   msdb.dbo.sysjobs    
  WHERE (name = N'-- RyderDBA - Recycle SQL error logs (@ two weeks)')       
  IF (@JobID IS NOT NULL)    
  BEGIN  
  -- Check if the job is a multi-server job  
  IF (EXISTS (SELECT  * 
              FROM    msdb.dbo.sysjobservers 
              WHERE   (job_id = @JobID) AND (server_id <> 0))) 
  BEGIN 
    -- There is, so abort the script 
    RAISERROR (N'Unable to import job ''-- RyderDBA - Recycle SQL error logs (@ two weeks)'' since there is already a multi-server job with this name.', 16, 1) 
    GOTO QuitWithRollback  
  END 
  ELSE 
    -- Delete the [local] job 
    EXECUTE msdb.dbo.sp_delete_job @job_name = N'-- RyderDBA - Recycle SQL error logs (@ two weeks)' 
    SELECT @JobID = NULL
  END 

EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'-- RyderDBA - Recycle SQL error logs (@ two weeks)', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'This script is meant to recycle the SQL error logs every two weeks in order to have a small size of the error log file.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [SQL error logs recycle]    Script Date: 12/07/2010 17:25:06 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'SQL error logs recycle', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE [master] 
EXEC xp_instance_regwrite ''HKEY_LOCAL_MACHINE'', ''Software\Microsoft\MSSQLServer\MSSQLServer'', ''NumErrorLogs'', REG_DWORD, 12
EXEC msdb.dbo.sp_cycle_errorlog', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Recycle process', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=64, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=2, 
		@active_start_date=20101207, 
		@active_end_date=99991231, 
		@active_start_time=30000, 
		@active_end_time=235959
IF (@@ERROR <> 0 OR @ReturnCode <> 0) 
	GOTO QuitWithRollback
exec @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) 
	GOTO QuitWithRollback

COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
	IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
BEGIN TRANSACTION            
  DECLARE @JobID BINARY(16)  
  DECLARE @ReturnCode INT    
  SELECT @ReturnCode = 0     
IF (SELECT COUNT(*) FROM msdb.dbo.syscategories WHERE name = N'[Uncategorized (Local)]') < 1 
  EXECUTE msdb.dbo.sp_add_category @name = N'[Uncategorized (Local)]'

  -- Delete the job with the same name (if it exists)
  SELECT @JobID = job_id     
  FROM   msdb.dbo.sysjobs    
  WHERE (name = N'-- RyderDBA - Long Running Jobs (@ Every 23 Minutes)')
  IF (@JobID IS NOT NULL)    
  BEGIN  
  -- Check if the job is a multi-server job  
  IF (EXISTS (SELECT  * 
              FROM    msdb.dbo.sysjobservers 
              WHERE   (job_id = @JobID) AND (server_id <> 0))) 
  BEGIN 
    -- There is, so abort the script 
    RAISERROR (N'Unable to import job ''-- RyderDBA - Long Running Jobs (@ Every 23 Minutes)'' since there is already a multi-server job with this name.', 16, 1) 
    GOTO QuitWithRollback  
  END 
  ELSE 
    -- Delete the [local] job 
    EXECUTE msdb.dbo.sp_delete_job @job_name = N'-- RyderDBA - Long Running Jobs (@ Every 23 Minutes)'
    SELECT @JobID = NULL
  END 

BEGIN 

  -- Add the job
  EXECUTE @ReturnCode = msdb.dbo.sp_add_job  
  @job_id = @JobID OUTPUT , 
  @job_name = N'-- RyderDBA - Long Running Jobs (@ Every 23 Minutes)',
  @owner_login_name = N'sa', 
  @description = N'No description available.', 
  @category_name = N'[Uncategorized (Local)]', 
  @enabled = 1, 
  @notify_level_email = 0, 
  @notify_level_page = 0, 
  @notify_level_netsend = 0, 
  @notify_level_eventlog = 2, 
  @delete_level= 0
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

  -- Add the job steps
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep 
  @job_id = @JobID, 
  @step_id = 1, 
  @step_name = N'Check the jobs', 
  @command = N'exec DBA..usp_long_running_jobs;',
  @database_name = N'DBA', 
  @server = N'', 
  @database_user_name = N'', 
  @subsystem = N'TSQL', 
  @cmdexec_success_code = 0, 
  @flags = 0, 
  @retry_attempts = 0, 
  @retry_interval = 0, 
  @output_file_name = N'', 
  @on_success_step_id = 0, 
  @on_success_action = 1, 
  @on_fail_step_id = 0, 
  @on_fail_action = 3
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
  
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep 
  @job_id = @JobID, 
  @step_id = 2, 
  @step_name = N'Failure Notification', 
  @command = N'declare @Subject varchar(50), @Body varchar(100)
set  @Subject = ''Low - Failed - Long Running Jobs (@ Every 23 Minutes)''
select @Body = ''Failed at '' + convert(varchar,getdate())
exec DBA..usp_dba_SendMail ''LONG RUNNING JOBS'', @Subject, @Body', 
  @database_name = N'DBA', 
  @server = N'', 
  @database_user_name = N'', 
  @subsystem = N'TSQL', 
  @cmdexec_success_code = 0, 
  @flags = 0, 
  @retry_attempts = 0, 
  @retry_interval = 0, 
  @output_file_name = N'', 
  @on_success_step_id = 0, 
  @on_success_action = 2, 
  @on_fail_step_id = 0, 
  @on_fail_action = 2
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
  
  EXECUTE @ReturnCode = msdb.dbo.sp_update_job 
  @job_id = @JobID, 
  @start_step_id = 1 

  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

  -- Add the job schedules
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobschedule 
	@job_id = @JobID, 
	@name = N'Every 23 Minutes',
	@enabled=1, 
	@freq_type=4, 
	@freq_interval=1, 
	@freq_subday_type=8, 
	@freq_subday_interval=23, 
	@freq_relative_interval=0, 
	@freq_recurrence_factor=0, 
	@active_start_date=20061212, 
	@active_end_date=99991231, 
	@active_start_time=0, 
	@active_end_time=235959
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

  -- Add the Target Servers
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobserver 
  @job_id = @JobID, 
  @server_name = N'(local)' 
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

END
COMMIT TRANSACTION          
GOTO   EndSave              
QuitWithRollback:
  IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION 
EndSave: 
GO
BEGIN TRANSACTION            
  DECLARE @JobID BINARY(16)  
  DECLARE @ReturnCode INT    
  SELECT @ReturnCode = 0     
IF (SELECT COUNT(*) FROM msdb.dbo.syscategories WHERE name = N'[Uncategorized (Local)]') < 1 
  EXECUTE msdb.dbo.sp_add_category @name = N'[Uncategorized (Local)]'

  -- Delete the job with the same name (if it exists)
  SELECT @JobID = job_id     
  FROM   msdb.dbo.sysjobs    
  WHERE (name = N'-- RyderDBA - MSDB Clean Up (weekly)')
  IF (@JobID IS NOT NULL)    
  BEGIN  
  -- Check if the job is a multi-server job  
  IF (EXISTS (SELECT  * 
              FROM    msdb.dbo.sysjobservers 
              WHERE   (job_id = @JobID) AND (server_id <> 0))) 
  BEGIN 
    -- There is, so abort the script 
    RAISERROR (N'Unable to import job ''-- RyderDBA - MSDB Clean Up (weekly)'' since there is already a multi-server job with this name.', 16, 1) 
    GOTO QuitWithRollback  
  END 
  ELSE 
    -- Delete the [local] job 
    EXECUTE msdb.dbo.sp_delete_job @job_name = N'-- RyderDBA - MSDB Clean Up (weekly)' 
    SELECT @JobID = NULL
  END 

BEGIN 

  -- Add the job
  EXECUTE @ReturnCode = msdb.dbo.sp_add_job  
  @job_id = @JobID OUTPUT , 
  @job_name = N'-- RyderDBA - MSDB Clean Up (weekly)', 
  @owner_login_name = N'sa', 
  @description = N'No description available.', 
  @category_name = N'[Uncategorized (Local)]', 
  @enabled = 1,
  @notify_level_email = 0, 
  @notify_level_page = 0, 
  @notify_level_netsend = 0, 
  @notify_level_eventlog = 2, 
  @delete_level= 0
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

  -- Add the job steps
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep 
  @job_id = @JobID, 
  @step_id = 1, 
  @step_name = N'Clean up MSDB', 
  @command = N'-- Clean up MSDB
exec DBA..usp_tbl_dba_MSDB_Clean_Up;',
  @database_name = N'DBA', 
  @server = N'', 
  @database_user_name = N'', 
  @subsystem = N'TSQL', 
  @cmdexec_success_code = 0, 
  @flags = 0, 
  @retry_attempts = 0, 
  @retry_interval = 0, 
  @output_file_name = N'', 
  @on_success_step_id = 0, 
  @on_success_action = 1, 
  @on_fail_step_id = 0, 
  @on_fail_action = 3
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
  
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep 
  @job_id = @JobID, 
  @step_id = 2, 
  @step_name = N'Failure Notification', 
  @command = N'declare @Subject varchar(50), @Body varchar(100)
set  @Subject = ''Low - Failed - MSDB Clean Up''
select @Body = ''Failed at '' + convert(varchar,getdate())
exec DBA..usp_dba_SendMail ''MSDBCLEANUP'', @Subject, @Body', 
  @database_name = N'DBA', 
  @server = N'', 
  @database_user_name = N'', 
  @subsystem = N'TSQL', 
  @cmdexec_success_code = 0, 
  @flags = 0, 
  @retry_attempts = 0, 
  @retry_interval = 0, 
  @output_file_name = N'', 
  @on_success_step_id = 0, 
  @on_success_action = 2, 
  @on_fail_step_id = 0, 
  @on_fail_action = 2
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
  
  EXECUTE @ReturnCode = msdb.dbo.sp_update_job 
  @job_id = @JobID, 
  @start_step_id = 1,
  @owner_login_name = N'sa';

  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

  -- Add the job schedules
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobschedule 
  @job_id = @JobID, 
  @name = N'Schedule 1', 
  @enabled = 1, 
  @freq_type = 8, 
  @freq_interval = 32, 
  @freq_subday_type = 1, 
  @freq_subday_interval = 0, 
  @freq_relative_interval = 0, 
  @freq_recurrence_factor = 1, 
  @active_start_date=20101209, 
  @active_end_date=99991231, 
  @active_start_time=30000, 
  @active_end_time=235959

  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

  -- Add the Target Servers
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobserver 
  @job_id = @JobID, 
  @server_name = N'(local)' 
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

END
COMMIT TRANSACTION          
GOTO   EndSave              
QuitWithRollback:
  IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION 
EndSave: 
GO
BEGIN TRANSACTION            
  DECLARE @JobID BINARY(16)  
  DECLARE @ReturnCode INT    
  SELECT @ReturnCode = 0     
IF (SELECT COUNT(*) FROM msdb.dbo.syscategories WHERE name = N'[Uncategorized (Local)]') < 1 
  EXECUTE msdb.dbo.sp_add_category @name = N'[Uncategorized (Local)]'

  -- Delete the job with the same name (if it exists)
  SELECT @JobID = job_id     
  FROM   msdb.dbo.sysjobs    
  WHERE (name = N'-- RyderDBA - Query Performance CPU (On Demand)')
  IF (@JobID IS NOT NULL)    
  BEGIN  
  -- Check if the job is a multi-server job  
  IF (EXISTS (SELECT  * 
              FROM    msdb.dbo.sysjobservers 
              WHERE   (job_id = @JobID) AND (server_id <> 0))) 
  BEGIN 
    -- There is, so abort the script 
    RAISERROR (N'Unable to import job ''-- RyderDBA - Query Performance CPU (On Demand)'' since there is already a multi-server job with this name.', 16, 1) 
    GOTO QuitWithRollback  
  END 
  ELSE 
    -- Delete the [local] job 
    EXECUTE msdb.dbo.sp_delete_job @job_name = N'-- RyderDBA - Query Performance CPU (On Demand)' 
    SELECT @JobID = NULL
  END 

BEGIN 

  -- Add the job
  EXECUTE @ReturnCode = msdb.dbo.sp_add_job  
  @job_id = @JobID OUTPUT , 
  @job_name = N'-- RyderDBA - Query Performance CPU (On Demand)', 
  @owner_login_name = N'sa', 
  @description = N'TOP CPU Intensive Queries
  Would identify query and execution plan in XML Format
  
  Query the table tbl_dba_query_perf_analysis_cpu for the results', 
  @category_name = N'[Uncategorized (Local)]', 
  @enabled = 0,
  @notify_level_email = 0, 
  @notify_level_page = 0, 
  @notify_level_netsend = 0, 
  @notify_level_eventlog = 2, 
  @delete_level= 0
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

  -- Add the job steps
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep 
  @job_id = @JobID, 
  @step_id = 1, 
  @step_name = N'Start monitor', 
  @command = N'-- Start monitor
  exec DBA..usp_dba_query_perf_analysis_cpu',
  @database_name = N'DBA', 
  @server = N'', 
  @database_user_name = N'', 
  @subsystem = N'TSQL', 
  @cmdexec_success_code = 0, 
  @flags = 0, 
  @retry_attempts = 0, 
  @retry_interval = 0, 
  @output_file_name = N'', 
  @on_success_step_id = 0, 
  @on_success_action = 1, 
  @on_fail_step_id = 0, 
  @on_fail_action = 3
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
  
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep 
  @job_id = @JobID, 
  @step_id = 2, 
  @step_name = N'Failure Notification', 
  @command = N'declare @Subject varchar(50), @Body varchar(100)
set  @Subject = ''Low - Failed - Query Performance CPU''
select @Body = ''Failed at '' + convert(varchar,getdate())
exec DBA..usp_dba_SendMail ''QUERY PERFORMANCE'', @Subject, @Body', 
  @database_name = N'DBA', 
  @server = N'', 
  @database_user_name = N'', 
  @subsystem = N'TSQL', 
  @cmdexec_success_code = 0, 
  @flags = 0, 
  @retry_attempts = 0, 
  @retry_interval = 0, 
  @output_file_name = N'', 
  @on_success_step_id = 0, 
  @on_success_action = 2, 
  @on_fail_step_id = 0, 
  @on_fail_action = 2
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
  
  EXECUTE @ReturnCode = msdb.dbo.sp_update_job 
  @job_id = @JobID, 
  @start_step_id = 1,
  @owner_login_name = N'sa';

  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

  -- Add the job schedules
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobschedule 
  @job_id = @JobID, 
  @name = N'Schedule 1', 
  @enabled = 1, 
  @freq_type = 4, 
  @freq_interval = 1, 
  @freq_subday_type = 4, 
  @freq_subday_interval = 3, 
  @freq_relative_interval = 2, 
  @freq_recurrence_factor = 0, 
  @active_start_date = 20101209, 
  @active_end_date = 99991231, 
  @active_start_time = 0, 
  @active_end_time = 235959

 
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

  -- Add the Target Servers
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobserver 
  @job_id = @JobID, 
  @server_name = N'(local)' 
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

END
COMMIT TRANSACTION          
GOTO   EndSave              
QuitWithRollback:
  IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION 
EndSave: 
GO
--------------------------------------------------------------
--------------------------------------------------------------
GO
BEGIN TRANSACTION            
  DECLARE @JobID BINARY(16)  
  DECLARE @ReturnCode INT    
  SELECT @ReturnCode = 0     
IF (SELECT COUNT(*) FROM msdb.dbo.syscategories WHERE name = N'[Uncategorized (Local)]') < 1 
  EXECUTE msdb.dbo.sp_add_category @name = N'[Uncategorized (Local)]'

  -- Delete the job with the same name (if it exists)
  SELECT @JobID = job_id     
  FROM   msdb.dbo.sysjobs    
  WHERE (name = N'-- RyderDBA - Query Performance IO (On Demand)')
  IF (@JobID IS NOT NULL)    
  BEGIN  
  -- Check if the job is a multi-server job  
  IF (EXISTS (SELECT  * 
              FROM    msdb.dbo.sysjobservers 
              WHERE   (job_id = @JobID) AND (server_id <> 0))) 
  BEGIN 
    -- There is, so abort the script 
    RAISERROR (N'Unable to import job ''-- RyderDBA - Query Performance IO (On Demand)'' since there is already a multi-server job with this name.', 16, 1) 
    GOTO QuitWithRollback  
  END 
  ELSE 
    -- Delete the [local] job 
    EXECUTE msdb.dbo.sp_delete_job @job_name = N'-- RyderDBA - Query Performance IO (On Demand)' 
    SELECT @JobID = NULL
  END 

BEGIN 

  -- Add the job
  EXECUTE @ReturnCode = msdb.dbo.sp_add_job  
  @job_id = @JobID OUTPUT , 
  @job_name = N'-- RyderDBA - Query Performance IO (On Demand)', 
  @owner_login_name = N'sa', 
  @description = N'I/O Intensive Queries
  Would identify queries with high I/O performance
  
  Query the table tbl_dba_query_perf_analysis_io for the results', 
  @category_name = N'[Uncategorized (Local)]', 
  @enabled = 0,
  @notify_level_email = 0, 
  @notify_level_page = 0, 
  @notify_level_netsend = 0, 
  @notify_level_eventlog = 2, 
  @delete_level= 0
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

  -- Add the job steps
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep 
  @job_id = @JobID, 
  @step_id = 1, 
  @step_name = N'Start monitor', 
  @command = N'-- Start monitor
exec DBA..usp_dba_query_perf_analysis_io;',
  @database_name = N'DBA', 
  @server = N'', 
  @database_user_name = N'', 
  @subsystem = N'TSQL', 
  @cmdexec_success_code = 0, 
  @flags = 0, 
  @retry_attempts = 0, 
  @retry_interval = 0, 
  @output_file_name = N'', 
  @on_success_step_id = 0, 
  @on_success_action = 1, 
  @on_fail_step_id = 0, 
  @on_fail_action = 3
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
  
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep 
  @job_id = @JobID, 
  @step_id = 2, 
  @step_name = N'Failure Notification', 
  @command = N'declare @Subject varchar(50), @Body varchar(100)
set  @Subject = ''Low - Failed - Query Performance IO''
select @Body = ''Failed at '' + convert(varchar,getdate())
exec DBA..usp_dba_SendMail ''QUERY PERFORMANCE'', @Subject, @Body', 
  @database_name = N'DBA', 
  @server = N'', 
  @database_user_name = N'', 
  @subsystem = N'TSQL', 
  @cmdexec_success_code = 0, 
  @flags = 0, 
  @retry_attempts = 0, 
  @retry_interval = 0, 
  @output_file_name = N'', 
  @on_success_step_id = 0, 
  @on_success_action = 2, 
  @on_fail_step_id = 0, 
  @on_fail_action = 2
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
  
  EXECUTE @ReturnCode = msdb.dbo.sp_update_job 
  @job_id = @JobID, 
  @start_step_id = 1,
  @owner_login_name = N'sa';

  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

  -- Add the job schedules
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobschedule 
  @job_id = @JobID, 
  @name = N'Schedule 1', 
  @enabled = 1, 
  @freq_type = 4, 
  @freq_interval = 1, 
  @freq_subday_type = 4, 
  @freq_subday_interval = 3, 
  @freq_relative_interval = 2, 
  @freq_recurrence_factor = 0, 
  @active_start_date = 20101209, 
  @active_end_date = 99991231, 
  @active_start_time = 0, 
  @active_end_time = 235959

  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

  -- Add the Target Servers
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobserver 
  @job_id = @JobID, 
  @server_name = N'(local)' 
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

END
COMMIT TRANSACTION          
GOTO   EndSave              
QuitWithRollback:
  IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION 
EndSave: 
GO
-----------------------------------------------
-----------------------------------------------
GO
BEGIN TRANSACTION            
  DECLARE @JobID BINARY(16)  
  DECLARE @ReturnCode INT    
  SELECT @ReturnCode = 0     
IF (SELECT COUNT(*) FROM msdb.dbo.syscategories WHERE name = N'[Uncategorized (Local)]') < 1 
  EXECUTE msdb.dbo.sp_add_category @name = N'[Uncategorized (Local)]'

  -- Delete the job with the same name (if it exists)
  SELECT @JobID = job_id     
  FROM   msdb.dbo.sysjobs    
  WHERE (name = N'-- RyderDBA - Query Performance FRS (On Demand)')
  IF (@JobID IS NOT NULL)    
  BEGIN  
  -- Check if the job is a multi-server job  
  IF (EXISTS (SELECT  * 
              FROM    msdb.dbo.sysjobservers 
              WHERE   (job_id = @JobID) AND (server_id <> 0))) 
  BEGIN 
    -- There is, so abort the script 
    RAISERROR (N'Unable to import job ''-- RyderDBA - Query Performance FRS (On Demand)'' since there is already a multi-server job with this name.', 16, 1) 
    GOTO QuitWithRollback  
  END 
  ELSE 
    -- Delete the [local] job 
    EXECUTE msdb.dbo.sp_delete_job @job_name = N'-- RyderDBA - Query Performance FRS (On Demand)' 
    SELECT @JobID = NULL
  END 

BEGIN 

  -- Add the job
  EXECUTE @ReturnCode = msdb.dbo.sp_add_job  
  @job_id = @JobID OUTPUT , 
  @job_name = N'-- RyderDBA - Query Performance FRS (On Demand)', 
  @owner_login_name = N'sa', 
  @description = N'Frequently Recompiled statements
  Identify Queries in cache that have high recompile executions

  Query the table tbl_dba_query_perf_analysis_frs for the results', 
  @category_name = N'[Uncategorized (Local)]', 
  @enabled = 0,
  @notify_level_email = 0, 
  @notify_level_page = 0, 
  @notify_level_netsend = 0, 
  @notify_level_eventlog = 2, 
  @delete_level= 0
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

  -- Add the job steps
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep 
  @job_id = @JobID, 
  @step_id = 1, 
  @step_name = N'Start monitor', 
  @command = N'-- Start monitor
exec DBA..usp_dba_query_perf_analysis_frs',
  @database_name = N'DBA', 
  @server = N'', 
  @database_user_name = N'', 
  @subsystem = N'TSQL', 
  @cmdexec_success_code = 0, 
  @flags = 0, 
  @retry_attempts = 0, 
  @retry_interval = 0, 
  @output_file_name = N'', 
  @on_success_step_id = 0, 
  @on_success_action = 1, 
  @on_fail_step_id = 0, 
  @on_fail_action = 3
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
  
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep 
  @job_id = @JobID, 
  @step_id = 2, 
  @step_name = N'Failure Notification', 
  @command = N'declare @Subject varchar(50), @Body varchar(100)
set  @Subject = ''Low - Failed - Query Performance FRS''
select @Body = ''Failed at '' + convert(varchar,getdate())
exec DBA..usp_dba_SendMail ''QUERY PERFORMANCE'', @Subject, @Body', 
  @database_name = N'DBA', 
  @server = N'', 
  @database_user_name = N'', 
  @subsystem = N'TSQL', 
  @cmdexec_success_code = 0, 
  @flags = 0, 
  @retry_attempts = 0, 
  @retry_interval = 0, 
  @output_file_name = N'', 
  @on_success_step_id = 0, 
  @on_success_action = 2, 
  @on_fail_step_id = 0, 
  @on_fail_action = 2
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
  
  EXECUTE @ReturnCode = msdb.dbo.sp_update_job 
  @job_id = @JobID, 
  @start_step_id = 1,
  @owner_login_name = N'sa';

  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

  -- Add the job schedules
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobschedule 
  @job_id = @JobID, 
  @name = N'Schedule 1', 
  @enabled = 1, 
  @freq_type = 4, 
  @freq_interval = 1, 
  @freq_subday_type = 4, 
  @freq_subday_interval = 3, 
  @freq_relative_interval = 2, 
  @freq_recurrence_factor = 0, 
  @active_start_date = 20101209, 
  @active_end_date = 99991231, 
  @active_start_time = 0, 
  @active_end_time = 235959
  
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

  -- Add the Target Servers
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobserver 
  @job_id = @JobID, 
  @server_name = N'(local)' 
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

END
COMMIT TRANSACTION          
GOTO   EndSave              
QuitWithRollback:
  IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION 
EndSave: 
GO

-----------------------------------------------
-----------------------------------------------
GO
BEGIN TRANSACTION            
  DECLARE @JobID BINARY(16)  
  DECLARE @ReturnCode INT    
  SELECT @ReturnCode = 0     
IF (SELECT COUNT(*) FROM msdb.dbo.syscategories WHERE name = N'[Uncategorized (Local)]') < 1 
  EXECUTE msdb.dbo.sp_add_category @name = N'[Uncategorized (Local)]'

  -- Delete the job with the same name (if it exists)
  SELECT @JobID = job_id     
  FROM   msdb.dbo.sysjobs    
  WHERE (name = N'-- RyderDBA - Query Performance MII (On Demand)')
  IF (@JobID IS NOT NULL)    
  BEGIN  
  -- Check if the job is a multi-server job  
  IF (EXISTS (SELECT  * 
              FROM    msdb.dbo.sysjobservers 
              WHERE   (job_id = @JobID) AND (server_id <> 0))) 
  BEGIN 
    -- There is, so abort the script 
    RAISERROR (N'Unable to import job ''-- RyderDBA - Query Performance MII (On Demand)'' since there is already a multi-server job with this name.', 16, 1) 
    GOTO QuitWithRollback  
  END 
  ELSE 
    -- Delete the [local] job 
    EXECUTE msdb.dbo.sp_delete_job @job_name = N'-- RyderDBA - Query Performance MII (On Demand)' 
    SELECT @JobID = NULL
  END 

BEGIN 

  -- Add the job
  EXECUTE @ReturnCode = msdb.dbo.sp_add_job 
  @job_id = @JobID OUTPUT , 
  @job_name = N'-- RyderDBA - Query Performance MII (On Demand)', 
  @owner_login_name = N'sa', 
  @description = N'Missing Indexes Information
  Identify queries that may (or may not) be missing indexes based on execution stats,

  Query the table tbl_dba_query_perf_analysis_mii for the results', 
  @category_name = N'[Uncategorized (Local)]', 
  @enabled = 0,
  @notify_level_email = 0, 
  @notify_level_page = 0, 
  @notify_level_netsend = 0, 
  @notify_level_eventlog = 2, 
  @delete_level= 0
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

  -- Add the job steps
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep 
  @job_id = @JobID, 
  @step_id = 1, 
  @step_name = N'Start monitor', 
  @command = N'-- Start monitor
exec DBA..usp_dba_query_perf_analysis_mii',
  @database_name = N'DBA', 
  @server = N'', 
  @database_user_name = N'', 
  @subsystem = N'TSQL', 
  @cmdexec_success_code = 0, 
  @flags = 0, 
  @retry_attempts = 0, 
  @retry_interval = 0, 
  @output_file_name = N'', 
  @on_success_step_id = 0, 
  @on_success_action = 1, 
  @on_fail_step_id = 0, 
  @on_fail_action = 3
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
  
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep 
  @job_id = @JobID, 
  @step_id = 2, 
  @step_name = N'Failure Notification', 
  @command = N'declare @Subject varchar(50), @Body varchar(100)
set  @Subject = ''Low - Failed - Query Performance MII''
select @Body = ''Failed at '' + convert(varchar,getdate())
exec DBA..usp_dba_SendMail ''QUERY PERFORMANCE'', @Subject, @Body', 
  @database_name = N'DBA', 
  @server = N'', 
  @database_user_name = N'', 
  @subsystem = N'TSQL', 
  @cmdexec_success_code = 0, 
  @flags = 0, 
  @retry_attempts = 0, 
  @retry_interval = 0, 
  @output_file_name = N'', 
  @on_success_step_id = 0, 
  @on_success_action = 2, 
  @on_fail_step_id = 0, 
  @on_fail_action = 2
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
  
  EXECUTE @ReturnCode = msdb.dbo.sp_update_job 
  @job_id = @JobID, 
  @start_step_id = 1,
  @owner_login_name = N'sa';

  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

  -- Add the job schedules
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobschedule 
  @job_id = @JobID, 
  @name = N'Schedule 1', 
  @enabled = 1, 
  @freq_type = 4, 
  @freq_interval = 1, 
  @freq_subday_type = 4, 
  @freq_subday_interval = 3, 
  @freq_relative_interval = 2, 
  @freq_recurrence_factor = 0, 
  @active_start_date = 20101209, 
  @active_end_date = 99991231, 
  @active_start_time = 0, 
  @active_end_time = 235959
  
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

  -- Add the Target Servers
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobserver 
  @job_id = @JobID, 
  @server_name = N'(local)' 
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

END
COMMIT TRANSACTION          
GOTO   EndSave              
QuitWithRollback:
  IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION 
EndSave: 
go

-- Script generated on 1/14/2009 1:32 PM
-- By: NA\Solowayc
-- Server: (local)

BEGIN TRANSACTION            
  DECLARE @JobID BINARY(16)  
  DECLARE @ReturnCode INT    
  SELECT @ReturnCode = 0     
IF (SELECT COUNT(*) FROM msdb.dbo.syscategories WHERE name = N'[Uncategorized (Local)]') < 1 
  EXECUTE msdb.dbo.sp_add_category @name = N'[Uncategorized (Local)]'

  -- Delete the job with the same name (if it exists)
  SELECT @JobID = job_id     
  FROM   msdb.dbo.sysjobs    
  WHERE (name = N'-- RyderDBA - Archive DB Size and Space')       
  IF (@JobID IS NOT NULL)    
  BEGIN  
  -- Check if the job is a multi-server job  
  IF (EXISTS (SELECT  * 
              FROM    msdb.dbo.sysjobservers 
              WHERE   (job_id = @JobID) AND (server_id <> 0))) 
  BEGIN 
    -- There is, so abort the script 
    RAISERROR (N'Unable to import job ''-- RyderDBA - Archive DB Size and Space'' since there is already a multi-server job with this name.', 16, 1) 
    GOTO QuitWithRollback  
  END 
  ELSE 
    -- Delete the [local] job 
    EXECUTE msdb.dbo.sp_delete_job @job_name = N'-- RyderDBA - Archive DB Size and Space' 
    SELECT @JobID = NULL
  END 

BEGIN 

  -- Add the job
  EXECUTE @ReturnCode = msdb.dbo.sp_add_job 
  @job_id = @JobID OUTPUT , 
  @job_name = N'-- RyderDBA - Archive DB Size and Space', 
  @owner_login_name = N'sa', 
  @description = N'No description available.', 
  @category_name = N'[Uncategorized (Local)]', 
  @enabled = 1, 
  @notify_level_email = 0, 
  @notify_level_page = 0, 
  @notify_level_netsend = 0, 
  @notify_level_eventlog = 2, 
  @delete_level= 0
  
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) 
	GOTO QuitWithRollback 

  -- Add the job steps
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep 
  @job_id = @JobID, 
  @step_id = 1, 
  @step_name = N'Archive Drive Space', 
  @command = N'EXEC DBA..usp_tbl_dba_archive_drive_space',
  @database_name = N'DBA', 
  @server = N'', 
  @database_user_name = N'', 
  @subsystem = N'TSQL', 
  @cmdexec_success_code = 0, 
  @flags = 0, 
  @retry_attempts = 0, 
  @retry_interval = 1, 
  @output_file_name = N'', 
  @on_success_step_id = 0, 
  @on_success_action = 3, 
  @on_fail_step_id = 0, 
  @on_fail_action = 2
  
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) 
	GOTO QuitWithRollback 
	
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep 
  @job_id = @JobID, 
  @step_id = 2, 
  @step_name = N'Archive DB Size', 
  @command = N'EXEC DBA..usp_tbl_dba_archive_dbsize',
  @database_name = N'master', 
  @server = N'', 
  @database_user_name = N'', 
  @subsystem = N'TSQL', 
  @cmdexec_success_code = 0, 
  @flags = 0, 
  @retry_attempts = 0, 
  @retry_interval = 1, 
  @output_file_name = N'', 
  @on_success_step_id = 0, 
  @on_success_action = 1, 
  @on_fail_step_id = 0, 
  @on_fail_action = 2
  
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) 
	GOTO QuitWithRollback 
	
  EXECUTE @ReturnCode = msdb.dbo.sp_update_job @job_id = @JobID, @start_step_id = 1 

  IF (@@ERROR <> 0 OR @ReturnCode <> 0) 
	GOTO QuitWithRollback 

  -- Add the job schedules
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobschedule 
  @job_id = @JobID, 
  @name = N'Monthly Run', 
  @enabled = 1, 
  @freq_type = 16, 
  @active_start_date = 20090113, 
  @active_start_time = 0, 
  @freq_interval = 25, 
  @freq_subday_type = 1, 
  @freq_subday_interval = 0, 
  @freq_relative_interval = 0, 
  @freq_recurrence_factor = 1, 
  @active_end_date = 99991231, 
  @active_end_time = 235959
  
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) 
	GOTO QuitWithRollback 

  -- Add the Target Servers
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @JobID, @server_name = N'(local)' 
  
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) 
	GOTO QuitWithRollback 

END
COMMIT TRANSACTION          
GOTO   EndSave              
QuitWithRollback:
  IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION 
EndSave:
Go
USE [msdb]
GO

/****** Object:  Job [-- RyderDBA - Runbook (Daily)]    Script Date: 11/9/2011 5:04:35 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]]    Script Date: 11/9/2011 5:04:35 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)

-- Delete the job with the same name (if it exists)
  SELECT @JobID = job_id     
  FROM   msdb.dbo.sysjobs    
  WHERE (name = N'-- RyderDBA - Runbook (Daily)')       
  IF (@JobID IS NOT NULL)    
  BEGIN  
  -- Check if the job is a multi-server job  
  IF (EXISTS (SELECT  * 
              FROM    msdb.dbo.sysjobservers 
              WHERE   (job_id = @JobID) AND (server_id <> 0))) 
  BEGIN 
    -- There is, so abort the script 
    RAISERROR (N'Unable to import job ''-- RyderDBA - Runbook (Daily)'' since there is already a multi-server job with this name.', 16, 1) 
    GOTO QuitWithRollback  
  END 
  ELSE 
    -- Delete the [local] job 
    EXECUTE msdb.dbo.sp_delete_job @job_name = N'-- RyderDBA - Runbook (Daily)' 
    SELECT @JobID = NULL
  END 



EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'-- RyderDBA - Runbook (Daily)', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Gets the Runbook of the current instance and exports the information to a file', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Update Job]    Script Date: 11/9/2011 5:04:35 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Update Job', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'declare @db_job_output_location varchar(150);
select @db_job_output_location = m.db_job_output_location + ''\'' + @@SERVERNAME + ''\Runbook.sql'' from DBA..tbl_dba_maint_file_location m
select @db_job_output_location

exec msdb.dbo.sp_update_jobstep @job_name = ''-- RyderDBA - Runbook (Daily)'', @step_id = 2, @output_file_name = @db_job_output_location;', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Get Runbook]    Script Date: 11/9/2011 5:04:35 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Get Runbook', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'--run in query analyzer
--set output to text (control t)
--Make sure output is in Tab delimited format
--Save output in a textfile
use master
go
select ''Servername:''
select @@servername
go
select ''Current Versioning''
select @@Version
go
DECLARE @test varchar(15),@value_name varchar(15),@RegistryPath varchar(200)

IF (charindex(''\'',@@SERVERNAME)<>0) -- Named Instance
BEGIN
 SET @RegistryPath = ''SOFTWARE\Microsoft\Microsoft SQL Server\'' + RIGHT(@@SERVERNAME,LEN(@@SERVERNAME)-CHARINDEX(''\'',@@SERVERNAME)) + ''\MSSQLServer\SuperSocketNetLib\Tcp''
END
ELSE -- Default Instance 
BEGIN
  SET @RegistryPath = ''SOFTWARE\Microsoft\MSSQLServer\MSSQLServer\SuperSocketNetLib\Tcp''
END

EXEC master..xp_regread @rootkey=''HKEY_LOCAL_MACHINE'' ,@key=@RegistryPath,@value_name=''TcpPort'',@value=@test OUTPUT

select ''The Port Number in use for this instance is ''+ @test
go
select '' ''
go 

select ''License and page file information''
Declare @version varchar(47)
Declare @CDKey varchar(40)
Declare @PageFile varchar(50)
Select @version = @@version

create table #PageFileDetails (data varchar(500))
insert into #PageFileDetails  exec master.dbo.xp_cmdshell ''wmic pagefile list /format:list''
select @PageFile=rtrim(ltrim(data)) from #PageFileDetails where data like ''AllocatedBaseSize%''
drop table #PageFileDetails

If charindex(''2000'',@version,1)>0 
Begin
EXEC master.dbo.xp_regread @rootkey=''HKEY_LOCAL_MACHINE'',
@key=''SOFTWARE\Microsoft\Microsoft SQL Server\80\Registration'',
@value_name=''CD_KEY'', @Value=@CDKey OUTPUT
SELECT ''SQL 2000'' AS SQLVersion,
CONVERT(char(20), SERVERPROPERTY(''ServerName'')) AS SQL_Service_Name,
@PageFile AS PageFile,
CONVERT(char(50), SERVERPROPERTY(''Edition''))AS SQLEdition,
CONVERT(char(20), SERVERPROPERTY(''productversion'')) AS ProductVersion,
CONVERT(char(20), SERVERPROPERTY(''LicenseType''))AS License_Type,
CONVERT(char(20), SERVERPROPERTY(''NumLicenses'')) AS Number_Of_Licenses,
@CDKey AS CDKey
end

Else If charindex(''2008'',@version,1)>0 
Begin
EXEC master.dbo.xp_regread @rootkey=''HKEY_LOCAL_MACHINE'',   
  @key=''SOFTWARE\Microsoft\Microsoft SQL Server\100\Tools\Setup'', 
  @value_name=''ProductID'', @value=@CDKey OUTPUT
SELECT ''SQL 2008'' AS SQLVersion,
CONVERT(char(20), SERVERPROPERTY(''ServerName'')) AS SQL_Service_Name,
@PageFile AS PageFile,
CONVERT(char(50), SERVERPROPERTY(''Edition''))AS SQLEdition,
CONVERT(char(20), SERVERPROPERTY(''productversion'')) AS ProductVersion,
CONVERT(char(20), SERVERPROPERTY(''LicenseType''))AS License_Type,
CONVERT(char(20), SERVERPROPERTY(''NumLicenses'')) AS Number_Of_Licenses,
@CDKey AS CDKey
End

Else If charindex(''2008 R2'',@version,1)>0 
Begin
EXEC master.dbo.xp_regread @rootkey=''HKEY_LOCAL_MACHINE'',   
  @key=''SOFTWARE\Microsoft\Microsoft SQL Server\150\Tools\Setup'', 
  @value_name=''ProductID'', @value=@CDKey OUTPUT
SELECT ''SQL 2008 R2'' AS SQLVersion,
CONVERT(char(20), SERVERPROPERTY(''ServerName'')) AS SQL_Service_Name,
@PageFile AS PageFile,
CONVERT(char(50), SERVERPROPERTY(''Edition''))AS SQLEdition,
CONVERT(char(20), SERVERPROPERTY(''productversion'')) AS ProductVersion,
CONVERT(char(20), SERVERPROPERTY(''LicenseType''))AS License_Type,
CONVERT(char(20), SERVERPROPERTY(''NumLicenses'')) AS Number_Of_Licenses,
@CDKey AS CDKey
End
Else
SELECT @version AS SQLVersion,
CONVERT(char(20), SERVERPROPERTY(''ServerName'')) AS SQL_Service_Name,
@PageFile AS PageFile,
CONVERT(char(50), SERVERPROPERTY(''Edition''))AS SQLEdition,
CONVERT(char(20), SERVERPROPERTY(''productversion'')) AS ProductVersion,
CONVERT(char(20), SERVERPROPERTY(''LicenseType''))AS License_Type,
CONVERT(char(20), SERVERPROPERTY(''NumLicenses'')) AS Number_Of_Licenses




select ''Database Information''
go
sp_helpdb
go
select ''Configuration Information''
go
sp_configure ''advanced options'', 1
go
reconfigure with override
go
sp_configure
go
sp_configure ''advanced options'', 0
go
reconfigure with override
go
select ''File Location Information''
go
select fileid, groupid, size, dbid, name, filename from sysaltfiles
go
select ''Login Information''
select * from syslogins
go
use msdb
go
select ''Jobs Information''
select * from sysjobs
go
select ''SSIS Packages''
select distinct name, id, vermajor, verminor, verbuild, description, createdate, ownersid from [dbo].[sysssispackages]
go


use master
go
create table #tblInfo
(

	Parameter	varchar(100),
	MinVal		int,
	MaxVal		int,
	configVal	int,
	run_value	int
)
declare @strSQL varchar(4000)

set @strSQL = ''sp_configure ''''show advanced options'''',1 reconfigure with override''
exec(@strSQL)

insert into #tblInfo exec(''sp_configure'')

set @strSQL = '' sp_configure ''''show advanced options'''',0 reconfigure with override''
exec(@strSQL)

delete #tblInfo where Parameter not in(''awe enabled'',''max server memory (MB)'',''max worker threads'',''min memory per query (KB)'')


select * from #tblInfo -- sp_configure result for selected parameters

drop table #tblInfo

-- Following statement will return version, processor, and total memory. Please refer 
-- column (Name and Character_Value)
exec (''xp_msver ''''ProductVersion'''', ''''ProcessorCount'''', ''''PhysicalMemory'''''')

go
--the following gets drive sizes and free space
select ''Drive Sizes''
SET NOCOUNT ON
DECLARE @hr int
DECLARE @fso int
DECLARE @drive char(1)
DECLARE @odrive int
DECLARE @TotalSize varchar(20)
DECLARE @MB bigint ; SET @MB = 1048576
CREATE TABLE #drives (ServerName varchar(15),
drive char(1) PRIMARY KEY,
FreeSpace int NULL,
TotalSize int NULL,
FreespaceTimestamp DATETIME NULL)
INSERT #drives(drive,FreeSpace)
EXEC master.dbo.xp_fixeddrives
EXEC @hr=sp_OACreate ''Scripting.FileSystemObject'',@fso OUT
IF @hr <> 0 EXEC sp_OAGetErrorInfo @fso
DECLARE dcur CURSOR LOCAL FAST_FORWARD
FOR SELECT drive from #drives
ORDER by drive
OPEN dcur
FETCH NEXT FROM dcur INTO @drive
WHILE @@FETCH_STATUS=0
BEGIN
EXEC @hr = sp_OAMethod @fso,''GetDrive'', @odrive OUT, @drive
IF @hr <> 0 EXEC sp_OAGetErrorInfo @fso
EXEC @hr = sp_OAGetProperty @odrive,''TotalSize'', @TotalSize OUT
IF @hr <> 0 EXEC sp_OAGetErrorInfo @odrive
UPDATE #drives
SET TotalSize=@TotalSize/@MB, ServerName = host_name(), FreespaceTimestamp = (GETDATE())
WHERE drive=@drive
FETCH NEXT FROM dcur INTO @drive
END
CLOSE dcur
DEALLOCATE dcur
EXEC @hr=sp_OADestroy @fso
IF @hr <> 0 EXEC sp_OAGetErrorInfo @fso
SELECT ServerName,
drive,
TotalSize as ''Total(MB)'',
FreeSpace as ''Free(MB)'',
CAST((FreeSpace/(TotalSize*1.0))*100.0 as int) as ''Free(%)'',
FreespaceTimestamp
FROM #drives
ORDER BY drive
DROP TABLE #drives
RETURN
GO

--Get Linked Server Information
select ''Linked Server Information''
use master
SET NOCOUNT ON
DECLARE @this_server VARCHAR(255),
  @server_ct INT,
  @server VARCHAR(255),
     @srvproduct VARCHAR(255),
     @provider VARCHAR(255),
     @datasrc VARCHAR(255),
     @location VARCHAR(255),
     @provstr VARCHAR(255),
     @catalog VARCHAR(255),
  @rpc INT,
  @pub INT,
  @sub INT,
  @dist INT,
  @dpub INT,
  @rpcout INT,
  @dataaccess INT,
  @collationcompatible INT,
  @system INT,
  @userremotecollation INT,
  @lazyschemavalidation INT,
  @collation VARCHAR(255)

CREATE TABLE #outputLog(
   rowId  INT IDENTITY(1, 1),
   outputData VARCHAR(1000))

CREATE TABLE #srvLogin(
   rowId  INT IDENTITY(1, 1),
   linkedServer VARCHAR(255),
   localLogin VARCHAR(255),
   isSelfMapping INT,
   remoteLogin VARCHAR(255))

SELECT @this_server = srvname FROM sysservers WHERE srvid = 0
SELECT @server_ct = 1

WHILE @server_ct <= (SELECT max(srvid) FROM sysservers)
BEGIN
 select 
  @server = srvname,
     @srvproduct = srvproduct,
     @provider = CASE WHEN srvproduct = ''SQL Server'' THEN NULL ELSE providername END,
     @datasrc = CASE WHEN srvproduct = ''SQL Server'' THEN NULL ELSE datasource END,
     @location = CASE WHEN srvproduct = ''SQL Server'' THEN NULL ELSE location END,
     @provstr = CASE WHEN srvproduct = ''SQL Server'' THEN NULL ELSE providerstring END,
     @catalog =  CASE WHEN srvproduct = ''SQL Server'' THEN NULL ELSE catalog END,
  @rpc = rpc,
  @pub = pub,
  @sub = sub,
  @dist = dist,
  @dpub = dpub,
  @rpcout = rpcout,
  @dataaccess = dataaccess,
  @collationcompatible = collationcompatible,
  @system = system,
  @userremotecollation = useremotecollation,
  @lazyschemavalidation = lazyschemavalidation,
  @collation = collation
 from 
  sysservers
 WHERE 
  srvid = @server_ct

 INSERT INTO #outputLog
 SELECT ''EXEC sp_addlinkedserver '''''' + @server + '''''', ''
   + CASE WHEN @srvproduct IS NULL THEN ''NULL'' ELSE '''''''' + @srvproduct + '''''''' END + '', ''
   + CASE WHEN @provider IS NULL THEN ''NULL'' ELSE '''''''' + @provider + '''''''' END + '', ''
   + CASE WHEN @datasrc IS NULL THEN ''NULL'' ELSE '''''''' + @datasrc + '''''''' END + '', ''
   + CASE WHEN @location IS NULL THEN ''NULL'' ELSE '''''''' + @location + '''''''' END + '', ''
   + CASE WHEN @provstr IS NULL THEN ''NULL'' ELSE '''''''' + @provstr + '''''''' END + '', ''
   + CASE WHEN @catalog IS NULL THEN ''NULL'' ELSE '''''''' + @catalog + '''''''' END

 INSERT INTO #outputLog
 SELECT ''EXEC sp_serveroption '''''' + @server + '''''', '''''' + ''rpc'''', '' + CASE WHEN @rpc = 1 THEN ''''''TRUE'''''' ELSE ''''''FALSE'''''' END 

 INSERT INTO #outputLog
 SELECT ''EXEC sp_serveroption '''''' + @server + '''''', '''''' + ''pub'''', '' + CASE WHEN @pub = 1 THEN ''''''TRUE'''''' ELSE ''''''FALSE'''''' END 

 INSERT INTO #outputLog
 SELECT ''EXEC sp_serveroption '''''' + @server + '''''', '''''' + ''sub'''', '' + CASE WHEN @sub = 1 THEN ''''''TRUE'''''' ELSE ''''''FALSE'''''' END 

 INSERT INTO #outputLog
 SELECT ''EXEC sp_serveroption '''''' + @server + '''''', '''''' + ''dist'''', '' + CASE WHEN @dist = 1 THEN ''''''TRUE'''''' ELSE ''''''FALSE'''''' END 

 INSERT INTO #outputLog
 SELECT ''EXEC sp_serveroption '''''' + @server + '''''', '''''' + ''dpub'''', '' + CASE WHEN @dpub = 1 THEN ''''''TRUE'''''' ELSE ''''''FALSE'''''' END 

 INSERT INTO #outputLog
 SELECT ''EXEC sp_serveroption '''''' + @server + '''''', '''''' + ''rpc out'''', '' + CASE WHEN @rpcout = 1 THEN ''''''TRUE'''''' ELSE ''''''FALSE'''''' END 

 INSERT INTO #outputLog
 SELECT ''EXEC sp_serveroption '''''' + @server + '''''', '''''' + ''data access'''', '' + CASE WHEN @dataaccess = 1 THEN ''''''TRUE'''''' ELSE ''''''FALSE'''''' END 

 INSERT INTO #outputLog
 SELECT ''EXEC sp_serveroption '''''' + @server + '''''', '''''' + ''collation compatible'''', '' + CASE WHEN @collationcompatible = 1 THEN ''''''TRUE'''''' ELSE ''''''FALSE'''''' END 

--  INSERT INTO #outputLog
--  SELECT ''EXEC sp_serveroption '''''' + @server + '''''', '''''' + ''system'''', '' + CASE WHEN @system = 1 THEN ''''''TRUE'''''' ELSE ''''''FALSE'''''' END 

 INSERT INTO #outputLog
 SELECT ''EXEC sp_serveroption '''''' + @server + '''''', '''''' + ''use remote collation'''', '' + CASE WHEN @userremotecollation = 1 THEN ''''''TRUE'''''' ELSE ''''''FALSE'''''' END 

 INSERT INTO #outputLog
 SELECT ''EXEC sp_serveroption '''''' + @server + '''''', '''''' + ''lazy schema validation'''', '' + CASE WHEN @lazyschemavalidation = 1 THEN ''''''TRUE'''''' ELSE ''''''FALSE'''''' END 

--  INSERT INTO #outputLog
--  SELECT ''EXEC sp_serveroption '''''' + @server + '''''', '''''' + ''collation'''', '' + CASE WHEN @collation IS NULL THEN ''NULL'' ELSE '''''''' + @collation + '''''''' END + '''' 

 INSERT INTO #srvLogin
 EXEC sp_helplinkedsrvlogin @server

 INSERT INTO #outputLog
 SELECT ''EXEC sp_addlinkedsrvlogin @rmtsrvname = ''+ CASE WHEN linkedServer IS NULL THEN ''NULL'' ELSE '''''''' + linkedServer + '''''''' END
   + '', @useself = '' + CASE WHEN isSelfMapping = 1 THEN ''''''TRUE'''''' ELSE ''''''FALSE'''''' END 
   + '', @locallogin = '' + CASE WHEN localLogin IS NULL THEN ''NULL'' ELSE '''''''' + localLogin + '''''''' END 
   + '', @rmtuser = '' + CASE WHEN remoteLogin IS NULL THEN ''NULL'' ELSE '''''''' + remoteLogin + '''''''' END
   + '', @rmtpassword  = '' + CASE WHEN isSelfMapping = 1 THEN ''NULL'' ELSE ''''''ENTER_PASSWORD_HERE'''''' END
   
 FROM  #srvLogin
 
 DELETE #srvLogin

 SELECT @server_ct = @server_ct + 1
END

SELECT outputData from #outputLog
ORDER BY rowId

DROP TABLE #outputLog
DROP TABLE #srvLogin

--END

--security information
select ''Security Information''
select @@Servername


--run in query analyzer
--execute in text file format
--save as a text file.  This script pulls all data for roles and grants from sql and windows.



SET NOCOUNT ON

IF EXISTS (SELECT * FROM tempdb.dbo.sysobjects WHERE name = ''##Users'' AND type in (N''U''))
 DROP TABLE ##Users;
IF EXISTS (SELECT * FROM tempdb.dbo.sysobjects WHERE name = ''##DBUsers'' AND type in (N''U''))
 DROP TABLE ##DBUsers;

-- ***************************************************************************
-- Always run this from master  --Not needed
-- USE master 
-- ***************************************************************************

-- ***************************************************************************
-- Declare local variables
DECLARE @DBName VARCHAR(75);
DECLARE @SQLCmd VARCHAR(1024);
-- ***************************************************************************

-- ***************************************************************************
-- Get the SQL Server logins
-- Create Temp User table
CREATE TABLE ##Users (
[sid] varbinary(100) NULL,
[Login Name] varchar(100) NULL,
[Default Database] varchar(255) NULL,
[Login Type] varchar(15),
[AD Login Type] varchar(25),
[sysadmin] varchar(3),
[securityadmin] varchar(3),
[serveradmin] varchar(3),
[setupadmin] varchar(3),
[processadmin] varchar(3),
[diskadmin] varchar(3),
[dbcreator] varchar(3),
[bulkadmin] varchar(3));
---------------------------------------------------------
INSERT INTO ##Users SELECT sid,
 loginname AS [Login Name], 
 dbname AS [Default Database],
 CASE isntname 
 WHEN 1 THEN ''AD Login''
 ELSE ''SQL Login''
 END AS [Login Type],
 CASE 
 WHEN isntgroup = 1 THEN ''AD Group''
 WHEN isntuser = 1 THEN ''AD User''
 ELSE ''''
 END AS [AD Login Type],
 CASE sysadmin
 WHEN 1 THEN ''Yes''
 ELSE ''No''
 END AS [sysadmin],
 CASE [securityadmin]
 WHEN 1 THEN ''Yes''
 ELSE ''No''
 END AS [securityadmin],
 CASE [serveradmin]
 WHEN 1 THEN ''Yes''
 ELSE ''No''
 END AS [serveradmin],
 CASE [setupadmin]
 WHEN 1 THEN ''Yes''
 ELSE ''No''
 END AS [setupadmin],
 CASE [processadmin]
 WHEN 1 THEN ''Yes''
 ELSE ''No''
 END AS [processadmin],
 CASE [diskadmin]
 WHEN 1 THEN ''Yes''
 ELSE ''No''
 END AS [diskadmin],
 CASE [dbcreator]
 WHEN 1 THEN ''Yes''
 ELSE ''No''
 END AS [dbcreator],
 CASE [bulkadmin]
 WHEN 1 THEN ''Yes''
 ELSE ''No''
 END AS [bulkadmin]
FROM master.dbo.syslogins;
---------------------------------------------------------
SELECT [Login Name],
 [Default Database], 
 [Login Type],
 [AD Login Type],
 [sysadmin],
 [securityadmin],
 [serveradmin],
 [setupadmin],
 [processadmin],
 [diskadmin],
 [dbcreator],
 [bulkadmin]
FROM ##Users
ORDER BY [Login Type], [AD Login Type], [Login Name]
-- ***************************************************************************
-- ***************************************************************************
-- Create the output table for the Database User ID''s
CREATE TABLE ##DBUsers (
 [Database User ID] VARCHAR(100),
 [Server Login] VARCHAR(100),
 [Database Role] VARCHAR(160),
 [Database] VARCHAR(200));
-- ***************************************************************************
-- ***************************************************************************
-- Declare a cursor to loop through all the databases on the server
DECLARE csrDB CURSOR FOR 
 SELECT name
 FROM master..sysdatabases
 WHERE name NOT IN (''master'', ''model'', ''msdb'', ''tempdb'');
-- ***************************************************************************
-- ***************************************************************************
-- Open the cursor and get the first database name
OPEN csrDB
FETCH NEXT 
 FROM csrDB
 INTO @DBName
-- ***************************************************************************
-- ***************************************************************************
-- Loop through the cursor
WHILE @@FETCH_STATUS = 0
 BEGIN
-- ***************************************************************************
-- ***************************************************************************
-- 
 SELECT @SQLCmd = ''INSERT ##DBUsers '' +
 '' SELECT su.[name] AS [Database User ID], '' +
 '' COALESCE (u.[Login Name], ''''** Orphaned **'''') AS [Server Login], '' +
 '' COALESCE (sug.name, ''''Public'''') AS [Database Role],'' + 
 '''''''' + @DBName + '''''' AS [Database]'' +
 '' FROM ['' + @DBName + ''].[dbo].[sysusers] su'' +
 '' LEFT OUTER JOIN ##Users u'' +
 '' ON su.sid = u.sid'' +
 '' LEFT OUTER JOIN (['' + @DBName + ''].[dbo].[sysmembers] sm '' +
 '' INNER JOIN ['' + @DBName + ''].[dbo].[sysusers] sug '' +
 '' ON sm.groupuid = sug.uid)'' +
 '' ON su.uid = sm.memberuid '' +
 '' WHERE su.hasdbaccess = 1'' +
 '' AND su.[name] != ''''dbo'''' ''
 EXEC (@SQLCmd)
-- ***************************************************************************
-- ***************************************************************************
-- Get the next database name
 FETCH NEXT 
 FROM csrDB
 INTO @DBName
-- ***************************************************************************
-- ***************************************************************************
-- End of the cursor loop
 END
-- ***************************************************************************
-- ***************************************************************************
-- Close and deallocate the CURSOR
CLOSE csrDB
DEALLOCATE csrDB
-- ***************************************************************************
-- ***************************************************************************
-- Return the Database User data
SELECT * 
 FROM ##DBUsers
 ORDER BY [Database User ID],[Database];
-- ***************************************************************************
-- ***************************************************************************
-- Clean up - delete the Global temp tables
IF EXISTS (SELECT * FROM tempdb.dbo.sysobjects WHERE name = ''##Users'' AND type in (N''U''))
 DROP TABLE ##Users;

IF EXISTS (SELECT * FROM tempdb.dbo.sysobjects WHERE name = ''##DBUsers'' AND type in (N''U''))
 DROP TABLE ##DBUsers;
-- ***************************************************************************

GO
--this code pulls all items from the windows admin security group
select ''Windows Administrator Group''
EXEC master..xp_cmdshell ''net localgroup administrators''
go

--pull sql server logins and check for null passwords
--accounts null have no password encryption
select ''SQL Server Accounts/Passwords''
select ''Note:  Anything with no encrypted password needs attention''
select name, password from syslogins
where isntgroup=0 and isntuser=0
go

--sp_help_revlogin output
--Note:  This may not exist in master but if it does--output will be created
--use master
--go
--exec sp_help_revlogin

--this section takes an excerpt of the past 7 days
select ''Backup Report For Past 7 Days''
use msdb
go
select database_name, name, type, backup_finish_date from backupset
where (type=''D'' or type=''I'')
and backup_finish_date > getdate()-7
', 
		@database_name=N'DBA', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Failure Notification]    Script Date: 11/9/2011 5:04:35 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Failure Notification', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=2, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'declare @Subject varchar(50), @Body varchar(100)

set  @Subject = ''Medium - Failed - AutoRunbook''
select @Body = ''Failed at '' + convert(varchar,getdate())

exec DBA..usp_dba_SendMail ''AUTORUNBOOK'', @Subject, @Body', 
		@database_name=N'DBA', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Daily @ 1 AM', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20061027, 
		@active_end_date=99991231, 
		@active_start_time=10000, 
		@active_end_time=235959, 
		@schedule_uid=N'6294951e-6691-45bc-9ef0-db5aacd9615f'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO
