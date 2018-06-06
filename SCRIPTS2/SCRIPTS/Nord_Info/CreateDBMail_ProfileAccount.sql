sp_CONFIGURE 'show advanced', 1
GO
RECONFIGURE
GO
sp_CONFIGURE 'Database Mail XPs', 1
GO
RECONFIGURE
GO 





-- Create a Database Mail profile 
declare @ServerInstance sysname
declare @profile sysname
declare @email sysname

set @ServerInstance = @@SERVERNAME

If @ServerInstance like '%\%'
begin
set @profile = 'DB_' + REPLACE(@ServerInstance,'\','_SQL_')
end
else
set @profile = 'DB_' + @ServerInstance + '_SQL'
set @email = @profile + '@nordstrom.com'

select @ServerInstance as ServerName_Instance
select @profile as Profile_AccountName
select @email as EmailAddress

--Create the Profile
If not exists(SELECT * FROM msdb.dbo.sysmail_profile where name = @profile)
Begin
	EXECUTE msdb.dbo.sysmail_add_profile_sp 
	@profile_name = @profile, 
	@description = 'Notification service for SQL Server' ; 
End

-- Create a Database Mail account 
If not exists(SELECT * FROM msdb.dbo.sysmail_account where name = @profile)
Begin
	EXECUTE msdb.dbo.sysmail_add_account_sp 
	@account_name = @profile, 
	@description = 'SQL Server Notification Service', 
	@email_address = @email, 
	@replyto_address = 'do_not_reply@nordstrom.com', 
	@display_name = '', 
	@mailserver_name = 'exchange.nordstrom.net' ; 
End

-- Add the account to the profile 
If Not exists(SELECT 1 FROM [msdb].[dbo].[sysmail_profileaccount] pa
JOIN [msdb].[dbo].[sysmail_profile] p on pa.profile_id = p.profile_id
JOIN [msdb].[dbo].[sysmail_account] a on pa.account_id = a.account_id
WHERE p.name = @profile and a.name = @profile)
Begin
	EXECUTE msdb.dbo.sysmail_add_profileaccount_sp 
	@profile_name = @profile, 
	@account_name = @profile, 
	@sequence_number =1 ; 
End

-- Grant access to the profile to the DBMailUsers role   
If Not exists(SELECT 1 FROM [msdb].[dbo].[sysmail_principalprofile] pp
JOIN [msdb].[dbo].[sysmail_profile] p on pp.profile_id = p.profile_id
WHERE p.name = @profile and pp.is_default = 1)
Begin
	EXECUTE msdb.dbo.sysmail_add_principalprofile_sp 
	@profile_name = @profile, 
	@principal_name = 'public',
	@is_default = 1 ; 
End

EXECUTE msdb.dbo.sysmail_configure_sp
    'MaxFileSize', '9000000' ;


SELECT * FROM msdb.dbo.sysmail_profile 
SELECT * FROM msdb.dbo.sysmail_account