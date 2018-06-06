DECLARE 
		@db_full_bkup_location	varchar(150),
		@db_diff_bkup_location	varchar(150),
		@db_tran_bkup_location	varchar(150),
		@db_job_output_location	varchar(150),
		@SMTPServer		varchar(100),
		@MailFrom		varchar(500),
		@DefaultEmailTo		varchar(2000),
		@strSQL1		varchar(1100),
		@strSQL2		varchar(1100),
		@strSQL3		varchar(1100),
		@version		varchar(2000)
	

	--*************Value for Backup Location***********************

	set @db_full_bkup_location	= 'P:\SQLBackup\RyderDBA' 
	set @db_diff_bkup_location	= 'P:\SQLBackup\RyderDBA'
	set @db_tran_bkup_location	= 'P:\SQLBackup\RyderDBA'
	set @db_job_output_location	= 'P:\SQLBackup\RyderDBA'

	--*************************************************************

	--*************Value for SMTP Server Config Setting************

	set @SMTPServer				= 'rydersendmailrelay.ryder.com'
	set @MailFrom				= 'ryder_dba@ryder.com'

	--****************************************************************

	--*************Value for Default Recepient**********************

	set @DefaultEmailTo = 'ryder_dba@ryder.com'

	--***************************************************************

					set @strSQL1 = 'set nocount on '
					set @strSQL1 = @strSQL1 + ' IF NOT EXISTS(select 1 from DBA..tbl_dba_maint_file_location)'
					set @strSQL1 = @strSQL1 + ' begin'
					set @strSQL1 = @strSQL1 + ' insert into DBA..tbl_dba_maint_file_location(db_full_bkup_location, db_diff_bkup_location, db_tran_bkup_location, db_job_output_location)'
					set @strSQL1 = @strSQL1 + ' values(''' + @db_full_bkup_location + ''',''' + @db_diff_bkup_location + ''',''' + @db_tran_bkup_location + ''',''' + @db_job_output_location + ''')'
					set @strSQL1 = @strSQL1 + ' PRINT ''Backup Locations are Specified'''
					set @strSQL1 = @strSQL1 + ' end'
					set @strSQL1 = @strSQL1 + ' else begin'
					set @strSQL1 = @strSQL1 + ' print ''Backup Locations are already specified'' end'

					set @strSQL1 = @strSQL1 + ' IF NOT EXISTS(select 1 from DBA..tbl_dba_SMTPServer_Config)'
					set @strSQL1 = @strSQL1 + ' begin'
					set @strSQL1 = @strSQL1 + ' insert into DBA..tbl_dba_SMTPServer_Config (SMTPServer, MailFrom)'
					set @strSQL1 = @strSQL1 + ' values (''' + @SMTPServer + ''',''' + @MailFrom + ''')'
					set @strSQL1 = @strSQL1 + ' print ''SMTP Server Detail Specified'''
					set @strSQL1 = @strSQL1 + ' end'
					set @strSQL1 = @strSQL1 + ' else'
					set @strSQL1 = @strSQL1 + ' print ''SMTP Server Detail already exist'''
					set @strSQL1 = @strSQL1 + ' truncate table DBA..tbl_dba_Block_Interval_Config'
					set @strSQL1 = @strSQL1 + ' insert into DBA..tbl_dba_Block_Interval_Config (BlockInterval)'
					set @strSQL1 = @strSQL1 + ' values(120)'
					set @strSQL1 = @strSQL1 + ' print ''Default Block Interval is set to 120 Seconds'''
exec (@strSQL1)
--===========================================================================================================
					
					set @strSQL2 = 'set nocount on'
					set @strSQL2 = @strSQL2 + ' insert into DBA..tbl_dba_Alert_Config(EmailTo,AlertType) '
					set @strSQL2 = @strSQL2 + ' values(''' + @DefaultEmailTo + ''',''ConfigCheck'')'
					set @strSQL2 = @strSQL2 + ' insert into DBA..tbl_dba_Alert_Config(EmailTo,AlertType)'
					set @strSQL2 = @strSQL2 + ' values(''' + @DefaultEmailTo + ''',''LogSpace'')'
					set @strSQL2 = @strSQL2 + ' insert into DBA..tbl_dba_Alert_Config(EmailTo,AlertType) '
					set @strSQL2 = @strSQL2 + ' values(''' + @DefaultEmailTo + ''',''LoginScript'')'
					set @strSQL2 = @strSQL2 + ' insert into DBA..tbl_dba_Alert_Config(EmailTo,AlertType) '
					set @strSQL2 = @strSQL2 + ' values(''' + @DefaultEmailTo + ''',''Login'')'
					set @strSQL2 = @strSQL2 + ' insert into DBA..tbl_dba_Alert_Config(EmailTo,AlertType) '
					set @strSQL2 = @strSQL2 + ' values(''' + @DefaultEmailTo + ''',''DiskSpace'')'
					set @strSQL2 = @strSQL2 + ' insert into DBA..tbl_dba_Alert_Config(EmailTo,AlertType) '
					set @strSQL2 = @strSQL2 + ' values(''' + @DefaultEmailTo + ''',''Backup'')'
					set @strSQL2 = @strSQL2 + ' insert into DBA..tbl_dba_Alert_Config(EmailTo,AlertType) '
					set @strSQL2 = @strSQL2 + ' values(''' + @DefaultEmailTo + ''',''Block'')'
					set @strSQL2 = @strSQL2 + ' insert into DBA..tbl_dba_Alert_Config(EmailTo,AlertType) '
					set @strSQL2 = @strSQL2 + ' values(''' + @DefaultEmailTo + ''',''DBCC'')'
					set @strSQL2 = @strSQL2 + ' print ''Default Receipient: ' + @DefaultEmailTo + ''''
--=========================================================================================================
exec (@strSQL2)
					set @strSQL3 = 'set nocount on '
					set @strSQL3 = @strSQL3 + ' exec DBA..usp_tbl_dba_maintenance_u ' -- populate database

					select @version = @@version
					
					if (charindex('2005',@version,1)>0) OR (charindex('2008',@version,1)>0) or (charindex('2012',@version,1)>0)
					begin

						set @strSQL3 = @strSQL3 + 'update DBA..tbl_dba_maintenance_config'
						set @strSQL3 = @strSQL3 + ' set xreindex = ''N'', xAlterIndex = ''Y'''
						set @strSQL3 = @strSQL3 + ' where xdatabase not in(''DBA'',''tempdb'')'
						set @strSQL3 = @strSQL3 + ' PRINT ''ALTER INDEX has been turned ON'''
					end
					else
					begin
							set @strSQL3 = @strSQL3 + ' update DBA..tbl_dba_maintenance_config ' -- flag off dba from reindex
							set @strSQL3 = @strSQL3 + ' set xreindex = ''N'''
							set @strSQL3 = @strSQL3 + ' where xdatabase = ''DBA'''
							set @strSQL3 = @strSQL3 + ' PRINT ''DBA database has been taken out from DBREINDEX process'''
					end					
exec (@strSQL3)
GO
USE [DBA]
GO
DECLARE @Result varchar(20);
DECLARE @lRootID int;
DECLARE @lParentID int;

SET @Result = NULL;

IF OBJECT_ID('tempdb..#tbl_result','U') IS NOT NULL
	DROP TABLE #tbl_result
	
CREATE TABLE #tbl_result(
	[ID] int identity(1,1) not null,
	[RootID] int,
	[ParentID] int,
	[Status] varchar(50), --'Ok', 'Incompatible', 'Missing', 'Validating', 'Already exists', NULL
	[Module] varchar(50),
	[ParentModule] varchar(50),
	[Message] varchar(255))

DECLARE @version varchar(47)
SELECT @version = @@version

--Checking if the log shipping fix is installed...
DECLARE @lModule varchar(50);
SET @lModule = 'Logshipping-Fix installed';

insert into #tbl_result ([Status], [Module], [Message]) values ('Validating', @lModule, 'Checking if the log shipping fix is installed...')
SET @lRootID = SCOPE_IDENTITY();


IF charindex('2000',@version,1)>0 
BEGIN
	--Checking procedure dbo.usp_tbl_dba_maintenance_u
	IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_tbl_dba_maintenance_u]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Ok', 'usp_tbl_dba_maintenance_u', @lModule, 'procedure dbo.usp_tbl_dba_maintenance_u')
	ELSE
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Missing', 'usp_tbl_dba_maintenance_u', @lModule, 'procedure dbo.usp_tbl_dba_maintenance_u')

	--Checking procedure dbo.usp_tbl_dba_log_backup
	IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_tbl_dba_log_backup]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Ok', 'usp_tbl_dba_log_backup', @lModule, 'procedure dbo.usp_tbl_dba_log_backup')
	ELSE
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Missing', 'usp_tbl_dba_log_backup', @lModule, 'procedure dbo.usp_tbl_dba_log_backup')

	--Checking procedure dbo.usp_dba_CallLogShippingBackupJob
	IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_dba_CallLogShippingBackupJob]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Ok', 'usp_dba_CallLogShippingBackupJob', @lModule, 'procedure dbo.usp_dba_CallLogShippingBackupJob')
	ELSE
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Missing', 'usp_dba_CallLogShippingBackupJob', @lModule, 'procedure dbo.usp_dba_CallLogShippingBackupJob')

	--Checking procedure dbo.usp_dba_CheckLogSpace
	IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_dba_CheckLogSpace]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Ok', 'usp_dba_CheckLogSpace', @lModule, 'procedure dbo.usp_dba_CheckLogSpace')
	ELSE
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Missing', 'usp_dba_CheckLogSpace', @lModule, 'procedure dbo.usp_dba_CheckLogSpace')

	--Checking function dbo.ufn_dba_IsLogShippingDatabase
	IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[ufn_dba_IsLogShippingDatabase]') AND xtype in (N'FN', N'IF', N'TF'))
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Ok', 'ufn_dba_IsLogShippingDatabase', @lModule, 'function dbo.ufn_dba_IsLogShippingDatabase')
	ELSE
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Missing', 'ufn_dba_IsLogShippingDatabase', @lModule, 'function dbo.ufn_dba_IsLogShippingDatabase')
	
	--Checking function dbo.ufn_dba_getMajorVersion
	IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[ufn_dba_getMajorVersion]') AND xtype in (N'FN', N'IF', N'TF'))
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Ok', 'ufn_dba_getMajorVersion', @lModule, 'function dbo.ufn_dba_getMajorVersion')
	ELSE
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Missing', 'ufn_dba_getMajorVersion', @lModule, 'function dbo.ufn_dba_getMajorVersion')
end
else
begin
	--Checking procedure dbo.usp_tbl_dba_maintenance_u
	IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_tbl_dba_maintenance_u]') AND type in (N'P', N'PC'))
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Ok', 'usp_tbl_dba_maintenance_u', @lModule, 'procedure dbo.usp_tbl_dba_maintenance_u')
	ELSE
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Missing', 'usp_tbl_dba_maintenance_u', @lModule, 'procedure dbo.usp_tbl_dba_maintenance_u')
	
	--Checking procedure dbo.usp_tbl_dba_log_backup
	IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_tbl_dba_log_backup]') AND type in (N'P', N'PC'))
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Ok', 'usp_tbl_dba_log_backup', @lModule, 'procedure dbo.usp_tbl_dba_log_backup')
	ELSE
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Missing', 'usp_tbl_dba_log_backup', @lModule, 'procedure dbo.usp_tbl_dba_log_backup')
	
	--Checking procedure dbo.usp_dba_CallLogShippingBackupJob
	IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_dba_CallLogShippingBackupJob]') AND type in (N'P', N'PC'))
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Ok', 'usp_dba_CallLogShippingBackupJob', @lModule, 'procedure dbo.usp_dba_CallLogShippingBackupJob')
	ELSE
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Missing', 'usp_dba_CallLogShippingBackupJob', @lModule, 'procedure dbo.usp_dba_CallLogShippingBackupJob')
	
	--Checking procedure dbo.usp_dba_CheckLogSpace
	IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_dba_CheckLogSpace]') AND type in (N'P', N'PC'))
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Ok', 'usp_dba_CheckLogSpace', @lModule, 'procedure dbo.usp_dba_CheckLogSpace')
	ELSE
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Missing', 'usp_dba_CheckLogSpace', @lModule, 'procedure dbo.usp_dba_CheckLogSpace')

	--Checking function dbo.ufn_dba_IsLogShippingDatabase
	IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ufn_dba_IsLogShippingDatabase]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Ok', 'ufn_dba_IsLogShippingDatabase', @lModule, 'function dbo.ufn_dba_IsLogShippingDatabase')
	ELSE
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Missing', 'ufn_dba_IsLogShippingDatabase', @lModule, 'function dbo.ufn_dba_IsLogShippingDatabase')
	
	--Checking function dbo.ufn_dba_getMajorVersion
	IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ufn_dba_getMajorVersion]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Ok', 'ufn_dba_getMajorVersion', @lModule, 'function dbo.ufn_dba_getMajorVersion')
	ELSE
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Missing', 'ufn_dba_getMajorVersion', @lModule, 'function dbo.ufn_dba_getMajorVersion')
end

IF exists (Select top 1 * from #tbl_result where [Status] <> 'Ok' and [RootID] = @lRootID)
	update #tbl_result set [Status] = 'Not installed or missing objects' where Module = @lModule and ParentModule is Null
ELSE
	update #tbl_result set [Status] = 'Ok' where Module = @lModule and ParentModule is Null

------------------------------------Validate if the DBA database might accept the log shipping fix------------------------------------

SET @lModule = 'Logshipping-Fix Compatible';

insert into #tbl_result ([Status], [Module], [Message]) values ('Validating', @lModule, 'Checking if the log shipping fix can be installed...')
SET @lRootID = SCOPE_IDENTITY();			

IF charindex('2000',@version,1)>0 
BEGIN
	--Checking table dbo.usp_tbl_dba_maintenance_u
	IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[tbl_dba_maint_file_location]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Ok', 'tbl_dba_maint_file_location', @lModule, 'table dbo.tbl_dba_maint_file_location')
	ELSE
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Missing', 'tbl_dba_maint_file_location', @lModule, 'table dbo.tbl_dba_maint_file_location')
		
	SET @lParentID = SCOPE_IDENTITY();
	
		IF EXISTS(Select * from dbo.syscolumns where id = OBJECT_ID(N'[dbo].[tbl_dba_maint_file_location]') and name = 'db_tran_bkup_location')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'db_tran_bkup_location', 'tbl_dba_maint_file_location', 'column dbo.tbl_dba_maint_file_location.db_tran_bkup_location')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'db_tran_bkup_location', 'tbl_dba_maint_file_location', 'column dbo.tbl_dba_maint_file_location.db_tran_bkup_location')
		
	--Checking procedure dbo.usp_dba_CallLogShippingBackupJob
	IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_dba_CallLogShippingBackupJob]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Already exists', 'usp_dba_CallLogShippingBackupJob', @lModule, 'procedure dbo.usp_dba_CallLogShippingBackupJob')
	ELSE
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Ok', 'usp_dba_CallLogShippingBackupJob', @lModule, 'procedure dbo.usp_dba_CallLogShippingBackupJob')

	--Checking function dbo.ufn_dba_IsLogShippingDatabase
	IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[ufn_dba_IsLogShippingDatabase]') AND xtype in (N'FN', N'IF', N'TF'))
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Already exists', 'ufn_dba_IsLogShippingDatabase', @lModule, 'function dbo.ufn_dba_IsLogShippingDatabase')
	ELSE
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Ok', 'ufn_dba_IsLogShippingDatabase', @lModule, 'function dbo.ufn_dba_IsLogShippingDatabase')

	--Checking procedure dbo.usp_tbl_dba_maintenance_u
	IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_tbl_dba_maintenance_u]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Ok', 'usp_tbl_dba_maintenance_u', @lModule, 'procedure dbo.usp_tbl_dba_maintenance_u')
	ELSE
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Missing', 'usp_tbl_dba_maintenance_u', @lModule, 'procedure dbo.usp_tbl_dba_maintenance_u')
	
	IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[tbl_dba_maintenance_config]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Ok', 'tbl_dba_maintenance_config', @lModule, 'table dbo.tbl_dba_maintenance_config')
	ELSE
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Missing', 'tbl_dba_maintenance_config', @lModule, 'table dbo.tbl_dba_maintenance_config')
		
	SET @lParentID = SCOPE_IDENTITY();
	
		IF EXISTS(Select * from dbo.syscolumns where id = OBJECT_ID(N'[dbo].[tbl_dba_maintenance_config]') and name = 'xdatabase')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'xdatabase', 'tbl_dba_maintenance_config', 'column dbo.tbl_dba_maintenance_config.xdatabase')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'xdatabase', 'tbl_dba_maintenance_config', 'column dbo.tbl_dba_maintenance_config.xdatabase')

		IF EXISTS(Select * from dbo.syscolumns where id = OBJECT_ID(N'[dbo].[tbl_dba_maintenance_config]') and name = 'xfull')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'xfull', 'tbl_dba_maintenance_config', 'column dbo.tbl_dba_maintenance_config.xfull')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'xfull', 'tbl_dba_maintenance_config', 'column dbo.tbl_dba_maintenance_config.xfull')

		IF EXISTS(Select * from dbo.syscolumns where id = OBJECT_ID(N'[dbo].[tbl_dba_maintenance_config]') and name = 'xdiff')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'xdiff', 'tbl_dba_maintenance_config', 'column dbo.tbl_dba_maintenance_config.xdiff')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'xdiff', 'tbl_dba_maintenance_config', 'column dbo.tbl_dba_maintenance_config.xdiff')

		IF EXISTS(Select * from dbo.syscolumns where id = OBJECT_ID(N'[dbo].[tbl_dba_maintenance_config]') and name = 'xskip')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'xskip', 'tbl_dba_maintenance_config', 'column dbo.tbl_dba_maintenance_config.xskip')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'xskip', 'tbl_dba_maintenance_config', 'column dbo.tbl_dba_maintenance_config.xskip')

		IF EXISTS(Select * from dbo.syscolumns where id = OBJECT_ID(N'[dbo].[tbl_dba_maintenance_config]') and name = 'xlog')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'xlog', 'tbl_dba_maintenance_config', 'column dbo.tbl_dba_maintenance_config.xlog')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'xlog', 'tbl_dba_maintenance_config', 'column dbo.tbl_dba_maintenance_config.xlog')

		IF EXISTS(Select * from dbo.syscolumns where id = OBJECT_ID(N'[dbo].[tbl_dba_maintenance_config]') and name = 'create_dt')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'create_dt', 'tbl_dba_maintenance_config', 'column dbo.tbl_dba_maintenance_config.create_dt')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'create_dt', 'tbl_dba_maintenance_config', 'column dbo.tbl_dba_maintenance_config.create_dt')

		IF EXISTS(Select * from dbo.syscolumns where id = OBJECT_ID(N'[dbo].[tbl_dba_maintenance_config]') and name = 'drop_dt')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'drop_dt', 'tbl_dba_maintenance_config', 'column dbo.tbl_dba_maintenance_config.drop_dt')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'drop_dt', 'tbl_dba_maintenance_config', 'column dbo.tbl_dba_maintenance_config.drop_dt')

		IF EXISTS(Select * from dbo.syscolumns where id = OBJECT_ID(N'[dbo].[tbl_dba_maintenance_config]') and name = 'xskipManual')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'xskipManual', 'tbl_dba_maintenance_config', 'column dbo.tbl_dba_maintenance_config.xskipManual')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'xskipManual', 'tbl_dba_maintenance_config', 'column dbo.tbl_dba_maintenance_config.xskipManual')

		IF EXISTS(Select * from dbo.syscolumns where id = OBJECT_ID(N'[dbo].[tbl_dba_maintenance_config]') and name = 'xreindex')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'xreindex', 'tbl_dba_maintenance_config', 'column dbo.tbl_dba_maintenance_config.xreindex')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'xreindex', 'tbl_dba_maintenance_config', 'column dbo.tbl_dba_maintenance_config.xreindex')

		IF EXISTS(Select * from dbo.syscolumns where id = OBJECT_ID(N'[dbo].[tbl_dba_maintenance_config]') and name = 'xReindexLimit')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'xReindexLimit', 'tbl_dba_maintenance_config', 'column dbo.tbl_dba_maintenance_config.xReindexLimit')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'xReindexLimit', 'tbl_dba_maintenance_config', 'column dbo.tbl_dba_maintenance_config.xReindexLimit')

		IF EXISTS(Select * from dbo.syscolumns where id = OBJECT_ID(N'[dbo].[tbl_dba_maintenance_config]') and name = 'xskipManual')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'xskipManual', 'tbl_dba_maintenance_config', 'column dbo.tbl_dba_maintenance_config.xskipManual')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'xskipManual', 'tbl_dba_maintenance_config', 'column dbo.tbl_dba_maintenance_config.xskipManual')

		IF EXISTS(Select * from dbo.syscolumns where id = OBJECT_ID(N'[dbo].[tbl_dba_maintenance_config]') and name = 'xskipManual')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'xskipManual', 'tbl_dba_maintenance_config', 'column dbo.tbl_dba_maintenance_config.xskipManual')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'xskipManual', 'tbl_dba_maintenance_config', 'column dbo.tbl_dba_maintenance_config.xskipManual')

		IF EXISTS(Select * from dbo.syscolumns where id = OBJECT_ID(N'[dbo].[tbl_dba_maintenance_config]') and name = 'xFileGroup')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'xFileGroup', 'tbl_dba_maintenance_config', 'column dbo.tbl_dba_maintenance_config.xFileGroup')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'xFileGroup', 'tbl_dba_maintenance_config', 'column dbo.tbl_dba_maintenance_config.xFileGroup')

		IF EXISTS(Select * from dbo.syscolumns where id = OBJECT_ID(N'[dbo].[tbl_dba_maintenance_config]') and name = 'xMultiBkupPlan')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'xMultiBkupPlan', 'tbl_dba_maintenance_config', 'column dbo.tbl_dba_maintenance_config.xMultiBkupPlan')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'xMultiBkupPlan', 'tbl_dba_maintenance_config', 'column dbo.tbl_dba_maintenance_config.xMultiBkupPlan')

		IF EXISTS(Select * from dbo.syscolumns where id = OBJECT_ID(N'[dbo].[tbl_dba_maintenance_config]') and name = 'xLogSpaceLimit')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'xLogSpaceLimit', 'tbl_dba_maintenance_config', 'column dbo.tbl_dba_maintenance_config.xLogSpaceLimit')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'xLogSpaceLimit', 'tbl_dba_maintenance_config', 'column dbo.tbl_dba_maintenance_config.xLogSpaceLimit')

	IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[tbl_dba_BackupPlan_History]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Ok', 'tbl_dba_BackupPlan_History', @lModule, 'table dbo.tbl_dba_BackupPlan_History')
	ELSE
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Missing', 'tbl_dba_BackupPlan_History', @lModule, 'table dbo.tbl_dba_BackupPlan_History')

	SET @lParentID = SCOPE_IDENTITY();
	
		IF EXISTS(Select * from dbo.syscolumns where id = OBJECT_ID(N'[dbo].[tbl_dba_BackupPlan_History]') and name = 'xdatabase')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'xdatabase', 'tbl_dba_BackupPlan_History', 'column dbo.tbl_dba_BackupPlan_History.xdatabase')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'xdatabase', 'tbl_dba_BackupPlan_History', 'column dbo.tbl_dba_BackupPlan_History.xdatabase')

		IF EXISTS(Select * from dbo.syscolumns where id = OBJECT_ID(N'[dbo].[tbl_dba_BackupPlan_History]') and name = 'xfilegroup')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'xfilegroup', 'tbl_dba_BackupPlan_History', 'column dbo.tbl_dba_BackupPlan_History.xfilegroup')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'xfilegroup', 'tbl_dba_BackupPlan_History', 'column dbo.tbl_dba_BackupPlan_History.xfilegroup')

		IF EXISTS(Select * from dbo.syscolumns where id = OBJECT_ID(N'[dbo].[tbl_dba_BackupPlan_History]') and name = 'xdaily')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'xdaily', 'tbl_dba_BackupPlan_History', 'column dbo.tbl_dba_BackupPlan_History.xdaily')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'xdaily', 'tbl_dba_BackupPlan_History', 'column dbo.tbl_dba_BackupPlan_History.xdaily')

		IF EXISTS(Select * from dbo.syscolumns where id = OBJECT_ID(N'[dbo].[tbl_dba_BackupPlan_History]') and name = 'xweekly')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'xweekly', 'tbl_dba_BackupPlan_History', 'column dbo.tbl_dba_BackupPlan_History.xweekly')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'xweekly', 'tbl_dba_BackupPlan_History', 'column dbo.tbl_dba_BackupPlan_History.xweekly')

		IF EXISTS(Select * from dbo.syscolumns where id = OBJECT_ID(N'[dbo].[tbl_dba_BackupPlan_History]') and name = 'xwdayname')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'xwdayname', 'tbl_dba_BackupPlan_History', 'column dbo.tbl_dba_BackupPlan_History.xwdayname')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'xwdayname', 'tbl_dba_BackupPlan_History', 'column dbo.tbl_dba_BackupPlan_History.xwdayname')

		IF EXISTS(Select * from dbo.syscolumns where id = OBJECT_ID(N'[dbo].[tbl_dba_BackupPlan_History]') and name = 'xmonthly')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'xmonthly', 'tbl_dba_BackupPlan_History', 'column dbo.tbl_dba_BackupPlan_History.xmonthly')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'xmonthly', 'tbl_dba_BackupPlan_History', 'column dbo.tbl_dba_BackupPlan_History.xmonthly')

		IF EXISTS(Select * from dbo.syscolumns where id = OBJECT_ID(N'[dbo].[tbl_dba_BackupPlan_History]') and name = 'xwofmonth')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'xwofmonth', 'tbl_dba_BackupPlan_History', 'column dbo.tbl_dba_BackupPlan_History.xwofmonth')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'xwofmonth', 'tbl_dba_BackupPlan_History', 'column dbo.tbl_dba_BackupPlan_History.xwofmonth')

		IF EXISTS(Select * from dbo.syscolumns where id = OBJECT_ID(N'[dbo].[tbl_dba_BackupPlan_History]') and name = 'xmdayname')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'xmdayname', 'tbl_dba_BackupPlan_History', 'column dbo.tbl_dba_BackupPlan_History.xmdayname')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'xmdayname', 'tbl_dba_BackupPlan_History', 'column dbo.tbl_dba_BackupPlan_History.xmdayname')

		IF EXISTS(Select * from dbo.syscolumns where id = OBJECT_ID(N'[dbo].[tbl_dba_BackupPlan_History]') and name = 'xsequence')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'xsequence', 'tbl_dba_BackupPlan_History', 'column dbo.tbl_dba_BackupPlan_History.xsequence')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'xsequence', 'tbl_dba_BackupPlan_History', 'column dbo.tbl_dba_BackupPlan_History.xsequence')

		IF EXISTS(Select * from dbo.syscolumns where id = OBJECT_ID(N'[dbo].[tbl_dba_BackupPlan_History]') and name = 'xbkuptype')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'xbkuptype', 'tbl_dba_BackupPlan_History', 'column dbo.tbl_dba_BackupPlan_History.xbkuptype')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'xbkuptype', 'tbl_dba_BackupPlan_History', 'column dbo.tbl_dba_BackupPlan_History.xbkuptype')

		IF EXISTS(Select * from dbo.syscolumns where id = OBJECT_ID(N'[dbo].[tbl_dba_BackupPlan_History]') and name = 'xalterdate')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'xalterdate', 'tbl_dba_BackupPlan_History', 'column dbo.tbl_dba_BackupPlan_History.xalterdate')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'xalterdate', 'tbl_dba_BackupPlan_History', 'column dbo.tbl_dba_BackupPlan_History.xalterdate')

	IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[tbl_dba_BackupPlan]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Ok', 'tbl_dba_BackupPlan', @lModule, 'table dbo.tbl_dba_BackupPlan')
	ELSE
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Missing', 'tbl_dba_BackupPlan', @lModule, 'table dbo.tbl_dba_BackupPlan')

	SET @lParentID = SCOPE_IDENTITY();
	
		IF EXISTS(Select * from dbo.syscolumns where id = OBJECT_ID(N'[dbo].[tbl_dba_BackupPlan]') and name = 'xdatabase')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'xdatabase', 'tbl_dba_BackupPlan', 'column dbo.tbl_dba_BackupPlan.xdatabase')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'xdatabase', 'tbl_dba_BackupPlan', 'column dbo.tbl_dba_BackupPlan.xdatabase')

		IF EXISTS(Select * from dbo.syscolumns where id = OBJECT_ID(N'[dbo].[tbl_dba_BackupPlan]') and name = 'xfilegroup')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'xfilegroup', 'tbl_dba_BackupPlan', 'column dbo.tbl_dba_BackupPlan.xfilegroup')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'xfilegroup', 'tbl_dba_BackupPlan', 'column dbo.tbl_dba_BackupPlan.xfilegroup')

		IF EXISTS(Select * from dbo.syscolumns where id = OBJECT_ID(N'[dbo].[tbl_dba_BackupPlan]') and name = 'xdaily')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'xdaily', 'tbl_dba_BackupPlan', 'column dbo.tbl_dba_BackupPlan.xdaily')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'xdaily', 'tbl_dba_BackupPlan', 'column dbo.tbl_dba_BackupPlan.xdaily')

		IF EXISTS(Select * from dbo.syscolumns where id = OBJECT_ID(N'[dbo].[tbl_dba_BackupPlan]') and name = 'xweekly')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'xweekly', 'tbl_dba_BackupPlan', 'column dbo.tbl_dba_BackupPlan.xweekly')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'xweekly', 'tbl_dba_BackupPlan', 'column dbo.tbl_dba_BackupPlan.xweekly')

		IF EXISTS(Select * from dbo.syscolumns where id = OBJECT_ID(N'[dbo].[tbl_dba_BackupPlan]') and name = 'xwdayname')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'xwdayname', 'tbl_dba_BackupPlan', 'column dbo.tbl_dba_BackupPlan.xwdayname')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'xwdayname', 'tbl_dba_BackupPlan', 'column dbo.tbl_dba_BackupPlan.xwdayname')

		IF EXISTS(Select * from dbo.syscolumns where id = OBJECT_ID(N'[dbo].[tbl_dba_BackupPlan]') and name = 'xmonthly')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'xmonthly', 'tbl_dba_BackupPlan', 'column dbo.tbl_dba_BackupPlan.xmonthly')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'xmonthly', 'tbl_dba_BackupPlan', 'column dbo.tbl_dba_BackupPlan.xmonthly')

		IF EXISTS(Select * from dbo.syscolumns where id = OBJECT_ID(N'[dbo].[tbl_dba_BackupPlan]') and name = 'xwofmonth')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'xwofmonth', 'tbl_dba_BackupPlan', 'column dbo.tbl_dba_BackupPlan.xwofmonth')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'xwofmonth', 'tbl_dba_BackupPlan', 'column dbo.tbl_dba_BackupPlan.xwofmonth')

		IF EXISTS(Select * from dbo.syscolumns where id = OBJECT_ID(N'[dbo].[tbl_dba_BackupPlan]') and name = 'xmdayname')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'xmdayname', 'tbl_dba_BackupPlan', 'column dbo.tbl_dba_BackupPlan.xmdayname')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'xmdayname', 'tbl_dba_BackupPlan', 'column dbo.tbl_dba_BackupPlan.xmdayname')

		IF EXISTS(Select * from dbo.syscolumns where id = OBJECT_ID(N'[dbo].[tbl_dba_BackupPlan]') and name = 'xsequence')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'xsequence', 'tbl_dba_BackupPlan', 'column dbo.tbl_dba_BackupPlan.xsequence')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'xsequence', 'tbl_dba_BackupPlan', 'column dbo.tbl_dba_BackupPlan.xsequence')

		IF EXISTS(Select * from dbo.syscolumns where id = OBJECT_ID(N'[dbo].[tbl_dba_BackupPlan]') and name = 'xbkuptype')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'xbkuptype', 'tbl_dba_BackupPlan', 'column dbo.tbl_dba_BackupPlan.xbkuptype')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'xbkuptype', 'tbl_dba_BackupPlan', 'column dbo.tbl_dba_BackupPlan.xbkuptype')

	IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[tbl_dba_full_backup_completed]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Ok', 'tbl_dba_full_backup_completed', @lModule, 'table dbo.tbl_dba_full_backup_completed')
	ELSE
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Missing', 'tbl_dba_full_backup_completed', @lModule, 'table dbo.tbl_dba_full_backup_completed')
		
	SET @lParentID = SCOPE_IDENTITY();
	
		IF EXISTS(Select * from dbo.syscolumns where id = OBJECT_ID(N'[dbo].[tbl_dba_full_backup_completed]') and name = 'xdatabase')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'xdatabase', 'tbl_dba_full_backup_completed', 'column dbo.tbl_dba_full_backup_completed.xdatabase')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'xdatabase', 'tbl_dba_full_backup_completed', 'column dbo.tbl_dba_full_backup_completed.xdatabase')

		IF EXISTS(Select * from dbo.syscolumns where id = OBJECT_ID(N'[dbo].[tbl_dba_full_backup_completed]') and name = 'starttime')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'starttime', 'tbl_dba_full_backup_completed', 'column dbo.tbl_dba_full_backup_completed.starttime')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'starttime', 'tbl_dba_full_backup_completed', 'column dbo.tbl_dba_full_backup_completed.starttime')

	IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_dba_GSMID_Setting]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Ok', 'usp_dba_GSMID_Setting', @lModule, 'procedure dbo.usp_dba_GSMID_Setting')
	ELSE
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Missing', 'usp_dba_GSMID_Setting', @lModule, 'procedure dbo.usp_dba_GSMID_Setting')

	IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_dba_CheckLogSpace]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Ok', 'usp_dba_CheckLogSpace', @lModule, 'procedure dbo.usp_dba_CheckLogSpace')
	ELSE
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Missing', 'usp_dba_CheckLogSpace', @lModule, 'procedure dbo.usp_dba_CheckLogSpace')

	--Checking procedure dbo.usp_dba_CallLogShippingBackupJob
	IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_tbl_dba_log_backup]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Ok', 'usp_tbl_dba_log_backup', @lModule, 'procedure dbo.usp_tbl_dba_log_backup')
	ELSE
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Missing', 'usp_tbl_dba_log_backup', @lModule, 'procedure dbo.usp_tbl_dba_log_backup')

	SET @lParentID = SCOPE_IDENTITY();
	
		IF EXISTS(Select * from syscolumns where id = OBJECT_ID(N'[dbo].[usp_tbl_dba_log_backup]') and name = '@database')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', '@database', 'usp_tbl_dba_log_backup', 'parameter dbo.usp_tbl_dba_log_backup.@database')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', '@database', 'usp_tbl_dba_log_backup', 'parameter dbo.usp_tbl_dba_log_backup.@database')

		IF EXISTS(Select * from syscolumns where id = OBJECT_ID(N'[dbo].[usp_tbl_dba_log_backup]') and name = '@execute')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', '@execute', 'usp_tbl_dba_log_backup', 'parameter dbo.usp_tbl_dba_log_backup.@execute')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', '@execute', 'usp_tbl_dba_log_backup', 'parameter dbo.usp_tbl_dba_log_backup.@execute')

	--Checking function dbo.ufn_dba_getMajorVersion
	IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[ufn_dba_getMajorVersion]') AND xtype in (N'FN', N'IF', N'TF'))
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Already exists', 'ufn_dba_getMajorVersion', @lModule, 'function dbo.ufn_dba_getMajorVersion')
	ELSE
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Ok', 'ufn_dba_getMajorVersion', @lModule, 'function dbo.ufn_dba_getMajorVersion')
END
ELSE
BEGIN
	--Checking table dbo.usp_tbl_dba_maintenance_u
	IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbl_dba_maint_file_location]') AND type in (N'U'))
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Ok', 'tbl_dba_maint_file_location', @lModule, 'table dbo.tbl_dba_maint_file_location')
	ELSE
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Missing', 'tbl_dba_maint_file_location', @lModule, 'table dbo.tbl_dba_maint_file_location')
		
	SET @lParentID = SCOPE_IDENTITY();
	
		IF EXISTS(Select * from sys.columns where object_id = OBJECT_ID(N'[dbo].[tbl_dba_maint_file_location]') and name = 'db_tran_bkup_location')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'db_tran_bkup_location', 'tbl_dba_maint_file_location', 'column dbo.tbl_dba_maint_file_location.db_tran_bkup_location')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'db_tran_bkup_location', 'tbl_dba_maint_file_location', 'column dbo.tbl_dba_maint_file_location.db_tran_bkup_location')
		
	--Checking procedure dbo.usp_dba_CallLogShippingBackupJob
	IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_dba_CallLogShippingBackupJob]') AND type in (N'P', N'PC'))
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Already exists', 'usp_dba_CallLogShippingBackupJob', @lModule, 'procedure dbo.usp_dba_CallLogShippingBackupJob')
	ELSE
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Ok', 'usp_dba_CallLogShippingBackupJob', @lModule, 'procedure dbo.usp_dba_CallLogShippingBackupJob')

	--Checking function dbo.ufn_dba_IsLogShippingDatabase
	IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ufn_dba_IsLogShippingDatabase]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Already exists', 'ufn_dba_IsLogShippingDatabase', @lModule, 'function dbo.ufn_dba_IsLogShippingDatabase')
	ELSE
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Ok', 'ufn_dba_IsLogShippingDatabase', @lModule, 'function dbo.ufn_dba_IsLogShippingDatabase')

	--Checking procedure dbo.usp_tbl_dba_maintenance_u
	IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_tbl_dba_maintenance_u]') AND type in (N'P', N'PC'))
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Ok', 'usp_tbl_dba_maintenance_u', @lModule, 'procedure dbo.usp_tbl_dba_maintenance_u')
	ELSE
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Missing', 'usp_tbl_dba_maintenance_u', @lModule, 'procedure dbo.usp_tbl_dba_maintenance_u')
	
	IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbl_dba_maintenance_config]') AND type in (N'U'))
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Ok', 'tbl_dba_maintenance_config', @lModule, 'table dbo.tbl_dba_maintenance_config')
	ELSE
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Missing', 'tbl_dba_maintenance_config', @lModule, 'table dbo.tbl_dba_maintenance_config')
		
	SET @lParentID = SCOPE_IDENTITY();
	
		IF EXISTS(Select * from sys.columns where object_id = OBJECT_ID(N'[dbo].[tbl_dba_maintenance_config]') and name = 'xdatabase')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'xdatabase', 'tbl_dba_maintenance_config', 'column dbo.tbl_dba_maintenance_config.xdatabase')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'xdatabase', 'tbl_dba_maintenance_config', 'column dbo.tbl_dba_maintenance_config.xdatabase')

		IF EXISTS(Select * from sys.columns where object_id = OBJECT_ID(N'[dbo].[tbl_dba_maintenance_config]') and name = 'xfull')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'xfull', 'tbl_dba_maintenance_config', 'column dbo.tbl_dba_maintenance_config.xfull')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'xfull', 'tbl_dba_maintenance_config', 'column dbo.tbl_dba_maintenance_config.xfull')

		IF EXISTS(Select * from sys.columns where object_id = OBJECT_ID(N'[dbo].[tbl_dba_maintenance_config]') and name = 'xdiff')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'xdiff', 'tbl_dba_maintenance_config', 'column dbo.tbl_dba_maintenance_config.xdiff')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'xdiff', 'tbl_dba_maintenance_config', 'column dbo.tbl_dba_maintenance_config.xdiff')

		IF EXISTS(Select * from sys.columns where object_id = OBJECT_ID(N'[dbo].[tbl_dba_maintenance_config]') and name = 'xskip')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'xskip', 'tbl_dba_maintenance_config', 'column dbo.tbl_dba_maintenance_config.xskip')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'xskip', 'tbl_dba_maintenance_config', 'column dbo.tbl_dba_maintenance_config.xskip')

		IF EXISTS(Select * from sys.columns where object_id = OBJECT_ID(N'[dbo].[tbl_dba_maintenance_config]') and name = 'xlog')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'xlog', 'tbl_dba_maintenance_config', 'column dbo.tbl_dba_maintenance_config.xlog')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'xlog', 'tbl_dba_maintenance_config', 'column dbo.tbl_dba_maintenance_config.xlog')

		IF EXISTS(Select * from sys.columns where object_id = OBJECT_ID(N'[dbo].[tbl_dba_maintenance_config]') and name = 'create_dt')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'create_dt', 'tbl_dba_maintenance_config', 'column dbo.tbl_dba_maintenance_config.create_dt')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'create_dt', 'tbl_dba_maintenance_config', 'column dbo.tbl_dba_maintenance_config.create_dt')

		IF EXISTS(Select * from sys.columns where object_id = OBJECT_ID(N'[dbo].[tbl_dba_maintenance_config]') and name = 'drop_dt')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'drop_dt', 'tbl_dba_maintenance_config', 'column dbo.tbl_dba_maintenance_config.drop_dt')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'drop_dt', 'tbl_dba_maintenance_config', 'column dbo.tbl_dba_maintenance_config.drop_dt')

		IF EXISTS(Select * from sys.columns where object_id = OBJECT_ID(N'[dbo].[tbl_dba_maintenance_config]') and name = 'xskipManual')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'xskipManual', 'tbl_dba_maintenance_config', 'column dbo.tbl_dba_maintenance_config.xskipManual')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'xskipManual', 'tbl_dba_maintenance_config', 'column dbo.tbl_dba_maintenance_config.xskipManual')

		IF EXISTS(Select * from sys.columns where object_id = OBJECT_ID(N'[dbo].[tbl_dba_maintenance_config]') and name = 'xreindex')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'xreindex', 'tbl_dba_maintenance_config', 'column dbo.tbl_dba_maintenance_config.xreindex')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'xreindex', 'tbl_dba_maintenance_config', 'column dbo.tbl_dba_maintenance_config.xreindex')

		IF EXISTS(Select * from sys.columns where object_id = OBJECT_ID(N'[dbo].[tbl_dba_maintenance_config]') and name = 'xReindexLimit')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'xReindexLimit', 'tbl_dba_maintenance_config', 'column dbo.tbl_dba_maintenance_config.xReindexLimit')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'xReindexLimit', 'tbl_dba_maintenance_config', 'column dbo.tbl_dba_maintenance_config.xReindexLimit')

		IF EXISTS(Select * from sys.columns where object_id = OBJECT_ID(N'[dbo].[tbl_dba_maintenance_config]') and name = 'xskipManual')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'xskipManual', 'tbl_dba_maintenance_config', 'column dbo.tbl_dba_maintenance_config.xskipManual')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'xskipManual', 'tbl_dba_maintenance_config', 'column dbo.tbl_dba_maintenance_config.xskipManual')

		IF EXISTS(Select * from sys.columns where object_id = OBJECT_ID(N'[dbo].[tbl_dba_maintenance_config]') and name = 'xskipManual')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'xskipManual', 'tbl_dba_maintenance_config', 'column dbo.tbl_dba_maintenance_config.xskipManual')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'xskipManual', 'tbl_dba_maintenance_config', 'column dbo.tbl_dba_maintenance_config.xskipManual')

		IF EXISTS(Select * from sys.columns where object_id = OBJECT_ID(N'[dbo].[tbl_dba_maintenance_config]') and name = 'xFileGroup')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'xFileGroup', 'tbl_dba_maintenance_config', 'column dbo.tbl_dba_maintenance_config.xFileGroup')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'xFileGroup', 'tbl_dba_maintenance_config', 'column dbo.tbl_dba_maintenance_config.xFileGroup')

		IF EXISTS(Select * from sys.columns where object_id = OBJECT_ID(N'[dbo].[tbl_dba_maintenance_config]') and name = 'xMultiBkupPlan')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'xMultiBkupPlan', 'tbl_dba_maintenance_config', 'column dbo.tbl_dba_maintenance_config.xMultiBkupPlan')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'xMultiBkupPlan', 'tbl_dba_maintenance_config', 'column dbo.tbl_dba_maintenance_config.xMultiBkupPlan')

		IF EXISTS(Select * from sys.columns where object_id = OBJECT_ID(N'[dbo].[tbl_dba_maintenance_config]') and name = 'xLogSpaceLimit')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'xLogSpaceLimit', 'tbl_dba_maintenance_config', 'column dbo.tbl_dba_maintenance_config.xLogSpaceLimit')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'xLogSpaceLimit', 'tbl_dba_maintenance_config', 'column dbo.tbl_dba_maintenance_config.xLogSpaceLimit')

	IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbl_dba_BackupPlan_History]') AND type in (N'U'))
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Ok', 'tbl_dba_BackupPlan_History', @lModule, 'table dbo.tbl_dba_BackupPlan_History')
	ELSE
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Missing', 'tbl_dba_BackupPlan_History', @lModule, 'table dbo.tbl_dba_BackupPlan_History')

	SET @lParentID = SCOPE_IDENTITY();
	
		IF EXISTS(Select * from sys.columns where object_id = OBJECT_ID(N'[dbo].[tbl_dba_BackupPlan_History]') and name = 'xdatabase')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'xdatabase', 'tbl_dba_BackupPlan_History', 'column dbo.tbl_dba_BackupPlan_History.xdatabase')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'xdatabase', 'tbl_dba_BackupPlan_History', 'column dbo.tbl_dba_BackupPlan_History.xdatabase')

		IF EXISTS(Select * from sys.columns where object_id = OBJECT_ID(N'[dbo].[tbl_dba_BackupPlan_History]') and name = 'xfilegroup')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'xfilegroup', 'tbl_dba_BackupPlan_History', 'column dbo.tbl_dba_BackupPlan_History.xfilegroup')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'xfilegroup', 'tbl_dba_BackupPlan_History', 'column dbo.tbl_dba_BackupPlan_History.xfilegroup')

		IF EXISTS(Select * from sys.columns where object_id = OBJECT_ID(N'[dbo].[tbl_dba_BackupPlan_History]') and name = 'xdaily')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'xdaily', 'tbl_dba_BackupPlan_History', 'column dbo.tbl_dba_BackupPlan_History.xdaily')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'xdaily', 'tbl_dba_BackupPlan_History', 'column dbo.tbl_dba_BackupPlan_History.xdaily')

		IF EXISTS(Select * from sys.columns where object_id = OBJECT_ID(N'[dbo].[tbl_dba_BackupPlan_History]') and name = 'xweekly')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'xweekly', 'tbl_dba_BackupPlan_History', 'column dbo.tbl_dba_BackupPlan_History.xweekly')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'xweekly', 'tbl_dba_BackupPlan_History', 'column dbo.tbl_dba_BackupPlan_History.xweekly')

		IF EXISTS(Select * from sys.columns where object_id = OBJECT_ID(N'[dbo].[tbl_dba_BackupPlan_History]') and name = 'xwdayname')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'xwdayname', 'tbl_dba_BackupPlan_History', 'column dbo.tbl_dba_BackupPlan_History.xwdayname')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'xwdayname', 'tbl_dba_BackupPlan_History', 'column dbo.tbl_dba_BackupPlan_History.xwdayname')

		IF EXISTS(Select * from sys.columns where object_id = OBJECT_ID(N'[dbo].[tbl_dba_BackupPlan_History]') and name = 'xmonthly')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'xmonthly', 'tbl_dba_BackupPlan_History', 'column dbo.tbl_dba_BackupPlan_History.xmonthly')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'xmonthly', 'tbl_dba_BackupPlan_History', 'column dbo.tbl_dba_BackupPlan_History.xmonthly')

		IF EXISTS(Select * from sys.columns where object_id = OBJECT_ID(N'[dbo].[tbl_dba_BackupPlan_History]') and name = 'xwofmonth')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'xwofmonth', 'tbl_dba_BackupPlan_History', 'column dbo.tbl_dba_BackupPlan_History.xwofmonth')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'xwofmonth', 'tbl_dba_BackupPlan_History', 'column dbo.tbl_dba_BackupPlan_History.xwofmonth')

		IF EXISTS(Select * from sys.columns where object_id = OBJECT_ID(N'[dbo].[tbl_dba_BackupPlan_History]') and name = 'xmdayname')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'xmdayname', 'tbl_dba_BackupPlan_History', 'column dbo.tbl_dba_BackupPlan_History.xmdayname')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'xmdayname', 'tbl_dba_BackupPlan_History', 'column dbo.tbl_dba_BackupPlan_History.xmdayname')

		IF EXISTS(Select * from sys.columns where object_id = OBJECT_ID(N'[dbo].[tbl_dba_BackupPlan_History]') and name = 'xsequence')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'xsequence', 'tbl_dba_BackupPlan_History', 'column dbo.tbl_dba_BackupPlan_History.xsequence')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'xsequence', 'tbl_dba_BackupPlan_History', 'column dbo.tbl_dba_BackupPlan_History.xsequence')

		IF EXISTS(Select * from sys.columns where object_id = OBJECT_ID(N'[dbo].[tbl_dba_BackupPlan_History]') and name = 'xbkuptype')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'xbkuptype', 'tbl_dba_BackupPlan_History', 'column dbo.tbl_dba_BackupPlan_History.xbkuptype')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'xbkuptype', 'tbl_dba_BackupPlan_History', 'column dbo.tbl_dba_BackupPlan_History.xbkuptype')

		IF EXISTS(Select * from sys.columns where object_id = OBJECT_ID(N'[dbo].[tbl_dba_BackupPlan_History]') and name = 'xalterdate')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'xalterdate', 'tbl_dba_BackupPlan_History', 'column dbo.tbl_dba_BackupPlan_History.xalterdate')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'xalterdate', 'tbl_dba_BackupPlan_History', 'column dbo.tbl_dba_BackupPlan_History.xalterdate')

	IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbl_dba_BackupPlan]') AND type in (N'U'))
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Ok', 'tbl_dba_BackupPlan', @lModule, 'table dbo.tbl_dba_BackupPlan')
	ELSE
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Missing', 'tbl_dba_BackupPlan', @lModule, 'table dbo.tbl_dba_BackupPlan')

	SET @lParentID = SCOPE_IDENTITY();
	
		IF EXISTS(Select * from sys.columns where object_id = OBJECT_ID(N'[dbo].[tbl_dba_BackupPlan]') and name = 'xdatabase')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'xdatabase', 'tbl_dba_BackupPlan', 'column dbo.tbl_dba_BackupPlan.xdatabase')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'xdatabase', 'tbl_dba_BackupPlan', 'column dbo.tbl_dba_BackupPlan.xdatabase')

		IF EXISTS(Select * from sys.columns where object_id = OBJECT_ID(N'[dbo].[tbl_dba_BackupPlan]') and name = 'xfilegroup')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'xfilegroup', 'tbl_dba_BackupPlan', 'column dbo.tbl_dba_BackupPlan.xfilegroup')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'xfilegroup', 'tbl_dba_BackupPlan', 'column dbo.tbl_dba_BackupPlan.xfilegroup')

		IF EXISTS(Select * from sys.columns where object_id = OBJECT_ID(N'[dbo].[tbl_dba_BackupPlan]') and name = 'xdaily')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'xdaily', 'tbl_dba_BackupPlan', 'column dbo.tbl_dba_BackupPlan.xdaily')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'xdaily', 'tbl_dba_BackupPlan', 'column dbo.tbl_dba_BackupPlan.xdaily')

		IF EXISTS(Select * from sys.columns where object_id = OBJECT_ID(N'[dbo].[tbl_dba_BackupPlan]') and name = 'xweekly')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'xweekly', 'tbl_dba_BackupPlan', 'column dbo.tbl_dba_BackupPlan.xweekly')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'xweekly', 'tbl_dba_BackupPlan', 'column dbo.tbl_dba_BackupPlan.xweekly')

		IF EXISTS(Select * from sys.columns where object_id = OBJECT_ID(N'[dbo].[tbl_dba_BackupPlan]') and name = 'xwdayname')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'xwdayname', 'tbl_dba_BackupPlan', 'column dbo.tbl_dba_BackupPlan.xwdayname')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'xwdayname', 'tbl_dba_BackupPlan', 'column dbo.tbl_dba_BackupPlan.xwdayname')

		IF EXISTS(Select * from sys.columns where object_id = OBJECT_ID(N'[dbo].[tbl_dba_BackupPlan]') and name = 'xmonthly')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'xmonthly', 'tbl_dba_BackupPlan', 'column dbo.tbl_dba_BackupPlan.xmonthly')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'xmonthly', 'tbl_dba_BackupPlan', 'column dbo.tbl_dba_BackupPlan.xmonthly')

		IF EXISTS(Select * from sys.columns where object_id = OBJECT_ID(N'[dbo].[tbl_dba_BackupPlan]') and name = 'xwofmonth')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'xwofmonth', 'tbl_dba_BackupPlan', 'column dbo.tbl_dba_BackupPlan.xwofmonth')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'xwofmonth', 'tbl_dba_BackupPlan', 'column dbo.tbl_dba_BackupPlan.xwofmonth')

		IF EXISTS(Select * from sys.columns where object_id = OBJECT_ID(N'[dbo].[tbl_dba_BackupPlan]') and name = 'xmdayname')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'xmdayname', 'tbl_dba_BackupPlan', 'column dbo.tbl_dba_BackupPlan.xmdayname')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'xmdayname', 'tbl_dba_BackupPlan', 'column dbo.tbl_dba_BackupPlan.xmdayname')

		IF EXISTS(Select * from sys.columns where object_id = OBJECT_ID(N'[dbo].[tbl_dba_BackupPlan]') and name = 'xsequence')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'xsequence', 'tbl_dba_BackupPlan', 'column dbo.tbl_dba_BackupPlan.xsequence')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'xsequence', 'tbl_dba_BackupPlan', 'column dbo.tbl_dba_BackupPlan.xsequence')

		IF EXISTS(Select * from sys.columns where object_id = OBJECT_ID(N'[dbo].[tbl_dba_BackupPlan]') and name = 'xbkuptype')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'xbkuptype', 'tbl_dba_BackupPlan', 'column dbo.tbl_dba_BackupPlan.xbkuptype')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'xbkuptype', 'tbl_dba_BackupPlan', 'column dbo.tbl_dba_BackupPlan.xbkuptype')

	IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbl_dba_full_backup_completed]') AND type in (N'U'))
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Ok', 'tbl_dba_full_backup_completed', @lModule, 'table dbo.tbl_dba_full_backup_completed')
	ELSE
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Missing', 'tbl_dba_full_backup_completed', @lModule, 'table dbo.tbl_dba_full_backup_completed')
		
	SET @lParentID = SCOPE_IDENTITY();
	
		IF EXISTS(Select * from sys.columns where object_id = OBJECT_ID(N'[dbo].[tbl_dba_full_backup_completed]') and name = 'xdatabase')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'xdatabase', 'tbl_dba_full_backup_completed', 'column dbo.tbl_dba_full_backup_completed.xdatabase')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'xdatabase', 'tbl_dba_full_backup_completed', 'column dbo.tbl_dba_full_backup_completed.xdatabase')

		IF EXISTS(Select * from sys.columns where object_id = OBJECT_ID(N'[dbo].[tbl_dba_full_backup_completed]') and name = 'starttime')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', 'starttime', 'tbl_dba_full_backup_completed', 'column dbo.tbl_dba_full_backup_completed.starttime')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', 'starttime', 'tbl_dba_full_backup_completed', 'column dbo.tbl_dba_full_backup_completed.starttime')

	IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_dba_GSMID_Setting]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Ok', 'usp_dba_GSMID_Setting', @lModule, 'procedure dbo.usp_dba_GSMID_Setting')
	ELSE
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Missing', 'usp_dba_GSMID_Setting', @lModule, 'procedure dbo.usp_dba_GSMID_Setting')

	IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_dba_CheckLogSpace]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Ok', 'usp_dba_CheckLogSpace', @lModule, 'procedure dbo.usp_dba_CheckLogSpace')
	ELSE
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Missing', 'usp_dba_CheckLogSpace', @lModule, 'procedure dbo.usp_dba_CheckLogSpace')

	--Checking procedure dbo.usp_dba_CallLogShippingBackupJob
	IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_tbl_dba_log_backup]') AND type in (N'P', N'PC'))
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Ok', 'usp_tbl_dba_log_backup', @lModule, 'procedure dbo.usp_tbl_dba_log_backup')
	ELSE
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Missing', 'usp_tbl_dba_log_backup', @lModule, 'procedure dbo.usp_tbl_dba_log_backup')

	SET @lParentID = SCOPE_IDENTITY();
	
		IF EXISTS(Select * from sys.parameters where object_id = OBJECT_ID(N'[dbo].[usp_tbl_dba_log_backup]') and name = '@database')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', '@database', 'usp_tbl_dba_log_backup', 'parameter dbo.usp_tbl_dba_log_backup.@database')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', '@database', 'usp_tbl_dba_log_backup', 'parameter dbo.usp_tbl_dba_log_backup.@database')

		IF EXISTS(Select * from sys.parameters where object_id = OBJECT_ID(N'[dbo].[usp_tbl_dba_log_backup]') and name = '@execute')
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Ok', '@execute', 'usp_tbl_dba_log_backup', 'parameter dbo.usp_tbl_dba_log_backup.@execute')
		ELSE
			insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lParentID, 'Missing', '@execute', 'usp_tbl_dba_log_backup', 'parameter dbo.usp_tbl_dba_log_backup.@execute')

	--Checking function dbo.ufn_dba_getMajorVersion
	IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ufn_dba_getMajorVersion]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Already exists', 'ufn_dba_getMajorVersion', @lModule, 'function dbo.ufn_dba_getMajorVersion')
	ELSE
		insert into #tbl_result (RootID, ParentID, Status, Module, ParentModule, Message) values (@lRootID, @lRootID, 'Ok', 'ufn_dba_getMajorVersion', @lModule, 'function dbo.ufn_dba_getMajorVersion')
END	

IF exists (Select top 1 * from #tbl_result where [Status] <> 'Ok' and [RootID] = @lRootID)
	update #tbl_result set [Status] = 'Incompatible' where Module = @lModule and ParentModule is Null
ELSE
	update #tbl_result set [Status] = 'Ok' where Module = @lModule and ParentModule is Null

--select Status, Module from #tbl_result where RootID is null;
--select * from #tbl_result where (Status <> 'Ok') or (ID in (select ParentID from #tbl_result where Status <> 'Ok')) 
--or (ID in (select RootID from #tbl_result where Status <> 'Ok'));

declare @LogshippingFixInstalled char(1);
set @LogshippingFixInstalled = 'N';
select @LogshippingFixInstalled = CASE upper(Status) WHEN 'Not installed or missing objects' THEN 'N' ELSE 'Y' END from #tbl_result where RootID is null and Module = 'Logshipping-Fix installed';
select @LogshippingFixInstalled

declare @intSQLVersion int;
SET @intSQLVersion = DBA.dbo.ufn_dba_getMajorVersion()

DECLARE @strSQLVersion varchar(30);
SET @strSQLVersion = 'Initial Version - ' + CAST(@intSQLVersion as varchar);

exec DBA.dbo.usp_dba_SetDBAVersion @pMajorVersion = 1, @pMinorVersion = 0, @pNotes = @strSQLVersion;
exec DBA.dbo.usp_dba_IncDBAVersion @pNotes = 'Version control', @pIncreaseMajorVersion = 'N';

if @LogshippingFixInstalled <> 'N' 
	exec DBA.dbo.usp_dba_IncDBAVersion @pNotes = 'Log shipping Fix', @pIncreaseMajorVersion = 'N';

Select * from DBA..tbl_dba_Version
GO
exec DBA.dbo.usp_dba_IncDBAVersion @pNotes = 'Compressed backups support', @pIncreaseMajorVersion = 'N';
go
Select * from DBA.dbo.tbl_dba_Version;
GO
Print 'Done installing compressed backups support'
GO
USE DBA
GO
DECLARE @Module varchar(1100);
SET @Module = N'TEMPDB MONITOR';

if exists(Select * from DBA..tbl_dba_Alert_Config where AlertType = @Module)
begin
	raiserror (N'An Audit email configuration already exists', 16, 1)
end
else
begin
	DECLARE @strSQL2 varchar(1100);
	DECLARE @DefaultEmailTo varchar(2000);
	select top 1 @DefaultEmailTo = EmailTo from DBA..tbl_dba_Alert_Config
	set @strSQL2 = N'set nocount on insert into DBA..tbl_dba_Alert_Config(EmailTo,AlertType) values(''' + @DefaultEmailTo + ''','+ '''' + @Module + '''' +')'
	exec (@strSQL2)
end

if OBJECT_ID(N'tbl_dba_Version', N'U') is not null
	exec DBA..usp_dba_SetDBAVersion @pMajorVersion = 1, @pMinorVersion = 4, @pNotes = @Module;
GO
select * from DBA..tbl_dba_Version
GO
if OBJECT_ID(N'tbl_dba_Version', N'U') is not null
	exec DBA..usp_dba_SetDBAVersion @pMajorVersion = 1, @pMinorVersion = 5, @pNotes = N'CheckLogSpace Fix';
GO
select * from DBA..tbl_dba_Version
GO
if OBJECT_ID(N'tbl_dba_Version', N'U') is not null
	exec DBA..usp_dba_SetDBAVersion @pMajorVersion = 1, @pMinorVersion = 6, @pNotes = 'DDL Triggers';
GO
select * from DBA..tbl_dba_Version
GO
USE DBA
Go
if OBJECT_ID(N'tbl_dba_Version', N'U') is not null
exec DBA..usp_dba_SetDBAVersion @pMajorVersion = 1, @pMinorVersion = 7, @pNotes = 'Recycle SQL Error log job';
Go
select * from DBA..tbl_dba_Version
GO
USE DBA
GO

DECLARE @Module varchar(1100);
SET @Module = N'LONG RUNNING JOBS';

if exists(Select * from DBA..tbl_dba_Alert_Config where AlertType = @Module)
begin
	raiserror (N'A "Long running jobs" email configuration already exists', 16, 1)
end
else
begin
	DECLARE @strSQL2 varchar(1100);
	DECLARE @DefaultEmailTo varchar(2000);
	select top 1 @DefaultEmailTo = EmailTo from DBA..tbl_dba_Alert_Config
	set @strSQL2 = N'set nocount on insert into DBA..tbl_dba_Alert_Config(EmailTo,AlertType) values(''' + @DefaultEmailTo + ''',' + '''' + @Module + '''' + ')'
	exec (@strSQL2)
end

if OBJECT_ID(N'tbl_dba_Version', N'U') is not null
	exec DBA..usp_dba_SetDBAVersion @pMajorVersion = 1, @pMinorVersion = 8, @pNotes = @Module;
GO
select * from DBA..tbl_dba_Version
GO
if OBJECT_ID(N'tbl_dba_Version', N'U') is not null
	exec DBA..usp_dba_SetDBAVersion @pMajorVersion = 1, @pMinorVersion = 9, @pNotes = 'DeleteDiffBackups Fix';
GO
select * from DBA..tbl_dba_Version
GO
IF OBJECT_ID(N'tbl_dba_Version', N'U') is not null
	exec DBA..usp_dba_SetDBAVersion @pMajorVersion = 1, @pMinorVersion = 10, @pNotes = 'xAlterIndex';
GO
select * from DBA..tbl_dba_Version
GO
IF OBJECT_ID(N'tbl_dba_Version', N'U') is not null
	exec DBA..usp_dba_SetDBAVersion @pMajorVersion = 1, @pMinorVersion = 11, @pNotes = 'AlterIndex process';
GO
select * from DBA..tbl_dba_Version
GO
USE DBA
GO
declare @Module varchar(50);
set @Module = N'MSDBCLEANUP';
if exists(Select * from DBA..tbl_dba_Alert_Config where AlertType = @Module)
begin
	raiserror (N'An Audit email configuration already exists', 16, 1)
end
else
begin
	DECLARE @strSQL2 varchar(1100);
	DECLARE @DefaultEmailTo varchar(2000);
	select top 1 @DefaultEmailTo = EmailTo from DBA..tbl_dba_Alert_Config
	set @strSQL2 = N'set nocount on insert into DBA..tbl_dba_Alert_Config(EmailTo,AlertType) values(''' + @DefaultEmailTo + ''',' + '''' + @Module + '''' + ')'
	exec (@strSQL2)
end

IF OBJECT_ID(N'tbl_dba_Version', N'U') is not null
	exec DBA..usp_dba_SetDBAVersion @pMajorVersion = 1, @pMinorVersion = 12, @pNotes = @Module;
GO
select * from DBA..tbl_dba_Version
GO
USE DBA
GO
declare @Module varchar(50);
set @Module = N'QUERY PERFORMANCE';
if exists(Select * from DBA..tbl_dba_Alert_Config where AlertType = @Module)
begin
	raiserror (N'An Audit email configuration already exists', 16, 1)
end
else
begin
	DECLARE @strSQL2 varchar(1100);
	DECLARE @DefaultEmailTo varchar(2000);
	select top 1 @DefaultEmailTo = EmailTo from DBA..tbl_dba_Alert_Config
	set @strSQL2 = N'set nocount on insert into DBA..tbl_dba_Alert_Config(EmailTo,AlertType) values(''' + @DefaultEmailTo + ''',' + '''' + @Module + '''' +')'
	exec (@strSQL2)
end

if OBJECT_ID(N'tbl_dba_Version', N'U') is not null
	exec DBA..usp_dba_SetDBAVersion @pMajorVersion = 1, @pMinorVersion = 13, @pNotes = @Module;
GO
select * from DBA..tbl_dba_Version
GO
USE DBA
GO
declare @Module varchar(50);
set @Module = N'DBSizeAndSpace';
if exists(Select * from DBA..tbl_dba_Alert_Config where AlertType = @Module)
begin
	raiserror (N'An Audit email configuration already exists', 16, 1)
end
else
begin
	DECLARE @strSQL2 varchar(1100);
	DECLARE @DefaultEmailTo varchar(2000);
	select top 1 @DefaultEmailTo = EmailTo from DBA..tbl_dba_Alert_Config
	set @strSQL2 = N'set nocount on insert into DBA..tbl_dba_Alert_Config(EmailTo,AlertType) values(''' + @DefaultEmailTo + ''',' + '''' + @Module + '''' +')'
	exec (@strSQL2)
end

if OBJECT_ID(N'tbl_dba_Version', N'U') is not null
	exec DBA..usp_dba_SetDBAVersion @pMajorVersion = 1, @pMinorVersion = 14, @pNotes = @Module;
GO
select * from DBA..tbl_dba_Version
GO
if OBJECT_ID(N'tbl_dba_Version', N'U') is not null
	exec DBA..usp_dba_SetDBAVersion @pMajorVersion = 1, @pMinorVersion = 15, @pNotes = N'SendMailFix';
GO
select * from DBA..tbl_dba_Version
GO
if OBJECT_ID(N'tbl_dba_Version', N'U') is not null
	exec DBA..usp_dba_SetDBAVersion @pMajorVersion = 1, @pMinorVersion = 16, @pNotes = N'AutoFullBackups';
GO
select * from DBA..tbl_dba_Version
GO
--Note: The value of the variable: @DefaultEmailTo must be carfully assigned.
--The default value is: DL-WK-InfrastructureDBA@ps.net, but it is prefered to first review the content of the table 
--DBA..tbl_dba_Alert_Config to know the correct email address

USE DBA
GO

DECLARE @Module varchar(1100);
SET @Module = N'AUTORUNBOOK';

if exists(Select * from DBA..tbl_dba_Alert_Config where AlertType = @Module)
begin
	raiserror (N'A "AUTORUNBOOK" email configuration already exists', 16, 1)
end
else
begin
	DECLARE @strSQL2 varchar(1100);
	DECLARE @DefaultEmailTo varchar(2000);
	select top 1 @DefaultEmailTo = EmailTo from DBA..tbl_dba_Alert_Config
	set @strSQL2 = N'set nocount on insert into DBA..tbl_dba_Alert_Config(EmailTo,AlertType) values(''' + @DefaultEmailTo + ''',' + '''' + @Module + '''' + ')'
	exec (@strSQL2)
end

if OBJECT_ID(N'tbl_dba_Version', N'U') is not null
	exec DBA..usp_dba_SetDBAVersion @pMajorVersion = 1, @pMinorVersion = 17, @pNotes = @Module;
GO
select * from DBA..tbl_dba_Version